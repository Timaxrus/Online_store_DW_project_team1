/*
===============================================================================
Stored Procedure: silver.PlaceOrder (Source -> Bronze)
===============================================================================
Script Purpose:
    This stored procedure Places an order making sure the inventory level is sufficient and adds the new order to silver.orders table. 
    
===============================================================================
*/

CREATE OR ALTER PROCEDURE silver.PlaceOrder
	@CustomerID INT,
	@ProductID INT,
	@Quantity INT,
	@OrderDate DATE,
	@OrderStatus NVARCHAR(50) OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @Stock INT;
	DECLARE @Price DECIMAL(10, 2);
	DECLARE @OrderTotal INT;

	-- Step 1: Check if the product exists and get its price and stock
	SELECT @Price = p.Price, @Stock = i.QuantityInStock
	FROM silver.products p
	JOIN silver.inventory i ON p.ProductID = i.ProductID
	WHERE p.ProductID = @ProductID;

	-- Step 2: Validate stock availability
	IF @Stock >= @Quantity
	BEGIN
		-- Calculate the total order amount
		SET @OrderTotal = @Price * @Quantity;

		-- Insert the order into the Orders table
		INSERT INTO bronze.orders (ProductID, CustomerID, OrderDate, OrderQuantity, TotalAmount, Status)
		VALUES (@ProductID, @CustomerID, @OrderDate, @Quantity, @OrderTotal, 'Pending');

		-- Update the inventory by reducing the stock
		UPDATE silver.inventory
		SET QuantityInStock = QuantityInStock - @Quantity
		WHERE ProductID = @ProductID;

		-- Set success status
		SET @OrderStatus = 'Order placed successfully.';
	END
	ELSE
	BEGIN
		-- Set error status if stock is insufficient
		SET @OrderStatus = 'Insufficient stock to place the order.';
	END
END;

-- Below is the example of running the PlaceOrder proc.

-- This places an order for customer 101, product 5, with a quantity of 2 on 2023-10-15.

--DECLARE @OrderStatus NVARCHAR(50);

--EXEC bronze.PlaceOrder
--    @CustomerID = 101,
--    @ProductID = 5,
--    @Quantity = 2,
--    @OrderDate = '2026-10-15',
--    @OrderStatus = @OrderStatus OUTPUT;

--PRINT @OrderStatus;
