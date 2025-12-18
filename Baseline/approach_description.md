# Approach Description

## Forecasting Methodology
The forecasting approach utilizes a Seasonal Naive (SNAIVE) model to predict daily sales for the next 28 days. This model assumes that the sales pattern repeats seasonally, making it suitable for datasets with strong seasonal trends. The model is applied to each product individually, ensuring tailored predictions for each item.

### Steps:
1. **Data Cleaning**: The training dataset is cleaned to ensure consistency and remove any anomalies.
2. **Model Fitting**: The SNAIVE model is fitted to the cleaned training data, leveraging the seasonal patterns in the sales data.
3. **Forecast Generation**: Forecasts are generated for the next 28 days, starting from "2016-04-25" to align with the validation dataset.
4. **Formatting Predictions**: Predictions are formatted for submission, ensuring compatibility with the validation dataset.

## Evaluation Methodology
The evaluation of the forecasts is performed using the validation dataset, which contains actual sales data for the same 28-day period. The following metrics are calculated:

1. **Root Mean Square Error (RMSE)**:
   \[
   RMSE = \sqrt{\frac{1}{n} \sum_{i=1}^{n} (y_i - \hat{y}_i)^2}
   \]
   This metric measures the average magnitude of the error, giving higher weight to larger errors.

2. **Mean Absolute Error (MAE)**:
   \[
   MAE = \frac{1}{n} \sum_{i=1}^{n} |y_i - \hat{y}_i|
   \]
   This metric measures the average absolute difference between the actual and predicted values.

### Steps:
1. **Data Alignment**: Predictions are aligned with the validation dataset based on the `day` and `product` columns.
2. **Metric Calculation**: RMSE and MAE are calculated using the aligned data.
3. **Result Interpretation**: The metrics are used to assess the accuracy of the forecasts, with lower values indicating better performance.

## Key Considerations
- The validation dataset is strictly used for evaluation and not for training.
- The evaluation metrics provide insights into both the magnitude and direction of errors, ensuring a comprehensive assessment of the model's performance.