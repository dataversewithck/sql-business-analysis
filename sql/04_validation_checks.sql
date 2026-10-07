USE SQLBusinessAnalysis;
GO

SELECT 'Customers' AS table_name, COUNT(*) AS row_count FROM dbo.Customers
UNION ALL
SELECT 'Products', COUNT(*) FROM dbo.Products
UNION ALL
SELECT 'Orders', COUNT(*) FROM dbo.Orders
UNION ALL
SELECT 'OrderItems', COUNT(*) FROM dbo.OrderItems;
GO

SELECT
    MIN(order_date) AS min_order_date,
    MAX(order_date) AS max_order_date,
    SUM(CASE WHEN order_status = 'Completed' THEN 1 ELSE 0 END) AS completed_orders,
    SUM(CASE WHEN order_status <> 'Completed' THEN 1 ELSE 0 END) AS non_completed_orders
FROM dbo.Orders;
GO

SELECT
    COUNT(*) AS completed_order_lines,
    SUM(quantity * unit_price) AS completed_revenue
FROM dbo.OrderItems oi
JOIN dbo.Orders o ON o.order_id = oi.order_id
WHERE o.order_status = 'Completed';
GO
