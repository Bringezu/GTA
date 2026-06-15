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
        checkboxGroupInput(
          ns("exclude_groups"),
          "Exclude Groups from Analysis:",
          choices = NULL,
          selected = NULL
        ),
        helpText("Select groups to exclude from comparison (e.g., positive controls). Control group cannot be excluded."),
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

    # Update exclude groups checkboxes when data changes
    observe({
      req(data())

      # Extract actual data from result structure
      actual_data <- if (is.list(data()) && "data" %in% names(data())) {
        data()$data
      } else {
        data()
      }

      if (!"GroupNumber" %in% names(actual_data)) {
        updateCheckboxGroupInput(session, "exclude_groups", choices = NULL)
        return()
      }

      groups <- sort(unique(actual_data$GroupNumber))
      group_names <- if ("Group" %in% names(actual_data)) {
        sapply(groups, function(g) {
          name <- unique(actual_data[actual_data$GroupNumber == g, "Group"])
          name <- name[!is.na(name)]
          if (length(name) > 0) as.character(name[1]) else "Unknown"
        })
      } else {
        rep("Unknown", length(groups))
      }

      # Create named vector for checkbox choices
      choices <- setNames(groups, paste0("Group ", groups, ": ", group_names))

      updateCheckboxGroupInput(
        session,
        "exclude_groups",
        choices = choices,
        selected = NULL
      )
    })

    # Display available groups
    output$group_info <- renderText({
      req(data())

      # Extract actual data from result structure
      actual_data <- if (is.list(data()) && "data" %in% names(data())) {
        data()$data
      } else {
        data()
      }

      if (!"GroupNumber" %in% names(actual_data)) {
        return("No group information available")
      }

      groups <- sort(unique(actual_data$GroupNumber))
      group_names <- if ("Group" %in% names(actual_data)) {
        sapply(groups, function(g) {
          name <- unique(actual_data[actual_data$GroupNumber == g, "Group"])
          name <- name[!is.na(name)]
          if (length(name) > 0) as.character(name[1]) else "Unknown"
        })
      } else {
        rep("Unknown", length(groups))
      }

      # Show excluded groups if any
      excluded <- input$exclude_groups
      excluded_info <- if (length(excluded) > 0) {
        paste0("\n\nExcluded from analysis: ", paste(excluded, collapse = ", "))
      } else {
        ""
      }

      info_text <- paste0(
        "Available groups in dataset:\n",
        paste(paste0("Group ", groups, ": ", group_names), collapse = "\n"),
        excluded_info
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

      # Check if control group is in excluded groups
      if (input$control_group %in% input$exclude_groups) {
        showNotification(
          "Control group cannot be excluded from analysis",
          type = "error",
          duration = 5
        )
        analysis_status("Error: Control group cannot be excluded")
        return()
      }

      # Extract actual data and metadata
      result <- data()
      actual_data <- if (is.list(result) && "data" %in% names(result)) {
        result$data
      } else {
        result
      }
      metadata <- if (is.list(result) && "metadata" %in% names(result)) {
        result$metadata
      } else {
        list(study_number = "Not specified", test_item = "Not specified",
             species = "Not specified", sex = "Not specified")
      }

      # Validate parameters
      param_validation <- validate_analysis_params(
        input$control_group,
        input$sig_level,
        actual_data
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

          # Get excluded groups as numeric
          excluded_groups <- if (length(input$exclude_groups) > 0) {
            as.numeric(input$exclude_groups)
          } else {
            NULL
          }

          # Call analysis function with excluded groups
          results <- run_mn_analysis_shiny(
            data = actual_data,
            control_group = input$control_group,
            sig_level = input$sig_level,
            exclude_groups = excluded_groups,
            metadata = metadata
          )

          incProgress(0.4, detail = "Applying corrections")
          analysis_status("Applying multiple testing corrections...")

          incProgress(0.1, detail = "Complete")

          # Build status message
          status_msg <- paste("Analysis completed successfully:", nrow(results), "comparisons")
          if (length(excluded_groups) > 0) {
            status_msg <- paste0(status_msg, " (Excluded groups: ",
                                paste(excluded_groups, collapse = ", "), ")")
          }
          analysis_status(status_msg)

          # Store results
          analysis_results(results)

          showNotification(
            status_msg,
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
#' @param exclude_groups Vector of group numbers to exclude from analysis
#' @param metadata List with study metadata (study_number, test_item, species, sex)
#' @return Data frame with analysis results
#' @importFrom coin wilcox_test
#' @importFrom dplyr filter group_by summarise mutate arrange
#' @importFrom stats p.adjust
run_mn_analysis_shiny <- function(data, control_group = 1, sig_level = 0.05, exclude_groups = NULL, metadata = NULL) {

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

  # Exclude specified groups
  if (!is.null(exclude_groups) && length(exclude_groups) > 0) {
    # Make sure control group is not in exclude list
    if (control_group %in% exclude_groups) {
      stop("Control group cannot be excluded from analysis")
    }
    treatment_groups <- treatment_groups[!treatment_groups %in% exclude_groups]
  }

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
    test_data <- rbind(control_data, treatment_data)
    test_data$Group <- factor(test_data$Group)

    # Run Wilcoxon test with alternative='greater'
    # This tests if treatment group has higher MN values than control
    test_result <- coin::wilcox_test(
      MN ~ Group,
      data = test_data,
      distribution = "exact",
      correct = FALSE,
      alternative = 'greater'
    )

    # Extract p-value
    p_value <- as.numeric(coin::pvalue(test_result))
    message( as.numeric(paste0(coin::pvalue(test_result))))

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
      group_vals <- unique(data[data$GroupNumber == treatment_group, "Group"])
      group_vals <- group_vals[!is.na(group_vals)]
      if (length(group_vals) > 0) {
        as.character(group_vals[1])
      } else {
        paste("Group", treatment_group)
      }
    } else {
      paste("Group", treatment_group)
    }

    # Store results for treatment group
    results_list[[i]] <- data.frame(
      GroupNumber = treatment_group,
      GroupName = as.character(group_name),
      N = treatment_n,
      Median = treatment_median,
      Mean = treatment_mean,
      SD = treatment_sd,
      p_value = p_value,
      stringsAsFactors = FALSE
    )
  }

  # Combine results from treatment groups
  results_df <- do.call(rbind, results_list)

  # Apply Holm-Bonferroni correction to treatment groups only
  results_df$index <- rank(results_df$p_value)
  rows <- nrow(results_df)
  results_df <- results_df %>% dplyr::mutate(local_ai = sig_level / (rows - index + 1))
  results_df <- results_df %>%
    dplyr::mutate(Significance = ifelse(p_value <= local_ai, '*', 'ns'))

  # Process excluded groups (e.g., positive controls) if any
  # These are tested separately with alternative='less' (expect higher than control)
  if (!is.null(exclude_groups) && length(exclude_groups) > 0) {
    excluded_results_list <- list()

    for (i in seq_along(exclude_groups)) {
      excluded_group <- exclude_groups[i]
      excluded_data <- data[data$GroupNumber == excluded_group, ]

      if (nrow(excluded_data) == 0) next

      # Combine control and excluded group data for test
      ex_test_data <- rbind(control_data, excluded_data)
      ex_test_data$Group <- factor(ex_test_data$Group)

      # Run Wilcoxon test with alternative='less'
      # This tests if excluded group (positive control) has higher MN values than control
      ex_result <- coin::wilcox_test(
        MN ~ Group,
        data = ex_test_data,
        distribution = "exact",
        correct = FALSE,
        alternative = 'less'
      )

      # Extract p-value
      ex_p_value <- as.numeric(coin::pvalue(ex_result))

      # Calculate descriptive statistics
      ex_n <- nrow(excluded_data)
      ex_median <- median(excluded_data$MN, na.rm = TRUE)
      ex_mean <- mean(excluded_data$MN, na.rm = TRUE)
      ex_sd <- sd(excluded_data$MN, na.rm = TRUE)

      # Get group name
      ex_group_name <- if ("Group" %in% names(data)) {
        group_vals <- unique(data[data$GroupNumber == excluded_group, "Group"])
        group_vals <- group_vals[!is.na(group_vals)]
        if (length(group_vals) > 0) {
          as.character(group_vals[1])
        } else {
          paste("Group", excluded_group)
        }
      } else {
        paste("Group", excluded_group)
      }

      # Store excluded group result (no Holm-Bonferroni adjustment)
      excluded_results_list[[i]] <- data.frame(
        GroupNumber = excluded_group,
        GroupName = as.character(ex_group_name),
        N = ex_n,
        Median = ex_median,
        Mean = ex_mean,
        SD = ex_sd,
        p_value = ex_p_value,
        index = NA,
        local_ai = NA,
        Significance = ifelse(ex_p_value < sig_level, '*', 'ns'),
        stringsAsFactors = FALSE
      )
    }

    # Combine excluded group results if any
    if (length(excluded_results_list) > 0) {
      excluded_df <- do.call(rbind, excluded_results_list)
    } else {
      excluded_df <- NULL
    }
  } else {
    excluded_df <- NULL
  }

  # Create control group row (first row in final results)
  control_result <- data.frame(
    GroupNumber = control_group,
    GroupName = as.character(control_data$Group[1]),
    N = nrow(control_data),
    Median = control_median,
    Mean = control_mean,
    SD = control_sd,
    p_value = NA,
    index = NA,
    local_ai = NA,
    Significance = '',
    stringsAsFactors = FALSE
  )

  # Assemble final results: control + treatment groups + excluded groups
  results_df <- dplyr::add_row(results_df, control_result, .before = 1)

  if (!is.null(excluded_df)) {
    results_df <- rbind(results_df, excluded_df)
  }

  # Add metadata columns if provided
  if (!is.null(metadata)) {
    results_df$Study_Number <- metadata$study_number
    results_df$Test_Item <- metadata$test_item
    results_df$Species <- metadata$species
    results_df$Sex <- metadata$sex
  }

  # Arrange by group number
  results_df <- results_df[order(results_df$GroupNumber), ]

  # Reset row names
  rownames(results_df) <- NULL

  return(results_df)
}
