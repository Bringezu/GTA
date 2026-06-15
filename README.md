# MN Test Analysis Dashboard

A professional Shiny dashboard application for analyzing micronucleus (MN) test data using Mann-Whitney U tests with Holm-Bonferroni multiple comparison correction.

## Features

- **Configuration Management**: Set and save root directory path for data files
- **Study/File Selection**: Browse study folders and select Excel files
- **Data Preview**: Interactive preview of Excel data with filtering and search
- **Statistical Analysis**: Mann-Whitney U test with Holm-Bonferroni correction
- **Results Export**: Export to Excel, CSV, or PDF report

## Statistical Method

- **Test**: Mann-Whitney U test (Wilcoxon rank-sum test)
- **Implementation**: `coin::wilcox_test` with exact distribution
- **Multiple Testing Correction**: Holm-Bonferroni method
- **Comparison**: Each treatment group vs control group

## Installation

```r
# Install the GTA package
# (Instructions depend on your installation method)

# Install required dependencies
install.packages(c(
  "shiny", "shinydashboard", "DT", "yaml", "shinyjs",
  "rmarkdown", "knitr", "readxl", "coin", "dplyr", "writexl"
))
```

## Launching the Dashboard

### Method 1: Using the launch function (recommended)

```r
library(GTA)
launch_mn_dashboard()
```

### Method 2: Direct execution

```r
shiny::runApp("path/to/GTA/inst/shiny-app")
```

## Usage Workflow

### 1. Configuration

1. Navigate to the **Configuration** tab
2. Enter the absolute path to your root data directory (e.g., `G:/R_Statistik` or `C:/Data/R-Statistik`)
3. Click "Save Configuration"
4. Optionally configure default analysis settings

### 2. Data Selection

1. Navigate to the **Data Selection** tab
2. Select a study folder from the dropdown
3. Select an Excel file from the dropdown
4. The selected file path will be displayed

### 3. Data Preview

1. Navigate to the **Data Preview** tab
2. Click "Load Data" to preview Sheet 2 of the selected Excel file
3. Verify that the data contains required columns: `GroupNumber`, `Group`, `MN`
4. Use the search and filter options to explore the data

### 4. Analysis

1. Navigate to the **Analysis** tab
2. Set the control group number (default: 1)
3. Set the significance level (default: 0.05)
4. Review available groups in the dataset
5. Click "Run Analysis" to execute the statistical tests

### 5. Results

1. Navigate to the **Results** tab
2. View the analysis results in an interactive table
3. Export results using one of the download buttons:
   - **Excel**: Download as .xlsx file
   - **CSV**: Download as .csv file
   - **PDF**: Generate a formatted PDF report

## Data Structure

### Expected Directory Structure

```
Root Directory (e.g., G:/R_Statistik)
├── 21DA-0032/
│   ├── 21DA-0032_female.xlsx
│   └── 21DA-0032_male.xlsx
├── 22DA-0047/
│   ├── 22DA-0047_female.xlsx
│   └── 22DA-0047_male.xlsx
└── 23DA-0003/
    └── 23DA-0003_data.xlsx
```

### Expected Excel File Structure

- **Sheet 2** must contain MN test data
- **Required columns**:
  - `GroupNumber`: Numeric group identifier (e.g., 1, 2, 3)
  - `Group`: Text description of group (e.g., "Control", "Treatment 1")
  - `MN`: Micronucleus count values

Example:

| GroupNumber | Group       | MN  |
|-------------|-------------|-----|
| 1           | Control     | 2.5 |
| 1           | Control     | 3.1 |
| 2           | Treatment 1 | 4.2 |
| 2           | Treatment 1 | 3.8 |

## Output

### Analysis Results Table

The results table includes:

- **Comparison**: Groups being compared (e.g., "Group 2 vs 1")
- **GroupNumber**: Treatment group number
- **GroupName**: Treatment group name
- **Control_n**: Control group sample size
- **Control_Median**: Control group median
- **Control_Mean**: Control group mean
- **Control_SD**: Control group standard deviation
- **Treatment_n**: Treatment group sample size
- **Treatment_Median**: Treatment group median
- **Treatment_Mean**: Treatment group mean
- **Treatment_SD**: Treatment group standard deviation
- **p_value**: Raw p-value from Mann-Whitney U test
- **p_value_adj**: Adjusted p-value (Holm-Bonferroni correction)
- **Significance**: `*` if p_value_adj < significance level

### PDF Report

The PDF report includes:

- Study and file information
- Analysis parameters
- Formatted results table
- Summary statistics
- Statistical method description

## Troubleshooting

### Dashboard doesn't launch

- Check that all required packages are installed
- Verify the package installation path
- Try reinstalling the GTA package

### "Directory does not exist" error

- Ensure the root directory path is absolute (not relative)
- Check that you have read permissions for the directory
- Use forward slashes (/) or escaped backslashes (\\\\) in Windows paths

### "File does not exist" error

- Verify the Excel file exists in the selected study folder
- Check that the file has a .xlsx or .xls extension
- Ensure you have read permissions for the file

### "Missing required columns" error

- Ensure Sheet 2 of the Excel file contains columns: `GroupNumber`, `Group`, `MN`
- Check for typos in column names (case-sensitive)
- Verify that Sheet 2 is the correct sheet with MN data

### Analysis fails

- Verify that the control group exists in the dataset
- Check that there are treatment groups to compare against control
- Ensure MN values are numeric
- Check for NA values in critical columns

## Version Information

- **Version**: 1.0.0
- **R Version**: >= 4.0.0

## Support

For issues or questions, please contact the package maintainer or file an issue in the package repository.
