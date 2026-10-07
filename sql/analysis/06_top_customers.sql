USE SQLBusinessAnalysis;
GO

WITH CustomerRevenue AS
(
    SELECT o.customer_id,
           COUNT(DISTINCT o.order_id) AS orders,
           SUM(oi.quantity * oi.unit_price) AS lifetime_revenue,
           MIN(o.order_date) AS first_order_date,
           MAX(o.order_date) AS last_order_date
    FROM dbo.Orders o
    JOIN dbo.OrderItems oi ON oi.order_id = o.order_id
    WHERE o.order_status = 'Completed'
    GROUP BY o.customer_id
),
Ranked AS
(
    SELECT cr.*, c.customer_name, c.segment,
           RANK() OVER (ORDER BY cr.lifetime_revenue DESC) AS revenue_rank
    FROM CustomerRevenue cr
    JOIN dbo.Customers c ON c.customer_id = cr.customer_id
)
SELECT TOP (10) revenue_rank, customer_id, customer_name, segment, orders,
       CAST(lifetime_revenue AS DECIMAL(12,2)) AS lifetime_revenue,
       CAST(lifetime_revenue / NULLIF(orders,0) AS DECIMAL(12,2)) AS customer_aov,
       first_order_date, last_order_date
FROM Ranked
ORDER BY revenue_rank;
