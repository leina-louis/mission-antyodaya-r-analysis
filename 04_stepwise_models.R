###############################################################
# Mission Antyodaya Maharashtra Student-Teacher Ratio Analysis
#
# Author: Leina Louis
#
# Description:
# Fits district-level stepwise regression models, evaluates test-set
# prediction performance, and exports diagnostics.
#
# Repository:
# mission-antyodaya-r-analysis
###############################################################

prepare_district_data <- function(data, variables) {
  existing_vars <- variables[variables %in% names(data)]

  prepared <- data |>
    select(shrid2, district_name, str, any_of(existing_vars))

  valid_cols <- c("shrid2", "district_name", "str")

  for (col in existing_vars) {
    col_data <- prepared[[col]]

    if (all(is.na(col_data))) {
      next
    }

    unique_vals <- unique(na.omit(col_data))
    if (length(unique_vals) < 2) {
      next
    }

    if (is.character(col_data)) {
      numeric_version <- suppressWarnings(as.numeric(col_data))
      if (sum(is.na(numeric_version)) < length(numeric_version) * 0.5) {
        prepared[[col]] <- numeric_version
      } else {
        next
      }
    }

    valid_cols <- c(valid_cols, col)
  }

  prepared |>
    select(all_of(valid_cols))
}

run_stepwise <- function(district_data, district_name) {
  predictor_cols <- setdiff(names(district_data), c("shrid2", "district_name", "str"))

  if (length(predictor_cols) == 0) {
    message("No valid predictors for ", district_name)
    return(NULL)
  }

  model_data <- district_data |>
    select(str, all_of(predictor_cols)) |>
    na.omit()

  if (nrow(model_data) < 10) {
    message("Not enough observations for ", district_name)
    return(NULL)
  }

  # Preserve the earlier safeguard against over-parameterising small district samples.
  max_predictors <- max(floor(nrow(model_data) / 10), 5)

  if (length(predictor_cols) > max_predictors) {
    adj_r2_values <- numeric(length(predictor_cols))
    names(adj_r2_values) <- predictor_cols

    for (predictor in predictor_cols) {
      temp_data <- model_data |>
        select(str, all_of(predictor)) |>
        na.omit()

      if (nrow(temp_data) >= 10 && length(unique(temp_data[[predictor]])) >= 2) {
        adj_r2_values[predictor] <- summary(lm(str ~ ., data = temp_data))$adj.r.squared
      }
    }

    predictor_cols <- names(sort(adj_r2_values, decreasing = TRUE))[seq_len(max_predictors)]
    predictor_cols <- predictor_cols[!is.na(predictor_cols)]

    model_data <- model_data |>
      select(str, all_of(predictor_cols)) |>
      na.omit()
  }

  full_formula <- as.formula(paste("str ~", paste(predictor_cols, collapse = " + ")))

  full_model <- tryCatch(
    lm(full_formula, data = model_data),
    error = function(e) {
      message("Error fitting model for ", district_name, ": ", e$message)
      NULL
    }
  )

  if (is.null(full_model)) {
    return(NULL)
  }

  tryCatch(
    stepAIC(full_model, direction = "both", trace = 0, k = 2),
    error = function(e) {
      message("Stepwise selection failed for ", district_name, ": ", e$message)
      full_model
    }
  )
}

extract_model_summary <- function(model, district_name) {
  sm <- summary(model)

  coefficients <- as.data.frame(sm$coefficients) |>
    rownames_to_column("variable") |>
    filter(variable != "(Intercept)") |>
    rename(
      estimate = Estimate,
      std_error = `Std. Error`,
      t_value = `t value`,
      p_value = `Pr(>|t|)`
    ) |>
    mutate(district = district_name)

  list(
    coefficients = coefficients,
    adj_r2 = sm$adj.r.squared,
    rmse = sqrt(mean(sm$residuals^2)),
    n_vars = nrow(coefficients),
    n_obs = nrow(model$model)
  )
}

training_prepared <- prepare_district_data(training, all_variables)
test_prepared <- prepare_district_data(test, all_variables)

district_models <- list()
district_summaries <- list()

for (district in unique(training_prepared$district_name)) {
  district_data <- training_prepared |>
    filter(district_name == district)

  model <- run_stepwise(district_data, district)

  if (!is.null(model)) {
    district_models[[district]] <- model
    district_summaries[[district]] <- extract_model_summary(model, district)
  }
}

stepwise_model_summary <- map_dfr(names(district_summaries), function(district) {
  tibble(
    district = district,
    adj_r2 = district_summaries[[district]]$adj_r2,
    rmse = district_summaries[[district]]$rmse,
    n_vars = district_summaries[[district]]$n_vars,
    n_obs = district_summaries[[district]]$n_obs
  )
})

stepwise_coefficients <- map_dfr(
  district_summaries,
  "coefficients",
  .id = "model_district"
) |>
  select(-model_district)

significant_stepwise_results <- stepwise_coefficients |>
  filter(p_value <= 0.05) |>
  arrange(district, variable)

save_table(stepwise_model_summary, "stepwise_model_summary.csv")
save_table(stepwise_coefficients, "stepwise_coefficients_all.csv")
save_table(significant_stepwise_results, "stepwise_significant_results.csv")

theme_lookup <- significant_simple_results |>
  distinct(variable, theme)

simple_plot_data <- significant_simple_results |>
  mutate(source = "Simple") |>
  select(district, variable, estimate, theme, source)

stepwise_plot_data <- significant_stepwise_results |>
  left_join(theme_lookup, by = "variable") |>
  mutate(source = "Stepwise") |>
  select(district, variable, estimate, theme, source)

for (district_name_value in unique(simple_plot_data$district)) {
  s_df <- simple_plot_data |>
    filter(.data$district == district_name_value)
  st_df <- stepwise_plot_data |>
    filter(.data$district == district_name_value)

  if (nrow(s_df) == 0 && nrow(st_df) == 0) {
    next
  }

  simple_plot <- ggplot(s_df, aes(x = reorder(variable, estimate), y = estimate, fill = theme)) +
    geom_col() +
    coord_flip() +
    scale_fill_manual(values = theme_colors, na.value = "#999999") +
    labs(
      title = paste("Simple Model Predictors in", district_name_value),
      x = "Variable",
      y = "Estimate",
      fill = "Theme"
    ) +
    theme(axis.text.y = element_text(size = 7))

  stepwise_plot <- ggplot(st_df, aes(x = reorder(variable, estimate), y = estimate, fill = theme)) +
    geom_col() +
    coord_flip() +
    scale_fill_manual(values = theme_colors, na.value = "#999999") +
    labs(
      title = paste("Stepwise Model Predictors in", district_name_value),
      x = "Variable",
      y = "Estimate",
      fill = "Theme"
    ) +
    theme(axis.text.y = element_text(size = 7))

  save_plot(
    simple_plot / stepwise_plot,
    paste0("simple_vs_stepwise_", make.names(district_name_value), ".png"),
    width = 10,
    height = 10
  )
}

sig_vars_by_district <- significant_stepwise_results |>
  select(district, variable) |>
  distinct()

variable_prediction_errors <- list()

for (district_name_value in unique(sig_vars_by_district$district)) {
  district_sig_vars <- sig_vars_by_district |>
    filter(.data$district == district_name_value)

  train_d <- training_prepared |>
    filter(.data$district_name == district_name_value)
  test_d <- test_prepared |>
    filter(.data$district_name == district_name_value)

  for (i in seq_len(nrow(district_sig_vars))) {
    variable <- district_sig_vars$variable[i]

    if (!variable %in% names(train_d) || !variable %in% names(test_d)) {
      next
    }

    train_df <- train_d |>
      select(str, all_of(variable)) |>
      na.omit()
    test_df <- test_d |>
      select(str, all_of(variable)) |>
      na.omit()

    if (nrow(train_df) < 5 || length(unique(train_df[[variable]])) < 2) {
      next
    }

    train_model <- lm(str ~ ., data = train_df)
    train_summary <- summary(train_model)
    train_pred <- predict(train_model, newdata = train_df)

    if (nrow(test_df) >= 5 && length(unique(test_df[[variable]])) >= 2) {
      test_model <- lm(str ~ ., data = test_df)
      test_summary <- summary(test_model)
      test_pred <- predict(test_model, newdata = test_df)

      estimate_test <- coef(test_summary)[2, 1]
      test_rmse <- sqrt(mean((test_df$str - test_pred)^2))
      test_r2 <- test_summary$adj.r.squared
    } else {
      estimate_test <- NA_real_
      test_rmse <- NA_real_
      test_r2 <- NA_real_
    }

    variable_prediction_errors[[length(variable_prediction_errors) + 1]] <- tibble(
      district = district_name_value,
      variable = variable,
      estimate_train = coef(train_summary)[2, 1],
      estimate_test = estimate_test,
      train_rmse = sqrt(mean((train_df$str - train_pred)^2)),
      test_rmse = test_rmse,
      train_r2 = train_summary$adj.r.squared,
      test_r2 = test_r2
    )
  }
}

variable_prediction_errors_df <- bind_rows(variable_prediction_errors)
save_table(variable_prediction_errors_df, "variable_prediction_errors.csv")

test_predictions <- list()

for (district in names(district_models)) {
  district_test <- test_prepared |>
    filter(district_name == district)

  if (nrow(district_test) > 0) {
    model <- district_models[[district]]

    predictions <- tryCatch(
      predict(model, newdata = district_test),
      error = function(e) rep(NA_real_, nrow(district_test))
    )

    test_predictions[[district]] <- tibble(
      shrid2 = district_test$shrid2,
      district = district,
      actual = district_test$str,
      predicted = predictions
    ) |>
      filter(!is.na(predicted))
  }
}

all_predictions <- bind_rows(test_predictions)
save_table(all_predictions, "test_predictions_by_district.csv")

if (nrow(all_predictions) > 0) {
  test_performance <- all_predictions |>
    group_by(district) |>
    summarise(
      n_observations = n(),
      rmse = sqrt(mean((actual - predicted)^2)),
      r_squared = safe_cor_squared(actual, predicted),
      .groups = "drop"
    ) |>
    arrange(rmse)

  save_table(test_performance, "test_performance_by_district.csv")
}

all_train_residuals <- tibble()
all_test_residuals <- tibble()

for (district in names(district_models)) {
  model <- district_models[[district]]

  train_df <- training_prepared |>
    filter(district_name == district)

  train_complete <- train_df |>
    select(all_of(names(model$model))) |>
    na.omit()

  train_fitted <- predict(model, newdata = train_complete)
  train_resid <- train_complete$str - train_fitted

  all_train_residuals <- bind_rows(
    all_train_residuals,
    tibble(fitted = train_fitted, residual = train_resid, district = district)
  )

  test_df <- test_prepared |>
    filter(district_name == district)

  test_complete <- tryCatch(
    test_df |>
      select(all_of(names(model$model))) |>
      na.omit(),
    error = function(e) NULL
  )

  if (!is.null(test_complete) && nrow(test_complete) > 0) {
    test_fitted <- predict(model, newdata = test_complete)
    test_resid <- test_complete$str - test_fitted

    all_test_residuals <- bind_rows(
      all_test_residuals,
      tibble(fitted = test_fitted, residual = test_resid, district = district)
    )

    residual_plot <- ggplot() +
      geom_point(
        data = tibble(fitted = train_fitted, residual = train_resid),
        aes(fitted, residual),
        alpha = 0.6,
        color = cb_palette[1]
      ) +
      geom_hline(yintercept = 0, color = cb_palette[2], linewidth = 0.7) +
      labs(
        title = paste("Training Residuals vs Fitted Values:", district),
        x = "Fitted values",
        y = "Residuals"
      )

    test_residual_plot <- ggplot(
      tibble(fitted = test_fitted, residual = test_resid),
      aes(fitted, residual)
    ) +
      geom_point(alpha = 0.6, color = cb_palette[3]) +
      geom_hline(yintercept = 0, color = cb_palette[2], linewidth = 0.7) +
      labs(
        title = paste("Test Residuals vs Fitted Values:", district),
        x = "Fitted values",
        y = "Residuals"
      )

    save_plot(
      residual_plot / test_residual_plot,
      paste0("stepwise_residuals_", make.names(district), ".png"),
      width = 9,
      height = 8
    )
  }
}

save_table(all_train_residuals, "stepwise_training_residuals.csv")
save_table(all_test_residuals, "stepwise_test_residuals.csv")

maharashtra_residual_plot <- ggplot() +
  geom_point(
    data = all_train_residuals,
    aes(fitted, residual),
    alpha = 0.5,
    color = cb_palette[1]
  ) +
  geom_hline(yintercept = 0, color = cb_palette[2], linewidth = 0.7) +
  labs(
    title = "Training Residuals vs Fitted Values: Maharashtra",
    x = "Fitted values",
    y = "Residuals"
  )

maharashtra_test_residual_plot <- ggplot() +
  geom_point(
    data = all_test_residuals,
    aes(fitted, residual),
    alpha = 0.5,
    color = cb_palette[3]
  ) +
  geom_hline(yintercept = 0, color = cb_palette[2], linewidth = 0.7) +
  labs(
    title = "Test Residuals vs Fitted Values: Maharashtra",
    x = "Fitted values",
    y = "Residuals"
  )

save_plot(
  maharashtra_residual_plot / maharashtra_test_residual_plot,
  "stepwise_residuals_maharashtra.png",
  width = 9,
  height = 8
)
