# Global configuration for MN Test Analysis Dashboard
# This file is sourced before ui.R and server.R

# Load required packages
library(shiny)
library(shinydashboard)
library(DT)
library(yaml)
library(shinyjs)

# Load utility functions
source("utils/file_utils.R", local = TRUE)
source("utils/validation.R", local = TRUE)
source("utils/report_generator.R", local = TRUE)

# Load modules
source("modules/mod_config.R", local = TRUE)
source("modules/mod_selector.R", local = TRUE)
source("modules/mod_preview.R", local = TRUE)
source("modules/mod_analysis.R", local = TRUE)
source("modules/mod_results.R", local = TRUE)

# Application metadata
app_title <- "MN Test Analysis Dashboard"
app_version <- "1.0.0"
app_description <- "Micronucleus Test Statistical Analysis Tool"

# Ensure config directory exists
if (!dir.exists("config")) {
  dir.create("config", recursive = TRUE)
}
