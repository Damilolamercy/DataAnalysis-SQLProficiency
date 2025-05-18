
-- Question 2
-- Task: Calculate the average number of transactions per customer per month and categorize them:
-- "High Frequency" (≥10 transactions/month)
-- "Medium Frequency" (3-9 transactions/month)
-- "Low Frequency" (≤2 transactions/month)

-- Extracted the month for each transaction
WITH monthly_transactions AS (
    SELECT
        s.owner_id,
        monthname(DATE(transaction_date)) AS month  -- To get the month
    FROM savings_savingsaccount s
    WHERE s.transaction_status = 'success'  -- choosing only successful transactions--
),
-- Count total transactions per months per user
user_transaction_counts AS (
    SELECT
        owner_id,
        COUNT(*) AS total_transactions,              -- Total number of transactions
        COUNT(DISTINCT month) AS active_months  -- Number of distinct months with at least one transaction
    FROM monthly_transactions
    GROUP BY owner_id
),
-- Average number of transactions per active_month
user_averages AS (
    SELECT
        owner_id,
        ROUND(total_transactions * 1.0 / NULLIF(active_months, 0), 2) AS avg_txns_per_month
    FROM user_transaction_counts
),

-- Categorize each customer based on transaction frequency
categorized_users AS (
    SELECT
        u.id AS user_id,
        a.avg_txns_per_month,
        CASE
            WHEN a.avg_txns_per_month >= 10 THEN 'High Frequency'
            WHEN a.avg_txns_per_month >= 3 THEN 'Medium Frequency'
            ELSE 'Low Frequency'
        END AS frequency_category
    FROM user_averages a
    JOIN users_customuser u ON u.id = a.owner_id
)

-- Count users in each category and get average txns per group
SELECT
    frequency_category, 
    COUNT(user_id) AS customer_count,  -- Number of users in each frequency group
    ROUND(AVG(avg_txns_per_month), 2) AS avg_transactions_per_month
FROM categorized_users
GROUP BY frequency_category
ORDER BY
    CASE frequency_category -- order results from High to Low
        WHEN 'High Frequency' THEN 1
        WHEN 'Medium Frequency' THEN 2
        ELSE 3
	END;
        
