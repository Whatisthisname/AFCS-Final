# Data Inspection and Cleaning Observations

This document will track all choices and observations made during the data inspection and cleaning process. These notes will be useful for the final report.

## Observations

### General Dataset Information
- **calendar_afcs2025.csv**: Contains date-related information, including events and SNAP purchase eligibility.
- **sell_prices_afcs2025.csv**: Weekly average prices for products.
- **sales_train_validation_afcs2025.csv**: Historical daily sales data.
- **sales_test_validation_afcs2025.csv**: Validation data for the next 28 days.
- **sales_test_evaluation_afcs_2025.csv**: Test evaluation dataset (only for testing performance).
- **sample_submission_afcs2025.csv**: Template for submission.

### Cleaning Steps
- Check for missing values and handle appropriately.
- Identify and address outliers.
- Ensure consistency in data types and formats.
- Merge datasets where necessary for analysis.

### Key Questions
- Are there any missing dates in the calendar?
- Are there products with no sales data?
- How do prices vary over time and across products?
- What is the impact of events and SNAP eligibility on sales?

### Next Steps
- Load datasets into R and perform initial exploratory analysis.
- Document findings and cleaning steps here.