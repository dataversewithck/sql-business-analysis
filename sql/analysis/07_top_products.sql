USE SQLBusinessAnalysis;
GO

WITH ProductRevenue AS
(
    SELECT p.category, p.product_id, p.product_name,
           SUM(oi.quantity * oi.unit_price) AS revenue,
           SUM(oi.quantity) AS units_sold
    FROM dbo.OrderItems oi
    JOIN dbo.Orders o ON o.order_id = oi.order_id
    JOIN dbo.Products p ON p.product_id = oi.product_id
    WHERE o.order_status = 'Completed'
    GROUP BY p.category, p.product_id, p.product_name
),
Ranked AS
(
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY category ORDER BY revenue DESC) AS category_rank
    FROM ProductRevenue
)
SELECT category, category_rank, product_id, product_name, units_sold,
       CAST(revenue AS DECIMAL(12,2)) AS revenue
FROM Ranked
WHERE category_rank <= 5
ORDER BY category, category_rank;
