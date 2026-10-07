USE SQLBusinessAnalysis;
GO

SET NOCOUNT ON;

/*
 REALISTIC SYNTHETIC DATA GENERATOR
 Creates realistic customer cohort behavior for the portfolio project.

 Data:
 - 2,500 customers
 - 120 products
 - Customer cohorts from Oct-2024 through Sep-2026
 - Month 0 = first purchase
 - Repeat purchase probability declines over time
 - Approximately 94% Completed, 4% Returned, 2% Cancelled
 - 1-3 line items per order
*/

-- ============================================================
-- 1. CLEAR EXISTING DEMO DATA
-- ============================================================

DELETE FROM dbo.OrderItems;
DELETE FROM dbo.Orders;
DELETE FROM dbo.Products;
DELETE FROM dbo.Customers;
GO


-- ============================================================
-- 2. PRODUCTS
-- ============================================================

;WITH N AS
(
    SELECT TOP (120)
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.all_objects a
    CROSS JOIN sys.all_objects b
)
INSERT INTO dbo.Products
(
    product_id,
    product_name,
    category,
    unit_cost,
    list_price
)
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
        ' Product ',
        RIGHT('000' + CAST(n AS VARCHAR(3)), 3)
    ),
    CASE ((n - 1) % 6)
        WHEN 0 THEN 'Performance'
        WHEN 1 THEN 'Lifestyle'
        WHEN 2 THEN 'Home'
        WHEN 3 THEN 'Electronics'
        WHEN 4 THEN 'Accessories'
        ELSE 'Office'
    END,
    CAST(20 + ((n * 17) % 120) AS DECIMAL(10,2)),
    CAST(50 + ((n * 31) % 250) AS DECIMAL(10,2))
FROM N;
GO


-- ============================================================
-- 3. CUSTOMERS
-- ============================================================

;WITH N AS
(
    SELECT TOP (2500)
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.all_objects a
    CROSS JOIN sys.all_objects b
)
INSERT INTO dbo.Customers
(
    customer_id,
    customer_name,
    segment,
    signup_date,
    city,
    state
)
SELECT
    n,
    CONCAT(
        'Customer ',
        RIGHT('0000' + CAST(n AS VARCHAR(4)), 4)
    ),
    CASE
        WHEN n % 10 < 5 THEN 'Consumer'
        WHEN n % 10 < 8 THEN 'Small Business'
        ELSE 'Corporate'
    END,
    DATEADD(
        DAY,
        -(ABS(CHECKSUM(CONCAT('signup-', n))) % 900),
        CAST('2026-09-30' AS DATE)
    ),
    CASE (n % 10)
        WHEN 0 THEN 'Austin'
        WHEN 1 THEN 'Dallas'
        WHEN 2 THEN 'Houston'
        WHEN 3 THEN 'Atlanta'
        WHEN 4 THEN 'Chicago'
        WHEN 5 THEN 'Phoenix'
        WHEN 6 THEN 'Denver'
        WHEN 7 THEN 'Seattle'
        WHEN 8 THEN 'Boston'
        ELSE 'New York'
    END,
    CASE (n % 10)
        WHEN 0 THEN 'TX'
        WHEN 1 THEN 'TX'
        WHEN 2 THEN 'TX'
        WHEN 3 THEN 'GA'
        WHEN 4 THEN 'IL'
        WHEN 5 THEN 'AZ'
        WHEN 6 THEN 'CO'
        WHEN 7 THEN 'WA'
        WHEN 8 THEN 'MA'
        ELSE 'NY'
    END
FROM N;
GO


-- ============================================================
-- 4. GENERATE REALISTIC ORDERS
-- ============================================================
-- Month 0 = first purchase.
-- Repeat probability declines over time.

IF OBJECT_ID('tempdb..#Numbers') IS NOT NULL
    DROP TABLE #Numbers;

IF OBJECT_ID('tempdb..#CandidateOrders') IS NOT NULL
    DROP TABLE #CandidateOrders;


;WITH N AS
(
    SELECT TOP (24)
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1 AS month_number
    FROM sys.all_objects
)
SELECT
    month_number
INTO #Numbers
FROM N;


;WITH CustomerCohorts AS
(
    SELECT
        c.customer_id,

        DATEADD(
            MONTH,
            (c.customer_id - 1) % 24,
            CAST('2024-10-01' AS DATE)
        ) AS cohort_month

    FROM dbo.Customers c
),
CandidateOrders AS
(
    SELECT
        cc.customer_id,
        n.month_number,

        DATEADD(
            DAY,
            ABS(
                CHECKSUM(
                    CONCAT(
                        'order-date-',
                        cc.customer_id,
                        '-',
                        n.month_number
                    )
                )
            ) % 27,

            DATEADD(
                MONTH,
                n.month_number,
                cc.cohort_month
            )
        ) AS order_date

    FROM CustomerCohorts cc

    CROSS JOIN #Numbers n

    WHERE
        DATEADD(
            MONTH,
            n.month_number,
            cc.cohort_month
        ) <= CAST('2026-09-01' AS DATE)

        AND
        (
            -- Month 0: every customer makes first purchase
            n.month_number = 0

            OR

            -- Months 1-12: declining repeat probability
            (
                n.month_number BETWEEN 1 AND 12

                AND ABS(
                    CHECKSUM(
                        CONCAT(
                            'repeat-',
                            cc.customer_id,
                            '-',
                            n.month_number
                        )
                    )
                ) % 100

                <

                CASE n.month_number
                    WHEN 1 THEN 45
                    WHEN 2 THEN 34
                    WHEN 3 THEN 28
                    WHEN 4 THEN 24
                    WHEN 5 THEN 21
                    WHEN 6 THEN 19
                    WHEN 7 THEN 17
                    WHEN 8 THEN 16
                    WHEN 9 THEN 15
                    WHEN 10 THEN 14
                    WHEN 11 THEN 13
                    WHEN 12 THEN 12
                END
            )

            OR

            -- Months after 12: low long-term repeat probability
            (
                n.month_number > 12

                AND ABS(
                    CHECKSUM(
                        CONCAT(
                            'long-repeat-',
                            cc.customer_id,
                            '-',
                            n.month_number
                        )
                    )
                ) % 100 < 10
            )
        )
)

SELECT
    ROW_NUMBER() OVER (
        ORDER BY customer_id, month_number
    ) AS order_id,

    customer_id,
    order_date,

    CASE
        WHEN ABS(
            CHECKSUM(
                CONCAT(
                    'status-',
                    customer_id,
                    '-',
                    month_number
                )
            )
        ) % 100 < 94
            THEN 'Completed'

        WHEN ABS(
            CHECKSUM(
                CONCAT(
                    'status-',
                    customer_id,
                    '-',
                    month_number
                )
            )
        ) % 100 < 98
            THEN 'Returned'

        ELSE 'Cancelled'
    END AS order_status,

    CASE
        WHEN ABS(
            CHECKSUM(
                CONCAT(
                    'channel-',
                    customer_id,
                    '-',
                    month_number
                )
            )
        ) % 10 < 6
            THEN 'Web'

        WHEN ABS(
            CHECKSUM(
                CONCAT(
                    'channel-',
                    customer_id,
                    '-',
                    month_number
                )
            )
        ) % 10 < 9
            THEN 'Mobile'

        ELSE 'Marketplace'
    END AS sales_channel

INTO #CandidateOrders
FROM CandidateOrders;
GO


INSERT INTO dbo.Orders
(
    order_id,
    customer_id,
    order_date,
    order_status,
    sales_channel
)
SELECT
    order_id,
    customer_id,
    order_date,
    order_status,
    sales_channel
FROM #CandidateOrders;
GO


-- ============================================================
-- 5. GENERATE 1-3 LINE ITEMS PER ORDER
-- ============================================================

;WITH ItemNumbers AS
(
    SELECT 1 AS item_number

    UNION ALL

    SELECT 2

    UNION ALL

    SELECT 3
),
OrderItemCandidates AS
(
    SELECT
        o.order_id,
        i.item_number

    FROM dbo.Orders o

    CROSS JOIN ItemNumbers i

    WHERE i.item_number <=
        CASE
            WHEN ABS(
                CHECKSUM(
                    CONCAT(
                        'item-count-',
                        o.order_id
                    )
                )
            ) % 100 < 60
                THEN 1

            WHEN ABS(
                CHECKSUM(
                    CONCAT(
                        'item-count-',
                        o.order_id
                    )
                )
            ) % 100 < 90
                THEN 2

            ELSE 3
        END
)

INSERT INTO dbo.OrderItems
(
    order_item_id,
    order_id,
    product_id,
    quantity,
    unit_price
)
SELECT
    ROW_NUMBER() OVER (
        ORDER BY order_id, item_number
    ) AS order_item_id,

    order_id,

    1 + ABS(
        CHECKSUM(
            CONCAT(
                'product-',
                order_id,
                '-',
                item_number
            )
        )
    ) % 120,

    1 + ABS(
        CHECKSUM(
            CONCAT(
                'quantity-',
                order_id,
                '-',
                item_number
            )
        )
    ) % 4,

    CAST(
        50 + ABS(
            CHECKSUM(
                CONCAT(
                    'price-',
                    order_id,
                    '-',
                    item_number
                )
            )
        ) % 250
        AS DECIMAL(10,2)
    )

FROM OrderItemCandidates;
GO


-- ============================================================
-- 6. VALIDATION
-- ============================================================

SELECT
    'Customers' AS table_name,
    COUNT(*) AS row_count
FROM dbo.Customers

UNION ALL

SELECT
    'Products',
    COUNT(*)
FROM dbo.Products

UNION ALL

SELECT
    'Orders',
    COUNT(*)
FROM dbo.Orders

UNION ALL

SELECT
    'OrderItems',
    COUNT(*)
FROM dbo.OrderItems;
GO


SELECT
    MIN(order_date) AS min_order_date,
    MAX(order_date) AS max_order_date,

    SUM(
        CASE
            WHEN order_status = 'Completed'
                THEN 1
            ELSE 0
        END
    ) AS completed_orders,

    SUM(
        CASE
            WHEN order_status = 'Returned'
                THEN 1
            ELSE 0
        END
    ) AS returned_orders,

    SUM(
        CASE
            WHEN order_status = 'Cancelled'
                THEN 1
            ELSE 0
        END
    ) AS cancelled_orders

FROM dbo.Orders;
GO
