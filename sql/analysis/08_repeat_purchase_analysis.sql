USE SQLBusinessAnalysis;
GO

WITH CustomerOrders AS
(
    SELECT customer_id,
           COUNT(DISTINCT order_id) AS order_count,
           MIN(order_date) AS first_order_date,
           MAX(order_date) AS last_order_date
    FROM dbo.Orders
    WHERE order_status = 'Completed'
    GROUP BY customer_id
),
Buckets AS
(
    SELECT
        CASE
            WHEN order_count = 1 THEN '1 order'
            WHEN order_count BETWEEN 2 AND 3 THEN '2-3 orders'
            WHEN order_count BETWEEN 4 AND 6 THEN '4-6 orders'
            ELSE '7+ orders'
        END AS purchase_frequency,
        COUNT(*) AS customers,
        SUM(order_count) AS orders
    FROM CustomerOrders
    GROUP BY
        CASE
            WHEN order_count = 1 THEN '1 order'
            WHEN order_count BETWEEN 2 AND 3 THEN '2-3 orders'
            WHEN order_count BETWEEN 4 AND 6 THEN '4-6 orders'
            ELSE '7+ orders'
        END
)
SELECT purchase_frequency, customers, orders,
       CAST(100.0 * customers / SUM(customers) OVER () AS DECIMAL(6,2)) AS customer_share_pct
FROM Buckets
ORDER BY CASE purchase_frequency
    WHEN '1 order' THEN 1 WHEN '2-3 orders' THEN 2
    WHEN '4-6 orders' THEN 3 ELSE 4 END;
