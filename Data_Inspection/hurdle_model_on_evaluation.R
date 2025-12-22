library(dplyr, quietly = TRUE)
library(tsibble, quietly = TRUE)
library(fable, quietly = TRUE)
library(ggplot2, quietly = TRUE)
library(tidyr, quietly = TRUE)
library(purrr, quietly = TRUE)
library(feasts, quietly = TRUE)
library(GGally, quietly = TRUE)
library(patchwork, quietly = TRUE)
options(repr.plot.width = 20, repr.plot.height = 7, repr.plot.res = 100)


# Import Helper Functions
source("data_cleaning_helpers.R")
source("sales_exploration_helpers.R")
source("hurdle_model_helper_functions.R")
source("../Baseline/baseline_helpers.R")


# Get the new train data:
dates <- get_dates()
train <- get_train_and_validation_data_concatted(dates)

# Now load the evaluation data as validation:
validation <- get_evaluation_data()
min_date_eval <- min(validation$day)

h <- 28

sell_price_future <- generate_future_sell_prices(
    price_model = fit_or_load_price_model(train, force_fit = FALSE),
    date_events = dates,
    h = h
)

feat_int <- train |>
    as_tibble() |>
    group_by(product) |>
    summarise(intermittency_features(sales), .groups = "drop")


median_sparsity <- median(feat_int$p_zero)
cat("Median Sparsity (Proportion of zero daily sales across all products): ", round(median_sparsity, 4), "\n")


# Update the regime classification based on the new median sparsity
feat <- feat_int |>
    mutate(
        # regime = if_else(p_zero >= max(feat_int$p_zero), "sparse", "dense")
        # regime = if_else(p_zero > median_sparsity, "sparse", "dense")
        regime = "sparse" # TODO CHANGE BACK
    )


# Fit models to sparse products
sparse_products <- feat |>
    filter(regime == "sparse") |>
    pull(product)

hurdle_models <- fit_or_load_hurdle_models(train, sparse_products, force_fit = FALSE)


# Do an actual prediction using the models on the test data and evaluate:
# Predict using the models on the future_data and evaluate against validation:

predictions <- generate_hurdle_predictions(hurdle_models, h, sell_price_future, sparse_products)
print("Predictions:")
print(head(predictions))

# Ensure `product` column exists in both datasets before join
eval_data <- validation |>
    inner_join(predictions, by = c("product", "day"))

aligned_data <- align_predictions(
    formatted_predictions = predictions |> rename(sales = y_hat),
    validation = validation
)
cat("Evaluation Metrics:\n")
metrics <- calculate_metrics(aligned_data)
print(metrics)
final_products_and_errors <- calculate_metrics(aligned_data |> group_by(product)) |> arrange(-RMSE)

compare_errors_with_mean_baseline(train, validation, h)
