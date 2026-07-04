###############################################################
# Mission Antyodaya Maharashtra Student-Teacher Ratio Analysis
#
# Author: Leina Louis
#
# Description:
# Main entry point for the reproducible analysis workflow.
#
# Repository:
# mission-antyodaya-r-analysis
###############################################################

if (!requireNamespace("here", quietly = TRUE)) {
  stop(
    "Install the here package before running this project: install.packages('here')",
    call. = FALSE
  )
}

# When sourced by absolute path, align the session with the repository root
# before asking here to anchor the project.
source_file <- tryCatch(
  normalizePath(sys.frame(1)$ofile, winslash = "/", mustWork = FALSE),
  error = function(e) NA_character_
)

if (is.na(source_file)) {
  file_arg <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(file_arg) > 0) {
    source_file <- normalizePath(sub("^--file=", "", file_arg[1]), winslash = "/", mustWork = FALSE)
  }
}

if (!is.na(source_file)) {
  setwd(dirname(source_file))
}

here::i_am("run_analysis.R")

source(here::here("scripts", "01_setup.R"))
source(here::here("scripts", "02_data_import_cleaning.R"))
source(here::here("scripts", "03_simple_regressions.R"))
source(here::here("scripts", "04_stepwise_models.R"))
source(here::here("scripts", "05_state_model.R"))
source(here::here("scripts", "06_lasso_model.R"))

writeLines(
  c(
    "Analysis complete.",
    "Tables were written to outputs/tables.",
    "Figures were written to figures.",
    "Cleaned Maharashtra data were written to data/processed/maharashtra_cleaned.csv."
  )
)
