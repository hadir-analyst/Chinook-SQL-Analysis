# Chinook-SQL-Analysis
SQL analysis of the Chinook music store database: revenue, customer churn, repeat rate, and sales trends using JOINs, CTEs, and window functions.

# Chinook Music Store: SQL Analysis

SQL analysis of the Chinook sample database (a digital music store) to answer key business questions about revenue, customers, and sales trends.

## Database
The Chinook database has 11 tables: Customer, Invoice, InvoiceLine, Track, Album, Artist, Genre, MediaType, Playlist, PlaylistTrack, and Employee.
Invoice data covers **2021 to 2025**.

## Business Questions
- What is the total revenue, number of orders, and average order value?
- How many customers are Active vs Churned (no purchase in the last 365 days)?
- What percentage of customers are repeat buyers?
- How does revenue change month by month in 2024?

## Key Results
| Metric | Value |
|---|---|
| Total Revenue | $2,329 (rounded up) |
| Total Orders | 412 |
| Total Customers | 59 |
| Avg Order Value | $5.65 |
| Active Customers | 46 (77.97%) |
| Churned Customers | 13 (22.03%) |
| Repeat Customer Rate | 100% |

## SQL Techniques
- Aggregations (SUM, COUNT, AVG, ROUND)
- Subqueries
- CASE WHEN (customer segmentation)
- Window Functions (SUM() OVER)
- Date Functions (YEAR, MONTH, DATEDIFF)

## Files
| File | Description |
|---|---|
| `01_chinook_database_setup.sql` | Creates the Chinook database (original sample script) |
| `02_analysis_queries.sql` | My analysis queries |

## How to Run
1. Run `01_chinook_database_setup.sql` to create the database.
2. Run `02_analysis_queries.sql` to see the analysis.

## Tools
MySQL
