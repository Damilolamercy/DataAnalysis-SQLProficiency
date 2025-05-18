-- Question 1
-- Task: Write a query to find customers with at least one funded-
-- savings plan AND one funded investment plan, sorted by total deposits.

-- Created a temporary table to get users who have funded savings plans
WITH savingsplan AS(
	Select distinct s.owner_id, 
    count(distinct s.plan_id) as savings,
	round(SUM(s.confirmed_amount)/100,2) as sum_of_savings -- converted the total confirmed savings deposits from kobo to naira
	from savings_savingsaccount s
    
	JOIN plans_plan P ON s.plan_id=p.id
    
	where p.is_regular_savings = 1 -- filtered to include savings plan only
	AND s.transaction_status = 'success' -- and successful transactions
	group by s.owner_id
),
-- Created a temporary table to get users who have funded investment plans
investmentplan AS(
	Select distinct s.owner_id, count(distinct s.plan_id) as investment,
	Round(Sum(s.confirmed_amount)/100,2) as sum_of_investment -- converted total confirmed investment from kobo to naira
	from savings_savingsaccount s
    
	JOIN plans_plan P ON s.plan_id=p.id
    
	where p.is_a_fund = 1 AND s.transaction_status = 'success' 
	group by s.owner_id
)
-- Select high-value users who have both funded savings and investment plans
SELECT 
    distinct u.id as owner_id, 
    CONCAT(u.first_name, ' ', u.last_name) AS fullname, 
    s.savings, -- count/number of savings plan 
    -- s.sum_of_savings,
    i.investment, -- number of investment plan
    -- i.sum_of_investment,
    COALESCE(s.sum_of_savings, 0) + COALESCE(i.sum_of_investment, 0) AS total_deposits -- total inflow from savings and investment plan
FROM 
    users_customuser u
LEFT JOIN 
    savingsplan s ON u.id = s.owner_id -- join savingsplan table (CTE) to savings information
LEFT JOIN 
    investmentplan i ON u.id = i.owner_id -- join investmentplan table (CTE) to investment information
    
WHERE 
u.last_name NOT LIKE '%test%' AND -- exclude test accounts
u.is_active = 1 AND -- only active user
u.is_admin = 0 AND -- exclude admin accounts
    COALESCE(s.sum_of_savings, 0) > 0 AND -- ensure user have savingss 
    COALESCE(i.sum_of_investment, 0) > 0 AND -- ensure user have investment
    COALESCE(s.savings, 0) > 0 AND -- ensure user have at least 1 saving plan 
    COALESCE(i.investment, 0) > 0 -- ensure user have at least 1 investment plan
    Order by total_deposits;






