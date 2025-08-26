## Hi, I'm Sharon!
I'm a Data Analyst with expertise in Excel, SQL, Power BI, and Python. 

Below is a summary of my Data Analysis and Data Science projects.

### Data Analysis Projects
#### [1. Bike Sales Dashboard](https://github.com/Shane360/Portfolio/blob/main/Bike%20Sales%20Dashbord.pbix)
Used SQL Server and Power BI to analyze data from a bicycle-sharing company (17,290 records).
Business questions answered include:

a. Hourly Revenue: Peak periods were at 5 pm on Mondays (total of $260,313 in sales)

b. Profit and Revenue Trends: Price was increased by 25% in 2022 (from $3.99 to $4.99), but still experienced a 64% increase in patronage in 2022.

c. Seasonal Revenue: Highest sales were recorded in Autumn ($4.9 million)

d. Rider demographics: 81.17% of riders were registered vs. 18.83% of casual, unregistered drivers. 


#### [2. Customer Churn Analysis](https://github.com/Shane360/Portfolio/blob/main/Customer_Churn_SO_PwC.pbix)
Used Power BI to analyze 7,043 records of customers for a telecoms client. The goal of the analysis was to determine which clients were likely to churn based on the insights gleaned from the data. 
Major factors that determined customer churn were: 
a. Short-term contracts: customers with monthly contracts were more likely to churn than those with mid to long-term (yearly) contracts.

b. High Complaints and unavailability of tech support: customers with 2 or above unresolved complaints regarding technical issues were very likely to leave.

c. Unavailability of online security services: Customers without access to online security services were likely to churn.

d. Fibre Optic Service: 69% of subscribers (1,290) who churned were subscribed to the Fibre Optic service. 

e. Loss of over $139,000 as a result of customer churn was recorded during the period under review, with a churn rate of 26.54%.

**Recommendations:**
1. Engage with the Customer Success and operations teams to ensure availability of tech support for and swift interventions for complaints logged by customers.
   
2. Review of the Fibre Optic Service to determine pain points and reasons for the mass churn. 


#### [3. Diversity and Inclusion Analysis](https://github.com/Shane360/Portfolio/blob/main/Diversity_Inclusion_Analysis_SO_PwCv2.pbix)
Used Power BI to analyse and visualize the distribution and performance of male and female employees at the  executive level in the client's company. 

a. Men dominated the executive level in Financial Year (FY) 20 with 74%, and 74.39% in FY 21.

b. 100% of the hires in FY20 and  FY21 were, unfortunately, Male, indicating a hiring process skewed in favour of Male talent. This could be due to a dearth of female talent to fill the roles or other factors not captured in the data.  

c. Performance ratings were similar, with female talents (2.40 on average) pipping their male counterparts (2.35 on average).

d. The majority of hires in executive roles were between the ages of 40 - 49. The 20 - 29-year-olds dominated the Junior roles in the company.


#### [4. Flight Status Dashboard](https://github.com/Shane360/Portfolio/blob/main/Flight%20Status%20Dashboard%20-%20Portfolio%20Project%20Sharon.pbix)
Used Power BI to analyze and visualize the performance of 1.95 million flights recorded in 2015. Data was obtained from the Federal Aviation Administration. 

a. 58% of the flights (1.13million) were on time, 40.5% were delayed, and 1.5 % were cancelled. 

b. The top reason for cancellation (57.3%) was the weather, followed by airline carriers' internal issues, with 8,000 flights cancelled for this reason. 

c. Southwest Airlines Co. recorded the most delays (142,000 within the year) while American Eagle Airlines canceled the most flights (5,731).

#### [5. Credit Analysis and Fraud Detection]
Used Advanced SQL techniques to analyze over 150,000 transaction records from bank customers to identify customer demographics, spending behaviours, and customers who pose a credit risk to the bank. Finally, conducted credit risk analysis and fraud analysis to identify accounts that initiated fraudulent transactions  

a. 303 customers out of a total of 2,000 Customers accounted for a total of $6,874,483.49.

b. 101 transactions were flagged for critical-level fraud activity, with 23 accounts identified as repeat critical-level transactions.

c. Credit Risk analysis revealed debt-heavy but credit-worthy customers who are possibly leveraging good debt.

d. Created triggers to flag loans that will adversely impact credit scores and flag fraudulent transactions in real-time.
 



### Data Science Projects
#### [1. Restaurant Analysis and Predictive Modeling](https://github.com/Shane360/Portfolio/blob/main/Restaurant%20Data%20Analysis%20and%20Predictive%20Modelling%20Project%20(ML).ipynb)
Used Python (Pandas, Numpy, Sci-kit learn, XGboost, and SHAP) to analyze data from a restaurant with 1,000 records (dishes). The goal of the analysis was to understand what drives revenue at the restaurant and determine which factors were responsible for the increase in revenue using Machine learning techniques. 

a. The **Data analysis** revealed that:

i. Japanese dishes recorded the highest sales ($71,185 total monthly revenue) with the highest marketing spend ($2,700) compared to the Italian and Mexican dishes. 

ii. Promotions had a marginal impact on revenue, especially for Italian and Mexican dishes, while Marketing Spend was more effective at the macro-level with diminishing returns at the micro-level: higher spend resulted in higher revenue, while marginal spend resulted in very minimal changes in revenue.

**b. Predictive Modeling:** of the 6 machine learning models trained on the full and pruned features, the LassoCV model trained on the pruned features performed the best (r2 score of 69.8% and RMSE of $59.58).

a. The data was split into train and test sets (70/30) and thereafter trained on the ML models before feature selection (after the Random Forest Model). 

b. SHAP was used to confirm the most important features for predicting monthly revenue: Number_of_Customers, Marketing_Spend, and Menu_Price. 

c. Because the features were scaled in the training pipeline, I unscaled the feature coefficients to determine the real-life impact of the features in predicting revenue:

i. Marketing Spend is more effective in predicting revenue; for every $1 increase in marketing spend, the restaurant recorded a $4.89 increase in monthly revenue. 

ii. For each new customer that patronizes the restaurant, monthly revenue increases by $2.87.

