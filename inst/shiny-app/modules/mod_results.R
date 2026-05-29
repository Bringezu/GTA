# Results Display and Export Module for MN Test Analysis Dashboard

#' Results Module UI
#'
#' @param id Module namespace ID
#' @return Shiny UI elements
mod_results_ui <- function(id) {
  ns <- NS(id)

  tagList(
    fluidRow(
      valueBoxOutput(ns("total_comparisons"), width = 4),
      valueBoxOutput(ns("significant_results"), width = 4),
      valueBoxOutput(ns("export_status"), width = 4)
    ),
    fluidRow(
      box(
        title = "Analysis Results",
        status = "success",
        solidHeader = TRUE,
        width = 12,
        p("Results of Mann-Whitney U test with Holm-Bonferroni correction."),
        p(strong("Note:"), "* indicates statistically significant result (p < alpha)"),
        DT::dataTableOutput(ns("results_table"))
      )
    ),
    fluidRow(
      box(
        title = "Export Options",
        status = "primary",
        solidHeader = TRUE,
        width = 12,
        fluidRow(
          column(
            4,
            downloadButton(
              ns("download_excel"),
              "Download Excel",
              class = "btn-success btn-block",
              icon = icon("file-excel")
            )
          ),
          column(
            4,
            downloadButton(
              ns("download_csv"),
              "Download CSV",
              class = "btn-info btn-block",
              icon = icon("file-csv")
            )
          ),
          column(
            4,
            downloadButton(
              ns("download_pdf"),
              "Download PDF Report",
              class = "btn-warning btn-block",
              icon = icon("file-pdf")
            )
          )
        )
      )
    )
  )
}

#' Results Module Server
#'
#' @param id Module namespace ID
#' @param results Reactive value with analysis results
#' @param file_path Reactive value with selected file path
#' @param config Reactive values with configuration
#' @return None
mod_results_server <- function(id, results, file_path, config) {
  moduleServer(id, function(input, output, session) {

    # Render results table
    output$results_table <- DT::renderDataTable({
      req(results())

      formatted_results <- format_results_table(results())

      DT::datatable(
        formatted_results,
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
      ) %>%
        DT::formatStyle(
          'Significance',
          target = 'row',
          backgroundColor = DT::styleEqual('*', '#d4edda')
        ) %>%
        DT::formatRound(
          columns = c('Control_Median', 'Control_Mean', 'Control_SD',
                     'Treatment_Median', 'Treatment_Mean', 'Treatment_SD'),
          digits = 2
        )
    })

    # Value box: Total comparisons
    output$total_comparisons <- renderValueBox({
      res <- results()
      count <- if (is.null(res)) 0 else nrow(res)

      valueBox(
        count,
        "Total Comparisons",
        icon = icon("calculator"),
        color = "blue"
      )
    })

    # Value box: Significant results
    output$significant_results <- renderValueBox({
      res <- results()

      if (is.null(res) || !"Significance" %in% names(res)) {
        count <- 0
      } else {
        count <- sum(res$Significance == "*", na.rm = TRUE)
      }

      valueBox(
        count,
        "Significant Results",
        icon = icon("star"),
        color = if (count > 0) "yellow" else "green"
      )
    })

    # Value box: Export status
    output$export_status <- renderValueBox({
      res <- results()

      if (is.null(res)) {
        valueBox(
          "No Data",
          "Export Status",
          icon = icon("exclamation-triangle"),
          color = "red"
        )
      } else {
        valueBox(
          "Ready",
          "Export Status",
          icon = icon("check-circle"),
          color = "green"
        )
      }
    })

    # Download Excel
    output$download_excel <- downloadHandler(
      filename = function() {
        timestamp <- format(Sys.time(), "%Y%m%d_%H%M%S")
        paste0("MN_Analysis_Results_", timestamp, ".xlsx")
      },
      content = function(file) {
        req(results())

        tryCatch({
          if (!requireNamespace("writexl", quietly = TRUE)) {
            showNotification(
              "Package 'writexl' is required for Excel export",
              type = "error",
              duration = 5
            )
            return()
          }

          writexl::write_xlsx(results(), file)

          showNotification(
            "Excel file exported successfully",
            type = "message",
            duration = 3
          )

        }, error = function(e) {
          showNotification(
            paste("Error exporting Excel:", e$message),
            type = "error",
            duration = 5
          )
        })
      }
    )

    # Download CSV
    output$download_csv <- downloadHandler(
      filename = function() {
        timestamp <- format(Sys.time(), "%Y%m%d_%H%M%S")
        paste0("MN_Analysis_Results_", timestamp, ".csv")
      },
      content = function(file) {
        req(results())

        tryCatch({
          write.csv(results(), file, row.names = FALSE)

          showNotification(
            "CSV file exported successfully",
            type = "message",
            duration = 3
          )

        }, error = function(e) {
          showNotification(
            paste("Error exporting CSV:", e$message),
            type = "error",
            duration = 5
          )
        })
      }
    )

    # Download PDF Report
    output$download_pdf <- downloadHandler(
      filename = function() {
        timestamp <- format(Sys.time(), "%Y%m%d_%H%M%S")
        paste0("MN_Analysis_Report_", timestamp, ".pdf")
      },
      content = function(file) {
        req(results(), file_path())

        tryCatch({
          # Extract study and file information
          file_parts <- strsplit(file_path(), .Platform$file.sep)[[1]]
          file_name <- file_parts[length(file_parts)]
          study_name <- if (length(file_parts) >= 2) file_parts[length(file_parts) - 1] else "Unknown"

          # Generate PDF report
          generate_pdf_report(
            results = results(),
            study_name = study_name,
            file_name = file_name,
            control_group = config$default_control_group,
            sig_level = config$default_sig_level,
            output_file = file
          )

          showNotification(
            "PDF report generated successfully",
            type = "message",
            duration = 3
          )

        }, error = function(e) {
          showNotification(
            paste("Error generating PDF report:", e$message),
            type = "error",
            duration = 5
          )
        })
      }
    )
  })
}
