###############################################################
# Mission Antyodaya Maharashtra Student-Teacher Ratio Analysis
#
# Author: Leina Louis
#
# Description:
# Fits the Maharashtra LASSO model, exports selected variables and
# residual diagnostics.
#
# Repository:
# mission-antyodaya-r-analysis
###############################################################

lasso_variables <- setdiff(all_variables, "availability_of_primary_school")
lasso_variables <- lasso_variables[lasso_variables %in% names(maharashtra)]

lasso_data <- maharashtra |>
  select(str, all_of(lasso_variables)) |>
  drop_na()

y <- lasso_data$str
x <- lasso_data |>
  select(-str) |>
  as.matrix()

set.seed(123)
cv_lasso <- cv.glmnet(x, y, alpha = 1, standardize = TRUE, nfolds = 10)
best_lambda <- cv_lasso$lambda.min
lasso_model <- glmnet(x, y, alpha = 1, lambda = best_lambda)
lasso_coefficients <- coef(lasso_model)

selected_lasso_variables <- tibble(
  variable = rownames(lasso_coefficients),
  coefficient = as.numeric(lasso_coefficients)
) |>
  filter(coefficient != 0) |>
  arrange(desc(abs(coefficient)))

save_table(tibble(lambda_min = best_lambda), "lasso_lambda.csv")
save_table(selected_lasso_variables, "lasso_selected_variables.csv")

lasso_fitted <- as.numeric(predict(lasso_model, x))
lasso_residuals <- y - lasso_fitted

lasso_residual_plot <- ggplot(
  tibble(fitted = lasso_fitted, residual = lasso_residuals),
  aes(fitted, residual)
) +
  geom_point(alpha = 0.6, color = cb_palette[1]) +
  geom_hline(yintercept = 0, color = cb_palette[2], linewidth = 0.7) +
  labs(
    title = "Residuals vs Fitted Values: LASSO Model",
    x = "Fitted values",
    y = "Residuals"
  )

save_plot(lasso_residual_plot, "lasso_residuals_vs_fitted.png", width = 8, height = 5)
