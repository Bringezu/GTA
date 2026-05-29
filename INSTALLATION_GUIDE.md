# MN Test Analysis Dashboard - Installation Guide

This guide provides step-by-step instructions for installing and running the MN Test Analysis Shiny Dashboard.

## Prerequisites

- R version 4.0.0 or higher
- RStudio (recommended but not required)
- Network or local access to MN test data directory

## Installation Steps

### Step 1: Install Required R Packages

Open R or RStudio and run the following command to install all required dependencies:

```r
install.packages(c(
  "shiny",
  "shinydashboard",
  "DT",
  "yaml",
  "shinyjs",
  "rmarkdown",
  "knitr",
  "readxl",
  "coin",
  "dplyr",
  "writexl"
))
```

This will install:
- **shiny**: Web application framework
- **shinydashboard**: Dashboard layout components
- **DT**: Interactive tables
- **yaml**: Configuration file handling
- **shinyjs**: JavaScript functionality
- **rmarkdown** & **knitr**: PDF report generation
- **readxl**: Excel file reading
- **coin**: Statistical tests (Mann-Whitney U)
- **dplyr**: Data manipulation
- **writexl**: Excel file writing

### Step 2: Install the GTA Package

If the GTA package is available in a repository or as a source:

```r
# From CRAN (if published)
install.packages("GTA")

# From source (if you have the package files)
install.packages("path/to/GTA", repos = NULL, type = "source")

# Using devtools (if in a Git repository)
devtools::install_github("username/GTA")

# Using local source
install.packages("C:/Users/M148068", repos = NULL, type = "source")
```

### Step 3: Verify Installation

Check that the package is installed correctly:

```r
library(GTA)
?launch_mn_dashboard
```

## Running the Dashboard

### Method 1: Using the Launch Function (Recommended)

```r
library(GTA)
launch_mn_dashboard()
```

This will:
1. Locate the Shiny app within the installed package
2. Launch the dashboard in your default web browser
3. Display the Configuration tab

### Method 2: Running from Source Directory

If you're developing or testing from the source directory:

```r
shiny::runApp("C:/Users/M148068/inst/shiny-app")
```

Or navigate to the directory and run:

```r
setwd("C:/Users/M148068/inst/shiny-app")
shiny::runApp()
```

## Initial Configuration

### 1. Set Up Data Directory

1. Launch the dashboard
2. Go to the **Configuration** tab
3. Enter the absolute path to your data directory

**Example paths:**
- Windows network drive: `G:/R_Statistik` or `G:\\R_Statistik`
- Windows local drive: `C:/Data/R-Statistik` or `C:\\Data\\R-Statistik`
- Linux/Mac: `/home/user/data/R-Statistik`

4. Click "Save Configuration"
5. Verify that the status shows "Valid"

### 2. Configure Default Settings (Optional)

- **Default Control Group**: Typically 1 (the control group number)
- **Default Significance Level**: Typically 0.05 (α = 5%)
- **Excel Sheet Number**: Typically 2 (Sheet 2 contains MN data)

Click "Save Defaults" to save these settings.

## Data Directory Structure

Ensure your data directory follows this structure:

```
Root Directory (e.g., G:/R_Statistik)
├── Study1/
│   ├── file1.xlsx
│   └── file2.xlsx
├── Study2/
│   ├── data_female.xlsx
│   └── data_male.xlsx
└── Study3/
    └── analysis.xlsx
```

Each Excel file should have:
- **Sheet 2** containing MN test data
- **Required columns**: `GroupNumber`, `Group`, `MN`

## Testing the Installation

### Quick Test

1. **Configuration Tab**
   - Enter a valid data directory path
   - Click "Save Configuration"
   - Verify status shows "Valid"

2. **Data Selection Tab**
   - Select a study folder
   - Select an Excel file
   - Verify file path is displayed

3. **Data Preview Tab**
   - Click "Load Data"
   - Verify data table displays
   - Check that row count, group count show correct values

4. **Analysis Tab**
   - Set control group (e.g., 1)
   - Set significance level (e.g., 0.05)
   - Click "Run Analysis"
   - Verify status shows "Analysis completed successfully"

5. **Results Tab**
   - View results table
   - Check that significant results are highlighted
   - Test Excel download
   - Test CSV download
   - Test PDF report generation

## Troubleshooting

### Problem: "Could not find shiny app directory"

**Solution:**
- The package may not be installed correctly
- Reinstall the package: `install.packages("path/to/GTA", repos = NULL, type = "source")`
- Or use Method 2 to run directly from source

### Problem: "Package 'X' is not installed"

**Solution:**
- Install the missing package: `install.packages("X")`
- Or install all dependencies from Step 1

### Problem: "Directory does not exist" or "Directory is not readable"

**Solution:**
- Check that the path is absolute (not relative)
- Verify spelling and use of slashes (forward slash `/` preferred)
- Ensure you have read permissions for the directory
- For Windows network drives, ensure the drive is mapped and accessible

### Problem: Analysis fails with "Control group not found"

**Solution:**
- Verify that Sheet 2 contains a `GroupNumber` column
- Check that the control group number (e.g., 1) exists in the data
- Preview the data to see available groups

### Problem: "Missing required columns"

**Solution:**
- Ensure Sheet 2 has columns named exactly: `GroupNumber`, `Group`, `MN`
- Column names are case-sensitive
- Check for extra spaces in column names

### Problem: PDF report generation fails

**Solution:**
- Ensure `rmarkdown` and `knitr` packages are installed
- For Windows, ensure MiKTeX or TinyTeX is installed for PDF generation:
  ```r
  install.packages("tinytex")
  tinytex::install_tinytex()
  ```
- For Linux/Mac, ensure LaTeX is installed

### Problem: Excel export fails

**Solution:**
- Ensure `writexl` package is installed: `install.packages("writexl")`
- Check that you have write permissions in the download directory

## Performance Notes

- **Loading data**: Typically completes in 1-2 seconds for files with < 1000 rows
- **Running analysis**: Typically completes in 2-5 seconds for datasets with 50-100 rows
- **Large datasets** (> 500 rows): May take longer, progress indicators will show status

## System Requirements

### Minimum
- R 4.0.0
- 4 GB RAM
- Modern web browser (Chrome, Firefox, Edge, Safari)

### Recommended
- R 4.2.0 or higher
- 8 GB RAM
- Chrome or Firefox browser
- SSD storage for faster data loading

## Security Notes

- The dashboard stores configuration in a local YAML file (`config/user_config.yml`)
- No data is transmitted over the network
- All analysis is performed locally on your machine
- Configuration file contains only directory paths and settings (no sensitive data)

## Getting Help

If you encounter issues:

1. Check this troubleshooting guide
2. Review the README.md in `inst/shiny-app/README.md`
3. Check R console for error messages
4. Verify all dependencies are installed correctly
5. Contact the package maintainer

## Updating the Dashboard

To update to a new version:

```r
# Remove old version
remove.packages("GTA")

# Install new version
install.packages("path/to/new/GTA", repos = NULL, type = "source")

# Restart R session
.rs.restartR()  # In RStudio
# Or restart R manually

# Launch updated dashboard
library(GTA)
launch_mn_dashboard()
```

## Uninstallation

To remove the dashboard:

```r
# Remove package
remove.packages("GTA")

# Optional: Remove configuration file
file.remove("inst/shiny-app/config/user_config.yml")
```

---

**Version**: 1.0.0
**Last Updated**: 2024-01-01
