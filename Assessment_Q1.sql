WITH savings AS (
  SELECT
    owner_id,
    COUNT(DISTINCT savings_id)   AS savings_count,
    SUM(confirmed_amount)        AS savings_deposits
  FROM adashi_staging.savings_savingsaccount
  WHERE transaction_status = 'success'
  GROUP BY owner_id
),
investment AS (
  SELECT
    owner_id,
    COUNT(*)      AS investment_count,
    SUM(amount)   AS investment_deposits
  FROM adashi_staging.plans_plan
  WHERE plan_type_id = 1    
    AND status_id    = 1    
  GROUP BY owner_id
)
SELECT
  s.owner_id,
  u.name,
  s.savings_count,
  i.investment_count,
  (s.savings_deposits + i.investment_deposits) AS total_deposits
FROM savings   AS s
JOIN investment AS i ON i.owner_id = s.owner_id
JOIN adashi_staging.users_customuser AS u ON u.id = s.owner_id
ORDER BY total_deposits DESC;
