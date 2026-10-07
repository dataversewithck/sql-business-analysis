USE SQLBusinessAnalysis;
GO

WITH CustomerRevenue AS
(
    SELECT o.customer_id,
           SUM(oi.quantity * oi.unit_price) AS revenue,
           COUNT(DISTINCT o.order_id) AS orders
    FROM dbo.Orders o
    JOIN dbo.OrderItems oi ON oi.order_id = o.order_id
    WHERE o.order_status = 'Completed'
    GROUP BY o.customer_id
),
SegmentSummary AS
(
    SELECT c.segment,
           SUM(cr.revenue) AS revenue,
           SUM(cr.orders) AS orders,
           COUNT(*) AS customers,
           AVG(cr.revenue) AS avg_customer_revenue
    FROM CustomerRevenue cr
    JOIN dbo.Customers c ON c.customer_id = cr.customer_id
    GROUP BY c.segment
)
SELECT segment, customers, orders, revenue,
       CAST(100.0 * revenue / SUM(revenue) OVER () AS DECIMAL(6,2)) AS revenue_share_pct,
       CAST(revenue / NULLIF(orders,0) AS DECIMAL(12,2)) AS avg_order_value,
       CAST(avg_customer_revenue AS DECIMAL(12,2)) AS avg_customer_revenue
FROM SegmentSummary
ORDER BY revenue DESC;
