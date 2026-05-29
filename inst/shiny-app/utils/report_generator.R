# PDF report generation functions for MN Test Analysis Dashboard

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
      results$p_value < 0.001,
      format(results$p_value, scientific = TRUE, digits = 3),
      format(results$p_value, scientific = FALSE, digits = 4)
    )
  }

  if ("p_value_adj" %in% names(results)) {
    results$p_value_adj <- ifelse(
      results$p_value_adj < 0.001,
      format(results$p_value_adj, scientific = TRUE, digits = 3),
      format(results$p_value_adj, scientific = FALSE, digits = 4)
    )
  }

  return(results)
}
