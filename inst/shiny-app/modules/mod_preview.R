# Data Preview Module for MN Test Analysis Dashboard

#' Preview Module UI
#'
#' @param id Module namespace ID
#' @return Shiny UI elements
mod_preview_ui <- function(id) {
  ns <- NS(id)

  tagList(
    fluidRow(
      valueBoxOutput(ns("row_count"), width = 3),
      valueBoxOutput(ns("group_count"), width = 3),
      valueBoxOutput(ns("column_count"), width = 3),
      valueBoxOutput(ns("data_status"), width = 3)
    ),
    fluidRow(
      box(
        title = "Data Preview",
        status = "primary",
        solidHeader = TRUE,
        width = 12,
        p("Preview of Excel Sheet 2 data. Use the search and filter options to explore the dataset."),
        actionButton(
          ns("load_data"),
          "Load Data",
          icon = icon("upload"),
          class = "btn-primary"
        ),
        hr(),
        DT::dataTableOutput(ns("data_table"))
      )
    )
  )
}

#' Preview Module Server
#'
#' @param id Module namespace ID
#' @param file_path Reactive value with selected file path
#' @param config Reactive values with configuration
#' @return Reactive value with loaded data
mod_preview_server <- function(id, file_path, config) {
  moduleServer(id, function(input, output, session) {

    # Reactive value for loaded data
    loaded_data <- reactiveVal(NULL)

    # Load data when button is clicked
    observeEvent(input$load_data, {
      req(file_path())

      tryCatch({
        # Show progress
        withProgress(message = "Loading data...", value = 0, {

          incProgress(0.3, detail = "Reading Excel file")

          # Load data
          data <- load_xlsx_sheet(file_path(), sheet = config$sheet_number)

          incProgress(0.4, detail = "Validating data")

          # Validate data structure
          validation <- validate_mn_data(data)

          if (!validation$valid) {
            showNotification(
              validation$message,
              type = "error",
              duration = 5
            )
            loaded_data(NULL)
            return()
          }

          incProgress(0.3, detail = "Complete")

          # Store loaded data
          loaded_data(data)

          showNotification(
            paste("Data loaded successfully:", nrow(data), "rows"),
            type = "message",
            duration = 3
          )
        })

      }, error = function(e) {
        showNotification(
          paste("Error loading data:", e$message),
          type = "error",
          duration = 5
        )
        loaded_data(NULL)
      })
    })

    # Auto-load data when file path changes (optional - can be removed if you want manual load only)
    observe({
      req(file_path())
      # Automatically trigger load when file changes
      # Comment out if manual load is preferred
      # click("load_data")
    })

    # Render data table
    output$data_table <- DT::renderDataTable({
      req(loaded_data())

      DT::datatable(
        loaded_data(),
        options = list(
          pageLength = 25,
          scrollX = TRUE,
          searchHighlight = TRUE,
          dom = 'Bfrtip',
          buttons = c('copy', 'csv', 'excel')
        ),
        filter = "top",
        selection = "none",
        rownames = FALSE
      )
    })

    # Value box: Row count
    output$row_count <- renderValueBox({
      data <- loaded_data()
      count <- if (is.null(data)) 0 else nrow(data)

      valueBox(
        count,
        "Total Rows",
        icon = icon("list"),
        color = if (count > 0) "blue" else "red"
      )
    })

    # Value box: Group count
    output$group_count <- renderValueBox({
      data <- loaded_data()

      if (is.null(data) || !"GroupNumber" %in% names(data)) {
        count <- 0
      } else {
        count <- length(unique(data$GroupNumber))
      }

      valueBox(
        count,
        "Groups",
        icon = icon("users"),
        color = if (count > 0) "green" else "red"
      )
    })

    # Value box: Column count
    output$column_count <- renderValueBox({
      data <- loaded_data()
      count <- if (is.null(data)) 0 else ncol(data)

      valueBox(
        count,
        "Columns",
        icon = icon("columns"),
        color = if (count > 0) "yellow" else "red"
      )
    })

    # Value box: Data status
    output$data_status <- renderValueBox({
      data <- loaded_data()

      if (is.null(data)) {
        valueBox(
          "No Data",
          "Status",
          icon = icon("exclamation-triangle"),
          color = "red"
        )
      } else {
        validation <- validate_mn_data(data)
        if (validation$valid) {
          valueBox(
            "Valid",
            "Data Status",
            icon = icon("check-circle"),
            color = "green"
          )
        } else {
          valueBox(
            "Invalid",
            "Data Status",
            icon = icon("times-circle"),
            color = "red"
          )
        }
      }
    })

    # Return loaded data
    return(loaded_data)
  })
}
