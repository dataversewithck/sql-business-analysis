USE SQLBusinessAnalysis;
GO

WITH OrderRevenue AS
(
    SELECT
        o.order_id,
        o.customer_id,
        SUM(oi.quantity * oi.unit_price) AS order_revenue
    FROM dbo.Orders o
    JOIN dbo.OrderItems oi ON oi.order_id = o.order_id
    WHERE o.order_status = 'Completed'
    GROUP BY o.order_id, o.customer_id
),
CustomerStats AS
(
    SELECT
        customer_id,
        COUNT(*) AS order_count
    FROM OrderRevenue
    GROUP BY customer_id
),
BusinessKPIs AS
(
    SELECT
        SUM(orv.order_revenue) AS total_revenue,
        COUNT(*) AS total_completed_orders,
        COUNT(DISTINCT orv.customer_id) AS unique_customers,
        CAST(SUM(orv.order_revenue) / NULLIF(COUNT(*),0) AS DECIMAL(12,2)) AS average_order_value,
        CAST(SUM(orv.order_revenue) / NULLIF(COUNT(DISTINCT orv.customer_id),0) AS DECIMAL(12,2)) AS revenue_per_customer
    FROM OrderRevenue orv
)
SELECT
    b.total_revenue,
    b.total_completed_orders,
    b.unique_customers,
    b.average_order_value,
    b.revenue_per_customer,
    CAST(
        100.0 * SUM(CASE WHEN cs.order_count > 1 THEN 1 ELSE 0 END)
        / NULLIF(COUNT(*),0)
        AS DECIMAL(6,2)
    ) AS repeat_customer_rate_pct
FROM BusinessKPIs b
CROSS JOIN CustomerStats cs
GROUP BY
    b.total_revenue,
    b.total_completed_orders,
    b.unique_customers,
    b.average_order_value,
    b.revenue_per_customer;
