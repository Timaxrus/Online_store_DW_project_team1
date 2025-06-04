--use Team1
/*
===============================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
===============================================================================
Script Purpose:
    This stored procedure performs the ETL (Extract, Transform, Load) process to 
    populate the 'silver' schema tables from the 'bronze' schema.
	Actions Performed:
		- Truncates Silver tables.
		- Inserts transformed and cleansed data from Bronze into Silver tables.
		
Parameters:
    None. 
	  This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC Silver.load_silver;
	*/
	CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
    -- Declare variables to track start and end times for loading operations.
    DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
	BEGIN TRY
    -- Start TRY block for error handling.
        -- Set the start time for the entire procedure execution.
        SET @batch_start_time = GETDATE();
        PRINT '================================================';
        PRINT 'Loading Silver Layer';
        PRINT '================================================';

        -- Start loading the Payments table
        PRINT '------------------------------------------------';
        PRINT 'Loading Payments table';
        PRINT '------------------------------------------------';

        -- Load silver.payments
        SET @start_time = GETDATE();
        PRINT '>> Truncating table: silver.Payments';
        TRUNCATE TABLE silver.payments; -- Clear the table before inserting.

        PRINT '>> Inserting data into: silver.Payments';
        INSERT INTO silver.payments (
            PaymentID,
            OrderID,
            PaymentMethod,
            Amount,
            PaymentDate,
            CreateDate
        )
        SELECT
            PaymentID,
            OrderID,
            CASE
                WHEN UPPER(TRIM(PaymentMethod)) = 'PAYPAL' THEN 'PayPal'
                WHEN UPPER(TRIM(PaymentMethod)) = 'BANK TRANSFER' THEN 'Bank Transfer'
                WHEN UPPER(TRIM(PaymentMethod)) = 'DEBIT CARD' THEN 'Debit Card'
                ELSE 'Other' -- Standardize payment method.
            END AS PaymentMethod,
            Amount,
            PaymentDate,
            GETDATE() AS CreateDate -- Populate CreateDate with current timestamp
        FROM (
            SELECT
                *,
                -- Select the latest record for each PaymentID to remove duplicates.
                ROW_NUMBER() OVER (PARTITION BY PaymentID ORDER BY paymentDate DESC) AS rn
            FROM bronze.payments
            WHERE PaymentID IS NOT NULL
        ) t
        WHERE rn = 1;

        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

        -- Start loading the Inventory table
        PRINT '------------------------------------------------';
        PRINT 'Loading Inventory table';
        PRINT '------------------------------------------------';

        -- Load silver.inventory
        SET @start_time = GETDATE();
        PRINT '>> Truncating table: silver.inventory';
        TRUNCATE TABLE silver.inventory;

        PRINT '>> Inserting data into: silver.inventory';
        INSERT INTO silver.inventory (
            InventoryID,
            ProductID,
            QuantityInStock,
            ReorderLevel,
			CreateDate
        )
        SELECT
            InventoryID,
            ProductID,
            QuantityInStock,
            Reorderlevel,
			GETDATE() AS CreateDate
        FROM (
            SELECT
                *,
                -- Select the latest record for each inventoryID.
                ROW_NUMBER() OVER (PARTITION BY InventoryID ORDER BY ProductID DESC) AS rn
            FROM bronze.inventory
            WHERE InventoryID IS NOT NULL
        ) t
        WHERE rn = 1;

        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

        -- Start loading the Reviews table
        PRINT '------------------------------------------------';
        PRINT 'Loading Reviews table';
        PRINT '------------------------------------------------';

        SET @start_time = GETDATE();
        PRINT '>> Truncating table: silver.reviews';
        TRUNCATE TABLE silver.reviews; -- Ensure the table name is correct: Reviews or product_reviews.

        PRINT '>> Inserting data into: silver.reviews';
        INSERT INTO silver.reviews ( -- The table name here should match TRUNCATE.
            ReviewID,
            ProductID,
            CustomerID,
            Rating,
            Comment,
            ReviewDate,
            CreateDate 
        )
        SELECT
            ReviewID,
            ProductID,
            CustomerID,
            CASE
                WHEN rating < 1 THEN 1
                WHEN rating > 5 THEN 5
                ELSE rating -- Normalize rating to a range from 1 to 5.
            END AS rating,
            -- Clean up comments: remove extra spaces, carriage returns, and line feeds.
            LTRIM(RTRIM(
                REPLACE(REPLACE(comment, CHAR(13), ''), CHAR(10), '')
            )) AS comment,
            -- Convert ReviewDate to DATE format, ignoring invalid dates.
            TRY_CAST(ReviewDate AS DATE) AS reviewDate,
            GETDATE() AS CreateDate -- Populate CreateDate with current timestamp
        FROM (
            SELECT
                *,
                -- Select the latest record for each ReviewID.
                ROW_NUMBER() OVER (PARTITION BY reviewID ORDER BY reviewDate DESC) AS rn
            FROM bronze.Reviews
            WHERE reviewID IS NOT NULL
        ) t
        WHERE rn = 1
        AND TRY_CAST(ReviewDate AS DATE) IS NOT NULL; -- Filter out records with invalid dates.

        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

        -- Start loading the Products table
        SET @start_time = GETDATE();
        PRINT '>> Truncating table: silver.products';
        TRUNCATE TABLE silver.products;

        PRINT '>> Inserting data into: silver.products';
        INSERT INTO silver.products (
            ProductID,
            ProductName,
            CategoryID,
            SupplierID,
            Price,
            Description,
            DateAdded,
            CreateDate 
        )
        SELECT
            ProductID,
            TRIM(ProductName) AS ProductName, -- Remove leading/trailing spaces.
            ISNULL(CategoryID, 0) AS CategoryID, -- Replace NULL with 0.
            ISNULL(SupplierID, 0) AS SupplierID, -- Replace NULL with 0.
            ISNULL(Price, 0.00) AS Price,         -- Replace NULL with 0.00.
            LEFT(TRIM(Description), 50) AS Description, -- Truncate and remove spaces.
            CAST(DateAdded AS DATE) AS DateAdded, -- Convert to DATE.
            GETDATE() AS CreateDate -- Populate CreateDate with current timestamp
        FROM bronze.products;

        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

        -- Start loading the Shipments table
        SET @start_time = GETDATE();
        PRINT '>> Truncating table: silver.shipments';
        TRUNCATE TABLE silver.shipments;

        PRINT '>> Inserting data into: silver.shipments';
        INSERT INTO silver.shipments (
            ShipmentID,
            OrderID,
            ShipmentDate,
            Carrier,
            TrackingNumber,
            CreateDate 
        )
        SELECT
            ShipmentID,
            ISNULL(OrderID, 0) AS OrderID, -- Replace NULL with 0.
            CAST(ShipmentDate AS DATE) AS ShipmentDate, -- Convert to DATE.
            LEFT(TRIM(Carrier), 50) AS Carrier,         -- Truncate and remove spaces.
            LEFT(TRIM(TrackingNumber), 50) AS TrackingNumber, -- Truncate and remove spaces.
            GETDATE() AS CreateDate -- Populate CreateDate with current timestamp
        FROM bronze.shipments;

        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

        -- Start loading the Categories table
        SET @start_time = GETDATE();
        PRINT '>> Truncating table: silver.categories';
        TRUNCATE TABLE silver.categories;

        PRINT '>> Inserting data into: silver.categories';
        INSERT INTO silver.categories (
            CategoryID,
            CategoryName,
            CreateDate -- Added CreateDate column
        )
        SELECT
            CategoryID,
            LEFT(TRIM(CategoryName), 50) AS CategoryName, -- Truncate and remove spaces.
            GETDATE() AS CreateDate -- Populate CreateDate with current timestamp
        FROM bronze.categories;

        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

        -- Start loading the Orders table
        SET @start_time = GETDATE(); -- Added start time measurement for Orders.
        PRINT '>> Truncating table: silver.orders';
        TRUNCATE TABLE silver.orders;

        PRINT '>> Inserting data into: silver.orders';
        INSERT INTO silver.orders (
            OrderID,
            ProductID,
            CustomerID,
            OrderDate,
            OrderQuantity,
            TotalAmount,
            Status,
            CreateDate 
        )
        SELECT
            OrderID,
            ISNULL(ProductID, 0) AS ProductID,      -- Replace NULL with 0.
            ISNULL(CustomerID, 0) AS CustomerID,    -- Replace NULL with 0.
            CAST(OrderDate AS DATE) AS OrderDate, -- Convert to DATE.
            ISNULL(OrderQuantity, 0) AS OrderQuantity, -- Replace NULL with 0.
            ISNULL(TotalAmount, 0.00) AS TotalAmount, -- Replace NULL with 0.00.
            LEFT(TRIM(Status), 50) AS Status,       -- Truncate and remove spaces.
            GETDATE() AS CreateDate -- Populate CreateDate with current timestamp
        FROM bronze.orders;

        SET @end_time = GETDATE(); -- Added end time measurement for Orders.
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

        -- Start loading the Customers table
        SET @start_time = GETDATE();
        PRINT '>> Truncating table: silver.customers';
        TRUNCATE TABLE silver.customers;
        PRINT '>> Inserting data into: silver.customers';
        INSERT INTO silver.customers(
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
            CreateDate -- Added CreateDate column
        )
        SELECT
            CustomerID,
            TRIM(FirstName) AS FirstName,
            TRIM(LastName) AS LastName,
            Gender,
            CASE
                WHEN Email LIKE '%@%.%' THEN Email
                ELSE 'Invalid' -- Validate Email format.
            END AS Email,
            CASE
                -- Remove all non-digit characters and validate phone number length.
                WHEN LEN(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
                Phone, '(', ''), ')', ''), '-', ''), '.', ''), ' ', ''), '+', ''), 'x', '')) < 10 THEN 'Invalid'
                ELSE Phone
            END AS Phone,
            -- Format address to "First letter capitalized, rest lowercase".
            UPPER(LEFT(Address, 1)) + LOWER(SUBSTRING(Address, 2, LEN(Address))) AS Address,
            TRIM(City) AS City,
            TRIM(State) AS State,
            TRIM(Country) AS Country,
            DateRegistered,
            GETDATE() AS CreateDate -- Populate CreateDate with current timestamp
        FROM (
            SELECT
                *,
                -- Select the latest record for each CustomerID.
                ROW_NUMBER() OVER (PARTITION BY CustomerID ORDER BY DateRegistered DESC) AS flag_last
            FROM bronze.customers
            WHERE CustomerID IS NOT NULL
        ) t
        WHERE flag_last = 1; -- Select only the latest record.

        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

        -- End of the entire batch loading.
        SET @batch_end_time = GETDATE();
        PRINT '==========================================';
        PRINT 'Silver Layer Load Completed!';
        PRINT '    - Total Load Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
        PRINT '==========================================';

     END TRY
     BEGIN CATCH
         -- NOTE: This CATCH block is also commented out in your original code.
         -- It is recommended to uncomment it for comprehensive error handling.
         PRINT '==========================================';
         PRINT 'AN ERROR OCCURRED DURING SILVER LAYER LOAD';
         PRINT 'Error Message: ' + ERROR_MESSAGE();
         PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS NVARCHAR);
         PRINT 'Error State: ' + CAST(ERROR_STATE() AS NVARCHAR);
         PRINT '==========================================';
     END CATCH
END;


EXEC silver.load_silver




