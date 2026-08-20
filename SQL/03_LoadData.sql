USE SupplyChainAnalyticsDB;
GO

/* =========================================================
   LOAD DATE DIMENSION
   ========================================================= */

INSERT INTO DimDate
(
    DateKey,
    Date,
    Day,
    Month,
    MonthName,
    Quarter,
    Year
)
SELECT DISTINCT
    CONVERT(INT, FORMAT(Date, 'yyyyMMdd')) AS DateKey,
    Date,
    DAY(Date) AS Day,
    MONTH(Date) AS Month,
    DATENAME(MONTH, Date) AS MonthName,
    DATEPART(QUARTER, Date) AS Quarter,
    YEAR(Date) AS Year
FROM Stg_SupplyChainData
WHERE Date IS NOT NULL;
GO

/* =========================================================
   LOAD PRODUCT DIMENSION
   ========================================================= */

INSERT INTO DimProduct
(
    SKU_ID,
    Unit_Cost,
    Unit_Price
)
SELECT
    SKU_ID,
    MAX(Unit_Cost) AS Unit_Cost,
    MAX(Unit_Price) AS Unit_Price
FROM Stg_SupplyChainData
WHERE SKU_ID IS NOT NULL
GROUP BY SKU_ID;
GO

/* =========================================================
   LOAD SUPPLIER DIMENSION
   ========================================================= */

INSERT INTO DimSupplier
(
    Supplier_ID
)
SELECT DISTINCT
    Supplier_ID
FROM Stg_SupplyChainData
WHERE Supplier_ID IS NOT NULL;
GO

/* =========================================================
   LOAD WAREHOUSE DIMENSION
   ========================================================= */

INSERT INTO DimWarehouse
(
    Warehouse_ID,
    Region
)
SELECT
    Warehouse_ID,
    MAX(Region) AS Region
FROM Stg_SupplyChainData
WHERE Warehouse_ID IS NOT NULL
GROUP BY Warehouse_ID;
GO


/* =========================================================
   LOAD FACT INVENTORY
   ========================================================= */

INSERT INTO FactInventory
(
    DateKey,
    ProductKey,
    SupplierKey,
    WarehouseKey,
    Units_Sold,
    Inventory_Level,
    Supplier_Lead_Time_Days,
    Reorder_Point,
    Order_Quantity,
    Promotion_Flag,
    Stockout_Flag,
    Demand_Forecast
)
SELECT
    d.DateKey,
    p.ProductKey,
    s.SupplierKey,
    w.WarehouseKey,
    st.Units_Sold,
    st.Inventory_Level,
    st.Supplier_Lead_Time_Days,
    st.Reorder_Point,
    st.Order_Quantity,
    st.Promotion_Flag,
    st.Stockout_Flag,
    st.Demand_Forecast
FROM Stg_SupplyChainData st

INNER JOIN DimDate d
    ON st.Date = d.Date

INNER JOIN DimProduct p
    ON st.SKU_ID = p.SKU_ID

INNER JOIN DimSupplier s
    ON st.Supplier_ID = s.Supplier_ID

INNER JOIN DimWarehouse w
    ON st.Warehouse_ID = w.Warehouse_ID;
GO