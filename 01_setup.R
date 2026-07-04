###############################################################
# Mission Antyodaya Maharashtra Student-Teacher Ratio Analysis
#
# Author: Leina Louis
#
# Description:
# Shared setup, dependencies, constants, and helper functions for
# the reproducible Mission Antyodaya Maharashtra analysis workflow.
#
# Repository:
# mission-antyodaya-r-analysis
###############################################################

required_packages <- c(
  "boot",
  "broom",
  "dplyr",
  "ggplot2",
  "glmnet",
  "here",
  "MASS",
  "patchwork",
  "purrr",
  "readr",
  "stringr",
  "tibble",
  "tidyr"
)

missing_packages <- required_packages[
  !vapply(required_packages, requireNamespace, logical(1), quietly = TRUE)
]

if (length(missing_packages) > 0) {
  stop(
    "Install the following packages before running this project: ",
    paste(missing_packages, collapse = ", "),
    "\nFor long-term reproducibility, consider managing dependencies with renv.",
    call. = FALSE
  )
}

suppressPackageStartupMessages({
  library(boot)
  library(broom)
  library(dplyr)
  library(ggplot2)
  library(glmnet)
  library(here)
  library(patchwork)
  library(purrr)
  library(readr)
  library(stringr)
  library(tibble)
  library(tidyr)
})

stepAIC <- MASS::stepAIC

set.seed(2)

ensure_project_dirs <- function() {
  dirs <- list(
    here("data", "processed"),
    here("figures"),
    here("outputs", "tables")
  )

  invisible(lapply(dirs, dir.create, recursive = TRUE, showWarnings = FALSE))
}

save_table <- function(data, filename) {
  readr::write_csv(data, here("outputs", "tables", filename))
}

save_processed_data <- function(data, filename) {
  readr::write_csv(data, here("data", "processed", filename))
}

save_plot <- function(plot, filename, width = 9, height = 6) {
  ggplot2::ggsave(
    filename = here("figures", filename),
    plot = plot,
    width = width,
    height = height,
    dpi = 300
  )
}

safe_cor_squared <- function(actual, predicted) {
  complete <- complete.cases(actual, predicted)
  actual <- actual[complete]
  predicted <- predicted[complete]

  if (length(actual) < 2 || stats::sd(actual) == 0 || stats::sd(predicted) == 0) {
    return(NA_real_)
  }

  stats::cor(actual, predicted)^2
}

theme_colors <- c(
  "Education" = "#E6A8B5",
  "Health" = "#F4D35E",
  "Facilities" = "#A7C5EB",
  "Others" = "#8BAF9F"
)

cb_palette <- c(
  "#0072B2",
  "#D55E00",
  "#009E73",
  "#F0E442",
  "#CC79A7",
  "#56B4E9",
  "#E69F00",
  "#999999"
)

theme_set(
  theme_minimal(base_size = 11) +
    theme(
      plot.title = element_text(face = "bold"),
      panel.grid.minor = element_blank()
    )
)

themes_list <- list(
  Education = c(
    "availability_of_high_school",
    "availability_of_middle_school",
    "no_of_children_not_attending_sch",
    "total_minority_children_getting_",
    "availability_of_mid_day_meal_sch",
    "is_vocational_edu_centre_availab",
    "availability_of_adult_edu_centre",
    "availability_of_ssc_school",
    "is_early_childhood_edu_provided_",
    "availability_of_govt_degree_coll",
    "availability_of_primary_school",
    "availability_of_public_library"
  ),
  Health = c(
    "total_no_of_pregnant_women",
    "total_no_of_women_delivered_babi",
    "total_anemic_pregnant_women",
    "total_no_of_newly_born_children",
    "total_no_of_newly_born_underweig",
    "total_underweight_child_age_unde",
    "total_no_of_lactating_mothers",
    "total_anemic_adolescent_girls",
    "phc",
    "sub_centre",
    "chc",
    "availability_of_mother_child_hea"
  ),
  Facilities = c(
    "total_hhd_having_piped_water_con",
    "no_electricity",
    "is_bank_available",
    "public_transport",
    "telephone_services",
    "is_broadband_available",
    "weekly_haat",
    "any_primary_sch_toilet",
    "is_primary_school_with_computer_",
    "is_village_connected_to_all_weat",
    "is_atm_available",
    "recreational_centre"
  ),
  Others = c(
    "total_hhd_having_bpl_cards",
    "gp_total_hhd_receiving_food_grai",
    "total_hhd_availing_pmjdy_bank_ac",
    "total_hhd_registered_under_pmjay",
    "total_no_of_beneficiaries_receiv",
    "total_no_of_farmers_received_ben",
    "total_shg",
    "total_shg_accessed_bank_loans",
    "total_hhd_having_pmsbhgy_benefit",
    "total_hhd_got_benefit_under_stat",
    "gp_total_no_of_eligible_benefici",
    "total_no_of_farmers_subscribed_a"
  )
)

all_variables <- unlist(themes_list, use.names = FALSE)

ensure_project_dirs()
