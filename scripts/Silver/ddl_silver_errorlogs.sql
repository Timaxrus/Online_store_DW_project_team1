/*
===============================================================================
DDL Error creation of error logging tables: silver.error_lot, silver.job_control
===============================================================================
Script Purpose:
    These tables contain error events happenned during stored procedure execution time.
	Creates the following tables:
		- Truncates Silver tables.
		- Inserts transformed and cleansed data from Bronze into Silver tables.
*/
-- Error logging table

CREATE TABLE silver.error_log (
log_id INT IDENTITY(1,1) PRIMARY KEY,
error_time DATETIME2 NOT NULL,
error_message NVARCHAR(4000),
procedure_name NVARCHAR(255),
batch_id UNIQUEIDENTIFIER
);

-- Job control table

CREATE TABLE silver.job_control (
job_name NVARCHAR(255) PRIMARY KEY,
last_run_time DATETIME2,
status NVARCHAR(50),
records_processed INT
);