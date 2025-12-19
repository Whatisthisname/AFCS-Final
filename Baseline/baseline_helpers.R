# Helper Functions for Baseline Model

# Load required libraries
library(dplyr)
library(tsibble)
library(fable)
library(ggplot2)

# Function to calculate RMSE
calculate_rmse <- function(actual, predicted) {
  sqrt(mean((actual - predicted)^2))
}


# Function to evaluate predictions
evaluate_predictions <- function(actual, predicted) {
  metrics <- list(
    RMSE = calculate_rmse(actual, predicted),
    MAE = mean(abs(actual - predicted))
  )
  return(metrics)
}

# Align Predictions and Validation Data
# Input:
# - formatted_predictions: A data frame containing formatted forecasted sales.
# - validation: A data frame containing actual sales data for validation.
# Output:
# - A data frame with the following columns:
#   1. day: The date of the sales.
#   2. product: The product identifier.
#   3. predicted_sales: The forecasted sales for the product on the given day.
#   4. sales: The actual sales for the product on the given day.
align_predictions <- function(formatted_predictions, validation) {
  aligned_data <- formatted_predictions |>
    inner_join(validation, by = c("day", "product")) |>
    rename(predicted_sales = sales.x, sales = sales.y) # Rename columns for clarity
  return(aligned_data)
}

# Schema of Aligned Data
# The aligned data contains the following columns:
# 1. day: The date of the sales.
# 2. product: The product identifier.
# 3. predicted_sales: The forecasted sales for the product on the given day.
# 4. sales: The actual sales for the product on the given day.

# Evaluate Predictions
# This function calculates RMSE and MAE for aligned data
calculate_metrics <- function(aligned_data) {
  metrics <- aligned_data |>
    summarise(
      RMSE = sqrt(mean((sales - predicted_sales)^2, na.rm = TRUE)),
      MAE = mean(abs(sales - predicted_sales), na.rm = TRUE)
    )
  return(metrics)
}
