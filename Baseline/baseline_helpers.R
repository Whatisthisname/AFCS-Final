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

# Function to format predictions for submission
# Input:
# - predictions: A data frame containing forecasted sales.
# - start_date: The starting date for the forecast period.
# Output:
# - A data frame with the following columns:
#   1. day: The date of the forecast.
#   2. id: The product identifier.
#   3. sales: The forecasted sales for the product on the given day.
format_predictions <- function(predictions, start_date) {
  formatted <- predictions %>%
    mutate(day = seq.Date(from = as.Date(start_date), by = "day", length.out = nrow(predictions))) %>%
    pivot_longer(cols = -day, names_to = "id", values_to = "sales")
  return(formatted)
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
  aligned_data <- formatted_predictions %>%
    rename(product = id) %>% # Rename `id` to `product` for joining
    inner_join(validation, by = c("day", "product")) %>%
    rename(predicted_sales = sales.x, sales = sales.y) # Rename columns for clarity
  return(aligned_data)
}

# Evaluate Predictions
# This function calculates RMSE and MAE for aligned data
calculate_metrics <- function(aligned_data) {
  metrics <- aligned_data %>%
    summarise(
      RMSE = sqrt(mean((sales - predicted_sales)^2, na.rm = TRUE)),
      MAE = mean(abs(sales - predicted_sales), na.rm = TRUE)
    )
  return(metrics)
}

# Schema of Aligned Data
# The aligned data contains the following columns:
# 1. day: The date of the sales.
# 2. product: The product identifier.
# 3. predicted_sales: The forecasted sales for the product on the given day.
# 4. sales: The actual sales for the product on the given day.