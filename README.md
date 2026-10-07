# SQL Business Analysis — E-commerce Customer & Revenue Analytics

![SQL Server](https://img.shields.io/badge/SQL%20Server-T--SQL-red)
![Analysis](https://img.shields.io/badge/Focus-Business%20Analysis-blue)
![Portfolio](https://img.shields.io/badge/Portfolio-Data%20Analyst-success)

## Business Problem

An e-commerce company wants to understand:

- How revenue is changing over time
- Which customer segments generate the most revenue
- How well the business retains customers after their first purchase
- Which customers and products are top performers
- How repeat purchasing affects customer value
- Where management should focus retention and revenue-growth efforts

This project answers those questions using **SQL Server / T-SQL**, with an emphasis on reusable analytical SQL rather than one-off queries.

## Key Analysis Areas

| Analysis | SQL techniques |
|---|---|
| Revenue & AOV | Aggregations, `CASE`, date functions |
| Revenue by segment | CTEs, conditional aggregation |
| Customer cohorts | CTEs, date arithmetic |
| Cohort retention | Window functions, conditional aggregation |
| Top customers | `RANK`, `DENSE_RANK` |
| Top products | `ROW_NUMBER`, partitions |
| Monthly performance | `LAG`, rolling metrics |
| Repeat-purchase behavior | CTEs, `MIN`, `COUNT`, date logic |
| Customer value | Revenue, orders, AOV, lifetime metrics |

## Data Model

```text
Customers
   │
   └───────────────< Orders
                       │
                       └───────────────< OrderItems
                                             │
                                             >──────────── Products
```

### Tables

- `Customers` — customer profile and acquisition segment
- `Products` — product catalog and category
- `Orders` — order-level transactions
- `OrderItems` — product-level order detail

## Business Definitions

### Revenue
Sum of `OrderItems.quantity * OrderItems.unit_price` for completed orders.

### Customer Segment
Segments are based on customer profile:

- Consumer
- Corporate
- Small Business

### Cohort Month
The month of a customer's first completed order.

### Retention
A customer is retained in month N when they place at least one completed order during N months after their cohort month.

## Project Structure

```text
sql-business-analysis/
│
├── README.md
├── LICENSE
│
├── sql/
│   ├── 01_create_database.sql
│   ├── 02_create_schema.sql
│   ├── 03_seed_data.sql
│   ├── 04_validation_checks.sql
│   └── analysis/
│       ├── 01_executive_kpis.sql
│       ├── 02_revenue_by_segment.sql
│       ├── 03_monthly_revenue_trend.sql
│       ├── 04_customer_cohorts.sql
│       ├── 05_cohort_retention.sql
│       ├── 06_top_customers.sql
│       ├── 07_top_products.sql
│       └── 08_repeat_purchase_analysis.sql
│
├── docs/
│   └── business_questions.md
│
├── data/
│   └── README.md
│
└── results/
    └── README.md
```

## How to Run

### Option 1 — SQL Server / SSMS

1. Open SQL Server Management Studio.
2. Run `sql/01_create_database.sql`.
3. Run `sql/02_create_schema.sql`.
4. Run `sql/03_seed_data.sql`.
5. Run `sql/04_validation_checks.sql`.
6. Run the analysis scripts under `sql/analysis/`.

The scripts are designed for a portfolio/demo database and intentionally use generated data so no proprietary information is included.

## Portfolio Questions

A hiring manager should be able to see that the project answers questions such as:

1. What is total revenue and average order value?
2. Which customer segment generates the most revenue?
3. Which months show the strongest growth?
4. What percentage of customers return after their first purchase?
5. Which acquisition cohorts have the strongest retention?
6. Who are the top 10 customers by lifetime revenue?
7. Which products generate the most revenue within each category?
8. What is the relationship between order frequency and customer value?

## Example Business Recommendations

The SQL results can be translated into recommendations such as:

- Prioritize retention campaigns for cohorts with weak month-1 retention.
- Identify high-value customers for loyalty/VIP programs.
- Protect high-revenue products from inventory shortages.
- Compare segment-level AOV and purchase frequency before allocating marketing budget.
- Use cohort trends to evaluate whether newer customers are becoming more valuable than older cohorts.

## Skills Demonstrated

**SQL:** T-SQL, CTEs, window functions, `CASE`, aggregation, joins, date functions, ranking, cohort analysis, conditional aggregation.

**Analytics:** KPI definition, segmentation, retention analysis, customer behavior, revenue analysis, business recommendations.

## Portfolio Positioning

This project is intended to demonstrate the complete analytical flow:

**Business question → Data model → SQL analysis → KPI → Insight → Recommendation**

---

### Author

Data Analyst portfolio project by **dataversewithck**.
