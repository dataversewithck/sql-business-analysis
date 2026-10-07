USE SQLBusinessAnalysis;
GO

IF OBJECT_ID('dbo.OrderItems','U') IS NOT NULL DROP TABLE dbo.OrderItems;
IF OBJECT_ID('dbo.Orders','U') IS NOT NULL DROP TABLE dbo.Orders;
IF OBJECT_ID('dbo.Products','U') IS NOT NULL DROP TABLE dbo.Products;
IF OBJECT_ID('dbo.Customers','U') IS NOT NULL DROP TABLE dbo.Customers;
GO

CREATE TABLE dbo.Customers
(
    customer_id     INT            NOT NULL PRIMARY KEY,
    customer_name   VARCHAR(100)   NOT NULL,
    segment         VARCHAR(30)    NOT NULL,
    signup_date     DATE           NOT NULL,
    city            VARCHAR(50)    NOT NULL,
    state           CHAR(2)        NOT NULL
);
GO

CREATE TABLE dbo.Products
(
    product_id      INT            NOT NULL PRIMARY KEY,
    product_name    VARCHAR(120)   NOT NULL,
    category        VARCHAR(50)    NOT NULL,
    unit_cost       DECIMAL(10,2)  NOT NULL,
    list_price      DECIMAL(10,2)  NOT NULL
);
GO

CREATE TABLE dbo.Orders
(
    order_id        INT            NOT NULL PRIMARY KEY,
    customer_id     INT            NOT NULL,
    order_date      DATE           NOT NULL,
    order_status    VARCHAR(20)    NOT NULL,
    sales_channel   VARCHAR(20)    NOT NULL,
    CONSTRAINT FK_Orders_Customers
        FOREIGN KEY (customer_id) REFERENCES dbo.Customers(customer_id)
);
GO

CREATE TABLE dbo.OrderItems
(
    order_item_id   INT            NOT NULL PRIMARY KEY,
    order_id        INT            NOT NULL,
    product_id      INT            NOT NULL,
    quantity        INT            NOT NULL,
    unit_price      DECIMAL(10,2)  NOT NULL,
    CONSTRAINT FK_OrderItems_Orders
        FOREIGN KEY (order_id) REFERENCES dbo.Orders(order_id),
    CONSTRAINT FK_OrderItems_Products
        FOREIGN KEY (product_id) REFERENCES dbo.Products(product_id)
);
GO

CREATE INDEX IX_Orders_CustomerDate
ON dbo.Orders(customer_id, order_date);

CREATE INDEX IX_OrderItems_Order
ON dbo.OrderItems(order_id);

CREATE INDEX IX_OrderItems_Product
ON dbo.OrderItems(product_id);
GO
