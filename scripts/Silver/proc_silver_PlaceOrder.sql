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
    @OrderDate DATE = NULL,
    @OrderStatus NVARCHAR(50) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @Stock INT;
    DECLARE @Price DECIMAL(10, 2);
    DECLARE @OrderTotal DECIMAL(10, 2);
    DECLARE @NewOrderID INT;
    
    -- Set default order date if not provided
    IF @OrderDate IS NULL
        SET @OrderDate = CAST(GETDATE() AS DATE);
    
    -- 1. Get product price and current stock
    SELECT @Price = p.Price, @Stock = i.QuantityInStock
    FROM silver.products p
    JOIN silver.inventory i ON p.ProductID = i.ProductID
    WHERE p.ProductID = @ProductID;
    
    -- 2. Validate stock availability
    IF @Stock >= @Quantity
    BEGIN
        BEGIN TRY
            BEGIN TRANSACTION;
            
            -- 3. Calculate order total
            SET @OrderTotal = @Price * @Quantity;
            
            -- 4. Get next OrderID (using IDENTITY or MAX+1)
            SELECT @NewOrderID = ISNULL(MAX(OrderID), 0) + 1 
            FROM silver.orders;
            
            -- 5. Insert into silver.orders (not bronze)
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
            VALUES (
                @NewOrderID,
                @ProductID,
                @CustomerID,
                @OrderDate,
                @Quantity,
                @OrderTotal,
                'Pending',
                GETDATE()
            );
            
            -- 6. Update inventory
            UPDATE silver.inventory
            SET QuantityInStock = QuantityInStock - @Quantity
            WHERE ProductID = @ProductID;
            
            -- 7. Set success status
            SET @OrderStatus = 'Order placed successfully. OrderID: ' + CAST(@NewOrderID AS VARCHAR(10));
            
            COMMIT TRANSACTION;
        END TRY
        BEGIN CATCH
            ROLLBACK TRANSACTION;
            SET @OrderStatus = 'Error placing order: ' + ERROR_MESSAGE();
        END CATCH
    END
    ELSE
    BEGIN
        -- Set error status if stock is insufficient
        SET @OrderStatus = 'Insufficient stock to place the order. Available: ' + CAST(@Stock AS VARCHAR(10));
    END
END;

-- Below is the example of running the PlaceOrder proc.

-- This places an order for customer 101, product 5, with a quantity of 2 on GETDATE().

--DECLARE @CustomerID INT = 101;
--DECLARE @ProductID INT = 5;
--DECLARE @Quantity INT = 2;
--DECLARE @OrderStatus NVARCHAR(100);

---- Place the order
--EXEC silver.PlaceOrder
--    @CustomerID = @CustomerID,
--    @ProductID = @ProductID,
--    @Quantity = @Quantity,
--    @OrderStatus = @OrderStatus OUTPUT;

---- View the result
--PRINT @OrderStatus;


