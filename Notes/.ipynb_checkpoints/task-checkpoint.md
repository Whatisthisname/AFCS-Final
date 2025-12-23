Project Paper should include the following:

(1) description of the dataset;

(2) the scientific goals, specific hypotheses;

(3) data exploratory analysis including preliminary plots and summary tables;

(4) plan for future analysis and modeling.

The written final report is due by Dec. 23th, 2025.

Reports have to be complete but brief.

See also this guide on how to write technical papers.

Data Analytics Strategies:
Perform adequate exploratory analysis of the data and provide a complete, yet succinct, presentation of the results.
Clearly state the statistical model used when presenting model estimates.
Clearly state the model building/selection/validation criteria used to address the scientific question(s) of interest.
Perform adequate model diagnostics.
Provide precise interpretations of the parameters in your model (or your estimates of those parameters) in the context of the scientific problem.
General Guidelines on the Report
Your final analysis should be presented in the form of a brief report between 10-12 double-columned pages including relevant tables and figures. Your report should be structured as follows:

Abstract
A brief summary of your findings.

Introduction
A brief introduction/motivation to the problem at hand, relevant details about the data, additional relevant scientific information from searching the web, for example, and what is to be addressed

Forecasting Methods
A discussion and justification of the methods you have used to analyze the data and how you went about analyzing the data. Don’t forget to describe in some detail how and why the particular model was selected.

Results
A presentation of the results of your analysis. Interpretations should include a discussion of the statistical versus practical importance of the results.

Important:  The report should include the RMSE score of your model obtained only from testing it on test evaluation dataset Download  test evaluation dataset.  Do not use this dataset for training your model, otherwise it will cause losing points from your project (since we will validate your code and results ourselves). 

Discussion
A synopsis of your findings and any limitations your study may suffer from. Present final conclusions in terms that non-statisticians will understand. Quantitative and qualitative aspects should be discussed. Your report should be succinct and to the point! It should be written in a language that is understandable to the scientific community.

Conclusions
Highlight key points in your analysis or findings by reflecting on them. Summarize your thoughts and the critical implications of your study. Demonstrate the importance of the insight and creative approaches for framing/contextualizing the research problem based on the results of your study.

Evaluation of the Report

1) 20%: Soundness/Performance of the Approach (Report the RMSE score of your model obtained only from test validation data. Providing additional metrics is optional).

2) 80%: Quality of the Scientific Report

'Missing' team members and grade distribution among team members

The author list is mandatory.  If one (or more) team members did not actually take part at all in the assignment they are to be left off the author list. Emails sent after the submission deadline telling the graders that someone was included on the author list but really wasn't there will be ignored. Authorship, as listed on the paper at the submission deadline, is what counts. All team members will be assumed to have contributed equally unless a student does not appear on the author list. If you end up in a smaller team (2-3) than usual the grading will take that into account, but only if you have a correct author list. 


The task itself:

The Task:

Forecasting predicts the number of sales in the future. Having the right amount of products in stock is a core challenge in retail. A good forecast makes sure there are enough of your favourite products in stock, even if you come to the store late in the evening.

In this project, you will use a subset of M5 Forecasting - Accuracy hierarchical sales data from Walmart at one store, TX3 in the State of Texas, the world’s largest company by revenue, to forecast daily sales for the next 28 days. The data include item level, department, product categories, and store details. In addition, it has explanatory variables such as price, promotions, day of the week, and special events. Altogether, it can be used to improve forecasting accuracy. 

Final Project deadline 23/12/2025,  23:59

 

The Dataset: 

The subset of M5 dataset, generously made available by Walmart, involves the unit sales of various products sold in the USA, more specifically, the dataset involves the unit sales of 3,049 products, classified into 3 product categories (Hobbies, Foods, and Household) and 7 product departments, in which the above-mentioned categories are disaggregated.

For this project, the selected products, Food3, are sold by TX3 store, located in Texas. 

The dataset consists of the following five (5) files:

File 1: “calendar_afcs2025.csv Download calendar_afcs2025.csv” contains information about the dates the products are sold.

date: The date in a “y-m-d” format.
wm_yr_wk: The id of the week the date belongs to.
weekday: The type of the day (Saturday, Sunday, …, Friday).
wday: The id of the weekday, starting from Saturday.
month: The month of the date.
year: The year of the date.
event_name_1: If the date includes an event, the name of this event.
event_type_1: If the date includes an event, the type of this event.
event_name_2: If the date includes a second event, the name of this event.
event_type_2: If the date includes a second event, the type of this event.
snap_TX: A binary variable (0 or 1) indicating whether the stores of TX, allow SNAP3 purchases on the examined date. 1 indicates that SNAP purchases are allowed.
 

File 2: “sell_prices_afcs2025.csv Download sell_prices_afcs2025.csv”
Contains information about the price of the products sold per store and date.

store_id: The id of the store where the product is sold.
item_id: The id of the product.
wm_yr_wk: The id of the week.
sell_price: The price of the product for the given week/store. The price is provided per week (average across seven days). If not available, this means that the product was not sold during the examined week. Note that although prices are constant at weekly basis, they may change through time (both training and test set).
File 3: “sales_train_validation_afcs2025.csv Download sales_train_validation_afcs2025.csv”, contains the historical daily unit sales data per product and store.

item_id: The id of the product.
dept_id: The id of the department the product belongs to.
cat_id: The id of the category the product belongs to.
store_id: The id of the store where the product is sold.
state_id: The State where the store is located.
d_1, d_2, …, d_i, … d_1913: The number of units sold at day i, starting from 2011-01-29.
File 4: “sales_test_validation_afcs2024.csv Download sales_test_validation_afcs2024.csv”, contains the historical daily unit sales data per product and store.

item_id: The id of the product.
dept_id: The id of the department the product belongs to.
cat_id: The id of the category the product belongs to.
store_id: The id of the store where the product is sold.
state_id: The State where the store is located.
d_1914, d_1925, …, d_i, … d_1941: The number of units sold for the next 28 days. 
File 5: "sample_submission_afcs2025.csv Download sample_submission_afcs2025.csv" contains the number of forecasts to be submitted for point forecasts, exactly 28 days (4 weeks ahead), starting at F1, F2, …, F28.

 

File 6: "sales_test_evaluation_afcs_2025.csv Download sales_test_evaluation_afcs_2025.csv" which you should only use to test the performance of your approach (warning: do not train with it!)




Last but not Least 

Take this as an opportunity for a mini-research project to combine what you have learned in the course with approaches and perspectives that go beyond the course content!  Don't be afraid to unleash your innovative ideas, exploring  or taking a particular research direction e.g., staying focusing on a particular approach and carry out a deep analysis, or perform a comparative analysis of a new and old methods, and so on. More conservative or more progressive, there is no wrong direction. What matters is the depth and soundness of your analysis!  This is an invitation to the challenging field of forecasting. I hope you enjoy it. 