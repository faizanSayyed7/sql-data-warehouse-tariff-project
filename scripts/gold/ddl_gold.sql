/*
===============================================================================
DDL Script: Create Gold Layer Tables (Star Schema Data Mart) 
===============================================================================
Script Purpose:
    This script creates the final dimensional model (star schema) in the 'gold' schema.

Model Structure:
    - 1 Fact Table:   gold.fact_imports
    - 4 Dimension Tables:
        - gold.dim_date (monthly/quarterly analysis)
        - gold.dim_product
        - gold.dim_country
        - gold.dim_metric_detail
===============================================================================
*/


-- === DIMENSION TABLES =======================================================

-- 1. Dimension: Date 
IF OBJECT_ID('gold.dim_date', 'U') IS NOT NULL
    DROP TABLE gold.dim_date;
GO
CREATE TABLE gold.dim_date (
    date_key        INT PRIMARY KEY,              -- Key format: YYYYMMDD
    full_date       DATE NOT NULL,
    day_of_month    INT,
    month_number    INT,
    month_name      NVARCHAR(20),
    quarter_number  INT,
    quarter_name    NVARCHAR(2),
    _year            INT,
    year_month      NVARCHAR(7)                   -- Format: YYYY-MM
);

GO

-- 2. Dimension: Product
IF OBJECT_ID('gold.dim_product', 'U') IS NOT NULL
    DROP TABLE gold.dim_product;
GO
CREATE TABLE gold.dim_product (
    product_key     INT IDENTITY(1,1) PRIMARY KEY,
    hts_number      NVARCHAR(50) NOT NULL,
    _description     NVARCHAR(255),
    hts_chapter     NVARCHAR(2),
    hts_heading     NVARCHAR(4)
);

GO

-- 3. Dimension: Country
IF OBJECT_ID('gold.dim_country', 'U') IS NOT NULL
    DROP TABLE gold.dim_country;
GO
CREATE TABLE gold.dim_country (
    country_key     INT IDENTITY(1,1) PRIMARY KEY,
    country_name    NVARCHAR(50) NOT NULL
);

GO

-- 4. Dimension: Metric Detail
IF OBJECT_ID('gold.dim_metric_detail', 'U') IS NOT NULL
    DROP TABLE gold.dim_metric_detail;
GO
CREATE TABLE gold.dim_metric_detail (
    metric_key      INT IDENTITY(1,1) PRIMARY KEY,
    metric_type     NVARCHAR(50) NOT NULL,
    unit_of_measure NVARCHAR(50)
);

GO

-- === FACT TABLE =============================================================

-- Fact Table: Imports
IF OBJECT_ID('gold.fact_imports', 'U') IS NOT NULL
    DROP TABLE gold.fact_imports;
GO
CREATE TABLE gold.fact_imports (
    date_key        INT NOT NULL,
    product_key     INT NOT NULL,
    country_key     INT NOT NULL,
    metric_key      INT NOT NULL,
    metric_value    DECIMAL(18, 2)
);

GO

-- Add Clustered Columnstore Index (CCI)
CREATE CLUSTERED COLUMNSTORE INDEX cci_fact_imports ON gold.fact_imports;
PRINT '>> Created Clustered Columnstore Index on gold.fact_imports';
GO
