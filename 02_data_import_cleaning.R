###############################################################
# Mission Antyodaya Maharashtra Student-Teacher Ratio Analysis
#
# Author: Leina Louis
#
# Description:
# Imports Mission Antyodaya and SHRID location data, constructs the
# Maharashtra analytical sample, computes student-teacher ratio, and
# creates the reproducible train/test split.
#
# Repository:
# mission-antyodaya-r-analysis
###############################################################

read_raw_data <- function(
  antyodaya_path = here("data", "raw", "antyodaya_shrid.csv"),
  location_path = here("data", "raw", "shrid_loc_names.csv")
) {
  if (!file.exists(antyodaya_path) || !file.exists(location_path)) {
    stop(
      "Raw data files were not found. Place antyodaya_shrid.csv and ",
      "shrid_loc_names.csv in data/raw/ before running this script.",
      call. = FALSE
    )
  }

  antyodaya <- read_csv(antyodaya_path, show_col_types = FALSE)
  locations <- read_csv(location_path, show_col_types = FALSE)

  required_antyodaya_cols <- c(
    "shrid2",
    "total_primary_school_students",
    "total_primary_school_teachers"
  )
  required_location_cols <- c(
    "shrid2",
    "district_name",
    "subdistrict_name",
    "village_name"
  )

  missing_antyodaya_cols <- setdiff(required_antyodaya_cols, names(antyodaya))
  missing_location_cols <- setdiff(required_location_cols, names(locations))

  if (length(missing_antyodaya_cols) > 0 || length(missing_location_cols) > 0) {
    stop(
      "The raw files are present, but required columns are missing.\n",
      "Missing from antyodaya_shrid.csv: ",
      paste(missing_antyodaya_cols, collapse = ", "),
      "\nMissing from shrid_loc_names.csv: ",
      paste(missing_location_cols, collapse = ", "),
      call. = FALSE
    )
  }

  list(antyodaya = antyodaya, locations = locations)
}

build_maharashtra_data <- function(antyodaya, locations) {
  antyodaya <- antyodaya |>
    mutate(shrid2 = as.character(shrid2))

  locations <- locations |>
    mutate(
      shrid2 = as.character(shrid2),
      district_name = tolower(as.character(district_name))
    )

  locations |>
    filter(grepl("^11-27", shrid2)) |>
    select(shrid2, district_name, subdistrict_name, village_name) |>
    filter(district_name != "mumbai suburban") |>
    left_join(antyodaya, by = "shrid2") |>
    mutate(
      total_primary_school_students = as.numeric(total_primary_school_students),
      total_primary_school_teachers = as.numeric(total_primary_school_teachers),
      str = if_else(
        total_primary_school_teachers > 0,
        total_primary_school_students / total_primary_school_teachers,
        NA_real_
      )
    ) |>
    filter(!is.na(str), is.finite(str), str >= 0, str <= 200)
}

raw_data <- read_raw_data()
maharashtra <- build_maharashtra_data(raw_data$antyodaya, raw_data$locations)

save_processed_data(maharashtra, "maharashtra_cleaned.csv")

training <- maharashtra |>
  group_by(district_name) |>
  slice_sample(prop = 0.7) |>
  ungroup()

test <- maharashtra |>
  filter(!shrid2 %in% training$shrid2)

mean_str <- maharashtra |>
  group_by(district_name) |>
  summarise(mean_str = mean(str, na.rm = TRUE), .groups = "drop") |>
  arrange(mean_str)

save_table(mean_str, "district_mean_str.csv")

mean_str_plot <- ggplot(mean_str, aes(x = reorder(district_name, mean_str), y = mean_str)) +
  geom_col(fill = "#B78B56") +
  coord_flip() +
  labs(
    title = "Average Student-Teacher Ratio Across Maharashtra Districts",
    x = "District",
    y = "Mean student-teacher ratio"
  )

save_plot(mean_str_plot, "district_mean_str.png", width = 8, height = 7)
