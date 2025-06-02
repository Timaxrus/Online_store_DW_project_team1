/*
===============================================================================
DDL Script: Create Silver Tables
===============================================================================
Script Purpose:
    This script creates tables in the 'silver' schema, dropping existing tables 
    if they already exist.
	  Run this script to re-define the DDL structure of 'silver' Tables
===============================================================================
*/

IF OBJECT_ID('silver.Categories', 'U') IS NOT NULL
    DROP TABLE silver.Categories;
GO

CREATE TABLE silver.categories (
    CategoryID INT,
	CategoryName NVARCHAR(50),
	CreateDate	DATETIME2 DEFAULT GETDATE()
);
GO

IF OBJECT_ID('silver.customers', 'U') IS NOT NULL
    DROP TABLE silver.customers;
GO

CREATE TABLE silver.customers (
  CustomerID       INT,
  FirstName       NVARCHAR(50),
  LastName      NVARCHAR(50),
  Gender        NVARCHAR(20),
  Email        NVARCHAR(50),
  Phone        NVARCHAR(50),
  Address      NVARCHAR(50),
  City       NVARCHAR(50),
  State      NVARCHAR(50),
  Country     NVARCHAR(50),
  DateRegistered DATE,
  CreateDate  DATETIME2 DEFAULT GETDATE()
);
GO

IF OBJECT_ID('silver.inventory', 'U') IS NOT NULL
    DROP TABLE silver.inventory;
GO

CREATE TABLE silver.inventory (
    InventoryID INT,
	ProductID INT,
	QuantityInStock INT,
	CreateDate	DATETIME2 DEFAULT GETDATE()
);
GO

IF OBJECT_ID('silver.orders', 'U') IS NOT NULL
    DROP TABLE silver.orders;
GO

CREATE TABLE silver.orders (
    OrderID    INT,
	ProductID  INT,
	CustomerID INT,
	OrderDate  DATE,
	OrderQuantity   INT,
	TotalAmount DECIMAL(10, 2),
	Status     NVARCHAR(50),
	CreateDate	DATETIME2 DEFAULT GETDATE()
);
GO

IF OBJECT_ID('silver.payments', 'U') IS NOT NULL
    DROP TABLE silver.payments;
GO

CREATE TABLE silver.payments (
    PaymentID INT,
	OrderID INT,
	PaymentMethod NVARCHAR(50),
	Amount DECIMAL(10, 2),
	PaymentDate DATE,
	CreateDate	DATETIME2 DEFAULT GETDATE()
);
GO

IF OBJECT_ID('silver.products', 'U') IS NOT NULL
    DROP TABLE silver.products;
GO

CREATE TABLE silver.products (
    ProductID INT,
	ProductName NVARCHAR(50),
	CategoryID INT,
	SupplierID INT,
	Price DECIMAL(10, 2),
	Description NVARCHAR(50),
	DateAdded DATE,
	CreateDate		DATETIME2 DEFAULT GETDATE()
);
GO

IF OBJECT_ID('silver.reviews', 'U') IS NOT NULL
    DROP TABLE silver.reviews;
GO

CREATE TABLE silver.reviews (
    ReviewID INT,
	ProductID INT,
	CustomerID INT,
	Rating INT,
	Comment NVARCHAR(50),
	ReviewDate DATE,
	CreateDate		DATETIME2 DEFAULT GETDATE()
);
GO

IF OBJECT_ID('silver.shipments', 'U') IS NOT NULL
    DROP TABLE silver.shipments;
GO

CREATE TABLE silver.shipments (
    ShipmentID INT,
	OrderID INT,
	ShipmentDate DATE,
	Carrier NVARCHAR(50),
	TrackingNumber NVARCHAR(50),

	CreateDate		DATETIME2 DEFAULT GETDATE()
);
GO

