# Helper Functions for Data Cleaning

# Load required libraries
library(dplyr)
library(lubridate)
library(tsibble)
library(ggplot2)
library(tidyr)

# Function to cast the date format in calendar data
cast_calendar_date <- function(calendar_data) {
    calendar_data <- calendar_data %>% mutate(date = lubridate::mdy(date))
    return(calendar_data)
}

# Function to clean sell prices data
clean_sell_prices <- function(sell_prices_data) {
  sell_prices_data <- sell_prices_data %>% select(-store_id)
  return(sell_prices_data)
}

# Function to clean and transform train data
clean_train_data <- function(train_data) {
  train_data <- train_data %>% mutate(id = substr(id, 1, 11))

  transposed <- t(train_data[,-1])  # Exclude 'id' column before transpose
  colnames(transposed) <- train_data$id  # Set column names to 'id' values

  df <- tibble::as_tibble(transposed) %>%
    mutate(day = row_number() - 1 + as.Date("2011-01-29")) %>%
    relocate(day, .before = 1)

  train_tsibble <- df %>% as_tsibble(index = day)
  return(train_tsibble)
}

# Function to clean and transform validation data
# This function prepares the validation dataset for evaluation by:
# 1. Reshaping the data from wide to long format, where each row represents a single product's sales on a specific day.
# 2. Calculating the day based on the offset from the earliest day (d_1914 corresponds to 2011-01-29).
# 3. Standardizing the `product` column names to match the `id` column format in `formatted_predictions`.
clean_validation_data <- function(validation_data) {
  validation_data <- validation_data %>%
    mutate(product = sub("_TX_\\d+_validation", "", id)) %>% # Strip extra identifiers from `product`
    select(-id) %>% # Exclude the original `id` column
    pivot_longer(
      cols = starts_with("d_"), # Select columns representing daily sales (e.g., d_1914)
      names_to = "day",         # Rename these columns to "day"
      values_to = "sales"       # Store their values under the "sales" column
    ) %>%
    mutate(day = as.Date("2011-01-29") + as.numeric(sub("d_", "", day)) - 1) # Calculate day based on offset
  return(validation_data)
}

# Function to calculate total sales and plot
plot_total_sales <- function(train_tsibble) {
  train_tsibble <- train_tsibble %>% mutate(total = rowSums(across(-day)))
  train_tsibble %>% ggtime::gg_tsdisplay(total, plot_type="partial")
  autoplot(train_tsibble) + labs(title = "Sales over Time for All Products", y = "Sales", x = "Date")
}