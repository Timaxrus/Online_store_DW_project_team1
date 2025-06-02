/*
===============================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
===============================================================================
Script Purpose:
    This stored procedure loads data into the 'bronze' schema from external CSV files. 
    It performs the following actions:
    - Truncates the bronze tables before loading data.
    - Uses the `BULK INSERT` command to load data from csv Files to bronze tables.
    - Error handling during loading.
    - Calculates durations for every table and total loading.

Parameters:
    None. 
	  This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC bronze.load_bronze;
===============================================================================
*/
CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN

	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
	BEGIN TRY
	SET @batch_start_time = GETDATE()
		PRINT '===========================================================================';
		PRINT 'Loading Bronze Layer'; 
		PRINT '===========================================================================';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.categories';
		TRUNCATE TABLE bronze.categories;

		PRINT '>> Iserting Data Into: bronze.categories';
		BULK INSERT bronze.categories
		FROM 'D:\Data Analytics_BI analyst\SQL training\Online_store_DW_project_team1\Online_store_DW_project_team1\datasets\categories.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> -------------------------------------------';
	



	   	SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.customers';
		TRUNCATE TABLE bronze.customers;

		PRINT '>> Inserting Data Into: bronze.customers';
		BULK INSERT bronze.customers
		FROM 'D:\Data Analytics_BI analyst\SQL training\Online_store_DW_project_team1\Online_store_DW_project_team1\datasets\customers.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> -------------------------------------------';
		
		
		
		
		
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.inventory';
		TRUNCATE TABLE bronze.inventory;

		PRINT '>> Inserting Data Into: bronze.inventory';
		BULK INSERT bronze.inventory
		FROM 'D:\Data Analytics_BI analyst\SQL training\Online_store_DW_project_team1\Online_store_DW_project_team1\datasets\inventory.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> -------------------------------------------';


		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.orders';
		TRUNCATE TABLE bronze.orders;

		PRINT '>> Inserting Data Into: bronze.orders';
		BULK INSERT bronze.orders
		FROM 'D:\Data Analytics_BI analyst\SQL training\Online_store_DW_project_team1\Online_store_DW_project_team1\datasets\orders.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> -------------------------------------------';
		



		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.payments';
		TRUNCATE TABLE bronze.payments;

		PRINT '>> Inserting Data Into: bronze.payments';
		BULK INSERT bronze.payments
		FROM 'D:\Data Analytics_BI analyst\SQL training\Online_store_DW_project_team1\Online_store_DW_project_team1\datasets\payments.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> -------------------------------------------';
		



		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.products';
		TRUNCATE TABLE bronze.products;

		PRINT '>> Inserting Data Into: bronze.products';
		BULK INSERT bronze.products
		FROM 'D:\Data Analytics_BI analyst\SQL training\Online_store_DW_project_team1\Online_store_DW_project_team1\datasets\products.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			ROWTERMINATOR = '\n',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> -------------------------------------------';



		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.reviews';
		TRUNCATE TABLE bronze.reviews;

		PRINT '>> Inserting Data Into: bronze.reviews';
		BULK INSERT bronze.reviews
		FROM 'D:\Data Analytics_BI analyst\SQL training\Online_store_DW_project_team1\Online_store_DW_project_team1\datasets\reviews.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> -------------------------------------------';




		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.shipments';
		TRUNCATE TABLE bronze.shipments;

		PRINT '>> Inserting Data Into: bronze.shipments';
		BULK INSERT bronze.shipments
		FROM 'D:\Data Analytics_BI analyst\SQL training\Online_store_DW_project_team1\Online_store_DW_project_team1\datasets\shipments.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> -------------------------------------------';




	SET @batch_end_time = GETDATE()
	PRINT '=========================================================================';
	PRINT 'Loading Bronze Layer is Completed!';
	PRINT '    - Total Load Duration: ' + CAST(DATEDIFF(second, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
	PRINT '=========================================================================';

	END TRY
	BEGIN CATCH
		PRINT '==============================================================';
		PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER';
		PRINT 'ERROR MESSAGE ' + ERROR_MESSAGE();
		PRINT 'ERROR MESSAGE ' + CAST(ERROR_NUMBER() AS NVARCHAR);
		PRINT 'ERROR MESSAGE ' + CAST(ERROR_STATE() AS NVARCHAR);
		PRINT '==============================================================';
	END CATCH
END

EXEC bronze.load_bronze;
