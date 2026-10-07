USE SQLBusinessAnalysis;
GO

WITH FirstPurchase AS
(
    SELECT customer_id, MIN(order_date) AS first_order_date
    FROM dbo.Orders
    WHERE order_status = 'Completed'
    GROUP BY customer_id
),
CohortBase AS
(
    SELECT customer_id,
           DATEFROMPARTS(YEAR(first_order_date), MONTH(first_order_date), 1) AS cohort_month
    FROM FirstPurchase
),
CustomerActivity AS
(
    SELECT DISTINCT customer_id,
           DATEFROMPARTS(YEAR(order_date), MONTH(order_date), 1) AS activity_month
    FROM dbo.Orders
    WHERE order_status = 'Completed'
),
CohortActivity AS
(
    SELECT cb.cohort_month, ca.activity_month,
           DATEDIFF(MONTH, cb.cohort_month, ca.activity_month) AS month_number,
           cb.customer_id
    FROM CohortBase cb
    JOIN CustomerActivity ca
      ON ca.customer_id = cb.customer_id
     AND ca.activity_month >= cb.cohort_month
),
CohortSize AS
(
    SELECT cohort_month, COUNT(DISTINCT customer_id) AS cohort_customers
    FROM CohortBase
    GROUP BY cohort_month
)
SELECT ca.cohort_month, cs.cohort_customers, ca.month_number,
       COUNT(DISTINCT ca.customer_id) AS retained_customers,
       CAST(100.0 * COUNT(DISTINCT ca.customer_id) /
            NULLIF(cs.cohort_customers,0) AS DECIMAL(6,2)) AS retention_pct
FROM CohortActivity ca
JOIN CohortSize cs ON cs.cohort_month = ca.cohort_month
GROUP BY ca.cohort_month, cs.cohort_customers, ca.month_number
ORDER BY ca.cohort_month, ca.month_number;
