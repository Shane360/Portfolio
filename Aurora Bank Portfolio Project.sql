-- AURORA SQL PORTFOLIO PROJECT
-- PART 1: CUSTOMER ANALYSIS

-- 1. Customer profiling and segmentation: customer demographics by Age, Gender and Region and how do these correlate with their income, debt and credit score
-- This helps to personalize offers, target marketing campaigns and build customer personas enabling customer segmentation and lifetime value modelling

-- 2. Financial Health & Credit Risk Analysis: debt-to-income ratios across income brakcets and age groups and how these align with credit scores
-- This pinpoints customers likely to default or churn and is also vital for credit limit adjustments and pre-emptive intervention

-- 3. Spending Behaviour by Merchant Category: Top Spending Categories and Transaction Volumes by Merchant Category (MCC) and how do they vary by customer segment?
-- This reveals spending behaviour of customers, for upselling, brand partnerships and customer loyalty strategy

-- 4. Card Usage Patterns by Demographic: Average number of cards per customer and how does card usage by transaction frequency and value) vary by demographic?
-- This informs card product performance and retention strategies


-- 5. Fraud Detection and Error Rates: Which locations or merchant categories have the highest transaction error rates or unusually high-value transactions?
-- This enables Fraud detection and friction points in customer journey.  It also identifies fraud-prone areas and is useful for compliance, customer trust and fraud prevention




-- Properly link the PKs to their FKs in the required tables
SELECT *
FROM transactions_data;


ALTER TABLE cards_data
ADD CONSTRAINT fk_user_id FOREIGN KEY (client_id) REFERENCES users_data(id);

SELECT *
FROM cards_data;


ALTER TABLE cards_data
DROP COLUMN column13, column14;


ALTER TABLE transactions_data
ADD CONSTRAINT fk_to_user FOREIGN KEY (client_id) REFERENCES users_data(id);

ALTER TABLE transactions_data
ADD CONSTRAINT fk_card_id FOREIGN KEY (card_id) REFERENCES cards_data(id);

SELECT *
FROM transactions_data



-- 1. CUSTOMER PROFILING AND SEGMENTATION: Customer demographics: Analyze age, gender, and geographical distribution of customers

SELECT *
FROM users_data;

-- 1.1 Average Per Capita and Yearly Incomes of Banks customers
SELECT 
    ROUND(SUM(t.amount), 2)as total_txn_usd,
    ROUND(AVG(u.per_capita_income), 2) as avg_per_capita,
    ROUND(AVG(u.yearly_income), 2) as avg_yearly_income,
    AVG(u.credit_score) as avg_credit_score
FROM users_data u
JOIN transactions_data t 
    ON u.id = t.client_id;

-- 1.1.1 Transaction timeline
SELECT
    MIN(CONVERT(Date, date)) as start_date,
    MAX(CONVERT(Date, date)) as end_date
FROM transactions_data;

/*
INSIGHTS:
a. The average salary per capita and average yearly income of the customer base are $22,795.57 and $45,250.75, respectively.
b. The 2000 customers in the dimension table accounted for a total volume of $6,874,483.48 between January 1, 2022, and October 31, 2024.
c. The Average credit score for customers is 719, which is a Good FICO score, but we shall dive deeper very soon.
*/

-- 1.1.2 Customers by Age (birthdate is a better indicator considering  errors may have been made during data entry into Age column)
 SELECT 
    birth_year,
    COUNT(*) AS total_customers
 FROM users_data
 GROUP BY birth_year
 ORDER BY total_customers DESC;

-- INSIGHT: Most customers (906) are middle-aged, born between 1970 and 1994.


 -- 1.1.3 Customer segmentation by Age
SELECT
    CASE 
        WHEN birth_year BETWEEN 1995 AND 2002 THEN 'Young'
        WHEN birth_year BETWEEN 1970 AND 1994 THEN 'Middle-Aged'
        WHEN birth_year BETWEEN 1959 AND 1969 THEN 'Old'
        ELSE 'Very Old'
    END AS age_bracket,
    COUNT(*) as total_customers
FROM users_data
GROUP BY 
    CASE 
        WHEN birth_year BETWEEN 1995 AND 2002 THEN 'Young'
        WHEN birth_year BETWEEN 1970 AND 1994 THEN 'Middle-Aged'
        WHEN birth_year BETWEEN 1959 AND 1969 THEN 'Old'
        ELSE 'Very Old'
    END
ORDER BY total_customers DESC;

-- INSIGHT: Majority of customers (906) are middle-aged (born between 1970 and 1994)


-- 1.2 Customer Count by Gender
SELECT
    gender,
    COUNT(*) AS num_customers
FROM users_data
GROUP BY gender
ORDER BY num_customers DESC;

-- INSIGHT: There are more female customers (1,016) than Male (984).


-- 1.3 Customer Gender Count by Age group  

With AgeGroup AS (
    SELECT 
        CASE 
            WHEN birth_year BETWEEN 1995 AND 2002 THEN 'Young'
            WHEN birth_year BETWEEN 1970 AND 1994 THEN 'Middle-Aged'
            WHEN birth_year BETWEEN 1959 AND 1969 THEN 'Old'
            ELSE 'Very Old'
        END As AgeGroup, 
        gender 
    FROM users_data
)

SELECT 
    AgeGroup,
    gender,
    COUNT(gender) AS GenderCount,   
    RANK() OVER (ORDER BY COUNT(gender) DESC) AS AgeRank
FROM AgeGroup
GROUP BY AgeGroup, gender;

-- INSIGHT: Most of the bank's customers are Middle-aged Females (456), followed by middle-aged men (450).



-- 1.4 Customer distribution by Income levels
SELECT 
    CASE 
        WHEN yearly_income < 20000 THEN 'Low Income (Below 20K)'
        WHEN yearly_income BETWEEN 20000 AND 50000 THEN 'Middle Income (20K - 50K)'
        WHEN yearly_income BETWEEN 50000 AND 100000 THEN 'Upper Income (50K - 100K)'
        ELSE 'High Income (Above 100K)'
    END AS income_bracket,
    COUNT(*) as total_customers
FROM users_data
GROUP BY 
        CASE 
        WHEN yearly_income < 20000 THEN 'Low Income (Below 20K)'
        WHEN yearly_income BETWEEN 20000 AND 50000 THEN 'Middle Income (20K - 50K)'
        WHEN yearly_income BETWEEN 50000 AND 100000 THEN 'Upper Income (50K - 100K)'
        ELSE 'High Income (Above 100K)'
    END
ORDER BY total_customers DESC;

-- INSIGHT: Middle-income earners dominate the distribution of the Banks customers. This offers a prime target for tailored banking products.



-- 1.5 Average Spend by Income Levels
With TotalSpend AS(
    SELECT 
        u.yearly_income,
        u.total_debt,
        u.credit_score,
        SUM(t.amount) as total_spend
    FROM users_data u
    JOIN transactions_data t ON u.id = t.client_id
    GROUP BY u.yearly_income, u.total_debt, u.credit_score
),
IncomeBracket AS (
    SELECT
        yearly_income,
        total_debt,
        total_spend,
        CASE 
            WHEN yearly_income < 20000 THEN 'Low Income (Below 20K)'
            WHEN yearly_income BETWEEN 20000 AND 50000 THEN 'Middle Income (20K - 50K)'
            WHEN yearly_income BETWEEN 50000 AND 100000 THEN 'Upper Income (50K - 100K)'
            ELSE 'High Income (Above 100K)'
        END AS income_bracket
    FROM TotalSpend
)

SELECT
    income_bracket,
    ROUND(AVG(total_spend), 2) as avg_spend
FROM IncomeBracket
GROUP BY income_bracket
ORDER BY avg_spend DESC;

-- INSIGHT: High-income customers, although being the fewest (52), recorded the highest average spend ($45,710.36).


-- 1.6 Customer demographics by Average Credit Score, Average Income and Average Debts

With CustomerSegmentation AS (
    SELECT 
        id,
        gender,
        total_debt,
        yearly_income,
        credit_score,
        CASE 
            WHEN birth_year BETWEEN 1995 AND 2002 THEN 'Young'
            WHEN birth_year BETWEEN 1970 AND 1994 THEN 'Middle-Aged'
            WHEN birth_year BETWEEN 1959 AND 1969 THEN 'Old'
            ELSE 'Very Old'
        END As age_group,
        CASE 
            WHEN credit_score BETWEEN 800 AND 850 THEN 'Exceptional'
            WHEN credit_score BETWEEN 740 AND 799 THEN 'Very Good'
            WHEN credit_score BETWEEN 670 AND 739 THEN 'Good'
            WHEN credit_score BETWEEN 580 AND 669 THEN 'Fair'
            ELSE 'Poor'
        END AS credit_bracket,
        CASE
            WHEN yearly_income < 20000 THEN 'Low Income (Below 20K)'
            WHEN yearly_income BETWEEN 20000 AND 50000 THEN 'Middle Income (20K - 50K)'
            WHEN yearly_income BETWEEN 50000 AND 100000 THEN 'Upper Income (50K - 100k)'
            ELSE 'High Income (Above 100K)'
        END AS income_bracket
    FROM users_data u
)

SELECT 
    credit_bracket,    
    ROUND(AVG(credit_score), 2) AS avg_credit_score,
    age_group,
    gender,
    COUNT(gender) AS gender_count,
    income_bracket,
    ROUND(AVG(yearly_income), 2) AS avg_income,
    ROUND(AVG(total_debt), 2) AS avg_debt
FROM CustomerSegmentation
GROUP BY 
    credit_bracket,
    age_group,
    gender,
    income_bracket
ORDER BY credit_bracket, gender_count, avg_income;

/* 
INSIGHTS:
a. Most of the customers with Exceptional credit scores are Middle income earners.
b. Middle-aged, Middle income earners populate most credit brackets, presenting a great bracket to target financial products and services.
c. Financial Products & Services such as loans, childrens savings accounts, bonds, and specialized savings accounts can be targetted at the Middle Income, Middle-aged customers
for increased uptake. 
d. Very old customers hold strong credit; these might be lower earners but they are quite trust worthy borrowers
*/



-- 2. CREDIT RISK ANALYSIS: debt-to-income ratios across income brackets and age groups and how these align with credit scores

-- 2.1 Customers with high debt to income ratio
SELECT TOP 10
    id,
     CASE 
        WHEN birth_year BETWEEN 1995 AND 2002 THEN 'Young'
        WHEN birth_year BETWEEN 1970 AND 1994 THEN 'Middle-Aged'
        WHEN birth_year BETWEEN 1959 AND 1969 THEN 'Old'
        ELSE 'Very Old'
    END As age_group,
    credit_score,
            CASE 
            WHEN credit_score BETWEEN 800 AND 850 THEN 'Exceptional'
            WHEN credit_score BETWEEN 740 AND 799 THEN 'Very Good'
            WHEN credit_score BETWEEN 670 AND 739 THEN 'Good'
            WHEN credit_score BETWEEN 580 AND 669 THEN 'Fair'
            ELSE 'Poor'
        END AS credit_bracket,
        CASE
            WHEN yearly_income < 20000 THEN 'Low Income (Below 20K)'
            WHEN yearly_income BETWEEN 20000 AND 50000 THEN 'Middle Income (20K - 50K)'
            WHEN yearly_income BETWEEN 50000 AND 100000 THEN 'Upper Income (50K - 100k)'
            ELSE 'High Income (Above 100K)'
        END AS income_bracket,  
    yearly_income,
    total_debt,
    ROUND((total_debt * 1.0/NULLIF(yearly_income, 0)), 2) AS debt_load_ratio
FROM users_data
ORDER BY debt_load_ratio DESC;


/*
INSIGHTS:
a. 8 out of the 10 customers with the highest debt load are highly leveraged (their debts outweigh their annual income by ~360% - 498%). 
Despite this, many have Good to Exceptional credit scores and fall within the Middle-Income bracket.
b. This suggests that these customers may owe good debts, such as mortgages, or have an impressive repayment history, keeping their credit scores high despite high borrowing.
c. To properly compute the DTI and distinguish between good risk and overextension, we need more data on the monthly debt repayments, repayment history, account age and activity, and product holdings; hence, the reversion to Total DTI.
*/

-- 2.2 Customers with high total debt to yearly income ratio who have poor credit scores
SELECT TOP 10
    id,
     CASE 
        WHEN birth_year BETWEEN 1995 AND 2002 THEN 'Young'
        WHEN birth_year BETWEEN 1970 AND 1994 THEN 'Middle-Aged'
        WHEN birth_year BETWEEN 1959 AND 1969 THEN 'Old'
        ELSE 'Very Old'
    END As age_group,
    credit_score,
            CASE 
            WHEN credit_score BETWEEN 800 AND 850 THEN 'Exceptional'
            WHEN credit_score BETWEEN 740 AND 799 THEN 'Very Good'
            WHEN credit_score BETWEEN 670 AND 739 THEN 'Good'
            WHEN credit_score BETWEEN 580 AND 669 THEN 'Fair'
            ELSE 'Poor'
        END AS credit_bracket,
        CASE
            WHEN yearly_income < 20000 THEN 'Low Income (Below 20K)'
            WHEN yearly_income BETWEEN 20000 AND 50000 THEN 'Middle Income (20K - 50K)'
            WHEN yearly_income BETWEEN 50000 AND 100000 THEN 'Upper Income (50K - 100k)'
            ELSE 'High Income (Above 100K)'
        END AS income_bracket,  
    yearly_income,
    total_debt,
    ROUND((total_debt * 1.0/NULLIF(yearly_income, 0)), 2) AS debt_load_ratio
FROM users_data
WHERE credit_score  < 580
ORDER BY debt_load_ratio DESC;

/*
INSIGHTS:
a. Of the 81 customers with poor credit scores, the top 10 have a total debt load ratio of ~244% - 389%.
b. 9 of the top 10 risky customers are middle-income individuals.
c. Statistically, persons with a DTI ratio above 50% are very likely to default on their loans.
d. We need more data on monthly loan repayments to capture a more precise DTI ratio.
*/ 

-- 2.3 Calculate Financial Stability Ratio: AvgIncome/AvgDebt
SELECT
    id,
     CASE 
        WHEN birth_year BETWEEN 1995 AND 2002 THEN 'Young'
        WHEN birth_year BETWEEN 1970 AND 1994 THEN 'Middle-Aged'
        WHEN birth_year BETWEEN 1959 AND 1969 THEN 'Old'
        ELSE 'Very Old'
    END As age_group,
    credit_score,
    CASE 
        WHEN credit_score BETWEEN 800 AND 850 THEN 'Exceptional'
        WHEN credit_score BETWEEN 740 AND 799 THEN 'Very Good'
        WHEN credit_score BETWEEN 670 AND 739 THEN 'Good'
        WHEN credit_score BETWEEN 580 AND 669 THEN 'Fair'
        ELSE 'Poor'
    END AS credit_bracket,
    CASE
        WHEN yearly_income < 20000 THEN 'Low Income (Below 20K)'
        WHEN yearly_income BETWEEN 20000 AND 50000 THEN 'Middle Income (20K - 50K)'
        WHEN yearly_income BETWEEN 50000 AND 100000 THEN 'Upper Income (50K - 100k)'
        ELSE 'High Income (Above 100K)'
    END AS income_bracket,  
    yearly_income,
    total_debt,
    (yearly_income/NULLIF(total_debt, 0)) AS financial_stability_ratio
FROM users_data
WHERE total_debt > 0.00
ORDER BY financial_stability_ratio DESC;

/*
INSIGHTS:
a. Financial Stability Ratio (FSR) calculates customers debt compared to their yearly income.
b. Those with an FSR above 100, all have fair to Exceptional credit scores. Made up of mostly middel income customers
*/


-- 3. SPENDING BEHAVIOUR BY MERCHANT CATEGORY (MCC): Top Spending Categories and Transaction Volumes by Merchant Category (MCC) and how do they vary by customer segment?

-- 3.1 Where do Customers spend the most money?
SELECT TOP 5
    m.description,
    ROUND(SUM(t.amount), 2) txn_volume_usd
FROM transactions_data t 
JOIN mcc_codes m ON t.mcc = m.mcc_id
GROUP BY m.description
ORDER by txn_volume_usd DESC;

-- INSIGHT: Money transfers account for the largest customer spend ($596,560), followed by Grocery Stores, Supermarkets ($501,980.56), Wholesale Clubs ($471,078.75), and Drug Stores and Pharmacies ($430,486.73).


-- 3.2 Where do the High-Income earners spend their money?

SELECT TOP 5
    CASE
        WHEN yearly_income < 20000 THEN 'Low Income (Below 20K)'
        WHEN yearly_income BETWEEN 20000 AND 50000 THEN 'Middle Income (20K - 50K)'
        WHEN yearly_income BETWEEN 50000 AND 100000 THEN 'Upper Income (50K - 100k)'
        ELSE 'High Income (Above 100K)'
    END AS income_bracket,
    m.Description as merchant,
    ROUND(SUM(t.amount), 2) as txn_volume
FROM transactions_data t
JOIN mcc_codes m ON m.mcc_id = t.mcc
JOIN users_data u ON t.client_id = u.id
WHERE yearly_income > 100000 AND errors IS NULL
GROUP BY 
    CASE
        WHEN yearly_income < 20000 THEN 'Low Income (Below 20K)'
        WHEN yearly_income BETWEEN 20000 AND 50000 THEN 'Middle Income (20K - 50K)'
        WHEN yearly_income BETWEEN 50000 AND 100000 THEN 'Upper Income (50K - 100k)'
        ELSE 'High Income (Above 100K)'
    END,
        m.description
ORDER BY txn_volume DESC;

/*
INSIGHTS:
High-income customers spent the most on eating places and restaurants (fine dining most likely) ($31,013), 
followed by money transfers ($23,480). Fast food restaurants were the third highest in transaction volume ($16,939), 
indicating that they are spending a significant amount on food.
*/


-- 3.3 Top Transactions by Customer segments (credit bracket and Income level)

SELECT Top 5
    CASE
        WHEN yearly_income < 20000 THEN 'Low Income (Below 20K)'
        WHEN yearly_income BETWEEN 20000 AND 50000 THEN 'Middle Income (20K - 50K)'
        WHEN yearly_income BETWEEN 50000 AND 100000 THEN 'Upper Income (50K - 100k)'
        ELSE 'High Income (Above 100K)'
    END AS income_bracket, 
    m.description as merchants,
    ROUND(SUM(t.amount), 2) as txn_volume
FROM transactions_data t
JOIN mcc_codes m ON t.mcc = m.mcc_id
JOIN users_data u ON t.client_id = u.id
GROUP BY
    m.description,
    CASE
        WHEN yearly_income < 20000 THEN 'Low Income (Below 20K)'
        WHEN yearly_income BETWEEN 20000 AND 50000 THEN 'Middle Income (20K - 50K)'
        WHEN yearly_income BETWEEN 50000 AND 100000 THEN 'Upper Income (50K - 100k)'
        ELSE 'High Income (Above 100K)'
    END
ORDER BY txn_volume DESC;



/*
INSIGHTS:
a. Money transfers ($194,540) account for the highest spend of all the merchant categories with those in the Middle Income Bracket accounting for most of this volume
b. Groceries and supermarkets ($149,697.31) account for the Second largest transaction volume iwth the MIddle income brcaket taking the lead in this regard as well
c. 3rd highest transaction volume in total with Middle Income bracket spending the most in this regard is Wholesale Clubs ($132,623.50)
d. The top merchants by transaction volume in the Upper Income bracket is Money Transfer ($136,400) followed by Drug Stores & Pharmacies ($132,623.50) and Service Stations ($126,859.96)
*/



-- 4. CARD USAGE PATTERNS: Average number of cars per customer and how does card usage by transaction frequency and value vary by demographic?
-- 4.1 Customers with the highest number of cards
SELECT 
    id,
    SUM(num_credit_cards) AS credit_cards
FROM users_data
GROUP BY id
ORDER BY credit_cards DESC;

-- 4.2 Average Number of cards per customer by demographic
SELECT
    CASE 
        WHEN credit_score BETWEEN 800 AND 850 THEN 'Exceptional'
        WHEN credit_score BETWEEN 740 AND 799 THEN 'Very Good'
        WHEN credit_score BETWEEN 670 AND 739 THEN 'Good'
        WHEN credit_score BETWEEN 580 AND 669 THEN 'Fair'
        ELSE 'Poor'
    END AS credit_bracket,
    CASE
        WHEN yearly_income < 20000 THEN 'Low Income (Below 20K)'
        WHEN yearly_income BETWEEN 20000 AND 50000 THEN 'Middle Income (20K - 50K)'
        WHEN yearly_income BETWEEN 50000 AND 100000 THEN 'Upper Income (50K - 100k)'
        ELSE 'High Income (Above 100K)'
    END AS income_bracket,  
    AVG(num_credit_cards) as avg_num_cards
FROM users_data
GROUP BY 
    CASE 
        WHEN credit_score BETWEEN 800 AND 850 THEN 'Exceptional'
        WHEN credit_score BETWEEN 740 AND 799 THEN 'Very Good'
        WHEN credit_score BETWEEN 670 AND 739 THEN 'Good'
        WHEN credit_score BETWEEN 580 AND 669 THEN 'Fair'
        ELSE 'Poor'
    END,
    CASE
        WHEN yearly_income < 20000 THEN 'Low Income (Below 20K)'
        WHEN yearly_income BETWEEN 20000 AND 50000 THEN 'Middle Income (20K - 50K)'
        WHEN yearly_income BETWEEN 50000 AND 100000 THEN 'Upper Income (50K - 100k)'
        ELSE 'High Income (Above 100K)'
    END
ORDER BY avg_num_cards DESC;

/*
INSIGHTS:
a. Those in the low-income bracket with exceptional credit scores have an average of 6 credit cards (the highest)
b. Upper-Income customers with exceptional credit scores have an average of 4 credit cards.
c. Those with poor credit scores have between 1 - 2 credit cards.
*/

-- 4.3 Transaction frequency and volume by demographic
SELECT
    CASE 
        WHEN credit_score BETWEEN 800 AND 850 THEN 'Exceptional'
        WHEN credit_score BETWEEN 740 AND 799 THEN 'Very Good'
        WHEN credit_score BETWEEN 670 AND 739 THEN 'Good'
        WHEN credit_score BETWEEN 580 AND 669 THEN 'Fair'
        ELSE 'Poor'
    END AS credit_bracket,
    CASE
        WHEN yearly_income < 20000 THEN 'Low Income (<20K)'
        WHEN yearly_income BETWEEN 20000 AND 50000 THEN 'Middle Income (20K - 50K)'
        WHEN yearly_income BETWEEN 50000 AND 100000 THEN 'Upper Income (50K - 100k)'
        ELSE 'High Income (Above 100K)'
    END AS income_bracket,
    ROUND(SUM(t.amount), 2) AS txn_value,
    COUNT(*) AS txn_frequency
FROM transactions_data t
JOIN users_data u ON t.client_id = u.id
WHERE t.errors IS NOT NULL
GROUP BY 
    CASE 
        WHEN credit_score BETWEEN 800 AND 850 THEN 'Exceptional'
        WHEN credit_score BETWEEN 740 AND 799 THEN 'Very Good'
        WHEN credit_score BETWEEN 670 AND 739 THEN 'Good'
        WHEN credit_score BETWEEN 580 AND 669 THEN 'Fair'
        ELSE 'Poor'
    END,
    CASE
        WHEN yearly_income < 20000 THEN 'Low Income (<20K)'
        WHEN yearly_income BETWEEN 20000 AND 50000 THEN 'Middle Income (20K - 50K)'
        WHEN yearly_income BETWEEN 50000 AND 100000 THEN 'Upper Income (50K - 100k)'
        ELSE 'High Income (Above 100K)'
    END
ORDER BY txn_value DESC;

/*
INSIGHTS:
a. Middle-income customers once again lead the transaction frequency (924) and total transaction value of $49,002.31
b. Upper income customer follow closely with 409 transactions worth $32,113.64.
*/


-- 5. FRAUD DETECTION AND ERROR RATES: Which locations or merchant categories have the highest transaction error rates or unusually high-value transactions?

-- 5.1 Locations and merchant categories with the highest transaction error rates

With AggErrors AS (
    SELECT
        m.[Description],
        t.merchant_city,
        t.merchant_state,
        t.errors,
        ROUND(SUM(t.amount), 2) AS txn_value
    FROM mcc_codes m
    JOIN transactions_data t ON m.mcc_id = t.mcc
    WHERE t.errors IS NOT NULL
    GROUP BY 
        m.[Description],
        t.merchant_city,
        t.merchant_state,
        t.errors
)

SELECT TOP 5
    *,
    COUNT(*) OVER (PARTITION BY Description ORDER BY txn_value DESC) as txn_volume
FROM AggErrors
ORDER BY txn_value DESC;


-- 5.1.1 Merchants with the highest recorded errors

SELECT TOP 5
    m.[Description],
    t.errors,
    ROUND(SUM(t.amount), 2) as txn_volume_USD    
FROM transactions_data t 
JOIN mcc_codes m ON t.mcc = m.mcc_id
WHERE t.errors IS NOT NULL
GROUP BY m.[Description], t.errors
ORDER BY txn_volume_USD DESC;


-- 5.1.2 Errors by transaciton volume

SELECT TOP 5
    errors,
    ROUND(SUM(amount), 2) as txn_volume
FROM transactions_data
WHERE errors IS NOT NULL
GROUP BY errors
ORDER BY txn_volume DESC;

/*
INSIGHTS:
a. Insufficient balance was the chief reason for transaction errors, accounting for a total of $123,259.26 of failed transactions.
b. Another key reason for transaction failures is technical glitches ($15,212.79), followed closely by client-side errors such as wrong pins, wrong card numbers, and wrong CVVs.
c. For merchants, Money Transfers accounted for the highest errors - $16,900 in failed transactions due to insufficient balance.
d. Orlando, Florida, recorded the highest total transaction errors value, all due to insufficient balance - $3,080 (money transfers) and $1,864.44 (automotive repair shops).

*/

-- 5.2 Fraud Detection: where the total transactions for the month are 200% higher than the Average monthly expenditure for a customer
With MonthlySpend AS (
    SELECT 
        client_id,
        FORMAT(date, 'yyyy-MM') as txn_month,
        SUM(amount) as monthly_spend
    FROM transactions_data 
    GROUP BY client_id, FORMAT(date, 'yyyy-MM')
),
AvgSpend AS (
    SELECT
        client_id,
        AVG(monthly_spend) as avg_monthly_spend
    FROM MonthlySpend
    GROUP BY client_id
)

SELECT 
    m.client_id as client,
    m.txn_month as month,
    ROUND(m.monthly_spend, 2) as monthly_spend,
    ROUND(a.avg_monthly_spend, 2) as avg_monthly_spend,
    ROUND((m.monthly_spend - a.avg_monthly_spend), 2) as spike_diff,
    ROUND((m.monthly_spend - a.avg_monthly_spend)/a.avg_monthly_spend,2) AS percent_diff
FROM AvgSpend a
JOIN MonthlySpend m ON a.client_id = m.client_id
WHERE m.monthly_spend > 2 * a.avg_monthly_spend
ORDER BY percent_diff DESC, spike_diff DESC;


-- 5.3 Flagging spike levels
With MonthlySpend AS (
    SELECT 
        client_id,
        FORMAT(date, 'yyyy-MM') as txn_month,
        SUM(amount) as monthly_spend
    FROM transactions_data 
    GROUP BY client_id, FORMAT(date, 'yyyy-MM')
),
AvgSpend AS (
    SELECT
        client_id,
        AVG(monthly_spend) as avg_monthly_spend
    FROM MonthlySpend
    GROUP BY client_id
),
SpikeLevels AS (
SELECT 
    m.client_id AS client_id,
    m.txn_month AS txn_month,
    m.monthly_spend,
    a.avg_monthly_spend,
    (m.monthly_spend - a.avg_monthly_spend) AS spike_diff,
    (m.monthly_spend - a.avg_monthly_spend)/a.avg_monthly_spend AS percent_diff,
	CASE
        WHEN m.monthly_spend > 3 * a.avg_monthly_spend  THEN 'Critical'
        WHEN m.monthly_spend > 2 * a.avg_monthly_spend  THEN 'High'
        WHEN m.monthly_spend > 1.5 *a.avg_monthly_spend THEN 'Moderate'
    ELSE 'Safe'
	END AS fraud_alert
FROM AvgSpend a
JOIN MonthlySpend m ON a.client_id = m.client_id
WHERE m.monthly_spend > 1.5 * a.avg_monthly_spend 
)

SELECT 
    client_id,
    txn_month,
    monthly_spend,
    avg_monthly_spend,
    ROUND(spike_diff, 2) as spike_diff,
    ROUND(percent_diff, 2) AS percent_diff,
	fraud_alert
FROM SpikeLevels
ORDER by fraud_alert;



-- 5.4 Customers who had multiple critical level transactions
With MonthlySpend AS (
    SELECT 
        client_id,
        FORMAT(date, 'yyyy-MM') as txn_month,
        SUM(amount) as monthly_spend
    FROM transactions_data 
    GROUP BY client_id, FORMAT(date, 'yyyy-MM')
),
AvgSpend AS (
    SELECT
        client_id,
        AVG(monthly_spend) as avg_monthly_spend
    FROM MonthlySpend
    GROUP BY client_id
),
SpikeLevels AS (
SELECT 
    m.client_id AS client_id,
    m.txn_month AS month,
    m.monthly_spend,
    a.avg_monthly_spend,
    (m.monthly_spend - a.avg_monthly_spend) AS spike_diff,
    (m.monthly_spend - a.avg_monthly_spend)/a.avg_monthly_spend AS percent_diff,
	CASE
        WHEN m.monthly_spend > 3 * a.avg_monthly_spend  THEN 'Critical'
        WHEN m.monthly_spend > 2 * a.avg_monthly_spend  THEN 'High'
        WHEN m.monthly_spend > 1.5 *a.avg_monthly_spend THEN 'Moderate'
    ELSE 'Safe'
	END AS fraud_alert
FROM AvgSpend a
JOIN MonthlySpend m ON a.client_id = m.client_id
WHERE m.monthly_spend > 1.5 * a.avg_monthly_spend
),
MultipleCriticals AS (
    SELECT
        client_id
    FROM SpikeLevels
    WHERE fraud_alert = 'Critical'
    GROUP BY client_id
    HAVING COUNT(*) > 1
),
FraudTxnCounts AS (
    SELECT 
        s.client_id,
        s.month,
        s.fraud_alert,
        COUNT(*) OVER (PARTITION BY mc.client_id) as txn_count
    FROM SpikeLevels s 
    JOIN MultipleCriticals mc ON s.client_id = mc.client_id
    WHERE s.fraud_alert = 'Critical'
)

SELECT
    s.client_id,
    s.month,
    s.fraud_alert,
    COUNT(*) OVER (PARTITION BY mc.client_id) as txn_count
FROM SpikeLevels s 
JOIN MultipleCriticals mc ON s.client_id = mc.client_id
WHERE s.fraud_alert = 'Critical'
ORDER BY txn_count DESC, s.client_id DESC, s.month DESC;



-- 5.5 Distinct Customers with multiple fraudulent transactions

With MonthlySpend AS (
    SELECT 
        client_id,
        FORMAT(date, 'yyyy-MM') as txn_month,
        SUM(amount) as monthly_spend
    FROM transactions_data 
    GROUP BY client_id, FORMAT(date, 'yyyy-MM')
),
AvgSpend AS (
    SELECT
        client_id,
        AVG(monthly_spend) as avg_monthly_spend
    FROM MonthlySpend
    GROUP BY client_id
),
SpikeLevels AS (
SELECT 
    m.client_id AS client_id,
    m.txn_month AS month,
    m.monthly_spend,
    a.avg_monthly_spend,
    (m.monthly_spend - a.avg_monthly_spend) AS spike_diff,
    (m.monthly_spend - a.avg_monthly_spend)/a.avg_monthly_spend AS percent_diff,
	CASE
        WHEN m.monthly_spend > 3 * a.avg_monthly_spend  THEN 'Critical'
        WHEN m.monthly_spend > 2 * a.avg_monthly_spend  THEN 'High'
        WHEN m.monthly_spend > 1.5 *a.avg_monthly_spend THEN 'Moderate'
    ELSE 'Safe'
	END AS fraud_alert
FROM AvgSpend a
JOIN MonthlySpend m ON a.client_id = m.client_id
WHERE m.monthly_spend > 1.5 * a.avg_monthly_spend
),
MultipleCriticals AS (
    SELECT
        client_id
    FROM SpikeLevels
    WHERE fraud_alert = 'Critical'
    GROUP BY client_id
    HAVING COUNT(*) > 1
),
FraudTxnCounts AS (
    SELECT 
        s.client_id,
        s.month,
        s.fraud_alert,
        COUNT(*) OVER (PARTITION BY mc.client_id) as txn_count
    FROM SpikeLevels s 
    JOIN MultipleCriticals mc ON s.client_id = mc.client_id
    WHERE s.fraud_alert = 'Critical'
)

SELECT DISTINCT
    f.client_id,
    f.fraud_alert,
    f.txn_count
FROM FraudTxnCounts f
ORDER BY f.txn_count DESC, f.client_id DESC;

/*
INSIGHTS: 
a. Between January 2022 and October 2024, exactly 100 transactions were flagged as having critical fraud level transacitons
b. 23 customers had 2+ repeated critical-level transactions 
*/



/*
=======================================================================================
CUSTOMER REPORT
=======================================================================================
Purpose
This report consolidates key customer metrics and behaviours

Highlights
1. Aggregates customer level_metrics:
	- Total transactions
	- Total cards issued per customer
	- Total loans 
	- Transaction volumne by merchant categories

2. Details customer segments by Age, Gender, Income, Credit Score

3. Financial Health and Debt-Load Ratio of customer segments
=======================================================================================

*/
CREATE VIEW vw_customer_report AS
WITH base_query AS (
-- Base Query
	SELECT
		t.id AS transaction_id,
		CAST(t.date AS date) AS txn_date,
		t.client_id,
		t.amount, 
		t.use_chip,
		t.errors,
		m.description AS merchant,
		u.birth_year,
		u.current_age,
		u.gender,
		u.yearly_income,
		u.total_debt,
		u.credit_score,
		u.num_credit_cards
	FROM transactions_data t
	LEFT JOIN mcc_codes m ON t.merchant_id = m.mcc_id
	JOIN users_data u ON t.client_id = u.id
),
aggregations AS(
-- 1. Aggregations 
	SELECT
		client_id,
		COUNT(transaction_id) AS total_transactions,
		COUNT(DISTINCT merchant) AS total_merchants,
		SUM(total_debt) AS total_loans_issued,
		SUM(num_credit_cards) AS total_cards_issued,
		AVG(credit_score) AS avg_credit_score,
		SUM(amount) AS total_spend
	FROM base_query
	GROUP BY client_id
),
-- 2. Customer segments by Age, Gender, Income, Credit Score
CustomerSegmentation AS (
    SELECT 
        b.client_id,
		b.current_age,
		b.gender,
		b.yearly_income,
		b.total_debt,
		a.total_spend,
		b.credit_score,
		b.num_credit_cards
    FROM base_query b
	LEFT JOIN aggregations a ON b.client_id = a.client_id
)
SELECT 
    b.client_id,
	b.birth_year,
	b.current_age,
	b.gender,
	b.yearly_income,
	b.total_debt,
	a.total_spend,
	b.credit_score,
	b.num_credit_cards,
	a.total_transactions,
	a.total_merchants,
	a.total_loans_issued,
	a.total_cards_issued,
	a.avg_credit_score,
	CASE 
        WHEN b.birth_year BETWEEN 1995 AND 2002 THEN 'Young'
        WHEN b.birth_year BETWEEN 1970 AND 1994 THEN 'Middle-Aged'
        WHEN b.birth_year BETWEEN 1959 AND 1969 THEN 'Old'
        ELSE 'Very Old'
    END AS age_group,
    CASE 
        WHEN b.credit_score BETWEEN 800 AND 850 THEN 'Exceptional'
        WHEN b.credit_score BETWEEN 740 AND 799 THEN 'Very Good'
        WHEN b.credit_score BETWEEN 670 AND 739 THEN 'Good'
        WHEN b.credit_score BETWEEN 580 AND 669 THEN 'Fair'
        ELSE 'Poor'
    END AS credit_bracket,
    CASE
        WHEN b.yearly_income < 20000 THEN 'Low Income (Below 20K)'
        WHEN b.yearly_income BETWEEN 20000 AND 50000 THEN 'Middle Income (20K - 50K)'
        WHEN b.yearly_income BETWEEN 50000 AND 100000 THEN 'Upper Income (50K - 100k)'
        ELSE 'High Income (Above 100K)'
    END AS income_bracket,
-- 4. Financial Health and Debt-Load Ratio
    ROUND((b.total_debt * 1.0/NULLIF(yearly_income, 0)), 2) AS debt_load_ratio
FROM base_query b
LEFT JOIN aggregations a ON b.client_id = a.client_id
GROUP BY b.client_id, b.birth_year, b.current_age, b.gender, b.yearly_income, b.total_debt, a.total_spend, 
			b.credit_score, b.num_credit_cards, a.total_transactions, a.total_merchants,
			a.total_loans_issued, a.total_cards_issued, a.avg_credit_score;


/*
=======================================================================================
FRAUD REPORT

=======================================================================================
*/
-- 3. Fraudulent transactions (MonthlySpend, AvgSpend, SpikeLevels)

CREATE VIEW vw_fraud_report AS
With base_query AS(
	SELECT 
		t.id as transaction_id,
		CAST(t.date AS date) AS txn_date,
		t.client_id,
		t.amount
	FROM transactions_data t
),
MonthlySpend AS (
    SELECT 
        client_id,
		CONVERT(char(7), txn_date, 120) as txn_month,
        SUM(amount) as monthly_spend
    FROM base_query 
    GROUP BY client_id, CONVERT(char(7), txn_date, 120)
),
AvgSpend AS (
    SELECT
        client_id,
        AVG(monthly_spend) as avg_monthly_spend
    FROM MonthlySpend
    GROUP BY client_id
),
SpikeLevels AS (
SELECT 
	m.client_id,
    m.txn_month,
	m.monthly_spend,
	a.avg_monthly_spend,
    (m.monthly_spend - a.avg_monthly_spend) AS spike_diff,
    (m.monthly_spend - a.avg_monthly_spend)/ NULLIF(a.avg_monthly_spend, 0) AS percent_diff
FROM MonthlySpend m
JOIN AvgSpend a ON m.client_id = a.client_id
WHERE m.monthly_spend > 1.5 * a.avg_monthly_spend
)

SELECT
	s.client_id,
	s.txn_month,
	s.monthly_spend,
	s.avg_monthly_spend,
	ROUND(spike_diff, 2) as spike_diff,
	ROUND(percent_diff, 2) as percent_diff,
	CASE
        WHEN s.monthly_spend > 3 * ROUND(s.avg_monthly_spend,2) THEN 'Critical'
        WHEN s.monthly_spend > 2 * ROUND(s.avg_monthly_spend,2) THEN 'High'
		WHEN s.monthly_spend > 1.5 * ROUND(s.avg_monthly_spend,2) THEN 'Moderate'
		ELSE 'Safe'
	END AS fraud_alert
FROM SpikeLevels s;




/*
CONCLUSION:
This analysis provides a clear picture of the bank's customer base, their spending patterns, and associated risks (credit and fraud). 
Middle-income, middle-aged customers make up the core segment, driving transaction volume and engagement across most categories. 
High-income customers, although a fraction of the other segments in number, recorded a much higher average spend ($45,710.36) than the other income segments.
Their expenditure showed a disproportionately high spend on dining, fast food, and money transfers, indicating an opportunity for marketing in these merchant outlets.

Credit Risk analysis revealed debt-heavy but credit-worthy customers who are possibly leveraging good debt. 
This underscores the need for bespoke credit management strategies.

Customer spending is anchored on money transfers and essential goods, highlighting opportunities for loyalty programs and partnerships with these merchant categories.

Fraud detection flagged 23 customers with repeated critical-level anomalies, signaling a need for immediate investigative actions to mitigate financial exposure. 

These insights, if leveraged, can enhance profitability, reduce exposure to credit and fraud risks, and strengthen customer loyalty.


RECOMMENDATIONS:
Marketing & Customer Retention: Focus marketing efforts on middle-aged, middle-income earners to maximise reach and develop premium offerings to high-income customers. Build partnerships with fine dining establishments and fast food outlets frequented by customers, to launch cross-promotional offers and loyalty incentives. 
Risk & Fraud Prevention: Initiate immediate investigations on the 23 customers whose accounts recorded multiple critical-level transactions to minimize exposure to fraud. Enhance fraud detection by implementing business rules for live detection to ensure swift action.
Operational Adjustments: Upgrade network, third-party, and inter-banking software to minimize technical glitches. Monitor customers with high debt load and strong credit scores to identify sustainable lending policies and nuanced credit limits without increasing default risk. 
Expand Data Collection: Broaden data collection to include monthly loan repayments to enable more precise debt calculations and analyses.
*/




-- PART 2 --
-- REAL-TIME CREDIT RISK DETECTION & FRAUD DETECTION

-- 1. Real-Time Credit Risk Detection
-- The goal here is to create business logic to flag and record customers that pose a credit risk now
-- and in the future


-- 1.1 Customers that pose a Credit Risk
-- Business Logic: Those with high debt_load_ratio and Fair to Poor credit scores pose credit risk
SELECT
	id,
	CASE
		WHEN yearly_income < 20000 THEN 'Low Income (Below 20K)'
		WHEN yearly_income BETWEEN 20000 AND 50000 THEN 'Middle Income (20K - 50K)'
		WHEN yearly_income BETWEEN 50000 AND 100000 THEN 'Upper Income (50K - 100K)'
		ELSE 'High Income (Above 100K)'
	END AS income_bracket,
	CASE 
		WHEN credit_score BETWEEN 800 AND 850 THEN 'Exceptional'
		WHEN credit_score BETWEEN 740 AND 799 THEN 'Very Good'
		WHEN credit_score BETWEEN 670 AND 739 THEN 'Good'
		WHEN credit_score BETWEEN 580 AND 669 THEN 'Fair'
		ELSE 'Poor'
	END AS credit_bracket,
	credit_score,
	yearly_income,
	total_debt,
	ROUND((total_debt/NULLIF(yearly_income, 0)),2) AS debt_load_ratio
FROM users_data
WHERE credit_score < 670 AND ROUND((total_debt/NULLIF(yearly_income, 0)),2) >= 0.5
ORDER by debt_load_ratio DESC;



-- 1.3 Risk Labels: Banks categorize Debt to Income ratios above 0.4 (40%) as worthy of concern and designate DTI >= 0.5 as risky
-- We shall designate Risk labels accordingly

With RiskyCustomers AS(
	SELECT
	id,
	CASE
		WHEN yearly_income < 20000 THEN 'Low Income (Below 20K)'
		WHEN yearly_income BETWEEN 20000 AND 50000 THEN 'Middle Income (20K - 50K)'
		WHEN yearly_income BETWEEN 50000 AND 100000 THEN 'Upper Income (50K - 100K)'
		ELSE 'High Income (Above 100K)'
	END AS income_bracket,
	CASE 
		WHEN credit_score BETWEEN 800 AND 850 THEN 'Exceptional'
		WHEN credit_score BETWEEN 740 AND 799 THEN 'Very Good'
		WHEN credit_score BETWEEN 670 AND 739 THEN 'Good'
		WHEN credit_score BETWEEN 580 AND 669 THEN 'Fair'
		ELSE 'Poor'
	END AS credit_bracket,
	credit_score,
	yearly_income,
	total_debt,
	ROUND((total_debt/NULLIF(yearly_income, 0)),2) AS debt_load_ratio,
	CASE
		WHEN ROUND((total_debt/NULLIF(yearly_income, 0)),2) BETWEEN 0.5 AND 0.99 THEN 'Moderate'
		WHEN ROUND((total_debt/NULLIF(yearly_income, 0)),2) BETWEEN 1.0 AND 1.99 THEN 'High'
		WHEN ROUND((total_debt/NULLIF(yearly_income, 0)),2) >= 2.0 THEN 'Critical'
		ELSE 'Safe'
	END AS risk_level
FROM users_data
WHERE credit_score < 670 AND ROUND((total_debt/NULLIF(yearly_income, 0)),2) >= 0.5
)

SELECT *
FROM RiskyCustomers
ORDER BY risk_level, debt_load_ratio DESC;



-- 1.4 Loan  Triggers

-- 1.4.1 Create Log Tables for Customers who pose Credit Risk

CREATE TABLE credit_risk_flags (
	flag_id INT PRIMARY KEY IDENTITY (1,1) NOT NULL,
	client_id INT NOT NULL,
	credit_score INT NOT NULL,
	yearly_income DECIMAL (10,2) NOT NULL,
	total_debt DECIMAL (10,2) NOT NULL,
	debt_load_ratio DECIMAL (10,2) NOT NULL,
	risk_level VARCHAR(20) NOT NULL,
	flagged_at DATETIME DEFAULT GETDATE() NOT NULL
);




-- 1.4.2 Batch insert of all current Accounts at Risk
INSERT INTO credit_risk_flags (client_id, credit_score, yearly_income, total_debt, debt_load_ratio, risk_level, flagged_at)
SELECT
	u.id,
	u.credit_score,
	u.yearly_income,
	u.total_debt,
	ROUND((u.total_debt/NULLIF(u.yearly_income, 0)),2) AS debt_load_ratio,
	CASE
		WHEN ROUND((total_debt/NULLIF(yearly_income, 0)),2) BETWEEN 0.5 AND 0.99 THEN 'Moderate'
		WHEN ROUND((total_debt/NULLIF(yearly_income, 0)),2) BETWEEN 1.0 AND 1.99 THEN 'High'
		WHEN ROUND((total_debt/NULLIF(yearly_income, 0)),2) >= 2.0 THEN 'Critical'
		ELSE 'Safe'
	END AS risk_level,
	GETDATE()
FROM users_data u
WHERE ROUND((u.total_debt/NULLIF(u.yearly_income, 0)),2) >= 0.5
	AND credit_score < 670;

SELECT * FROM credit_risk_flags; 



-- 1.4.3 Credit Risk Trigger

CREATE TRIGGER trg_flag_credit_risk ON users_data
AFTER INSERT, UPDATE
AS 
BEGIN
	INSERT INTO credit_risk_flags (client_id, credit_score, yearly_income, total_debt, debt_load_ratio, risk_level)
	SELECT
		i.id,
		i.credit_score,
		yearly_income,
		total_debt,
		ROUND((i.total_debt * 1.0/NULLIF(i.yearly_income, 0)), 2) AS debt_load_ratio,
		CASE 
			WHEN i.credit_score < 670 AND ROUND((i.total_debt * 1.0/NULLIF(i.yearly_income, 0)), 2) BETWEEN 0.5 AND 0.99 THEN 'Moderate'
			WHEN i.credit_score < 670 AND ROUND((i.total_debt * 1.0/NULLIF(i.yearly_income, 0)), 2) BETWEEN 1.0 AND 1.99 THEN 'High'
			WHEN i.credit_score < 670 AND ROUND((i.total_debt * 1.0/NULLIF(i.yearly_income, 0)), 2) >= 2.0 THEN 'Critical'
		END AS risk_level
	FROM inserted i
	WHERE i.credit_score < 670 
	AND ROUND((i.total_debt * 1.0/NULLIF(i.yearly_income, 0)), 2) >= 0.5;
END;




-- 2. Real-Time Fraud Detection
-- 2.1 Create log table for fraudulent transactions

CREATE TABLE fraud_flags (
	flag_id INT PRIMARY KEY IDENTITY (1,1) NOT NULL,
	transaction_id INT NOT NULL,
	client_id INT NOT NULL,
	txn_date DATETIME DEFAULT GETDATE(),
	avg_monthly_spend DECIMAL(10, 2) NOT NULL,
	amount INT NOT NULL,
	reason VARCHAR(500),
	flagged_at DATETIME DEFAULT GETDATE()
);


-- 2.2 Fraud detection logic; Anomally detection
-- Anomalies
-- a. High transaction value 
-- b. high frequency in a short time


With MonthlySpend AS (
	SELECT
		client_id,
		FORMAT(date, 'yyyy-MM') AS txn_month,
		SUM(amount) as monthly_spend
	FROM transactions_data
	GROUP BY client_id, FORMAT(date, 'yyyy-MM')
),
AvgSpend AS (
    SELECT
        client_id,
        ROUND(AVG(monthly_spend),2) AS avg_monthly_spend
    FROM MonthlySpend
    GROUP BY client_id
),
HighValueTransactions AS (
    SELECT
        t.id AS txn_id,
        t.client_id,
        t.date AS txn_date,
		a.avg_monthly_spend,
        t.amount AS txn_amount,
        'High Spend vs Avg Spend' AS reason
    FROM transactions_data t
    JOIN AvgSpend a ON t.client_id = a.client_id
    WHERE t.amount > 3 * a.avg_monthly_spend
),
HighFrequency AS (
    SELECT
        t1.id AS txn_id,
		t1.client_id,
        t1.date AS txn_date,
		a.avg_monthly_spend,
        t1.amount AS txn_amount,
        'High frequency transactions' AS reason
    FROM transactions_data t1
    JOIN transactions_data t2 ON t1.client_id = t2.client_id
        AND t2.date BETWEEN DATEADD(MINUTE, -5, t1.date) AND t1.date  -- looks at all transactions on hte account within 5 minutes
	JOIN AvgSpend a ON a.client_id = t1.client_id
    GROUP BY t1.client_id, t1.id, t1.date, a.avg_monthly_spend, t1.amount
    HAVING COUNT(*) >= 4
)

SELECT * FROM HighValueTransactions
UNION ALL
SELECT * FROM HighFrequency;




-- 2.3 Create Fraud Summary Table: This creates a look-up table for the MonthlySpend and AvgSpend
CREATE TABLE customer_spend_summary (
	client_id INT PRIMARY KEY,
	avg_monthly_spend DECIMAL(12,2)
)

INSERT INTO customer_spend_summary(client_id, avg_monthly_spend)
SELECT
	client_id,
	ROUND(AVG(monthly_spend),2) as avg_monthly_spend
FROM (
	SELECT	
		client_id,
		DATEPART(YEAR, date) AS txn_yr,
		DATEPART(MONTH, date) AS txn_month,
		SUM(amount) AS monthly_spend
	FROM transactions_data
	GROUP BY client_id, DATEPART(YEAR, date), DATEPART(MONTH, date)
) m
GROUP BY client_id;

SELECT * FROM customer_spend_summary;


-- 2.4 Fraud Detection Trigger
CREATE TRIGGER tr_flag_suspicious_txns ON transactions_data
AFTER INSERT
AS
BEGIN
	SET NOCOUNT ON;
	-- a. High Spend vs. Avg Spend
	INSERT INTO fraud_flags (transaction_id, client_id, txn_date, avg_monthly_spend, amount, reason)
	SELECT
        i.id,
        i.client_id,
        i.date,
		cs.avg_monthly_spend,
        i.amount,
        'High Spend vs Avg Spend'
    FROM inserted i 
    JOIN customer_spend_summary cs ON i.client_id = cs.client_id
    WHERE i.amount > 3 * cs.avg_monthly_spend;

	-- b. High frequency (4+ transactions within 5 minutes)
	INSERT INTO fraud_flags (transaction_id, client_id, txn_date, avg_monthly_spend, amount, reason)
	SELECT
		i.id,
		i.client_id,
		i.date,
		cs.avg_monthly_spend,
		i.amount,
		'High frequency transactions'
	FROM inserted i
	JOIN customer_spend_summary cs ON i.client_id = cs.client_id 
	CROSS APPLY (
		SELECT COUNT(*) AS txn_count
		FROM transactions_data t
		WHERE t.client_id = i.client_id	
			AND t.date BETWEEN DATEADD(MINUTE, -5, i.date) AND i.date
	) recent r
	WHERE r.txn_count >= 4
END;


/*
Conclusion:
1. The triggers create automated risk prevention systems and real-time anomaly detection to ensure
a reductino in the banks exposure to credit and fraud risks.

2. The customer logs for loans and suspicious transactions also enable the Bank to comply
with reporting obligations to regulators and fulfill its audit responsibilities to stakeholders.

3. We have shown that advanced SQL queries can be effective for risk monitoring and fraud detection.







