###############################################################
# Mission Antyodaya Maharashtra Student-Teacher Ratio Analysis
#
# Author: Leina Louis
#
# Description:
# Compatibility wrapper for the modular analysis workflow.
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

source_file <- tryCatch(
  normalizePath(sys.frame(1)$ofile, winslash = "/", mustWork = FALSE),
  error = function(e) NA_character_
)

if (!is.na(source_file)) {
  setwd(dirname(dirname(source_file)))
}

here::i_am("run_analysis.R")
source(here::here("run_analysis.R"))
