USE SQLBusinessAnalysis;
GO
SET NOCOUNT ON;

/*
Generated demo data:
- 2,500 customers
- 120 products
- ~15,000 orders
- ~35,000 order items

The randomization uses NEWID(). Values are intentionally synthetic.
*/

-- PRODUCTS
;WITH N AS
(
    SELECT TOP (120)
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.all_objects a
    CROSS JOIN sys.all_objects b
)
INSERT INTO dbo.Products(product_id, product_name, category, unit_cost, list_price)
SELECT
    n,
    CONCAT(
        CASE ((n - 1) % 6)
            WHEN 0 THEN 'Performance'
            WHEN 1 THEN 'Lifestyle'
            WHEN 2 THEN 'Home'
            WHEN 3 THEN 'Electronics'
            WHEN 4 THEN 'Accessories'
            ELSE 'Office'
        END,
        ' Product ', RIGHT('000' + CAST(n AS VARCHAR(3)), 3)
    ),
    CASE ((n - 1) % 6)
        WHEN 0 THEN 'Performance'
        WHEN 1 THEN 'Lifestyle'
        WHEN 2 THEN 'Home'
        WHEN 3 THEN 'Electronics'
        WHEN 4 THEN 'Accessories'
        ELSE 'Office'
    END,
    CAST(10 + ((n * 17) % 90) AS DECIMAL(10,2)),
    CAST(25 + ((n * 31) % 220) AS DECIMAL(10,2))
FROM N;
GO

-- CUSTOMERS
;WITH N AS
(
    SELECT TOP (2500)
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.all_objects a
    CROSS JOIN sys.all_objects b
)
INSERT INTO dbo.Customers(customer_id, customer_name, segment, signup_date, city, state)
SELECT
    n,
    CONCAT('Customer ', RIGHT('0000' + CAST(n AS VARCHAR(4)), 4)),
    CASE
        WHEN n % 10 < 5 THEN 'Consumer'
        WHEN n % 10 < 8 THEN 'Small Business'
        ELSE 'Corporate'
    END,
    DATEADD(DAY, -((n * 13) % 900), CAST('2026-09-30' AS DATE)),
    CASE (n % 10)
        WHEN 0 THEN 'Austin' WHEN 1 THEN 'Dallas' WHEN 2 THEN 'Houston'
        WHEN 3 THEN 'Atlanta' WHEN 4 THEN 'Chicago' WHEN 5 THEN 'Phoenix'
        WHEN 6 THEN 'Denver' WHEN 7 THEN 'Seattle' WHEN 8 THEN 'Boston'
        ELSE 'New York'
    END,
    CASE (n % 10)
        WHEN 0 THEN 'TX' WHEN 1 THEN 'TX' WHEN 2 THEN 'TX' WHEN 3 THEN 'GA'
        WHEN 4 THEN 'IL' WHEN 5 THEN 'AZ' WHEN 6 THEN 'CO' WHEN 7 THEN 'WA'
        WHEN 8 THEN 'MA' ELSE 'NY'
    END
FROM N;
GO

-- ORDERS
;WITH N AS
(
    SELECT TOP (15000)
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.all_objects a
    CROSS JOIN sys.all_objects b
)
INSERT INTO dbo.Orders(order_id, customer_id, order_date, order_status, sales_channel)
SELECT
    n,
    1 + ABS(CHECKSUM(NEWID())) % 2500,
    DATEADD(DAY, -ABS(CHECKSUM(NEWID())) % 730, CAST('2026-09-30' AS DATE)),
    CASE
        WHEN n % 20 = 0 THEN 'Cancelled'
        WHEN n % 50 = 0 THEN 'Returned'
        ELSE 'Completed'
    END,
    CASE
        WHEN n % 10 < 6 THEN 'Web'
        WHEN n % 10 < 9 THEN 'Mobile'
        ELSE 'Marketplace'
    END
FROM N;
GO

-- ORDER ITEMS
;WITH N AS
(
    SELECT TOP (45000)
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.all_objects a
    CROSS JOIN sys.all_objects b
)
INSERT INTO dbo.OrderItems(order_item_id, order_id, product_id, quantity, unit_price)
SELECT
    n,
    1 + ABS(CHECKSUM(NEWID())) % 15000,
    1 + ABS(CHECKSUM(NEWID())) % 120,
    1 + ABS(CHECKSUM(NEWID())) % 4,
    CAST(25 + ABS(CHECKSUM(NEWID())) % 220 AS DECIMAL(10,2))
FROM N;
GO

-- Remove accidental duplicate product assignment within the same order is not required
-- for analytics; each row represents a sale line.
