
/*
===============================================================================
DDL Script: Create Bronze Tables (exaxt copies of source tables from csv files)
===============================================================================
Script Purpose:
    This script creates tables in the 'bronze' schema, dropping existing tables 
    if they already exist.
	  Run this script to re-define the DDL structure of 'bronze' Tables
===============================================================================
*/


IF OBJECT_ID('bronze.customers', 'U') IS NOT NULL
    DROP TABLE bronze.customers;
GO

CREATE TABLE bronze.customers (
    CustomerID          INT,
    FirstName           NVARCHAR(50),
    LastName            NVARCHAR(50),
	Gender              NVARCHAR(20),
    Email               NVARCHAR(50),
    Phone               NVARCHAR(50),
    Address             NVARCHAR(50),
	City                NVARCHAR(50),
	State               NVARCHAR(50),
	Country             NVARCHAR(50),
	DateRegistered      DATE
);
GO

IF OBJECT_ID('bronze.categories', 'U') IS NOT NULL
    DROP TABLE bronze.categories;
GO

CREATE TABLE bronze.categories (
    CategoryID       INT,
    CategoryName      NVARCHAR(50)
);
GO

IF OBJECT_ID('bronze.products', 'U') IS NOT NULL
    DROP TABLE bronze.products;
GO

CREATE TABLE bronze.products (
    ProductID    INT,
	ProductName  NVARCHAR(50),
    CategoryID   INT,
    SupplierID   INT,
    Price        DECIMAL(10,2),
    Description  NVARCHAR(100),
    DateAdded    DATE
);
GO

IF OBJECT_ID('bronze.payments', 'U') IS NOT NULL
    DROP TABLE bronze.payments;
GO

CREATE TABLE bronze.payments (
    PaymentID     INT,
	OrderID       INT,
	PaymentMethod  NVARCHAR(50),
	Amount        DECIMAL(10,2),
    PaymentDate   DATE
);
GO

IF OBJECT_ID('bronze.inventory', 'U') IS NOT NULL
    DROP TABLE bronze.inventory;
GO

CREATE TABLE bronze.inventory (
    InventoryID   INT,
	ProductID     INT,
	QuantityInStock  INT,
    ReorderLevel   INT
);
GO

IF OBJECT_ID('bronze.orders', 'U') IS NOT NULL
    DROP TABLE bronze.orders;
GO

CREATE TABLE bronze.orders (
    OrderID      INT,
	ProductID    INT,
	CustomerID   INT,
    OrderDate    DATE,
	OrderQuantity  INT,
    TotalAmount  DECIMAL(10, 2),
    Status       NVARCHAR(20) NOT NULL CHECK (Status IN ('Cancelled', 'Shipped', 'Delivered', 'Pending'))
);
GO

IF OBJECT_ID('bronze.shipments', 'U') IS NOT NULL
    DROP TABLE bronze.shipments;
GO

CREATE TABLE bronze.shipments (
    ShipmentID   INT,
	OrderID      INT,
    ShipmentDate DATE,
	Carrier      NVARCHAR(50),
	TrackingNumber  NVARCHAR(50)
);
GO

IF OBJECT_ID('bronze.reviews', 'U') IS NOT NULL
    DROP TABLE bronze.reviews;
GO

CREATE TABLE bronze.reviews (
    ReviewID     INT,
	ProductID    INT,
	CustomerID   INT,
	Rating       INT,
	Comment      NVARCHAR(100),
    ReviewDate   DATE
);
GO