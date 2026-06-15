# Input validation functions for MN Test Analysis Dashboard

#' Validate control group parameter
#'
#' @param control_group Control group number
#' @param data Data frame containing GroupNumber column
#' @return List with valid (TRUE/FALSE) and message
validate_control_group <- function(control_group, data) {
  if (is.null(control_group) || is.na(control_group)) {
    return(list(valid = FALSE, message = "Control group cannot be empty"))
  }

  if (!is.numeric(control_group)) {
    return(list(valid = FALSE, message = "Control group must be a number"))
  }

  if (control_group <= 0) {
    return(list(valid = FALSE, message = "Control group must be positive"))
  }

  if (!is.null(data) && "Group_num" %in% names(data)) {
    available_groups <- unique(data$GroupNumber)
    if (!(control_group %in% available_groups)) {
      return(list(
        valid = FALSE,
        message = paste0(
          "Control group ", control_group, " not found in data. ",
          "Available groups: ", paste(available_groups, collapse = ", ")
        )
      ))
    }
  }

  return(list(valid = TRUE, message = "Control group is valid"))
}

#' Validate significance level parameter
#'
#' @param sig_level Significance level (alpha)
#' @return List with valid (TRUE/FALSE) and message
validate_sig_level <- function(sig_level) {
  if (is.null(sig_level) || is.na(sig_level)) {
    return(list(valid = FALSE, message = "Significance level cannot be empty"))
  }

  if (!is.numeric(sig_level)) {
    return(list(valid = FALSE, message = "Significance level must be a number"))
  }

  if (sig_level <= 0 || sig_level >= 1) {
    return(list(valid = FALSE, message = "Significance level must be between 0 and 1"))
  }

  return(list(valid = TRUE, message = "Significance level is valid"))
}

#' Validate analysis parameters
#'
#' @param control_group Control group number
#' @param sig_level Significance level
#' @param data Data frame (optional)
#' @return List with valid (TRUE/FALSE) and message
validate_analysis_params <- function(control_group, sig_level, data = NULL) {
  # Validate control group
  control_result <- validate_control_group(control_group, data)
  if (!control_result$valid) {
    return(control_result)
  }

  # Validate significance level
  sig_result <- validate_sig_level(sig_level)
  if (!sig_result$valid) {
    return(sig_result)
  }

  return(list(valid = TRUE, message = "All parameters are valid"))
}
