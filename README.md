# DataAnalytics-Assessment

Q1: High-Value Customers

Goal: Identify customers with ≥1 funded savings plan and ≥1 funded investment plan, then rank by total deposits.

Approach:

Aggregate savings (COUNT(DISTINCT savings_id), SUM(confirmed_amount)) from savings_savingsaccount where status = funded.

Aggregate investments (COUNT(*), SUM(amount)) from plans_plan where type = investment and status = funded.

Inner-join both on owner_id, join users_customuser for names, compute total_deposits, sort DESC.

Challenges:

Discovered actual monetary columns (confirmed_amount, amount).

Mapped business statuses/types to transaction_status, plan_type_id, status_id.



Q2: Transaction Frequency Analysis

Goal: Segment customers by their average monthly transactions into High (≥10), Medium (3–9), and Low (≤2) frequency.

Approach:

Bucket transactions by month (DATE_FORMAT), count per customer per month.

Calculate each customer’s average monthly count.

Categorize via CASE into frequency buckets.

Count customers and compute overall avg transactions/month per bucket, round to one decimal.

Challenges:

Only active months counted; including zero-transaction months requires a calendar join.

Ensured proper status filter for valid transactions.

Rounding for readability.



Q3: Account Inactivity Alert

Goal: Flag savings or investment accounts with no inflow transactions in the last 365 days.

Approach:

For savings: find MAX(transaction_date) per savings_id where status = completed.

For investments: use last_charge_date from active investment plans (plan_type_id, status_id).

Union both sets with labels, filter where last_tx < CURDATE() - INTERVAL 365 DAY, compute DATEDIFF for inactivity days.

Challenges:

Different schemas: transactions vs. plan dates.



Q4: Customer Lifetime Value (CLV)

Goal: Estimate CLV = (avg transactions/year) × profit per transaction (0.1% of value).

Approach:

Compute tenure_months via TIMESTAMPDIFF from date_joined.

From savings transactions (status = completed), get COUNT(*) and AVG(amount) per customer.

Apply formula: (total_tx / tenure_months) × 12 × (avg_amount × 0.001), round to two decimals.

Join tenure and tx stats, filter out zero-tenure, sort by CLV DESC.

Challenges:

Handling zero-tenure edge cases.
