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
      RMSE = sqrt(mean((sales - predicted_sales)^2)),
      MAE = mean(abs(sales - predicted_sales))
    )
  return(metrics)
}


get_train_data <- function() {
  # Load train data
  train <- clean_train_data(read.csv("../sales_train_validation_afcs2025.csv"))

  # extending it by adding calander data
  train <- inner_join(
    train,
    dates,
    by = c("day")
  )
  train <- train |> as_tsibble(index = day, key = product)

  prices <- read.csv("../sell_prices_afcs2025.csv") |>
    rename(product = item_id) |>
    select(-store_id)

  # extending it by price
  train <- inner_join(
    train,
    prices,
    by = c("product", "wm_yr_wk")
  )

  train <- train |> mutate(log_sales = log(sales + 1)) |> mutate(sales = log_sales)
  return(train)
}

get_dates <- function() {
  # Load dates
  dates <- read.csv("../calendar_afcs2025.csv") |> mutate(date = as.Date(date, format = "%m/%d/%Y"))
  dates <- dates |> rename(day = date)

  # added this later, might break everything, gotta check it
  dates <- dates |> as_tsibble(index = day, key = wm_yr_wk)

  # adding dummy variables for each weekday
  dates <- dates |>
    mutate(
      wd_monday    = as.integer(weekday == "Monday"),
      wd_tuesday   = as.integer(weekday == "Tuesday"),
      wd_wednesday = as.integer(weekday == "Wednesday"),
      wd_thursday  = as.integer(weekday == "Thursday"),
      wd_friday    = as.integer(weekday == "Friday"),
      wd_saturday  = as.integer(weekday == "Saturday")
    )

  dates <- dates |>
    mutate(
      m_january   = as.integer(month == 1),
      m_february  = as.integer(month == 2),
      m_march     = as.integer(month == 3),
      m_april     = as.integer(month == 4),
      m_may       = as.integer(month == 5),
      m_june      = as.integer(month == 6),
      m_july      = as.integer(month == 7),
      m_august    = as.integer(month == 8),
      m_september = as.integer(month == 9),
      m_october   = as.integer(month == 10),
      m_november  = as.integer(month == 11)
    )

  # way too many unique event names so many we just focus on this,
  # it's implemented with an or because event1 and event2 are always different type,
  # and they can be in either order

  # adding dummy variables for each event category
  dates <- dates |>
    mutate(
      et_sporting  = as.integer((event_type_1 == "Sporting" | event_type_2 == "Sporting") %in% TRUE),
      et_cultural  = as.integer((event_type_1 == "Cultural" | event_type_2 == "Cultural") %in% TRUE),
      et_national  = as.integer((event_type_1 == "National" | event_type_2 == "National") %in% TRUE),
      et_religious = as.integer((event_type_1 == "Religious" | event_type_2 == "Religious") %in% TRUE)
    )

  return(dates)
}
