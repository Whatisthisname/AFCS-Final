# Helper Functions for Sales Exploration

# Function to calculate RMSE
rmse <- function(actual, predicted) {
    sqrt(mean((actual - predicted)^2, na.rm = TRUE))
}

# Function to calculate intermittency features
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

# Function to fit hurdle model for one product
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
            occ ~ dow + snap_TX + et_national + et_religious + et_cultural + sell_price,
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
                sales ~ dow + sell_price,
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

# Function to predict using hurdle model for one product
predict_hurdle_one <- function(model, df_test) {
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
