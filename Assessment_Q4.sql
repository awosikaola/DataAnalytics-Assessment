WITH customer_tenure AS (
  SELECT
    id                   AS customer_id,
    name,
    TIMESTAMPDIFF(
      MONTH,
      date_joined,
      CURDATE()
    )                   AS tenure_months
  FROM adashi_staging.users_customuser
),
tx_stats AS (
  SELECT
    owner_id            AS customer_id,
    COUNT(*)            AS total_transactions,
    AVG(amount)         AS avg_amount
  FROM adashi_staging.savings_savingsaccount
  WHERE transaction_status = 'success'
  GROUP BY owner_id
)
SELECT
  c.customer_id,
  c.name,
  c.tenure_months,
  t.total_transactions,
  ROUND(
    (t.total_transactions / c.tenure_months) * 12 * (t.avg_amount * 0.001),
    2
  )                    AS estimated_clv
FROM customer_tenure AS c
JOIN tx_stats      AS t USING (customer_id)
WHERE c.tenure_months > 0
ORDER BY estimated_clv DESC;
