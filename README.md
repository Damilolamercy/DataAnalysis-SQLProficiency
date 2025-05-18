# Data Analytics Assessment - SQL Proficiency

The SQL queries for this assessment were to answer questions related to cross-selling opportunities, transaction frequency - frequent vs occasional users, inactive accounts, and customer lifetime value (CLV). Below are detailed explanations of my approach to each question and the challenges I encountered.

---

## ✅ Per-Question Explanations

### **Question 1: High-Value Customers with Multiple Products**

**Task:**  
Identify customers with at least one funded savings plan AND one funded investment plan, sorted by total deposits.

**Approach:**  
- Created two CTEs (`savingsplan` and `investmentplan`) to isolate customers with successful transactions in regular savings and investment plans.
- Filtered for customers with at least one funded plan of each type.
- Calculated the total deposit by summing confirmed savings and investment amounts (converted from Kobo to Naira).
- Applied filters in the where clause to exclude test users, inactive users, and admins.
- Sorted the final result by total deposit.

---

### **Question 2: Transaction Frequency Analysis**

**Task:**  
Calculate the average number of transactions per customer per month and categorize them based on how frequently they transact each month.

**Approach:**  
- Extracted successful transactions per month per user.
- Counted total transactions and distinct active months to calculate average monthly transaction frequency.
- Categorized users into:  
  - High Frequency (≥10 transactions/month)  
  - Medium Frequency (3–9 transactions/month)  
  - Low Frequency (≤2 transactions/month)
- Aggregated and displayed the number of users and average monthly transactions per category.

---

### **Question 3: Account Inactivity Alert**

**Task:**  
Find all active accounts (savings or investment) with no transactions in the last 365 days.

**Approach:**  
- Joined `plans_plan` with `savings_savingsaccount` to track transactions by plan.
- Grouped by plan, owner_id,Id and extracted the latest transaction date.
- Used `DATEDIFF` to calculate inactivity in days.
- Filtered for plans where the last transaction was more than 365 days ago or where no transaction exists at all.
- Ensured successful transactions, relevant plan, and non-deleted plans were considered.

---

### **Question 4: Customer Lifetime Value (CLV)**

**Task:**  
Estimate CLV for each customer based on transaction volume and account tenure.

**Approach:**  
- Used the latest `date_joined` in the dataset (`2025-04-17`) as the reference date for tenure.
- Calculated each customer’s tenure in months.
- Summed confirmed transaction amounts (converted from Kobo to Naira).
- Estimated profit per user as 0.1% of transaction value.
- Applied the formula:  
  `CLV = (total_transactions / tenure_months) * 12 * avg_profit_per_transaction`
- Filtered out users with no transactions and sorted by estimated CLV.

---

## 🧩 Challenges & Resolutions

### 1. **Tenure Calculation Without `CURRENT_DATE()`**
- **Challenge:** The dataset is static, and using `CURRENT_DATE()` could lead to inaccurate tenure if run later.
- **Solution:** Used the latest `date_joined` value (`2025-04-17`) as a fixed date for consistency.

### 2. **Currency Conversion**
- **Challenge:** All amount fields were stored in Kobo.
- **Solution:** Ensured all relevant amounts were divided by 100 and rounded to 2 decimal places.

### 3. **Avoiding Division by Zero**
- **Challenge:** CLV calculation could result in division by zero for users with zero tenure.
- **Solution:** Ensured tenure > 0 through data context; optionally, can add explicit filter for safety.


---




