# Study and File Selector Module for MN Test Analysis Dashboard

#' Selector Module UI
#'
#' @param id Module namespace ID
#' @return Shiny UI elements
mod_selector_ui <- function(id) {
  ns <- NS(id)

  tagList(
    fluidRow(
      box(
        title = "Study Selection",
        status = "primary",
        solidHeader = TRUE,
        width = 12,
        p("Select a study folder and Excel file to analyze."),
        selectInput(
          ns("study_folder"),
          "Study Folder:",
          choices = NULL,
          selectize = TRUE
        ),
        selectInput(
          ns("excel_file"),
          "Excel File:",
          choices = NULL,
          selectize = TRUE
        ),
        hr(),
        h4("Selected File:"),
        verbatimTextOutput(ns("file_path_display")),
        actionButton(
          ns("refresh"),
          "Refresh File List",
          icon = icon("refresh"),
          class = "btn-info"
        )
      )
    ),
    fluidRow(
      valueBoxOutput(ns("study_count"), width = 4),
      valueBoxOutput(ns("file_count"), width = 4),
      valueBoxOutput(ns("selection_status"), width = 4)
    )
  )
}

#' Selector Module Server
#'
#' @param id Module namespace ID
#' @param config Reactive values with configuration
#' @return Reactive value with selected file path
mod_selector_server <- function(id, config) {
  moduleServer(id, function(input, output, session) {

    # Reactive value for selected file path
    selected_file <- reactiveVal(NULL)

    # Get list of study folders
    study_folders <- reactive({
      req(config$root_dir)
      if (config$root_dir == "" || !dir.exists(config$root_dir)) {
        return(character(0))
      }
      list_study_folders(config$root_dir)
    })

    # Update study folder choices when root directory changes
    observe({
      folders <- study_folders()
      updateSelectInput(
        session,
        "study_folder",
        choices = c("Select a folder..." = "", folders),
        selected = ""
      )
    })

    # Get list of Excel files in selected study folder
    excel_files <- reactive({
      req(input$study_folder)
      if (input$study_folder == "" || config$root_dir == "") {
        return(character(0))
      }

      folder_path <- file.path(config$root_dir, input$study_folder)
      list_excel_files(folder_path)
    })

    # Update Excel file choices when study folder changes
    observe({
      files <- excel_files()
      updateSelectInput(
        session,
        "excel_file",
        choices = c("Select a file..." = "", files),
        selected = ""
      )
    })

    # Update selected file path when Excel file is selected
    observe({
      req(input$study_folder, input$excel_file)

      if (input$study_folder != "" && input$excel_file != "" && config$root_dir != "") {
        file_path <- file.path(config$root_dir, input$study_folder, input$excel_file)

        if (file.exists(file_path)) {
          selected_file(file_path)
        } else {
          selected_file(NULL)
          showNotification(
            "Selected file does not exist",
            type = "error",
            duration = 5
          )
        }
      } else {
        selected_file(NULL)
      }
    })

    # Refresh file list
    observeEvent(input$refresh, {
      folders <- study_folders()
      updateSelectInput(
        session,
        "study_folder",
        choices = c("Select a folder..." = "", folders),
        selected = input$study_folder
      )

      if (input$study_folder != "") {
        files <- excel_files()
        updateSelectInput(
          session,
          "excel_file",
          choices = c("Select a file..." = "", files),
          selected = input$excel_file
        )
      }

      showNotification(
        "File list refreshed",
        type = "message",
        duration = 2
      )
    })

    # Display selected file path
    output$file_path_display <- renderText({
      file_path <- selected_file()
      if (is.null(file_path)) {
        return("No file selected")
      }
      return(file_path)
    })

    # Value box: Study count
    output$study_count <- renderValueBox({
      folders <- study_folders()
      valueBox(
        length(folders),
        "Study Folders",
        icon = icon("folder"),
        color = "blue"
      )
    })

    # Value box: File count
    output$file_count <- renderValueBox({
      files <- excel_files()
      valueBox(
        length(files),
        "Excel Files",
        icon = icon("file-excel"),
        color = "green"
      )
    })

    # Value box: Selection status
    output$selection_status <- renderValueBox({
      file_path <- selected_file()
      if (!is.null(file_path)) {
        valueBox(
          "Ready",
          "File Selected",
          icon = icon("check-circle"),
          color = "green"
        )
      } else {
        valueBox(
          "Waiting",
          "No Selection",
          icon = icon("exclamation-circle"),
          color = "yellow"
        )
      }
    })

    # Return selected file path
    return(selected_file)
  })
}
