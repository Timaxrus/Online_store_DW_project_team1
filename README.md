# Online_store_DW_project_team1
Online store datawarehouse designing project

# Data Warehouse Project Documentation

## Table of Contents
1. [Project Overview](#1-project-overview)
2. [Database Initialization Script](#2-database-initialization-script)
3. [Bronze Layer](#3-bronze-layer)
4. [Silver Layer](#4-silver-layer)
5. [Gold Layer](#5-gold-layer)
6. [Automation with SQL Agent](#6-automation-with-sql-agent)
7. [Deployment and Maintenance](#7-deployment-and-maintenance)
8. [Conclusion](#8-conclusion)

---

## 1. Project Overview

### Purpose:
The purpose of this Data Warehouse project is to provide a structured and reliable framework for analyzing data from an online store. The system supports advanced analytics by organizing data into three distinct layers: **Bronze**, **Silver**, and **Gold**.

### Target Audience:
- **Technical Users**: Data Engineers, Database Administrators, and Developers.
- **Business Users**: Data Analysts, Business Intelligence Teams, and Decision-Makers.

### Key Objectives:
1. **Bronze Layer**: Load raw data from source CSV files with minimal transformations.
2. **Silver Layer**: Perform ETL (Extract, Transform, Load) processes to clean, validate, and enrich the data.
3. **Gold Layer**: Create analytical views for business intelligence purposes, such as sales performance, customer lifetime value, inventory status, and product review summaries.

---

## 2. Database Initialization Script

### Purpose:
This script initializes the database and sets up the necessary schemas (`bronze`, `silver`, `gold`) for the Data Warehouse.

### Code Snippet:
```sql
USE master;
GO

-- Drop and recreate the 'Team1' database
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'Team1')
BEGIN
    ALTER DATABASE Team1 SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE Team1;
END;
GO

CREATE DATABASE Team1;
GO

USE Team1;
GO

-- Create Schemas
CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO
```

## **Warning** : Running this script will permanently delete all data in the Team1 database. Ensure proper backups before execution.

### 3. Bronze Layer

### Purpose:
The Bronze layer serves as the landing zone for raw data. It contains exact copies of the source tables without any transformations.

### Table Definitions:
DDL Script :
-  Creates tables for Customers, Products, Categories, Orders, Shipments, Inventories, and Reviews.
-  Each table mirrors the structure of the corresponding source CSV file.

**Example Table Definition:**

```sql
CREATE TABLE bronze.orders (
    OrderID      INT,
    ProductID    INT,
    CustomerID   INT,
    OrderDate    DATE,
    OrderQuantity INT,
    TotalAmount  DECIMAL(10, 2),
    Status       NVARCHAR(20) NOT NULL CHECK (Status IN ('Cancelled', 'Shipped', 'Delivered', 'Pending'))
);
```
---
### Bulk Insert Process:
1. **Script Name :** proc_load_bronze.sql
2. **Purpose :** Bulk inserts data from CSV files into the corresponding Bronze tables.
3. **Key Features :**
- Automates the ingestion of raw data.
- Ensures data integrity by matching column structures.
