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

#' Extract metadata from Sheet 1
#'
#' @param file_path Full path to Excel file
#' @return List with metadata (study_number, species, sex, test_item)
#' @importFrom readxl read_excel
extract_metadata <- function(file_path) {
  if (!file.exists(file_path)) {
    stop("File does not exist: ", file_path)
  }

  tryCatch({
    # Read Sheet 1 without column names to get specific cells
    sheet1 <- readxl::read_excel(file_path, sheet = 1, col_names = FALSE)

    # Extract specific cells
    metadata <- list(
      study_number = if (nrow(sheet1) >= 1 && ncol(sheet1) >= 1) as.character(sheet1[1, 2]) else NA,
      test_item = if (nrow(sheet1) >= 2 && ncol(sheet1) >= 1) as.character(sheet1[2, 2]) else NA,
      species = if (nrow(sheet1) >= 3 && ncol(sheet1) >= 2) as.character(sheet1[3, 2]) else NA,
      sex = if (nrow(sheet1) >= 3 && ncol(sheet1) >= 4) as.character(sheet1[3, 4]) else NA
    )

    # Clean up NA values
    metadata <- lapply(metadata, function(x) {
      if (is.na(x) || is.null(x) || x == "NA") {
        return("Not specified")
      }
      return(as.character(x))
    })

    return(metadata)
  }, error = function(e) {
    warning("Could not extract metadata from Sheet 1: ", e$message)
    return(list(
      study_number = "Not specified",
      test_item = "Not specified",
      species = "Not specified",
      sex = "Not specified"
    ))
  })
}

#' Load Excel sheet with metadata
#'
#' @param file_path Full path to Excel file
#' @param sheet Sheet number or name (default: 2)
#' @return List with data (data frame) and metadata (list)
#' @importFrom readxl read_excel
load_xlsx_sheet <- function(file_path, sheet = 2) {
  if (!file.exists(file_path)) {
    stop("File does not exist: ", file_path)
  }

  tryCatch({
    # Extract metadata from Sheet 1
    metadata <- extract_metadata(file_path)

    # Load data from Sheet 2
    data <- readxl::read_excel(file_path, sheet = sheet)
    data <- as.data.frame(data)

    # Standardize column names
    # Handle Group_num -> GroupNumber
    if ("Group_num" %in% names(data) && !"GroupNumber" %in% names(data)) {
      names(data)[names(data) == "Group_num"] <- "GroupNumber"
    }

    # Handle MN PCE -> MN
    if ("MN PCE" %in% names(data) && !"MN" %in% names(data)) {
      names(data)[names(data) == "MN PCE"] <- "MN"
    }

    # Fill down Group column if it exists but has missing values
    if ("Group" %in% names(data) && "GroupNumber" %in% names(data)) {
      # For each unique GroupNumber, fill down the Group name
      for (grp_num in unique(data$GroupNumber[!is.na(data$GroupNumber)])) {
        grp_rows <- which(data$GroupNumber == grp_num)
        if (length(grp_rows) > 0) {
          # Find the first non-NA Group value for this GroupNumber
          group_name <- data$Group[grp_rows][!is.na(data$Group[grp_rows])][1]
          if (!is.na(group_name)) {
            # Fill all rows with this GroupNumber
            data$Group[grp_rows] <- group_name
          }
        }
      }
    }

    # Return both data and metadata
    return(list(
      data = data,
      metadata = metadata
    ))
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

  # After standardization in load_xlsx_sheet, we expect GroupNumber and MN
  # Group column is optional (will be created if missing)
  required_cols <- c("GroupNumber", "MN")
  missing_cols <- setdiff(required_cols, names(data))

  if (length(missing_cols) > 0) {
    # Try to provide helpful feedback about original column names
    original_names <- names(data)
    if ("Group_num" %in% original_names) {
      message_add <- " (Note: Found 'Group_num' which should be standardized to 'GroupNumber')"
    } else if ("MN PCE" %in% original_names) {
      message_add <- " (Note: Found 'MN PCE' which should be standardized to 'MN')"
    } else {
      message_add <- paste0(" (Available columns: ", paste(original_names, collapse = ", "), ")")
    }

    return(list(
      valid = FALSE,
      message = paste0("Missing required columns: ", paste(missing_cols, collapse = ", "), message_add)
    ))
  }

  # If Group column doesn't exist, create it from GroupNumber
  if (!"Group" %in% names(data)) {
    data$Group <- paste("Group", data$GroupNumber)
  }

  return(list(valid = TRUE, message = "Data structure is valid"))
}
