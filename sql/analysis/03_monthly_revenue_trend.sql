USE SQLBusinessAnalysis;
GO

WITH MonthlyRevenue AS
(
    SELECT DATEFROMPARTS(YEAR(o.order_date), MONTH(o.order_date), 1) AS month_start,
           SUM(oi.quantity * oi.unit_price) AS revenue,
           COUNT(DISTINCT o.order_id) AS orders,
           COUNT(DISTINCT o.customer_id) AS customers
    FROM dbo.Orders o
    JOIN dbo.OrderItems oi ON oi.order_id = o.order_id
    WHERE o.order_status = 'Completed'
    GROUP BY DATEFROMPARTS(YEAR(o.order_date), MONTH(o.order_date), 1)
),
Trend AS
(
    SELECT *,
           LAG(revenue) OVER (ORDER BY month_start) AS prior_month_revenue,
           LAG(orders) OVER (ORDER BY month_start) AS prior_month_orders
    FROM MonthlyRevenue
)
SELECT month_start, revenue, orders, customers,
       CAST(100.0 * (revenue - prior_month_revenue) /
            NULLIF(prior_month_revenue,0) AS DECIMAL(7,2)) AS revenue_growth_pct,
       CAST(100.0 * (orders - prior_month_orders) /
            NULLIF(prior_month_orders,0) AS DECIMAL(7,2)) AS order_growth_pct
FROM Trend
ORDER BY month_start;
