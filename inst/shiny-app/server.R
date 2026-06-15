# Server logic for MN Test Analysis Dashboard

# Define server
server <- function(input, output, session) {

  # Configuration module
  config <- mod_config_server("config")

  # Selector module - returns selected file path
  selected_file <- mod_selector_server("selector", config)

  # Preview module - returns loaded data
  loaded_data <- mod_preview_server("preview", selected_file, config)

  # Analysis module - returns analysis results
  analysis_results <- mod_analysis_server("analysis", loaded_data, config)

  # Results module - handles display and export
  mod_results_server("results", analysis_results, selected_file, config)

  # Session info (for debugging)
  session$onSessionEnded(function() {
    cat("Session ended\n")
    stopApp()
  })
}
