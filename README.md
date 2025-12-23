# Sales Forecasting Benchmark: Parsimony vs. Complexity

![Forecasting overview](comparisons_RMSE.png)

This repository contains the code, data, and results for a sales forecasting project comparing simple statistical baselines against more complex time-series and machine learning approaches in a realistic retail setting.

The analysis focuses on daily item-level sales forecasting over a 28-day horizon using a subset of the `M5 Accuracy`-dataset (single Walmart store in Texas).

The central research question is whether increased model complexity yields meaningful accuracy gains when data are sparse, intermittent, and noisy.

---

## Repository

### `results.ipynb` and `results_helpers.R`
Final evaluation, diagnostics, and plots.
- RMSE / MAE comparisons  
- Aggregate forecast plots  
- Innovation diagnostics (ACF, Ljung–Box tests)  

---

### `data/`
Raw and provided datasets used throughout the project.
- `sales_train_validation_afcs2025.csv`: training data  
- `sales_test_validation_afcs2025.csv`: validation data  
- `sales_test_evaluation_afcs_2025.csv`: held-out evaluation data (not used for training)  
- `calendar_afcs2025.csv`, `sell_prices_afcs2025.csv`: calendar and price covariates  
- `baseline_mean_accuracy.csv`: stored benchmark results  

---

### `EDA/`
Exploratory data analysis and preprocessing.
- `sales_exploration.ipynb`: main EDA notebook  
- `data_cleaning_helpers.R`, `sales_exploration_helpers.R`: shared utilities  
- `observations.md`: qualitative insights from EDA  

---

### `Baseline/`
Implementation of **benchmark forecasting models**.
- `baseline_notebook.ipynb`: runs Naive, Seasonal Naive, ETS, ARIMA benchmarks  
- `baseline_helpers.R`: evaluation and plotting helpers  
- `approach_description.md`: rationale for baseline choices  

Subdirectories:
- `models/baseline/`: fitted baseline models (Naive, SNaive, ETS, ARIMA)  
- `models/arima_models/`: ARIMA variants with calendar, SNAP, and event effects  
- `models/prices/`: price-only forecasting models used for dynamic-price experiments  

---

### `models/`
Final stored models used in the results and evaluation.
- `baseline/`: final baseline fits  
- `arima_models/`: selected ARIMA specifications  
- `prices/`: selected price models  

---

### `NeuralNetwork/`
Exploratory neural network baseline.
- `nn_notebook.ipynb`: simple neural benchmark  
- `models/nn_naive.rds`: trained NN model  

> Included for completeness; not a central focus of the analysis.

---

### `Notes/`
Project planning and task context.
- `task.md`: assignment description  
- `forecasting_plan.md`: initial modeling plan