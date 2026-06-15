# User Interface for MN Test Analysis Dashboard

# Define UI
ui <- dashboardPage(
  skin = "yellow",

  # Dashboard Header
  dashboardHeader(
    title = "Merck - GTA",
    titleWidth = 300
  ),

  # Dashboard Sidebar
  dashboardSidebar(
    width = 300,
    sidebarMenu(
      id = "sidebar",
      menuItem("Configuration", tabName = "config", icon = icon("cog")),
      menuItem("Data Selection", tabName = "selection", icon = icon("folder-open")),
      menuItem("Data Preview", tabName = "preview", icon = icon("table")),
      menuItem("Analysis", tabName = "analysis", icon = icon("calculator")),
      menuItem("Results", tabName = "results", icon = icon("chart-bar")),
      hr(),
      menuItem("About", tabName = "about", icon = icon("info-circle"))
    ),
    hr(),
    tags$div(
      style = "padding: 15px; text-align: center;",
      tags$img(src = "logo.png", width = "20%", style = "margin-bottom: 10px;"),
      tags$p(
        style = "color: #b8c7ce; font-size: 11px; margin-top: 10px;",
        strong("Version:"), app_version
      ),
      tags$p(
        style = "color: #b8c7ce; font-size: 10px;",
        "© CPS, Merck Healthcare KGaA"
      )
    )
  ),

  # Dashboard Body
  dashboardBody(
    # Use shinyjs
    useShinyjs(),

    # Custom CSS
    tags$head(
      tags$link(rel = "stylesheet", type = "text/css", href = "custom.css")
    ),

    # Tab Items
    tabItems(

      # Configuration Tab
      tabItem(
        tabName = "config",
        h2("Configuration"),
        p("Configure the root directory and default settings for the MN Test Analysis Dashboard."),
        hr(),
        mod_config_ui("config")
      ),

      # Data Selection Tab
      tabItem(
        tabName = "selection",
        h2("Data Selection"),
        p("Browse study folders and select an Excel file to analyze."),
        hr(),
        mod_selector_ui("selector")
      ),

      # Data Preview Tab
      tabItem(
        tabName = "preview",
        h2("Data Preview"),
        p("Preview the selected Excel file data before running analysis."),
        hr(),
        mod_preview_ui("preview")
      ),

      # Analysis Tab
      tabItem(
        tabName = "analysis",
        h2("Analysis"),
        p("Configure analysis parameters and run the Mann-Whitney U test."),
        hr(),
        mod_analysis_ui("analysis")
      ),

      # Results Tab
      tabItem(
        tabName = "results",
        h2("Results"),
        p("View and export analysis results."),
        hr(),
        mod_results_ui("results")
      ),

      # About Tab
      tabItem(
        tabName = "about",
        h2("About"),
        fluidRow(
          box(
            title = "CPS GTA - Genotoxicity Test Analysis",
            status = "primary",
            solidHeader = TRUE,
            width = 12,
            tags$div(
              style = "text-align: center; padding: 10px;",
              tags$h1(style = "color: #0F69AF; margin-bottom: 5px;", "GTA"),
              tags$p(style = "color: #666; font-size: 14px;", "Genotoxicity Test Analysis Dashboard")
            ),
            hr(),
            h3("Overview"),
            p("This dashboard provides a user-friendly interface for analyzing micronucleus (MN) test data using Mann-Whitney U tests with Holm-Bonferroni multiple comparison correction."),
            hr(),
            h3("Features"),
            tags$ul(
              tags$li("Browse and select Excel files from study folders"),
              tags$li("Preview data before analysis"),
              tags$li("Configure analysis parameters (control group, significance level)"),
              tags$li("Run Mann-Whitney U tests with exact distribution"),
              tags$li("Apply Holm-Bonferroni correction for multiple comparisons"),
              tags$li("Export results to Excel, CSV, or PDF")
            ),
            hr(),
            h3("Statistical Method"),
            p(strong("Test:"), "Mann-Whitney U test (Wilcoxon rank-sum test)"),
            p(strong("Implementation:"), "coin::wilcox_test with exact distribution"),
            p(strong("Multiple Testing Correction:"), "Holm-Bonferroni method"),
            p(strong("Comparison:"), "Each treatment group vs control group"),
            hr(),
            h3("Workflow"),
            tags$ol(
              tags$li(strong("Configuration:"), "Set the root directory path"),
              tags$li(strong("Selection:"), "Choose study folder and Excel file"),
              tags$li(strong("Preview:"), "Load and verify the data"),
              tags$li(strong("Analysis:"), "Set parameters and run tests"),
              tags$li(strong("Results:"), "View and export results")
            ),
            hr(),
            h3("Version Information"),
            p(strong("Version:"), app_version),
            p(strong("Application:"), app_description),
            p(strong("Organization:"), "Merck Healthcare KGaA"),
            p(strong("Department:"), "Chemical and Preclincal Safety"),
            p(strong("Author:"), "Frank Bringezu, PhD"),
            hr(),
            tags$div(
              style = "text-align: center; color: #999; font-size: 12px;",
              "© 2026 Merck Healthcare KGaA, Darmstadt, Germany"
            )
          )
        )
      )
    )
  )
)
