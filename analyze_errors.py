import numpy as np
import matplotlib.pyplot as plt
import pandas as pd

# Load the baseline mean accuracy data from the CSV file
baseline_data = pd.read_csv("Baseline/baseline_mean_accuracy.csv", delimiter=",")
final_data = pd.read_csv("Data_Inspection/predictions_errors_final.csv", delimiter=",")


# join the two on "product"
merged_data = pd.merge(baseline_data, final_data, on="product", how="inner")
print(merged_data.head())

# Calculate the difference between RMSE_y and RMSE_x
merged_data["RMSE_diff"] = merged_data["RMSE_y"] - merged_data["RMSE_x"]
merged_data["MAE_diff"] = merged_data["MAE_y"] - merged_data["MAE_x"]

# Sort the data by RMSE_diff in descending order
sorted_data = merged_data.sort_values(by="MAE_diff", ascending=False)

# Display the products with the highest RMSE difference
print(np.sum(sorted_data[["MAE_diff"]] > 0))
