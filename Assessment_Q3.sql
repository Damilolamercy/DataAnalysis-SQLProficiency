

-- Question 3
-- Task: Find all active accounts (savings or investments) 
-- with no transactions in the last 1 year (365 days)

-- to get the maximum transaction date and use as a fixed date
SELECT MAX(s.transaction_date)  from savings_savingsaccount s -- 2025-04-18

-- A table to get the last transaction date per plan
WITH initial AS(

	SELECT
		p.id AS plan_id,
		p.owner_id,
		CASE
			WHEN p.is_regular_savings = 1 THEN 'Savings'
			WHEN p.is_a_fund = 1 THEN 'Investment'
			ELSE 'Other'
		END AS type,
		CAST(MAX(s.transaction_date) AS DATE) AS last_transaction_date, -- most recent transaction date
		DATEDIFF("2025-04-18", MAX(s.transaction_date)) AS inactivity_days -- days since last transaction date
	FROM plans_plan p
	LEFT JOIN savings_savingsaccount s
		ON p.id = s.plan_id -- get all transactions per plan
		
	WHERE s.transaction_status = 'success'
		AND s.confirmed_amount > 0 AND 
		(p.is_regular_savings = 1 OR p.is_a_fund = 1) -- include only relevant savings or investment plan
		AND p.is_deleted = 0 -- taking out deleted plan
		
	GROUP BY
		p.id,
		p.owner_id,
		type
		
	HAVING -- select only plan that have been inactive for more than 365 days
		(MAX(s.transaction_date) IS NULL OR MAX(s.transaction_date) < "2025-04-18" - INTERVAL 365 DAY)
	ORDER BY inactivity_days DESC
    )
select * from initial
where inactivity_days >365