USE SQLBusinessAnalysis;
GO

WITH FirstPurchase AS
(
    SELECT customer_id, MIN(order_date) AS first_order_date
    FROM dbo.Orders
    WHERE order_status = 'Completed'
    GROUP BY customer_id
)
SELECT customer_id, first_order_date,
       DATEFROMPARTS(YEAR(first_order_date), MONTH(first_order_date), 1) AS cohort_month
FROM FirstPurchase
ORDER BY cohort_month, customer_id;
