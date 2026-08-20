USE SupplyChainAnalyticsDB;
GO

/* =========================================================
   VIEW 1: MONTHLY DEMAND & INVENTORY PERFORMANCE
   ========================================================= */

CREATE OR ALTER VIEW vw_MonthlyDemand
AS
SELECT
    d.Year,
    d.Month,
    d.MonthName,

    SUM(f.Units_Sold) AS Total_Units_Sold,

    AVG(f.Inventory_Level) AS Avg_Inventory,

    CAST(
        SUM(f.Units_Sold) /
        NULLIF(AVG(f.Inventory_Level), 0)
        AS DECIMAL(10,2)
    ) AS Inventory_Turnover

FROM FactInventory f

INNER JOIN DimDate d
    ON f.DateKey = d.DateKey

GROUP BY
    d.Year,
    d.Month,
    d.MonthName;
GO

/* =========================================================
   VIEW 2: PRODUCT PERFORMANCE
   ========================================================= */

CREATE OR ALTER VIEW vw_ProductPerformance
AS
SELECT
    p.SKU_ID,

    SUM(f.Units_Sold) AS Total_Units_Sold,

    AVG(f.Inventory_Level) AS Avg_Inventory,

    AVG(f.Reorder_Point) AS Avg_Reorder_Point,

    AVG(f.Inventory_Level)
        - AVG(f.Reorder_Point) AS Inventory_Buffer,

    CAST(
        SUM(f.Units_Sold) /
        NULLIF(AVG(f.Inventory_Level), 0)
        AS DECIMAL(10,2)
    ) AS Inventory_Turnover,

    CAST(
        AVG(ABS(f.Units_Sold - f.Demand_Forecast))
        AS DECIMAL(10,2)
    ) AS Forecast_MAE,

    CAST(
        AVG(
            CASE
                WHEN f.Units_Sold <> 0
                THEN ABS(f.Units_Sold - f.Demand_Forecast)
                     * 100.0 / f.Units_Sold
            END
        )
        AS DECIMAL(10,2)
    ) AS Forecast_MAPE,

    SUM(f.Order_Quantity) AS Total_Order_Quantity,

    SUM(f.Order_Quantity)
        - SUM(f.Units_Sold) AS Order_Sales_Gap

FROM FactInventory f

INNER JOIN DimProduct p
    ON f.ProductKey = p.ProductKey

GROUP BY
    p.SKU_ID;
GO


/* =========================================================
   VIEW 3: WAREHOUSE PERFORMANCE
   ========================================================= */

CREATE OR ALTER VIEW vw_WarehousePerformance
AS
SELECT
    w.Warehouse_ID,
    w.Region,

    SUM(f.Units_Sold) AS Total_Units_Sold,

    AVG(f.Inventory_Level) AS Avg_Inventory,

    CAST(
        SUM(f.Units_Sold) /
        NULLIF(AVG(f.Inventory_Level), 0)
        AS DECIMAL(10,2)
    ) AS Inventory_Turnover,

    SUM(f.Order_Quantity) AS Total_Order_Quantity,

    SUM(f.Order_Quantity)
        - SUM(f.Units_Sold) AS Order_Sales_Gap,

    SUM(
        CASE
            WHEN f.Promotion_Flag = 1
            THEN f.Units_Sold
            ELSE 0
        END
    ) AS Promotion_Units_Sold

FROM FactInventory f

INNER JOIN DimWarehouse w
    ON f.WarehouseKey = w.WarehouseKey

GROUP BY
    w.Warehouse_ID,
    w.Region;
GO


/* =========================================================
   VIEW 4: SUPPLIER PERFORMANCE
   ========================================================= */

CREATE OR ALTER VIEW vw_SupplierPerformance
AS
SELECT
    s.Supplier_ID,

    AVG(f.Supplier_Lead_Time_Days) AS Avg_Lead_Time_Days,

    SUM(f.Order_Quantity) AS Total_Order_Quantity,

    SUM(f.Units_Sold) AS Total_Units_Sold,

    AVG(f.Inventory_Level) AS Avg_Inventory,

    CAST(
        SUM(f.Units_Sold) /
        NULLIF(AVG(f.Inventory_Level), 0)
        AS DECIMAL(10,2)
    ) AS Inventory_Turnover

FROM FactInventory f

INNER JOIN DimSupplier s
    ON f.SupplierKey = s.SupplierKey

GROUP BY
    s.Supplier_ID;
GO

/* =========================================================
   VIEW 5: FORECAST PERFORMANCE
   ========================================================= */

CREATE OR ALTER VIEW vw_ForecastPerformance
AS
SELECT
    p.SKU_ID,

    SUM(f.Units_Sold) AS Total_Actual_Demand,

    SUM(f.Demand_Forecast) AS Total_Forecast_Demand,

    SUM(f.Units_Sold)
        - SUM(f.Demand_Forecast) AS Total_Forecast_Error,

    CAST(
        AVG(ABS(f.Units_Sold - f.Demand_Forecast))
        AS DECIMAL(10,2)
    ) AS MAE,

    CAST(
        AVG(
            CASE
                WHEN f.Units_Sold <> 0
                THEN ABS(f.Units_Sold - f.Demand_Forecast)
                     * 100.0 / f.Units_Sold
            END
        )
        AS DECIMAL(10,2)
    ) AS MAPE,

    CAST(
        AVG(f.Units_Sold - f.Demand_Forecast)
        AS DECIMAL(10,2)
    ) AS Average_Forecast_Error

FROM FactInventory f

INNER JOIN DimProduct p
    ON f.ProductKey = p.ProductKey

GROUP BY
    p.SKU_ID;
GO

/* =========================================================
   VIEW 6: PROMOTION PERFORMANCE
   ========================================================= */

CREATE OR ALTER VIEW vw_PromotionPerformance
AS
SELECT
    CASE
        WHEN Promotion_Flag = 1
            THEN 'Promotion'
        ELSE 'No Promotion'
    END AS Promotion_Status,

    COUNT(*) AS Records,

    SUM(Units_Sold) AS Total_Units_Sold,

    AVG(Units_Sold) AS Avg_Units_Sold,

    AVG(Inventory_Level) AS Avg_Inventory,

    AVG(Demand_Forecast) AS Avg_Demand_Forecast

FROM FactInventory

GROUP BY
    Promotion_Flag;
GO


/* =========================================================
   VIEW 7: EXECUTIVE KPIs
   ========================================================= */

CREATE OR ALTER VIEW vw_ExecutiveKPIs
AS
SELECT
    COUNT(*) AS Total_Records,

    SUM(Units_Sold) AS Total_Units_Sold,

    AVG(Inventory_Level) AS Avg_Inventory,

    AVG(Supplier_Lead_Time_Days) AS Avg_Supplier_Lead_Time,

    CAST(
        AVG(
            CASE
                WHEN Units_Sold <> 0
                THEN ABS(Units_Sold - Demand_Forecast) * 100.0
                     / Units_Sold
            END
        )
        AS DECIMAL(10,2)
    ) AS Forecast_MAPE,

    CAST(
        100.0 *
        SUM(CASE WHEN Stockout_Flag = 1 THEN 1 ELSE 0 END)
        / COUNT(*)
        AS DECIMAL(10,2)
    ) AS Stockout_Rate

FROM FactInventory;
GO