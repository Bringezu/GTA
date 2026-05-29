# MN Test Analysis Dashboard - Quick Start Guide

## 5-Minute Setup

### Step 1: Verify Installation (1 minute)

Open R or RStudio and run:

```r
source("verify_installation.R")
```

This will check:
- R version
- Required packages
- Directory structure
- Critical files

### Step 2: Install Missing Packages (2 minutes)

If verification shows missing packages, install them:

```r
install.packages(c(
  "shiny", "shinydashboard", "DT", "yaml", "shinyjs",
  "rmarkdown", "knitr", "readxl", "coin", "dplyr", "writexl"
))
```

### Step 3: Launch the Dashboard (1 minute)

**Option A: Direct launch from source**

```r
shiny::runApp("inst/shiny-app")
```

**Option B: Install package and use launch function**

```r
# Install the package
install.packages(".", repos = NULL, type = "source")

# Load and launch
library(GTA)
launch_mn_dashboard()
```

### Step 4: Initial Configuration (1 minute)

1. The dashboard opens in your browser
2. Go to **Configuration** tab
3. Enter your data directory path (e.g., `G:/R_Statistik`)
4. Click "Save Configuration"

**You're ready to analyze data!**

---

## First Analysis (5 minutes)

### 1. Select Data (1 minute)
- Go to **Data Selection** tab
- Choose a study folder
- Choose an Excel file

### 2. Preview Data (1 minute)
- Go to **Data Preview** tab
- Click "Load Data"
- Verify the data looks correct

### 3. Run Analysis (1 minute)
- Go to **Analysis** tab
- Set control group (usually 1)
- Set significance level (usually 0.05)
- Click "Run Analysis"

### 4. View Results (1 minute)
- Go to **Results** tab
- Review the results table
- Significant results are highlighted

### 5. Export Results (1 minute)
- Click "Download Excel" for spreadsheet
- Click "Download CSV" for text format
- Click "Download PDF Report" for formatted report

---

## Troubleshooting

### Dashboard won't launch
```r
# Try direct launch
shiny::runApp("inst/shiny-app")

# Check for errors in R console
```

### Missing packages
```r
# Install all at once
install.packages(c("shiny", "shinydashboard", "DT", "yaml", "shinyjs",
                   "rmarkdown", "knitr", "readxl", "coin", "dplyr", "writexl"))
```

### "Directory not found"
- Use absolute path (e.g., `C:/Data` not `./Data`)
- Use forward slashes `/` or double backslashes `\\`
- Check spelling and capitalization

### "Missing required columns"
- Ensure Sheet 2 has: `GroupNumber`, `Group`, `MN`
- Column names are case-sensitive
- Check for typos

---

## Data Format

Your Excel files should have **Sheet 2** with these columns:

| GroupNumber | Group       | MN   |
|-------------|-------------|------|
| 1           | Control     | 2.5  |
| 1           | Control     | 3.1  |
| 2           | Treatment 1 | 4.2  |
| 2           | Treatment 1 | 3.8  |

**Required:**
- `GroupNumber`: Numeric (1, 2, 3, ...)
- `Group`: Text description
- `MN`: Numeric micronucleus count

---

## Keyboard Shortcuts

- **Ctrl+F**: Search in tables
- **Ctrl+C**: Copy from tables
- **ESC**: Close dialogs

---

## Tips

1. **Save time**: Configure defaults in the Configuration tab
2. **Check data first**: Always preview before analyzing
3. **Export early**: Download results immediately after analysis
4. **Multiple analyses**: You can change files without restarting
5. **PDF reports**: Best for documentation and regulatory submission

---

## Common Workflows

### Compare Male and Female Data

1. Select and analyze male file
2. Export results as `results_male.xlsx`
3. Select and analyze female file
4. Export results as `results_female.xlsx`
5. Compare in Excel or your preferred tool

### Batch Analysis

1. Create list of files to analyze
2. For each file:
   - Select file
   - Preview data
   - Run analysis
   - Export results
3. Collect all exports in one folder

### Quality Control

1. Preview data for each file
2. Check row counts match expected
3. Verify group numbers are correct
4. Look for outliers in preview table
5. Document any data issues

---

## Getting Help

- **Documentation**: See `INSTALLATION_GUIDE.md` for detailed instructions
- **About Tab**: Click the About tab in the dashboard for help
- **README**: See `inst/shiny-app/README.md` for detailed usage
- **Console**: Check R console for error messages

---

## Next Steps

Once comfortable with basic usage:

1. Read the full `INSTALLATION_GUIDE.md`
2. Review `inst/shiny-app/README.md` for advanced features
3. Customize default settings in Configuration tab
4. Set up your preferred directory structure

---

**Quick Reference:**

| Tab | Purpose | Key Action |
|-----|---------|------------|
| Configuration | Setup | Set data directory |
| Data Selection | Choose file | Select study and file |
| Data Preview | Check data | Load and verify |
| Analysis | Run tests | Click "Run Analysis" |
| Results | Export | Download results |

---

**Version**: 1.0.0
**Need Help?** See `INSTALLATION_GUIDE.md` for troubleshooting
