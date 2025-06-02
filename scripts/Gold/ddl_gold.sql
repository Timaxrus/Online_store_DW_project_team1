/*
===============================================================================
DDL Script: Create Gold Views
===============================================================================
Script Purpose:
    This script creates views for the Gold layer in the data warehouse. 
    The Gold layer represents the final dimension and fact tables (Star Schema)

    Each view performs transformations and combines data from the Silver layer 
    to produce a clean, enriched, and business-ready dataset.

Usage:
    - These views can be queried directly for analytics and reporting.
===============================================================================
*/

-- =============================================================================
-- Create Dimension: gold.dim_customers
-- =============================================================================

IF OBJECT_ID('gold.dim_customers', 'V') IS NOT NULL
    DROP VIEW gold.dim_customers;
GO

CREATE VIEW gold.dim_customers AS
SELECT 
	CustomerID,
	FirstName,
	LastName,
	Gender,
	Email,
	Phone,
	Address,
	City,
	State,
	Country,
	DateRegistered,
	CreateDate
  FROM silver.customers
GO

-- =============================================================================
-- Create Dimension: gold.dim_orders
-- =============================================================================

IF OBJECT_ID('gold.dim_orders', 'V') IS NOT NULL
    DROP VIEW gold.dim_orders;
GO

CREATE VIEW gold.dim_orders AS
SELECT
	OrderID,
	ProductID,
	CustomerID,
	OrderDate,
	OrderQuantity,
	TotalAmount,
	Status,
	CreateDate
  FROM silver.orders
GO

-- =============================================================================
-- Create Dimension: gold.dim_products
-- =============================================================================

IF OBJECT_ID('gold.dim_products', 'V') IS NOT NULL
    DROP VIEW gold.dim_products;
GO

CREATE VIEW gold.dim_products AS
SELECT
	ProductID,
	ProductName,
	CategoryID,
	SupplierID,
	Price,
	Description,
	DateAdded,
	CreateDate
  FROM silver.products
GO

-- =============================================================================
-- Create Dimension: gold.dim_categories
-- =============================================================================

IF OBJECT_ID('gold.dim_categories', 'V') IS NOT NULL
    DROP VIEW gold.dim_categories;
GO

CREATE VIEW gold.dim_categories AS
SELECT
	CategoryID,
	CategoryName,
	CreateDate
FROM silver.categories
GO

-- =============================================================================
-- Create Dimension: gold.dim_reviews
-- =============================================================================

IF OBJECT_ID('gold.dim_reviews', 'V') IS NOT NULL
    DROP VIEW gold.dim_reviews;
GO

CREATE VIEW gold.dim_reviews AS
SELECT
	ReviewID,
	ProductID,
	CustomerID,
	Rating,
	Comment,
	ReviewDate,
	CreateDate
  FROM silver.reviews
GO

-- =============================================================================
-- Create Dimension: gold.dim_payments
-- =============================================================================

IF OBJECT_ID('gold.dim_payments', 'V') IS NOT NULL
    DROP VIEW gold.dim_payments;
GO

CREATE VIEW gold.dim_payments AS
SELECT
	PaymentID,
	OrderID,
	PaymentMethod,
	Amount,
	PaymentDate,
	CreateDate
  FROM silver.payments
GO

-- =============================================================================
-- Create Dimension: gold.dim_shipments
-- =============================================================================

IF OBJECT_ID('gold.dim_shipments', 'V') IS NOT NULL
    DROP VIEW gold.dim_shipments;
GO

CREATE VIEW gold.dim_shipments AS
SELECT
	ShipmentID,
	OrderID,
	ShipmentDate,
	Carrier,
	TrackingNumber,
	CreateDate
  FROM silver.shipments
GO

-- =============================================================================
-- Create Dimension: gold.dim_categories
-- =============================================================================

IF OBJECT_ID('gold.dim_categories', 'V') IS NOT NULL
    DROP VIEW gold.dim_categories;
GO

CREATE VIEW gold.dim_categories AS
SELECT
	CategoryID,
	CategoryName,
	CreateDate
  FROM silver.categories

GO

-- =============================================================================
-- Create Dimension: gold.fact_SalesPerformance
-- =============================================================================


IF OBJECT_ID('gold.fact_SalesPerformance', 'V') IS NOT NULL
    DROP VIEW gold.fact_SalesPerformance;
GO

CREATE VIEW gold.fact_SalesPerformance AS
SELECT 
    p.ProductName,
    c.CategoryName,
    SUM(o.OrderQuantity) AS TotalQuantitySold,
    SUM(p.Price * o.OrderQuantity) AS TotalRevenue,
    AVG(p.Price * o.OrderQuantity) AS AverageOrderValue
FROM silver.orders o
JOIN silver.products p ON o.ProductID = p.ProductID
JOIN silver.categories c ON p.CategoryID = c.CategoryID
GROUP BY p.ProductName, c.CategoryName
GO

-- =============================================================================
-- Create Dimension: gold.fact_CustomerLifetimeValue (CLV)
-- =============================================================================

IF OBJECT_ID('gold.fact_CustomerLifetimeValue', 'V') IS NOT NULL
    DROP VIEW gold.fact_CustomerLifetimeValue;
GO

CREATE VIEW gold.fact_CustomerLifetimeValue AS
SELECT 
    c.CustomerID,
    c.FirstName + ' ' + c.LastName AS FullName,
	c.Gender,
    COUNT(DISTINCT o.OrderID) AS TotalOrders,
    SUM(o.TotalAmount) AS TotalSpent,
    MAX(o.OrderDate) AS LastOrderDate,
    DATEDIFF(DAY, MIN(o.OrderDate), MAX(o.OrderDate)) AS CustomerLifespanDays
FROM silver.customers c
JOIN silver.orders o ON c.CustomerID = o.CustomerID
GROUP BY c.CustomerID, c.FirstName, c.LastName, c.Gender;
GO

-- =============================================================================
-- Create Dimension: gold.fact_InventoryStatus
-- =============================================================================

IF OBJECT_ID('gold.fact_InventoryStatus', 'V') IS NOT NULL
    DROP VIEW gold.fact_InventoryStatus;
GO

CREATE VIEW gold.fact_InventoryStatus AS
SELECT 
    p.ProductID,
    p.ProductName,
    i.QuantityInStock,
    CASE 
        WHEN i.QuantityInStock < 10 THEN 'Low Stock'
        WHEN i.QuantityInStock BETWEEN 10 AND 50 THEN 'Moderate Stock'
        ELSE 'Sufficient Stock'
    END AS StockStatus
FROM silver.inventory i
JOIN silver.products p ON i.ProductID = p.ProductID;
GO

-- =============================================================================
-- Create Dimension: gold.fact_ProductReviewSummary
-- =============================================================================

IF OBJECT_ID('gold.fact_ProductReviewSummary', 'V') IS NOT NULL
    DROP VIEW gold.fact_ProductReviewSummary;
GO

CREATE VIEW gold.fact_ProductReviewSummary AS
SELECT DISTINCT
    r.ProductID,
    p.ProductName,
    AVG(r.Rating) AS AverageRating,
    COUNT(r.ReviewID) AS TotalReviews
FROM silver.reviews r
JOIN silver.products p ON r.ProductID = p.ProductID
GROUP BY r.ProductID, p.ProductName;
GO

