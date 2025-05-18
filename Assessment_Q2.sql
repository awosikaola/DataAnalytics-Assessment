WITH monthly_counts AS (
  SELECT
    owner_id,
    DATE_FORMAT(transaction_date, '%Y-%m') AS ym,
    COUNT(*) AS tx_count
  FROM adashi_staging.savings_savingsaccount
  WHERE transaction_status = 'success' 
  GROUP BY owner_id, ym
),
avg_tx AS (
  SELECT
    owner_id,
    AVG(tx_count) AS avg_tx_per_month
  FROM monthly_counts
  GROUP BY owner_id
),
categorized AS (
  SELECT
    CASE
      WHEN avg_tx_per_month >= 10 THEN 'High Frequency'
      WHEN avg_tx_per_month BETWEEN 3 AND 9 THEN 'Medium Frequency'
      ELSE 'Low Frequency'
    END AS frequency_category,
    avg_tx_per_month
  FROM avg_tx
)
SELECT
  frequency_category,
  COUNT(*)                   AS customer_count,
  ROUND(AVG(avg_tx_per_month), 1) AS avg_transactions_per_month
FROM categorized
GROUP BY frequency_category
ORDER BY
  FIELD(frequency_category, 'High Frequency', 'Medium Frequency', 'Low Frequency');
