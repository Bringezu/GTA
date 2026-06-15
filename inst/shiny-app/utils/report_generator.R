# Report generation functions for MN Test Analysis Dashboard

#' Check if LaTeX is available
#'
#' @return Logical indicating if LaTeX is available
check_latex_available <- function() {
  # Check if tinytex is installed
  if (requireNamespace("tinytex", quietly = TRUE)) {
    if (tinytex::is_tinytex()) {
      return(TRUE)
    }
  }

  # Check if pdflatex is in PATH
  tryCatch({
    system2("pdflatex", "--version", stdout = FALSE, stderr = FALSE)
    return(TRUE)
  }, error = function(e) {
    return(FALSE)
  }, warning = function(w) {
    return(FALSE)
  })
}

#' Generate PDF report
#'
#' @param results Data frame with analysis results
#' @param study_name Study folder name
#' @param file_name Excel file name
#' @param control_group Control group number
#' @param sig_level Significance level
#' @param output_file Output file path
#' @return Path to generated PDF
#' @importFrom rmarkdown render
#' @importFrom knitr kable
generate_pdf_report <- function(results, study_name, file_name,
                                 control_group, sig_level, output_file) {

  # Check if LaTeX is available
  if (!check_latex_available()) {
    stop(paste0(
      "LaTeX is not available on this system. PDF generation requires LaTeX.\n\n",
      "Options:\n",
      "1. Install tinytex in R: install.packages('tinytex'); tinytex::install_tinytex()\n",
      "2. Install MiKTeX or TeX Live on your system\n",
      "3. Use HTML report instead (recommended for no LaTeX setup)\n\n",
      "Please use the 'Download HTML Report' button instead."
    ))
  }

  template_path <- system.file("shiny-app/templates/report_template.Rmd", package = "GTA")

  # If template not found in package, look in current directory
  if (template_path == "" || !file.exists(template_path)) {
    template_path <- file.path("templates", "report_template.Rmd")
  }

  if (!file.exists(template_path)) {
    stop("Report template not found")
  }

  tryCatch({
    rmarkdown::render(
      input = template_path,
      output_file = basename(output_file),
      output_dir = dirname(output_file),
      params = list(
        results = results,
        study_name = study_name,
        file_name = file_name,
        control_group = control_group,
        sig_level = sig_level,
        report_date = format(Sys.Date(), "%Y-%m-%d")
      ),
      quiet = TRUE
    )
    return(output_file)
  }, error = function(e) {
    stop("Error generating PDF report: ", e$message)
  })
}

#' Generate HTML report
#'
#' @param results Data frame with analysis results
#' @param study_name Study folder name
#' @param file_name Excel file name
#' @param control_group Control group number
#' @param sig_level Significance level
#' @param output_file Output file path
#' @return Path to generated HTML
#' @importFrom rmarkdown render
#' @importFrom knitr kable
generate_html_report <- function(results, study_name, file_name,
                                  control_group, sig_level, output_file) {

  template_path <- system.file("shiny-app/templates/report_template_html.Rmd", package = "GTA")

  # If template not found in package, look in current directory
  if (template_path == "" || !file.exists(template_path)) {
    template_path <- file.path("templates", "report_template_html.Rmd")
  }

  if (!file.exists(template_path)) {
    stop("HTML report template not found")
  }

  tryCatch({
    rmarkdown::render(
      input = template_path,
      output_file = basename(output_file),
      output_dir = dirname(output_file),
      params = list(
        results = results,
        study_name = study_name,
        file_name = file_name,
        control_group = control_group,
        sig_level = sig_level,
        report_date = format(Sys.Date(), "%Y-%m-%d")
      ),
      quiet = TRUE
    )
    return(output_file)
  }, error = function(e) {
    stop("Error generating HTML report: ", e$message)
  })
}

#' Format results table for display
#'
#' @param results Data frame with analysis results
#' @return Formatted data frame
format_results_table <- function(results) {
  if (is.null(results) || nrow(results) == 0) {
    return(results)
  }

  # Round numeric columns
  numeric_cols <- sapply(results, is.numeric)
  results[numeric_cols] <- lapply(results[numeric_cols], function(x) round(x, 4))

  # Format p-values in scientific notation if very small
  if ("p_value" %in% names(results)) {
    results$p_value <- ifelse(
      is.na(results$p_value),
      NA,
      ifelse(
        results$p_value < 0.001,
        format(results$p_value, scientific = TRUE, digits = 3),
        format(results$p_value, scientific = FALSE, digits = 4)
      )
    )
  }

  # Format local_ai (Holm-Bonferroni threshold) if present
  if ("local_ai" %in% names(results)) {
    results$local_ai <- ifelse(
      is.na(results$local_ai),
      NA,
      round(results$local_ai, 4)
    )
  }

  return(results)
}
