# MN Test Analysis Dashboard
# Entry point for Shiny application

# Source global configuration
source("global.R", local = TRUE)

# Source UI
source("ui.R", local = TRUE)

# Source server
source("server.R", local = TRUE)

# Run the application
shinyApp(ui = ui, server = server)
