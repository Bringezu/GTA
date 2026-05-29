#' Launch MN Test Analysis Dashboard
#'
#' Launches the interactive Shiny dashboard for micronucleus test analysis.
#' The dashboard provides a user-friendly interface for:
#' \itemize{
#'   \item Browsing and selecting study folders and Excel files
#'   \item Previewing data before analysis
#'   \item Configuring analysis parameters (control group, significance level)
#'   \item Running Mann-Whitney U tests with Holm-Bonferroni correction
#'   \item Viewing and exporting results (Excel, CSV, PDF)
#' }
#'
#' @return Launches the Shiny application
#' @export
#'
#' @examples
#' \dontrun{
#'   # Launch the dashboard
#'   launch_mn_dashboard()
#' }
launch_mn_dashboard <- function() {
  app_dir <- system.file("shiny-app", package = "GTA")

  if (app_dir == "" || !dir.exists(app_dir)) {
    stop(
      "Could not find shiny app directory. ",
      "Try re-installing the GTA package or check the installation path."
    )
  }

  message("Launching MN Test Analysis Dashboard...")
  shiny::runApp(app_dir, launch.browser = TRUE)
}
