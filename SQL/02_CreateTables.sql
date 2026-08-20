USE SupplyChainAnalyticsDB;
GO

/* =========================================================
   1. STAGING TABLE
   ========================================================= */

CREATE TABLE Stg_SupplyChainData
(
    Date DATE,
    SKU_ID VARCHAR(50),
    Warehouse_ID VARCHAR(50),
    Supplier_ID VARCHAR(50),
    Region VARCHAR(50),
    Units_Sold INT,
    Inventory_Level DECIMAL(18,2),
    Supplier_Lead_Time_Days INT,
    Reorder_Point DECIMAL(18,2),
    Order_Quantity INT,
    Unit_Cost DECIMAL(18,2),
    Unit_Price DECIMAL(18,2),
    Promotion_Flag INT,
    Stockout_Flag INT,
    Demand_Forecast DECIMAL(18,2)
);
GO


/* =========================================================
   2. DATE DIMENSION
   ========================================================= */

CREATE TABLE DimDate
(
    DateKey INT PRIMARY KEY,
    Date DATE NOT NULL,
    Day INT,
    Month INT,
    MonthName VARCHAR(20),
    Quarter INT,
    Year INT
);
GO


/* =========================================================
   3. PRODUCT DIMENSION
   ========================================================= */

CREATE TABLE DimProduct
(
    ProductKey INT IDENTITY(1,1) PRIMARY KEY,
    SKU_ID VARCHAR(50) NOT NULL UNIQUE,
    Unit_Cost DECIMAL(18,2),
    Unit_Price DECIMAL(18,2)
);
GO


/* =========================================================
   4. SUPPLIER DIMENSION
   ========================================================= */

CREATE TABLE DimSupplier
(
    SupplierKey INT IDENTITY(1,1) PRIMARY KEY,
    Supplier_ID VARCHAR(50) NOT NULL UNIQUE
);
GO


/* =========================================================
   5. WAREHOUSE DIMENSION
   ========================================================= */

CREATE TABLE DimWarehouse
(
    WarehouseKey INT IDENTITY(1,1) PRIMARY KEY,
    Warehouse_ID VARCHAR(50) NOT NULL UNIQUE,
    Region VARCHAR(50)
);
GO


/* =========================================================
   6. FACT TABLE
   ========================================================= */

CREATE TABLE FactInventory
(
    InventoryKey BIGINT IDENTITY(1,1) PRIMARY KEY,

    DateKey INT NOT NULL,
    ProductKey INT NOT NULL,
    SupplierKey INT NOT NULL,
    WarehouseKey INT NOT NULL,

    Units_Sold INT,
    Inventory_Level DECIMAL(18,2),
    Supplier_Lead_Time_Days INT,
    Reorder_Point DECIMAL(18,2),
    Order_Quantity INT,
    Promotion_Flag INT,
    Stockout_Flag INT,
    Demand_Forecast DECIMAL(18,2),

    CONSTRAINT FK_Fact_Date
        FOREIGN KEY (DateKey)
        REFERENCES DimDate(DateKey),

    CONSTRAINT FK_Fact_Product
        FOREIGN KEY (ProductKey)
        REFERENCES DimProduct(ProductKey),

    CONSTRAINT FK_Fact_Supplier
        FOREIGN KEY (SupplierKey)
        REFERENCES DimSupplier(SupplierKey),

    CONSTRAINT FK_Fact_Warehouse
        FOREIGN KEY (WarehouseKey)
        REFERENCES DimWarehouse(WarehouseKey)
);
GO