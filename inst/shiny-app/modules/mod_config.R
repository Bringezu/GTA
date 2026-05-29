# Configuration Module for MN Test Analysis Dashboard

#' Configuration Module UI
#'
#' @param id Module namespace ID
#' @return Shiny UI elements
mod_config_ui <- function(id) {
  ns <- NS(id)

  tagList(
    fluidRow(
      box(
        title = "Data Directory Configuration",
        status = "primary",
        solidHeader = TRUE,
        width = 12,
        p("Configure the root directory containing your MN test data folders."),
        p(strong("Example:"), "G:/R_Statistik or C:/Data/R-Statistik"),
        textInput(
          ns("root_dir"),
          "Root Directory Path:",
          value = "",
          placeholder = "Enter absolute path to data directory"
        ),
        actionButton(
          ns("save_config"),
          "Save Configuration",
          icon = icon("save"),
          class = "btn-primary"
        ),
        hr(),
        h4("Current Configuration:"),
        verbatimTextOutput(ns("config_status"))
      )
    ),
    fluidRow(
      box(
        title = "Default Analysis Settings",
        status = "info",
        solidHeader = TRUE,
        width = 12,
        numericInput(
          ns("default_control"),
          "Default Control Group:",
          value = 1,
          min = 1,
          step = 1
        ),
        numericInput(
          ns("default_sig_level"),
          "Default Significance Level:",
          value = 0.05,
          min = 0.001,
          max = 0.999,
          step = 0.01
        ),
        numericInput(
          ns("sheet_number"),
          "Excel Sheet Number:",
          value = 2,
          min = 1,
          step = 1
        ),
        actionButton(
          ns("save_defaults"),
          "Save Defaults",
          icon = icon("save"),
          class = "btn-info"
        )
      )
    )
  )
}

#' Configuration Module Server
#'
#' @param id Module namespace ID
#' @return Reactive values with configuration
mod_config_server <- function(id) {
  moduleServer(id, function(input, output, session) {

    # Reactive values to store configuration
    config <- reactiveValues(
      root_dir = "",
      default_control_group = 1,
      default_sig_level = 0.05,
      sheet_number = 2,
      loaded = FALSE
    )

    # Configuration file path
    config_file <- file.path("config", "user_config.yml")

    # Load configuration on startup
    observe({
      if (!config$loaded) {
        loaded_config <- load_config(config_file)
        if (!is.null(loaded_config)) {
          config$root_dir <- loaded_config$root_dir %||% ""
          config$default_control_group <- loaded_config$default_control_group %||% 1
          config$default_sig_level <- loaded_config$default_sig_level %||% 0.05
          config$sheet_number <- loaded_config$sheet_number %||% 2

          # Update UI
          updateTextInput(session, "root_dir", value = config$root_dir)
          updateNumericInput(session, "default_control", value = config$default_control_group)
          updateNumericInput(session, "default_sig_level", value = config$default_sig_level)
          updateNumericInput(session, "sheet_number", value = config$sheet_number)
        }
        config$loaded <- TRUE
      }
    })

    # Save root directory configuration
    observeEvent(input$save_config, {
      validation <- validate_directory(input$root_dir)

      if (!validation$valid) {
        showNotification(
          validation$message,
          type = "error",
          duration = 5
        )
        return()
      }

      config$root_dir <- input$root_dir

      save_result <- save_config(
        config_file,
        list(
          root_dir = config$root_dir,
          default_control_group = config$default_control_group,
          default_sig_level = config$default_sig_level,
          sheet_number = config$sheet_number
        )
      )

      if (save_result$success) {
        showNotification(
          "Configuration saved successfully",
          type = "message",
          duration = 3
        )
      } else {
        showNotification(
          paste("Error saving configuration:", save_result$message),
          type = "error",
          duration = 5
        )
      }
    })

    # Save default settings
    observeEvent(input$save_defaults, {
      config$default_control_group <- input$default_control
      config$default_sig_level <- input$default_sig_level
      config$sheet_number <- input$sheet_number

      save_result <- save_config(
        config_file,
        list(
          root_dir = config$root_dir,
          default_control_group = config$default_control_group,
          default_sig_level = config$default_sig_level,
          sheet_number = config$sheet_number
        )
      )

      if (save_result$success) {
        showNotification(
          "Default settings saved successfully",
          type = "message",
          duration = 3
        )
      } else {
        showNotification(
          paste("Error saving defaults:", save_result$message),
          type = "error",
          duration = 5
        )
      }
    })

    # Display current configuration status
    output$config_status <- renderText({
      if (config$root_dir == "") {
        return("No configuration saved yet.")
      }

      status_text <- paste0(
        "Root Directory: ", config$root_dir, "\n",
        "Status: ", ifelse(dir.exists(config$root_dir), "Valid", "Invalid (directory not found)"), "\n",
        "Default Control Group: ", config$default_control_group, "\n",
        "Default Significance Level: ", config$default_sig_level, "\n",
        "Excel Sheet Number: ", config$sheet_number
      )

      return(status_text)
    })

    # Return configuration as reactive values
    return(config)
  })
}

# Helper functions

#' Load configuration from YAML file
#'
#' @param file_path Path to config file
#' @return List with configuration or NULL
load_config <- function(file_path) {
  if (!file.exists(file_path)) {
    return(NULL)
  }

  tryCatch({
    config <- yaml::read_yaml(file_path)
    return(config)
  }, error = function(e) {
    warning("Error loading configuration: ", e$message)
    return(NULL)
  })
}

#' Save configuration to YAML file
#'
#' @param file_path Path to config file
#' @param config List with configuration
#' @return List with success status and message
save_config <- function(file_path, config) {
  # Ensure config directory exists
  config_dir <- dirname(file_path)
  if (!dir.exists(config_dir)) {
    dir.create(config_dir, recursive = TRUE)
  }

  tryCatch({
    yaml::write_yaml(config, file_path)
    return(list(success = TRUE, message = "Configuration saved"))
  }, error = function(e) {
    return(list(success = FALSE, message = e$message))
  })
}

#' Null coalescing operator
#'
#' @param x First value
#' @param y Second value (default)
#' @return x if not NULL, otherwise y
`%||%` <- function(x, y) {
  if (is.null(x)) y else x
}
