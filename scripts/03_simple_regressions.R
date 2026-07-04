###############################################################
# Mission Antyodaya Maharashtra Student-Teacher Ratio Analysis
#
# Author: Leina Louis
#
# Description:
# Runs district-level simple regressions for each thematic predictor
# and exports significant-variable tables and figures.
#
# Repository:
# mission-antyodaya-r-analysis
###############################################################

run_simple_regression <- function(data, variable) {
  if (!variable %in% names(data)) {
    return(NULL)
  }

  x <- data[[variable]]
  if (all(is.na(x)) || length(unique(na.omit(x))) < 2) {
    return(NULL)
  }

  model_data <- data
  if (length(unique(na.omit(x))) <= 2) {
    model_data[[variable]] <- factor(x)
  }

  model <- lm(as.formula(paste("str ~", variable)), data = model_data)
  sm <- summary(model)

  data.frame(
    variable = variable,
    estimate = sm$coefficients[2, 1],
    p_value = sm$coefficients[2, 4],
    adj_r2 = sm$adj.r.squared,
    rmse = sqrt(mean((model_data$str - predict(model, model_data))^2)),
    row.names = NULL
  )
}

simple_results <- map_dfr(unique(training$district_name), function(district) {
  district_data <- training |>
    filter(district_name == district)

  map_dfr(names(themes_list), function(theme_name) {
    map_dfr(themes_list[[theme_name]], function(variable) {
      result <- run_simple_regression(district_data, variable)

      if (!is.null(result)) {
        result |>
          mutate(district = district, theme = theme_name)
      }
    })
  })
})

significant_simple_results <- simple_results |>
  filter(p_value <= 0.05) |>
  arrange(district, theme, variable)

save_table(simple_results, "simple_regression_all_results.csv")
save_table(significant_simple_results, "simple_regression_significant_results.csv")

theme_wide_names <- significant_simple_results |>
  group_by(district, theme) |>
  summarise(variables = paste(variable, collapse = ", "), .groups = "drop") |>
  pivot_wider(names_from = theme, values_from = variables, values_fill = "-") |>
  arrange(district)

save_table(theme_wide_names, "significant_variables_by_district_theme.csv")

variable_frequency <- significant_simple_results |>
  group_by(theme, variable) |>
  summarise(
    frequency = n(),
    avg_estimate = mean(estimate),
    avg_adj_r2 = mean(adj_r2),
    .groups = "drop"
  ) |>
  arrange(theme, desc(frequency))

top_vars_per_theme <- variable_frequency |>
  group_by(theme) |>
  slice_max(order_by = frequency, n = 6, with_ties = FALSE) |>
  ungroup() |>
  arrange(theme, desc(frequency))

save_table(variable_frequency, "significant_variable_frequency.csv")
save_table(top_vars_per_theme, "top_significant_variables_by_theme.csv")

for (district_name_value in unique(significant_simple_results$district)) {
  district_data <- significant_simple_results |>
    filter(.data$district == district_name_value)

  p <- ggplot(district_data, aes(x = reorder(variable, estimate), y = estimate, fill = theme)) +
    geom_col() +
    coord_flip() +
    scale_fill_manual(values = theme_colors) +
    labs(
      title = paste("Significant Simple Regression Predictors in", district_name_value),
      x = "Variable",
      y = "Estimate",
      fill = "Theme"
    ) +
    theme(axis.text.y = element_text(size = 7))

  save_plot(
    p,
    paste0("simple_significant_", make.names(district_name_value), ".png"),
    width = 9,
    height = 7
  )
}
