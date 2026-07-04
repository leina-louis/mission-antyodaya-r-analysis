###############################################################
# Output Validation Script
#
# Purpose:
# Validate that analysis outputs are sensible and
# complete before considering a run successful
###############################################################

cat("\n=== VALIDATING ANALYSIS OUTPUTS ===\n\n")

if (!requireNamespace("here", quietly = TRUE)) {
  stop("Install the 'here' package first: install.packages('here')")
}

library(here)

# Helper function: check file exists and has content
check_file_exists <- function(path, description) {
  full_path <- here(path)
  if (!file.exists(full_path)) {
    cat("✗ MISSING:", description, "(", path, ")\n")
    return(FALSE)
  }
  file_size <- file.size(full_path)
  if (file_size == 0) {
    cat("✗ EMPTY:", description, "(", path, ")\n")
    return(FALSE)
  }
  cat("✓", description, "(" , file_size, "bytes )\n")
  return(TRUE)
}

# Helper function: check if CSV has expected columns
check_csv_structure <- function(path, expected_cols, description) {
  full_path <- here(path)
  if (!file.exists(full_path)) {
    cat("✗ FILE NOT FOUND:", description, "\n")
    return(FALSE)
  }

  tryCatch(
    {
      data <- readr::read_csv(full_path, show_col_types = FALSE)
      missing_cols <- setdiff(expected_cols, colnames(data))

      if (length(missing_cols) > 0) {
        cat("✗ MISSING COLUMNS in", description, ":", paste(missing_cols, collapse = ", "), "\n")
        return(FALSE)
      }

      cat("✓", description, "structure OK (", nrow(data), "rows,", ncol(data), "cols )\n")
      return(TRUE)
    },
    error = function(e) {
      cat("✗ ERROR reading", description, ":", e$message, "\n")
      return(FALSE)
    }
  )
}

# --- Validation Checks ---

cat("1. Checking output directories...\n")
all_ok <- TRUE

all_ok <- all_ok & check_file_exists("output/tables", "Tables directory")
all_ok <- all_ok & check_file_exists("data/processed", "Processed data directory")

cat("\n2. Checking processed data...\n")

# Cleaned Maharashtra dataset should exist
all_ok <- all_ok & check_csv_structure(
  "data/processed/maharashtra_cleaned.csv",
  c("district", "str", "village"),
  "Cleaned Maharashtra dataset"
)

# Read it for deeper checks
tryCatch(
  {
    maha_data <- readr::read_csv(
      here("data/processed/maharashtra_cleaned.csv"),
      show_col_types = FALSE
    )

    # Check for reasonable STR ranges
    str_values <- maha_data$str
    str_min <- min(str_values, na.rm = TRUE)
    str_max <- max(str_values, na.rm = TRUE)
    str_mean <- mean(str_values, na.rm = TRUE)

    if (str_min < 0 || str_max > 200) {
      cat("✗ STR values out of expected range [0-200]:", str_min, "to", str_max, "\n")
      all_ok <- FALSE
    } else {
      cat("✓ STR values in valid range:", str_min, "to", str_max, "(mean:", round(str_mean, 2), ")\n")
    }

    # Check for required number of districts
    n_districts <- length(unique(maha_data$district))
    if (n_districts < 32) {
      cat("✗ Expected ~33 districts, found", n_districts, "\n")
      all_ok <- FALSE
    } else {
      cat("✓ Found", n_districts, "districts\n")
    }
  },
  error = function(e) {
    cat("✗ Error reading cleaned data:", e$message, "\n")
    all_ok <<- FALSE
  }
)

cat("\n3. Checking regression output tables...\n")

# List expected table files (example patterns)
expected_tables <- c(
  "simple_regression_summary",
  "stepwise_regression_summary",
  "state_model_coefficients",
  "lasso_coefficients"
)

for (table_name in expected_tables) {
  table_file <- paste0("output/tables/", table_name, ".csv")
  check_file_exists(table_file, paste("Table:", table_name))
}

cat("\n4. Checking analysis figures...\n")

# List expected figure files
expected_figures <- c(
  "district_mean_str",
  "residuals_diagnostics",
  "state_model_predictions"
)

for (figure_name in expected_figures) {
  figure_file <- paste0("output/figures/", figure_name, ".png")
  check_file_exists(figure_file, paste("Figure:", figure_name))
}

cat("\n5. Checking reproducibility metadata...\n")
check_file_exists("output/reproducibility_metadata.json", "Session metadata")

cat("\n=== VALIDATION SUMMARY ===\n")
if (all_ok) {
  cat("✓ All critical outputs present and valid\n")
  cat("✓ Analysis completed successfully\n")
  exit_code <- 0
} else {
  cat("✗ Some outputs are missing or invalid\n")
  cat("✗ Please review the analysis and re-run if needed\n")
  exit_code <- 1
}

cat("\n")
quit(save = "no", status = exit_code)
