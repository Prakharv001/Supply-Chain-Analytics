USE SupplyChainAnalyticsDB;
GO

/* =========================================================
   1. EXECUTIVE KPIs
   ========================================================= */

SELECT
    COUNT(*) AS Total_Records,
    SUM(Units_Sold) AS Total_Units_Sold,
    AVG(Inventory_Level) AS Avg_Inventory_Level,
    AVG(Supplier_Lead_Time_Days) AS Avg_Supplier_Lead_Time,
    SUM(Order_Quantity) AS Total_Order_Quantity
FROM FactInventory;
GO


/* =========================================================
   2. STOCKOUT ANALYSIS
   ========================================================= */

SELECT
    SUM(CASE WHEN Stockout_Flag = 1 THEN 1 ELSE 0 END) AS Stockout_Records,
    COUNT(*) AS Total_Records,
    CAST(
        100.0 * SUM(CASE WHEN Stockout_Flag = 1 THEN 1 ELSE 0 END)
        / COUNT(*)
        AS DECIMAL(10,2)
    ) AS Stockout_Rate_Percent
FROM FactInventory;
GO

/* =========================================================
   3. SALES BY PRODUCT
   ========================================================= */

SELECT TOP 10
    p.SKU_ID,
    SUM(f.Units_Sold) AS Total_Units_Sold
FROM FactInventory f
INNER JOIN DimProduct p
    ON f.ProductKey = p.ProductKey
GROUP BY
    p.SKU_ID
ORDER BY
    Total_Units_Sold DESC;
GO


/* =========================================================
   4. SALES BY WAREHOUSE
   ========================================================= */

SELECT
    w.Warehouse_ID,
    w.Region,
    SUM(f.Units_Sold) AS Total_Units_Sold,
    AVG(f.Inventory_Level) AS Avg_Inventory
FROM FactInventory f
INNER JOIN DimWarehouse w
    ON f.WarehouseKey = w.WarehouseKey
GROUP BY
    w.Warehouse_ID,
    w.Region
ORDER BY
    Total_Units_Sold DESC;
GO

/* =========================================================
   5. SALES BY REGION
   ========================================================= */

SELECT
    w.Region,
    SUM(f.Units_Sold) AS Total_Units_Sold,
    AVG(f.Inventory_Level) AS Avg_Inventory
FROM FactInventory f
INNER JOIN DimWarehouse w
    ON f.WarehouseKey = w.WarehouseKey
GROUP BY
    w.Region
ORDER BY
    Total_Units_Sold DESC;
GO


/* =========================================================
   6. SUPPLIER PERFORMANCE
   ========================================================= */

SELECT
    s.Supplier_ID,
    AVG(f.Supplier_Lead_Time_Days) AS Avg_Lead_Time_Days,
    SUM(f.Order_Quantity) AS Total_Order_Quantity,
    SUM(f.Units_Sold) AS Total_Units_Sold
FROM FactInventory f
INNER JOIN DimSupplier s
    ON f.SupplierKey = s.SupplierKey
GROUP BY
    s.Supplier_ID
ORDER BY
    Avg_Lead_Time_Days DESC;
GO

/* =========================================================
   7. PROMOTION EFFECTIVENESS
   ========================================================= */

SELECT
    CASE
        WHEN Promotion_Flag = 1 THEN 'Promotion'
        ELSE 'No Promotion'
    END AS Promotion_Status,
    COUNT(*) AS Records,
    SUM(Units_Sold) AS Total_Units_Sold,
    AVG(Units_Sold) AS Avg_Units_Sold
FROM FactInventory
GROUP BY
    Promotion_Flag
ORDER BY
    Promotion_Flag DESC;
GO