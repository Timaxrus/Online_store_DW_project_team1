/*
===============================================================================
Stored Procedure: silver.UpdateInventory 
===============================================================================
Script Purpose:
    This stored procedure allows you to manually update the inventory for a specific product.
    
===============================================================================
*/

CREATE OR ALTER PROCEDURE silver.UpdateInventory
    @ProductID INT,
    @NewQuantity INT,
    @UpdateStatus NVARCHAR(50) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    -- Step 1: Check if the product exists
    IF EXISTS (SELECT 1 FROM silver.products WHERE ProductID = @ProductID)
    BEGIN
        -- Step 2: Update the inventory with the new quantity
        UPDATE silver.inventory
        SET QuantityInStock = @NewQuantity
        WHERE ProductID = @ProductID;

        -- Set success status
        SET @UpdateStatus = 'Inventory updated successfully.';
    END
    ELSE
    BEGIN
        -- Set error status if the product does not exist
        SET @UpdateStatus = 'Product does not exist.';
    END
END;


-- This updates the inventory for product 5, setting the stock level to 100.

--DECLARE @UpdateStatus NVARCHAR(50);

--EXEC UpdateInventory
--    @ProductID = 5,
--    @NewQuantity = 100,
--    @UpdateStatus = @UpdateStatus OUTPUT;

--PRINT @UpdateStatus;