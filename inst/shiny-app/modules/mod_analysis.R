# Analysis Module for MN Test Analysis Dashboard

#' Analysis Module UI
#'
#' @param id Module namespace ID
#' @return Shiny UI elements
mod_analysis_ui <- function(id) {
  ns <- NS(id)

  tagList(
    fluidRow(
      box(
        title = "Analysis Parameters",
        status = "primary",
        solidHeader = TRUE,
        width = 6,
        numericInput(
          ns("control_group"),
          "Control Group Number:",
          value = 1,
          min = 1,
          step = 1
        ),
        helpText("The group number to use as control (typically Group 1)"),
        numericInput(
          ns("sig_level"),
          "Significance Level (alpha):",
          value = 0.05,
          min = 0.001,
          max = 0.999,
          step = 0.01
        ),
        helpText("Significance threshold for statistical tests (typically 0.05)"),
        hr(),
        actionButton(
          ns("run_analysis"),
          "Run Analysis",
          icon = icon("play"),
          class = "btn-success btn-lg",
          width = "100%"
        )
      ),
      box(
        title = "Analysis Status",
        status = "info",
        solidHeader = TRUE,
        width = 6,
        h4("Status:"),
        verbatimTextOutput(ns("status_message")),
        hr(),
        h4("Available Groups:"),
        verbatimTextOutput(ns("group_info"))
      )
    ),
    fluidRow(
      box(
        title = "Analysis Method",
        status = "warning",
        solidHeader = TRUE,
        width = 12,
        collapsible = TRUE,
        collapsed = TRUE,
        h4("Statistical Method"),
        p(strong("Test:"), "Mann-Whitney U test (Wilcoxon rank-sum test)"),
        p(strong("Implementation:"), "coin::wilcox_test with exact distribution"),
        p(strong("Multiple Testing Correction:"), "Holm-Bonferroni method"),
        p(strong("Comparison:"), "Each treatment group is compared against the control group"),
        hr(),
        h4("Output Includes:"),
        tags$ul(
          tags$li("Sample size (n) per group"),
          tags$li("Median and mean values"),
          tags$li("Standard deviation (SD)"),
          tags$li("Raw p-values"),
          tags$li("Adjusted p-values (Holm-Bonferroni correction)"),
          tags$li("Significance markers (* for significant results)")
        )
      )
    )
  )
}

#' Analysis Module Server
#'
#' @param id Module namespace ID
#' @param data Reactive value with loaded data
#' @param config Reactive values with configuration
#' @return Reactive value with analysis results
mod_analysis_server <- function(id, data, config) {
  moduleServer(id, function(input, output, session) {

    # Reactive value for analysis results
    analysis_results <- reactiveVal(NULL)

    # Reactive value for analysis status
    analysis_status <- reactiveVal("Ready to run analysis")

    # Initialize parameters from config
    observe({
      updateNumericInput(session, "control_group", value = config$default_control_group)
      updateNumericInput(session, "sig_level", value = config$default_sig_level)
    })

    # Display available groups
    output$group_info <- renderText({
      req(data())

      if (!"GroupNumber" %in% names(data())) {
        return("No group information available")
      }

      groups <- sort(unique(data()$GroupNumber))
      group_names <- if ("Group" %in% names(data())) {
        sapply(groups, function(g) {
          name <- unique(data()[data()$GroupNumber == g, "Group"])
          if (length(name) > 0) name[1] else "Unknown"
        })
      } else {
        rep("Unknown", length(groups))
      }

      info_text <- paste0(
        "Available groups in dataset:\n",
        paste(paste0("Group ", groups, ": ", group_names), collapse = "\n")
      )

      return(info_text)
    })

    # Display status message
    output$status_message <- renderText({
      analysis_status()
    })

    # Run analysis when button is clicked
    observeEvent(input$run_analysis, {
      req(data())

      # Validate parameters
      param_validation <- validate_analysis_params(
        input$control_group,
        input$sig_level,
        data()
      )

      if (!param_validation$valid) {
        showNotification(
          param_validation$message,
          type = "error",
          duration = 5
        )
        analysis_status(paste("Error:", param_validation$message))
        return()
      }

      # Run analysis with progress indicator
      withProgress(message = "Running analysis...", value = 0, {

        tryCatch({
          incProgress(0.2, detail = "Preparing data")
          analysis_status("Preparing data...")

          incProgress(0.3, detail = "Running Mann-Whitney U tests")
          analysis_status("Running statistical tests...")

          # Call analysis function
          results <- run_mn_analysis_shiny(
            data = data(),
            control_group = input$control_group,
            sig_level = input$sig_level
          )

          incProgress(0.4, detail = "Applying corrections")
          analysis_status("Applying multiple testing corrections...")

          incProgress(0.1, detail = "Complete")
          analysis_status("Analysis completed successfully")

          # Store results
          analysis_results(results)

          showNotification(
            paste("Analysis completed successfully:", nrow(results), "comparisons"),
            type = "message",
            duration = 5
          )

        }, error = function(e) {
          error_msg <- paste("Error running analysis:", e$message)
          analysis_status(error_msg)
          showNotification(
            error_msg,
            type = "error",
            duration = 10
          )
          analysis_results(NULL)
        })
      })
    })

    # Return analysis results
    return(analysis_results)
  })
}

#' Run MN analysis for Shiny (wrapper function)
#'
#' @param data Data frame with MN data
#' @param control_group Control group number
#' @param sig_level Significance level
#' @return Data frame with analysis results
#' @importFrom coin wilcox_test
#' @importFrom dplyr filter group_by summarise mutate arrange
#' @importFrom stats p.adjust
run_mn_analysis_shiny <- function(data, control_group = 1, sig_level = 0.05) {

  # Ensure required packages are loaded
  if (!requireNamespace("coin", quietly = TRUE)) {
    stop("Package 'coin' is required but not installed")
  }

  if (!requireNamespace("dplyr", quietly = TRUE)) {
    stop("Package 'dplyr' is required but not installed")
  }

  # Get control group data
  control_data <- data[data$GroupNumber == control_group, ]

  if (nrow(control_data) == 0) {
    stop(paste("Control group", control_group, "not found in data"))
  }

  # Get treatment groups (all groups except control)
  treatment_groups <- sort(unique(data$GroupNumber))
  treatment_groups <- treatment_groups[treatment_groups != control_group]

  if (length(treatment_groups) == 0) {
    stop("No treatment groups found for comparison")
  }

  # Initialize results list
  results_list <- list()

  # Run Mann-Whitney U test for each treatment group vs control
  for (i in seq_along(treatment_groups)) {
    treatment_group <- treatment_groups[i]
    treatment_data <- data[data$GroupNumber == treatment_group, ]

    # Combine data for test
    test_data <- rbind(
      data.frame(MN = control_data$MN, Group = "Control"),
      data.frame(MN = treatment_data$MN, Group = "Treatment")
    )
    test_data$Group <- factor(test_data$Group)

    # Run Wilcoxon test
    test_result <- coin::wilcox_test(
      MN ~ Group,
      data = test_data,
      distribution = "exact"
    )

    # Extract p-value
    p_value <- coin::pvalue(test_result)[1]

    # Calculate descriptive statistics
    control_n <- nrow(control_data)
    control_median <- median(control_data$MN, na.rm = TRUE)
    control_mean <- mean(control_data$MN, na.rm = TRUE)
    control_sd <- sd(control_data$MN, na.rm = TRUE)

    treatment_n <- nrow(treatment_data)
    treatment_median <- median(treatment_data$MN, na.rm = TRUE)
    treatment_mean <- mean(treatment_data$MN, na.rm = TRUE)
    treatment_sd <- sd(treatment_data$MN, na.rm = TRUE)

    # Get group name
    group_name <- if ("Group" %in% names(data)) {
      unique(data[data$GroupNumber == treatment_group, "Group"])[1]
    } else {
      paste("Group", treatment_group)
    }

    # Store results
    results_list[[i]] <- data.frame(
      Comparison = paste0("Group ", treatment_group, " vs ", control_group),
      GroupNumber = treatment_group,
      GroupName = as.character(group_name),
      Control_n = control_n,
      Control_Median = control_median,
      Control_Mean = control_mean,
      Control_SD = control_sd,
      Treatment_n = treatment_n,
      Treatment_Median = treatment_median,
      Treatment_Mean = treatment_mean,
      Treatment_SD = treatment_sd,
      p_value = p_value,
      stringsAsFactors = FALSE
    )
  }

  # Combine results
  results_df <- do.call(rbind, results_list)

  # Apply Holm-Bonferroni correction
  results_df$p_value_adj <- p.adjust(results_df$p_value, method = "holm")

  # Add significance markers
  results_df$Significance <- ifelse(results_df$p_value_adj < sig_level, "*", "")

  # Arrange by group number
  results_df <- results_df[order(results_df$GroupNumber), ]

  # Reset row names
  rownames(results_df) <- NULL

  return(results_df)
}
