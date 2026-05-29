# File utility functions for MN Test Analysis Dashboard

#' Validate directory path
#'
#' @param path Directory path to validate
#' @return List with status (TRUE/FALSE) and message
validate_directory <- function(path) {
  if (is.null(path) || path == "") {
    return(list(valid = FALSE, message = "Please enter a directory path"))
  }

  if (!dir.exists(path)) {
    return(list(valid = FALSE, message = "Directory does not exist"))
  }

  if (!file.access(path, mode = 4) == 0) {
    return(list(valid = FALSE, message = "Directory is not readable"))
  }

  return(list(valid = TRUE, message = "Directory is valid"))
}

#' List subdirectories in a path
#'
#' @param root_path Root directory path
#' @return Character vector of subdirectory names
list_study_folders <- function(root_path) {
  if (!dir.exists(root_path)) {
    return(character(0))
  }

  all_items <- list.files(root_path, full.names = FALSE, include.dirs = TRUE)

  # Filter to only directories
  dirs <- all_items[file.info(file.path(root_path, all_items))$isdir]

  # Remove hidden directories
  dirs <- dirs[!startsWith(dirs, ".")]

  return(sort(dirs))
}

#' List Excel files in a directory
#'
#' @param dir_path Directory path
#' @return Character vector of Excel filenames
list_excel_files <- function(dir_path) {
  if (!dir.exists(dir_path)) {
    return(character(0))
  }

  files <- list.files(
    dir_path,
    pattern = "\\.(xlsx|xls)$",
    full.names = FALSE,
    ignore.case = TRUE
  )

  return(sort(files))
}

#' Load Excel sheet
#'
#' @param file_path Full path to Excel file
#' @param sheet Sheet number or name (default: 2)
#' @return Data frame with Excel data
#' @importFrom readxl read_excel
load_xlsx_sheet <- function(file_path, sheet = 2) {
  if (!file.exists(file_path)) {
    stop("File does not exist: ", file_path)
  }

  tryCatch({
    data <- readxl::read_excel(file_path, sheet = sheet)
    return(as.data.frame(data))
  }, error = function(e) {
    stop("Error reading Excel file: ", e$message)
  })
}

#' Validate MN data structure
#'
#' @param data Data frame to validate
#' @return List with valid (TRUE/FALSE) and message
validate_mn_data <- function(data) {
  if (is.null(data) || nrow(data) == 0) {
    return(list(valid = FALSE, message = "Data is empty"))
  }

  required_cols <- c("GroupNumber", "Group", "MN")
  missing_cols <- setdiff(required_cols, names(data))

  if (length(missing_cols) > 0) {
    return(list(
      valid = FALSE,
      message = paste("Missing required columns:", paste(missing_cols, collapse = ", "))
    ))
  }

  return(list(valid = TRUE, message = "Data structure is valid"))
}
