use chinook;
SELECT * FROM Genre;
SELECT * FROM MediaType;
SELECT * FROM album;
SELECT * FROM playlist;
SELECT * FROM track;

Select * from album;
Select * from artist;
Select * from customer;
Select * from employee;
Select * from genre;
Select * from invoice;
Select * from invoiceline;
Select * from mediatype;
Select * from playlist;
Select * from playlisttrack,track;

select ceiling(sum(total)) as Total_Revenue from invoice;

select sum(InvoiceId) as total_order from invoice;

select count(*) as total_customer from customer;
select round(avg(Total),2) as avg_id from invoice;


SELECT 
    CustomerStatus,
    COUNT(*) AS CustomerCount,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS Percentage
FROM (
    SELECT 
        CustomerId,
        CASE 
            WHEN DATEDIFF(
                (SELECT MAX(InvoiceDate) FROM Invoice), 
                MAX(InvoiceDate)
            ) > 365 THEN 'Churned'
            ELSE 'Active'
        END AS CustomerStatus
    FROM Invoice
    GROUP BY CustomerId
) AS CustomerActivity
GROUP BY CustomerStatus;


SELECT
     ROUND(
        COUNT(DISTINCT CASE WHEN InvoiceCount > 1 THEN CustomerId END) * 100.0 
        / COUNT(DISTINCT CustomerId), 2
    ) AS RepeatRate_Percent
FROM (
    SELECT 
        CustomerId,
        COUNT(InvoiceId) AS InvoiceCount
    FROM Invoice
    GROUP BY CustomerId
) AS CustomerInvoices;

SELECT 
    YEAR(InvoiceDate) AS rev_year,
    MONTH(InvoiceDate) AS rev_month,
    SUM(Total) AS total_revenue
FROM Invoice
WHERE YEAR(InvoiceDate) = 2024
GROUP BY YEAR(InvoiceDate), MONTH(InvoiceDate)
ORDER BY rev_month;

SELECT InvoiceId, InvoiceDate, CustomerId, Total
FROM Invoice
WHERE YEAR(InvoiceDate) = 2024
ORDER BY InvoiceDate;

-- ============ Revenue Analysis ============

-- Revenue by year
SELECT YEAR(InvoiceDate) AS rev_year, ROUND(SUM(Total), 2) AS total_revenue
FROM Invoice
GROUP BY YEAR(InvoiceDate)
ORDER BY rev_year;

-- Top 5 countries by revenue
SELECT BillingCountry, ROUND(SUM(Total), 2) AS total_revenue
FROM Invoice
GROUP BY BillingCountry
ORDER BY total_revenue DESC
LIMIT 5;

-- Year-over-Year growth (Window Function: LAG)
SELECT rev_year, total_revenue,
       ROUND((total_revenue - LAG(total_revenue) OVER (ORDER BY rev_year))
             * 100.0 / LAG(total_revenue) OVER (ORDER BY rev_year), 2) AS yoy_growth_pct
FROM (
    SELECT YEAR(InvoiceDate) AS rev_year, SUM(Total) AS total_revenue
    FROM Invoice
    GROUP BY YEAR(InvoiceDate)
) AS yearly;

-- Running total of monthly revenue
SELECT rev_month, monthly_revenue,
       ROUND(SUM(monthly_revenue) OVER (ORDER BY rev_month), 2) AS running_total
FROM (
    SELECT DATE_FORMAT(InvoiceDate, '%Y-%m') AS rev_month, SUM(Total) AS monthly_revenue
    FROM Invoice
    GROUP BY DATE_FORMAT(InvoiceDate, '%Y-%m')
) AS monthly;

-- ============ Customer Analysis ============

-- Top 10 customers by spending
SELECT c.CustomerId, CONCAT(c.FirstName, ' ', c.LastName) AS customer,
       c.Country, ROUND(SUM(i.Total), 2) AS total_spent
FROM Customer c
JOIN Invoice i ON c.CustomerId = i.CustomerId
GROUP BY c.CustomerId, c.FirstName, c.LastName, c.Country
ORDER BY total_spent DESC
LIMIT 10;

-- Customer ranking inside each country (Window Function: RANK)
SELECT Country, customer, total_spent,
       RANK() OVER (PARTITION BY Country ORDER BY total_spent DESC) AS rank_in_country
FROM (
    SELECT c.Country, CONCAT(c.FirstName, ' ', c.LastName) AS customer,
           SUM(i.Total) AS total_spent
    FROM Customer c
    JOIN Invoice i ON c.CustomerId = i.CustomerId
    GROUP BY c.CustomerId, c.Country, c.FirstName, c.LastName
) AS t;

-- Customers who never placed an order
SELECT c.CustomerId, c.FirstName, c.LastName
FROM Customer c
LEFT JOIN Invoice i ON c.CustomerId = i.CustomerId
WHERE i.InvoiceId IS NULL;

-- ============ Product Analysis ============

-- Revenue by genre
SELECT g.Name AS genre, ROUND(SUM(il.UnitPrice * il.Quantity), 2) AS revenue
FROM InvoiceLine il
JOIN Track t ON il.TrackId = t.TrackId
JOIN Genre g ON t.GenreId = g.GenreId
GROUP BY g.Name
ORDER BY revenue DESC;

-- Top 10 best-selling tracks
SELECT t.Name AS track, SUM(il.Quantity) AS units_sold
FROM InvoiceLine il
JOIN Track t ON il.TrackId = t.TrackId
GROUP BY t.TrackId, t.Name
ORDER BY units_sold DESC
LIMIT 10;

-- Top 5 artists by revenue
SELECT ar.Name AS artist, ROUND(SUM(il.UnitPrice * il.Quantity), 2) AS revenue
FROM InvoiceLine il
JOIN Track t   ON il.TrackId = t.TrackId
JOIN Album al  ON t.AlbumId = al.AlbumId
JOIN Artist ar ON al.ArtistId = ar.ArtistId
GROUP BY ar.ArtistId, ar.Name
ORDER BY revenue DESC
LIMIT 5;

-- ============ Employee Analysis ============

-- Revenue per support rep
SELECT CONCAT(e.FirstName, ' ', e.LastName) AS sales_rep,
       COUNT(DISTINCT c.CustomerId) AS customers,
       ROUND(SUM(i.Total), 2) AS total_revenue
FROM Employee e
JOIN Customer c ON e.EmployeeId = c.SupportRepId
JOIN Invoice i  ON c.CustomerId = i.CustomerId
GROUP BY e.EmployeeId, e.FirstName, e.LastName
ORDER BY total_revenue DESC;

