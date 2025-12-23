# Helper Functions for Data Evaluation

# Load required libraries
library(dplyr)
library(lubridate)
library(tsibble)
library(ggplot2)
library(tidyr)

# Function to cast the date format in calendar data
cast_calendar_date <- function(calendar_data) {
  calendar_data <- calendar_data |> mutate(date = lubridate::mdy(date))
  return(calendar_data)
}

# Function to clean sell prices data
clean_sell_prices <- function(sell_prices_data) {
  sell_prices_data <- sell_prices_data |> select(-store_id)
  return(sell_prices_data)
}

# Function to clean and transform train data
clean_train_data <- function(train_data) {
  train_data <- train_data |> mutate(id = substr(id, 1, 11))

  transposed <- t(train_data[, -1]) # Exclude 'id' column before transpose
  colnames(transposed) <- train_data$id # Set column names to 'id' values

  df <- tibble::as_tibble(transposed) |>
    mutate(day = row_number() - 1 + as.Date("2011-01-29")) |>
    relocate(day, .before = 1)

  train_tsibble <- df |>
    as_tsibble(index = day) |>
    pivot_longer(cols = -day, names_to = "product", values_to = "sales") |>
    group_by(product)
  return(train_tsibble)
}

# Function to clean and transform validation data
# This function prepares the validation dataset for evaluation by:
# 1. Reshaping the data from wide to long format, where each row represents a single product's sales on a specific day.
# 2. Calculating the day based on the offset from the earliest day (d_1914 corresponds to 2011-01-29).
# 3. Standardizing the `product` column names to match the `id` column format in `formatted_predictions`.
get_validation_data <- function() {
  validation_data <- read.csv("./data/sales_test_validation_afcs2025.csv")
  validation_data <- validation_data |>
    mutate(product = sub("_TX_\\d+_validation", "", id)) |> # Strip extra identifiers from `product`
    select(-id) |> # Exclude the original `id` column
    pivot_longer(
      cols = starts_with("d_"), # Select columns representing daily sales (e.g., d_1914)
      names_to = "day", # Rename these columns to "day"
      values_to = "sales" # Store their values under the "sales" column
    ) |>
    mutate(day = as.Date("2011-01-29") + as.numeric(sub("d_", "", day)) - 1) |> # Calculate day based on offset
    as_tsibble(index = day, key = product)

  return(validation_data)
}

# Function to calculate total sales and plot
plot_total_sales <- function(train_tsibble) {
  train_tsibble <- train_tsibble |> mutate(total = rowSums(across(-day)))
  train_tsibble |> ggtime::gg_tsdisplay(total, plot_type = "partial")
  autoplot(train_tsibble) + labs(title = "Sales over Time for All Products", y = "Sales", x = "Date")
}


get_train_and_validation_data_concatted <- function(dates) {
  # Load train data
  train <- clean_train_data(read.csv("./data/sales_train_validation_afcs2025.csv"))
  validation <- get_validation_data()

  # Concatenate train and validation data
  train <- bind_rows(train, validation)

  # extending it by adding calander data
  train <- inner_join(
    train,
    dates,
    by = c("day")
  )
  train <- train |> as_tsibble(index = day, key = product)

  prices <- read.csv("./data/sell_prices_afcs2025.csv") |>
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

# Function to clean and transform evaluation data
# This function prepares the evaluation dataset for evaluation by:
# 1. Reshaping the data from wide to long format, where each row represents a single product's sales on a specific day.
# 2. Calculating the day based on the offset from the earliest day (d_1914 corresponds to 2011-01-29).
# 3. Standardizing the `product` column names to match the `id` column format in `formatted_predictions`.
get_evaluation_data <- function() {
  evaluation_data <- read.csv("./data/sales_test_evaluation_afcs_2025.csv")
  evaluation_data <- evaluation_data |>
    mutate(product = sub("_TX_\\d+_validation", "", id)) |> # Strip extra identifiers from `product`
    select(-id) |> # Exclude the original `id` column
    pivot_longer(
      cols = starts_with("d_"), # Select columns representing daily sales (e.g., d_1914)
      names_to = "day", # Rename these columns to "day"
      values_to = "sales" # Store their values under the "sales" column
    ) |>
    mutate(day = as.Date("2011-01-29") + as.numeric(sub("d_", "", day)) - 1) |> # Calculate day based on offset
    as_tsibble(index = day, key = product)

  return(evaluation_data)
}

fit_or_load_price_model <- function(train, force_fit) {
    # load fit or fit it and store the fit
    path <- "./models/prices/naive.rds"
    if (!force_fit && file.exists(path)) {
        price_fit_naive <- readRDS(path)
    } else {
        price_fit_naive <- train |>
            model(NAIVE(sell_price))

        saveRDS(price_fit_naive, path)
    }
    return(price_fit_naive)
}

# Make features of the products for clustering / grouping
intermittency_features <- function(y) {
    y <- as.numeric(y)
    y[is.na(y)] <- 0

    nz_idx <- which(y > 0)
    p_zero <- mean(y == 0)

    # Average inter-demand interval (ADI)
    adi <- if (length(nz_idx) <= 1) Inf else mean(diff(nz_idx))

    # Non-zero statistics
    y_nz <- y[y > 0]
    mean_nz <- if (length(y_nz) == 0) 0 else mean(y_nz)
    var_nz <- if (length(y_nz) <= 1) 0 else var(y_nz)

    cv2 <- if (mean_nz <= 0) Inf else var_nz / (mean_nz^2)

    tibble(
        p_zero = p_zero,
        adi = adi,
        mean_nz = mean_nz,
        cv2 = cv2
    )
}

generate_future_sell_prices <- function(price_model, date_events, h) {
    sell_price_future <- price_model |>
        forecast(h = h) |>
        as_tsibble() |>
        select(product, day, .mean) |>
        rename(sell_price = .mean)


    sell_price_future <- inner_join(
        sell_price_future,
        dates,
        by = c("day")
    )

    return(sell_price_future)
}


fit_or_load_hurdle_models <- function(train, sparse_products, force_fit) {
    path <- "./models/hurdle_models.rds"
    if (!force_fit && file.exists(path)) {
        hurdle_models <- readRDS(path)
    } else {
        hurdle_models <- train |>
            filter(product %in% sparse_products) |>
            group_by(product) |>
            nest() |>
            mutate(
                model = map(data, fit_hurdle_one)
            ) |>
            select(product, model)

        saveRDS(hurdle_models, path)
    }
    return(hurdle_models)
}

fit_hurdle_one <- function(df_train, n_pos_min = 10, mu_cap_q = 0.99) {
    product_id <- unique(df_train$product)[1]

    df_train <- df_train |>
        filter(!is.na(day)) |>
        mutate(
            occ = as.integer(sales > 0),
            dow = factor(weekday),
            snap_TX = as.integer(snap_TX),
            et_national = as.integer(et_national),
            et_religious = as.integer(et_religious),
            et_cultural = as.integer(et_cultural),
            sell_price = as.numeric(sell_price)
        )

    dow_levels <- levels(df_train$dow)

    occ_fit <- tryCatch(
        glm(
            occ ~ sell_price +
                # weekdays (Sunday reference)
                wd_monday + wd_tuesday + wd_wednesday +
                wd_thursday + wd_friday + wd_saturday +

                # months (December reference)
                m_january + m_february + m_march + m_april +
                m_may + m_june + m_july + m_august +
                m_september + m_october + m_november +

                # events
                et_sporting + et_cultural +
                et_national + et_religious +

                snap_TX,
            family = binomial(),
            data = df_train
        ),
        error = function(e) NULL
    )

    df_pos <- df_train |> filter(sales > 0)
    n_pos <- nrow(df_pos)

    mu_fallback <- if (n_pos == 0) 0 else mean(df_pos$sales)
    mu_cap <- if (n_pos == 0) 0 else as.numeric(stats::quantile(df_pos$sales, probs = mu_cap_q, na.rm = TRUE, names = FALSE))

    size_fit <- if (n_pos < n_pos_min) {
        NULL
    } else {
        tryCatch(
            glm(
                sales ~ sell_price +
                    # do you need to specify these?

                    # weekdays (Sunday reference)
                    wd_monday + wd_tuesday + wd_wednesday +
                    wd_thursday + wd_friday + wd_saturday +

                    # months (December reference)
                    m_january + m_february + m_march + m_april +
                    m_may + m_june + m_july + m_august +
                    m_september + m_october + m_november +

                    # events
                    et_sporting + et_cultural +
                    et_national + et_religious +

                    snap_TX,
                family = Gamma(link = "log"),
                data = df_pos
            ),
            error = function(e) NULL
        )
    }

    list(
        product_id = product_id,
        occ_fit = occ_fit,
        size_fit = size_fit,
        mu_fallback = mu_fallback,
        mu_cap = mu_cap,
        dow_levels = dow_levels
    )
}

predict_hurdle_one <- function(model, df_test) {
    # Handle missing models
    if (is.null(model)) {
        cat("Model is NULL for the given product. Returning empty predictions.\n")
        return(tibble(
            day = df_test$day,
            product = df_test$product,
            sales = df_test$sales,
            y_hat = numeric(0),
            p_hat = numeric(0),
            mu_hat = numeric(0)
        ))
    }


    df_test <- df_test |>
        filter(!is.na(day)) |>
        mutate(
            dow = factor(weekday, levels = model$dow_levels),
            snap_TX = as.integer(snap_TX),
            et_national = as.integer(et_national),
            et_religious = as.integer(et_religious),
            et_cultural = as.integer(et_cultural),
            sell_price = as.numeric(sell_price)
        )

    # Debugging intermediate calculations
    p_hat <- if (is.null(model$occ_fit)) {
        rep(0, nrow(df_test))
    } else {
        suppressWarnings(as.numeric(predict(model$occ_fit, newdata = df_test, type = "response")))
    }

    mu_hat <- if (!is.null(model$size_fit)) {
        suppressWarnings(as.numeric(predict(model$size_fit, newdata = df_test, type = "response")))
    } else {
        rep(model$mu_fallback, nrow(df_test))
    }

    mu_hat <- pmin(mu_hat, model$mu_cap)
    y_hat <- p_hat * mu_hat

    tibble(
        day = df_test$day,
        product = model$product_id,
        sales = df_test$sales,
        y_hat = y_hat,
        p_hat = p_hat,
        mu_hat = mu_hat
    )
}

generate_hurdle_predictions <- function(hurdle_models, h, sell_price_future, sparse_products) {
    predictions <- list() # Initialize an empty list to store predictions

    for (product in sparse_products) {
        # Filter sell_price_future for the current product
        product_data <- sell_price_future[sell_price_future$product == product, ]

        # Check if the product exists in hurdle_models
        if (!product %in% hurdle_models$product) {
            cat("No model found for product:", product, "\n")
            next
        }

        model <- hurdle_models$model[hurdle_models$product == product]

        if (is.null(model) || length(model) == 0) {
            cat("Invalid model for product:", product, "\n")
            next
        }

        if (nrow(product_data) == 0) {
            cat("No future data found for product:", product, "\n")
            next
        }

        # Generate predictions using `predict_hurdle_one`
        product_prediction <- predict_hurdle_one(model = model[[1]], df_test = product_data)
        # Store the prediction for the current product
        predictions[[product]] <- product_prediction
    }

    # Add `product` column to each tibble in predictions
    predictions <- lapply(names(predictions), function(product) {
        predictions[[product]] <- predictions[[product]] |>
            mutate(product = product)
        return(predictions[[product]])
    })

    # Combine predictions into a single data frame
    predictions <- do.call(rbind, predictions) |> as_tsibble(index = day, key = product)

    return(predictions)
}


compare_errors_with_mean_baseline <- function(train, validation, h) {
    # Baseline: Mean Forecasts
    means <- train |>
        as_tibble() |>
        group_by(product) |>
        summarise(mean_sales = mean(sales))

    mean_forecasts <- new_data(ungroup(train), n = h) |>
        left_join(means, by = "product") |>
        rename(sales = mean_sales) |>
        as_tibble()

    mean_aligned_data <- align_predictions(mean_forecasts, validation)
    accuracy_mean <- calculate_metrics(mean_aligned_data)
    print("Mean Forecast Baseline Metrics:")
    print(accuracy_mean)

    mean_products_and_errors <- calculate_metrics(mean_aligned_data |> group_by(product)) |> arrange(-RMSE)
    write.csv(mean_products_and_errors, "./data/baseline_mean_accuracy.csv", row.names = FALSE)

    joined_errors <- mean_products_and_errors |>
        inner_join(final_products_and_errors, by = "product", suffix = c("_mean", "_hurdle")) |>
        mutate(
            worsened_RMSE = RMSE_hurdle - RMSE_mean,
            worsened_MAE = MAE_hurdle - MAE_mean
        ) |>
        arrange(-worsened_RMSE) # Sort by largest increase in RMSE, which indicates worsening performance

    # For the 10 worst performing products, use the predictions from the mean model instead
    worst_products <- joined_errors |>
        slice_head(n = 100) |>
        pull(product)

    final_predictions <- predictions |>
        mutate(
            y_hat = if_else(product %in% worst_products,
                mean_forecasts$sales[match(paste(product, day), paste(mean_forecasts$product, mean_forecasts$day))],
                y_hat
            )
        )

    final_aligned_data <- align_predictions(
        formatted_predictions = final_predictions |> rename(sales = y_hat),
        validation = validation
    )

    cat("Final Evaluation Metrics after replacing worst products with mean forecasts:\n")
    final_metrics <- calculate_metrics(final_aligned_data)
    print(final_metrics)
    return(final_metrics)
}