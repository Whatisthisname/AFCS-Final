# Step-by-Step Plan for Forecasting Project

## 1. Data Inspection and Cleaning
- **Objective**: Understand the structure and quality of the dataset.
- **Actions**:
  - Load all datasets (`calendar_afcs2025.csv`, `sell_prices_afcs2025.csv`, `sales_train_validation_afcs2025.csv`, etc.) into R.
  - Inspect for missing values, outliers, and inconsistencies.
  - Perform exploratory data analysis (EDA) to understand trends, seasonality, and relationships between variables.
  - Visualize key variables such as sales over time, price changes, and event impacts.

## 2. Feature Engineering
- **Objective**: Create meaningful features to improve model performance.
- **Actions**:
  - Extract time-based features (e.g., day of the week, month, year, holidays).
  - Incorporate event-related features from `calendar_afcs2025.csv`.
  - Create lagged variables and rolling averages for sales to capture temporal dependencies.
  - Engineer price-related features (e.g., price changes, price elasticity).

## 3. Model Selection and Justification
- **Objective**: Choose an appropriate forecasting model.
- **Actions**:
  - Use an autoregressive model with external regressors (dynamic regression model) as described in the [fpp3 book](https://otexts.com/fpp3/dynamic.html).
  - Justify the choice of model:
    - Autoregressive models are well-suited for capturing temporal dependencies in sales data.
    - External regressors (e.g., holidays, promotions) provide additional context to improve accuracy.
  - Consider using the `fable` package in R for time series modeling.

## 3.1 Baseline Model
- **Objective**: Establish a baseline for comparison.
- **Actions**:
  - Implement a seasonal naive model as the baseline.
  - Justify the choice of the seasonal naive model:
    - It is simple and assumes that sales follow a repeating seasonal pattern.
    - Provides a benchmark to evaluate the added value of more complex models.
  - Evaluate the baseline model using RMSE and compare its performance to the dynamic regression models.

## 4. Model Implementation
- **Objective**: Build and train the forecasting models.
- **Actions**:
  - Create a separate model for each item in the dataset.
  - Use parallel time series (e.g., holidays, promotions) as external regressors.
  - Split the data into training and validation sets:
    - Use `sales_train_validation_afcs2025.csv` for training.
    - Reserve `sales_test_validation_afcs2025.csv` for validation.
  - Evaluate models using RMSE and other relevant metrics.

## 5. Model Diagnostics and Validation
- **Objective**: Ensure the models are robust and reliable.
- **Actions**:
  - Perform residual diagnostics to check for autocorrelation and heteroscedasticity.
  - Validate the models on the `sales_test_validation_afcs2025.csv` dataset.
  - Compare the performance of different models and select the best-performing one.

## 6. Forecasting and Submission
- **Objective**: Generate forecasts for the next 28 days.
- **Actions**:
  - Use the trained models to forecast daily sales for each item.
  - Aggregate forecasts as needed to match the format of `sample_submission_afcs2025.csv`.
  - Ensure forecasts are realistic and consistent with historical trends.

## 7. Report Writing
- **Objective**: Document the analysis and findings.
- **Actions**:
  - Follow the structure outlined in `task.md`:
    - Abstract
    - Introduction
    - Forecasting Methods
    - Results
    - Discussion
    - Conclusions
  - Justify all modeling choices and provide clear interpretations of the results.
  - Include RMSE scores and other relevant metrics.
  - Highlight limitations and potential improvements.

## 8. Final Review and Submission
- **Objective**: Ensure the project meets all requirements.
- **Actions**:
  - Review the report for completeness and clarity.
  - Verify that the code and results are reproducible.
  - Submit the report and forecasts by the deadline (Dec. 23, 2025).