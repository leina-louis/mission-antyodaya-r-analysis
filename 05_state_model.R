###############################################################
# Mission Antyodaya Maharashtra Student-Teacher Ratio Analysis
#
# Author: Leina Louis
#
# Description:
# Fits the state-level regression model with district effects, exports
# coefficient tables, diagnostics, and bootstrap confidence intervals.
#
# Repository:
# mission-antyodaya-r-analysis
###############################################################

state_data <- maharashtra |>
  mutate(
    student_teacher_ratio = str,
    district_name = factor(district_name)
  )

all_predictors <- all_variables[all_variables %in% names(state_data)]
missing_predictors <- setdiff(all_variables, names(state_data))

if (length(missing_predictors) > 0) {
  message(
    "These predictors were missing and removed from state-level models: ",
    paste(missing_predictors, collapse = ", ")
  )
}

continuous_vars <- all_predictors[
  vapply(
    state_data[all_predictors],
    function(x) length(unique(na.omit(x))) > 2,
    logical(1)
  )
]

state_data_scaled <- state_data |>
  mutate(across(all_of(continuous_vars), ~ as.numeric(scale(.x))))

state_formula <- as.formula(
  paste("student_teacher_ratio ~", paste(all_predictors, collapse = " + "), "+ district_name")
)

state_model <- lm(state_formula, data = state_data_scaled)
state_model_aug <- broom::augment(state_model)
state_coef_tbl <- broom::tidy(state_model, conf.int = TRUE)

save_table(broom::glance(state_model), "state_model_fit.csv")
save_table(state_coef_tbl, "state_model_coefficients.csv")

state_residual_plot <- ggplot(state_model_aug, aes(x = .fitted, y = .resid)) +
  geom_point(alpha = 0.6, color = cb_palette[1]) +
  geom_hline(yintercept = 0, linetype = "dashed", color = cb_palette[8]) +
  labs(
    title = "Residuals vs Fitted Values: State-Level Model",
    x = "Fitted values",
    y = "Residuals"
  )

save_plot(state_residual_plot, "state_level_residuals_vs_fitted.png", width = 8, height = 5)

sig_predictors <- state_coef_tbl |>
  filter(p.value < 0.05, !str_detect(term, "district_name"), term != "(Intercept)")

save_table(sig_predictors, "state_model_significant_predictors.csv")

state_coef_plot <- ggplot(sig_predictors, aes(x = reorder(term, estimate), y = estimate)) +
  geom_point(color = cb_palette[2], size = 3) +
  geom_errorbar(aes(ymin = conf.low, ymax = conf.high), width = 0.2, color = cb_palette[8]) +
  coord_flip() +
  labs(
    title = "Significant Predictors of Student-Teacher Ratio",
    x = "Predictor variable",
    y = "Standardised coefficient estimate"
  )

save_plot(state_coef_plot, "state_level_coefficients_scaled.png", width = 9, height = 6)

district_effects <- state_coef_tbl |>
  filter(str_detect(term, "district_name")) |>
  mutate(district_clean = str_replace(term, "district_name", ""))

save_table(district_effects, "state_model_district_effects.csv")

district_effects_plot <- ggplot(district_effects, aes(x = reorder(district_clean, estimate), y = estimate)) +
  geom_point(color = cb_palette[3], size = 3) +
  geom_errorbar(aes(ymin = conf.low, ymax = conf.high), width = 0.2, color = cb_palette[8]) +
  coord_flip() +
  labs(
    title = "District-Level Effects",
    x = "District",
    y = "Coefficient estimate"
  )

save_plot(district_effects_plot, "state_level_district_effects.png", width = 9, height = 6)

boot_fn <- function(data, indices) {
  d <- data[indices, ]
  coef(lm(state_formula, data = d))
}

set.seed(123)
boot_results <- boot(state_data_scaled, boot_fn, R = 500)

boot_cis <- tibble(
  term = names(coef(state_model)),
  boot_ci_low = apply(boot_results$t, 2, quantile, 0.025, na.rm = TRUE),
  boot_ci_high = apply(boot_results$t, 2, quantile, 0.975, na.rm = TRUE)
) |>
  filter(term %in% sig_predictors$term, term != "(Intercept)")

save_table(boot_cis, "state_model_bootstrap_ci.csv")

bootstrap_plot <- ggplot(
  boot_cis,
  aes(x = reorder(term, boot_ci_low), y = (boot_ci_low + boot_ci_high) / 2)
) +
  geom_point(color = cb_palette[4], size = 3) +
  geom_errorbar(aes(ymin = boot_ci_low, ymax = boot_ci_high), width = 0.3, color = cb_palette[8]) +
  coord_flip() +
  labs(
    title = "Bootstrap 95% Confidence Intervals",
    x = "Predictor variable",
    y = "Confidence interval midpoint"
  )

save_plot(bootstrap_plot, "state_level_bootstrap_ci_scaled.png", width = 9, height = 6)

for (variable in head(continuous_vars, 3)) {
  original_plot <- ggplot(state_data, aes(x = .data[[variable]])) +
    geom_histogram(bins = 30, fill = cb_palette[8], color = "white") +
    labs(title = paste("Before Scaling:", variable), x = variable, y = "Count")

  scaled_plot <- ggplot(state_data_scaled, aes(x = .data[[variable]])) +
    geom_histogram(bins = 30, fill = cb_palette[6], color = "white") +
    labs(title = paste("After Scaling:", variable), x = variable, y = "Count")

  save_plot(
    original_plot + scaled_plot,
    paste0("transform_", make.names(variable), ".png"),
    width = 9,
    height = 4
  )
}
