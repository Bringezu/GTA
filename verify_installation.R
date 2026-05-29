# Verification Script for MN Test Analysis Dashboard
# Run this script to verify that all dependencies and files are in place

cat("=== MN Test Analysis Dashboard - Installation Verification ===\n\n")

# Check R version
cat("1. Checking R version...\n")
r_version <- getRversion()
cat("   R version:", as.character(r_version), "\n")
if (r_version >= "4.0.0") {
  cat("   ✓ R version is sufficient (>= 4.0.0)\n\n")
} else {
  cat("   ✗ R version is too old. Please upgrade to R 4.0.0 or higher\n\n")
}

# Check required packages
cat("2. Checking required packages...\n")
required_packages <- c(
  "shiny", "shinydashboard", "DT", "yaml", "shinyjs",
  "rmarkdown", "knitr", "readxl", "coin", "dplyr", "writexl"
)

missing_packages <- c()
installed_packages <- c()

for (pkg in required_packages) {
  if (requireNamespace(pkg, quietly = TRUE)) {
    installed_packages <- c(installed_packages, pkg)
    cat("   ✓", pkg, "\n")
  } else {
    missing_packages <- c(missing_packages, pkg)
    cat("   ✗", pkg, "(NOT INSTALLED)\n")
  }
}

cat("\n")

# Summary of packages
if (length(missing_packages) == 0) {
  cat("   All required packages are installed!\n\n")
} else {
  cat("   Missing packages:", paste(missing_packages, collapse = ", "), "\n")
  cat("   To install missing packages, run:\n")
  cat("   install.packages(c(\"", paste(missing_packages, collapse = "\", \""), "\"))\n\n", sep = "")
}

# Check directory structure
cat("3. Checking directory structure...\n")

required_dirs <- c(
  "inst/shiny-app",
  "inst/shiny-app/modules",
  "inst/shiny-app/utils",
  "inst/shiny-app/templates",
  "inst/shiny-app/www",
  "R"
)

for (dir in required_dirs) {
  if (dir.exists(dir)) {
    cat("   ✓", dir, "\n")
  } else {
    cat("   ✗", dir, "(NOT FOUND)\n")
  }
}

cat("\n")

# Check critical files
cat("4. Checking critical files...\n")

required_files <- c(
  "DESCRIPTION",
  "NAMESPACE",
  "inst/shiny-app/app.R",
  "inst/shiny-app/global.R",
  "inst/shiny-app/ui.R",
  "inst/shiny-app/server.R",
  "inst/shiny-app/modules/mod_config.R",
  "inst/shiny-app/modules/mod_selector.R",
  "inst/shiny-app/modules/mod_preview.R",
  "inst/shiny-app/modules/mod_analysis.R",
  "inst/shiny-app/modules/mod_results.R",
  "inst/shiny-app/utils/file_utils.R",
  "inst/shiny-app/utils/validation.R",
  "inst/shiny-app/utils/report_generator.R",
  "inst/shiny-app/templates/report_template.Rmd",
  "inst/shiny-app/www/custom.css",
  "R/launch_dashboard.R"
)

all_files_present <- TRUE
for (file in required_files) {
  if (file.exists(file)) {
    cat("   ✓", file, "\n")
  } else {
    cat("   ✗", file, "(NOT FOUND)\n")
    all_files_present <- FALSE
  }
}

cat("\n")

# Final summary
cat("=== SUMMARY ===\n\n")

if (length(missing_packages) == 0 && all_files_present) {
  cat("✓ All dependencies and files are in place!\n")
  cat("✓ Installation appears to be complete.\n\n")
  cat("Next steps:\n")
  cat("1. Install the package: install.packages('.', repos = NULL, type = 'source')\n")
  cat("2. Load the package: library(GTA)\n")
  cat("3. Launch the dashboard: launch_mn_dashboard()\n")
  cat("\nOr run directly: shiny::runApp('inst/shiny-app')\n\n")
} else {
  cat("✗ Some issues were found:\n")
  if (length(missing_packages) > 0) {
    cat("   - Install missing packages\n")
  }
  if (!all_files_present) {
    cat("   - Some required files are missing\n")
  }
  cat("\nPlease resolve these issues before running the dashboard.\n\n")
}

cat("=== END OF VERIFICATION ===\n")
