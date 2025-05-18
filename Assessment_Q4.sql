
-- question 4
-- For each customer, assuming the profit_per_transaction is 0.1% of the transaction value, calculate:
-- Account tenure (months since signup)
-- Total transactions
-- Estimated CLV (Assume: CLV = (total_transactions / tenure) * 12 * avg_profit_per_transaction)
-- Order by estimated CLV from highest to lowest

-- to get the latest date_joined in your data and use as a fixed point for current date
select max(date_joined) from users_customuser -- ='2025-04-17'

-- Calculate account tenure (month since signup)
WITH Initial AS(
	SELECT distinct u.id, CONCAT(u.first_name, ' ', u.last_name) AS fullname, 
	TIMESTAMPDIFF(MONTH, date_joined, '2025-04-17') AS months_difference
	FROM users_customuser u
	group by u.id,fullname 
	),
    
   -- to get the total transaction and profit for each user 
Phase2 AS (
	select distinct(s.owner_id), count(s.owner_id) as transaction_count, 
	round(sum(s.confirmed_amount)/100,2) as total_transaction_value, -- converting to naira
	 round(SUM(0.001 * s.confirmed_amount) / 100, 2) as profit -- assuming 0.1% profit per transaction
     
	from savings_savingsaccount s
	WHERE s.transaction_status = 'success'
		AND s.confirmed_amount > 0 
	group by s.owner_id
	),
    
   -- Average profite per transaction for each user 
Phase3 AS (
	select owner_id, (profit/transaction_count) as avg_profit_per_transaction,
	transaction_count, 
	total_transaction_value,
	 profit
	from Phase2
	)
-- Estimated CLV (Assume: CLV = (total_transactions / tenure) * 12 * avg_profit_per_transaction)
select id as customer_id, fullname as name, 
months_difference as tenure_months,transaction_count as total_transaction,  
COALESCE(round(((transaction_count / months_difference) * 12 * avg_profit_per_transaction),2),0)as CLV
from initial
LEFT JOIN phase3 ON phase3.owner_id =initial.id
where transaction_count >0
order by CLV DESC