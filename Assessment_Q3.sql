WITH savings_activity AS (
  SELECT
    savings_id         AS account_id,
    owner_id,
    MAX(transaction_date) AS last_tx
  FROM adashi_staging.savings_savingsaccount
  WHERE transaction_status = 'success'   
  GROUP BY savings_id, owner_id
),
investment_activity AS (
  SELECT
    id                 AS account_id,
    owner_id,
    last_charge_date   AS last_tx
  FROM adashi_staging.plans_plan
  WHERE status_id = 1                       
    AND plan_type_id = 1                    
),
combined AS (
  SELECT account_id, owner_id, 'Savings'    AS acct_type, last_tx
  FROM savings_activity
  UNION ALL
  SELECT account_id, owner_id, 'Investment' AS acct_type, last_tx
  FROM investment_activity
)
SELECT
  account_id      AS plan_id,
  owner_id,
  acct_type       AS type,
  last_tx         AS last_transaction_date,
  DATEDIFF(CURDATE(), last_tx) AS inactivity_days
FROM combined
WHERE last_tx < CURDATE() - INTERVAL 365 DAY
ORDER BY inactivity_days DESC;
