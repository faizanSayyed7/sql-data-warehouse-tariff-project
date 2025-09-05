/*
===============================================================================
DDL Script: Create Bronze Tables (India & Global Split)
===============================================================================
Script Purpose:
    This script creates India and Global trade tables in the 'bronze' schema,
    dropping existing tables if they already exist.
===============================================================================
*/

-- =======================================================
-- 1. Calculated Duties (Raw)
-- =======================================================

IF OBJECT_ID('bronze.india_calculated_duties', 'U') IS NOT NULL
    DROP TABLE bronze.india_calculated_duties;
GO

CREATE TABLE bronze.india_calculated_duties (
    data_type NVARCHAR(50),
    hts_number NVARCHAR(50),
    _description NVARCHAR(255),
    _year INT,
    country NVARCHAR(50),
    quantity_desc NVARCHAR(50),
    january DECIMAL(10,2),
    february DECIMAL(10,2),
    march DECIMAL(10,2),
    april DECIMAL(10,2),
    may DECIMAL(10,2),
    june DECIMAL(10,2),
    july DECIMAL(10,2),
    august DECIMAL(10,2),
    september DECIMAL(10,2),
    october DECIMAL(10,2),
    november DECIMAL(10,2),
    december DECIMAL(10,2)
);
GO

IF OBJECT_ID('bronze.global_calculated_duties', 'U') IS NOT NULL
    DROP TABLE bronze.global_calculated_duties;
GO

CREATE TABLE bronze.global_calculated_duties (
    data_type NVARCHAR(50),
    hts_number NVARCHAR(50),
    _description NVARCHAR(255),
    _year INT,
    country NVARCHAR(50),
    quantity_desc NVARCHAR(50),
    january DECIMAL(10,2),
    february DECIMAL(10,2),
    march DECIMAL(10,2),
    april DECIMAL(10,2),
    may DECIMAL(10,2),
    june DECIMAL(10,2),
    july DECIMAL(10,2),
    august DECIMAL(10,2),
    september DECIMAL(10,2),
    october DECIMAL(10,2),
    november DECIMAL(10,2),
    december DECIMAL(10,2)
);
GO


-- =======================================================
-- 2. Customs Value (Raw)
-- =======================================================

IF OBJECT_ID('bronze.india_customs_value', 'U') IS NOT NULL
    DROP TABLE bronze.india_customs_value;
GO

CREATE TABLE bronze.india_customs_value (
    data_type NVARCHAR(50),
    hts_number NVARCHAR(50),
    _description NVARCHAR(255),
    _year INT,
    country NVARCHAR(50),
    quantity_desc NVARCHAR(50),
    january DECIMAL(10,2),
    february DECIMAL(10,2),
    march DECIMAL(10,2),
    april DECIMAL(10,2),
    may DECIMAL(10,2),
    june DECIMAL(10,2),
    july DECIMAL(10,2),
    august DECIMAL(10,2),
    september DECIMAL(10,2),
    october DECIMAL(10,2),
    november DECIMAL(10,2),
    december DECIMAL(10,2)
);
GO

IF OBJECT_ID('bronze.global_customs_value', 'U') IS NOT NULL
    DROP TABLE bronze.global_customs_value;
GO

CREATE TABLE bronze.global_customs_value (
    data_type NVARCHAR(50),
    hts_number NVARCHAR(50),
    _description NVARCHAR(255),
    _year INT,
    country NVARCHAR(50),
    quantity_desc NVARCHAR(50),
    january DECIMAL(10,2),
    february DECIMAL(10,2),
    march DECIMAL(10,2),
    april DECIMAL(10,2),
    may DECIMAL(10,2),
    june DECIMAL(10,2),
    july DECIMAL(10,2),
    august DECIMAL(10,2),
    september DECIMAL(10,2),
    october DECIMAL(10,2),
    november DECIMAL(10,2),
    december DECIMAL(10,2)
);
GO


-- =======================================================
-- 3. First Unit of Quantity (Raw)
-- =======================================================

IF OBJECT_ID('bronze.india_first_unit_quantity', 'U') IS NOT NULL
    DROP TABLE bronze.india_first_unit_quantity;
GO

CREATE TABLE bronze.india_first_unit_quantity (
    data_type NVARCHAR(50),
    hts_number NVARCHAR(50),
    _description NVARCHAR(255),
    _year INT,
    country NVARCHAR(50),
    quantity_desc NVARCHAR(50),
    january DECIMAL(10,2),
    february DECIMAL(10,2),
    march DECIMAL(10,2),
    april DECIMAL(10,2),
    may DECIMAL(10,2),
    june DECIMAL(10,2),
    july DECIMAL(10,2),
    august DECIMAL(10,2),
    september DECIMAL(10,2),
    october DECIMAL(10,2),
    november DECIMAL(10,2),
    december DECIMAL(10,2)
);
GO

IF OBJECT_ID('bronze.global_first_unit_quantity', 'U') IS NOT NULL
    DROP TABLE bronze.global_first_unit_quantity;
GO

CREATE TABLE bronze.global_first_unit_quantity (
    data_type NVARCHAR(50),
    hts_number NVARCHAR(50),
    _description NVARCHAR(255),
    _year INT,
    country NVARCHAR(50),
    quantity_desc NVARCHAR(50),
    january DECIMAL(10,2),
    february DECIMAL(10,2),
    march DECIMAL(10,2),
    april DECIMAL(10,2),
    may DECIMAL(10,2),
    june DECIMAL(10,2),
    july DECIMAL(10,2),
    august DECIMAL(10,2),
    september DECIMAL(10,2),
    october DECIMAL(10,2),
    november DECIMAL(10,2),
    december DECIMAL(10,2)
);
GO


-- =======================================================
-- 4. Charges, Insurance & Freight (Raw)
-- =======================================================

IF OBJECT_ID('bronze.india_charges_insurance_freight', 'U') IS NOT NULL
    DROP TABLE bronze.india_charges_insurance_freight;
GO

CREATE TABLE bronze.india_charges_insurance_freight (
    data_type NVARCHAR(50),
    hts_number NVARCHAR(50),
    _description NVARCHAR(255),
    _year INT,
    country NVARCHAR(50),
    quantity_desc NVARCHAR(50),
    january DECIMAL(10,2),
    february DECIMAL(10,2),
    march DECIMAL(10,2),
    april DECIMAL(10,2),
    may DECIMAL(10,2),
    june DECIMAL(10,2),
    july DECIMAL(10,2),
    august DECIMAL(10,2),
    september DECIMAL(10,2),
    october DECIMAL(10,2),
    november DECIMAL(10,2),
    december DECIMAL(10,2)
);
GO

IF OBJECT_ID('bronze.global_charges_insurance_freight', 'U') IS NOT NULL
    DROP TABLE bronze.global_charges_insurance_freight;
GO

CREATE TABLE bronze.global_charges_insurance_freight (
    data_type NVARCHAR(50),
    hts_number NVARCHAR(50),
    _description NVARCHAR(255),
    _year INT,
    country NVARCHAR(50),
    quantity_desc NVARCHAR(50),
    january DECIMAL(10,2),
    february DECIMAL(10,2),
    march DECIMAL(10,2),
    april DECIMAL(10,2),
    may DECIMAL(10,2),
    june DECIMAL(10,2),
    july DECIMAL(10,2),
    august DECIMAL(10,2),
    september DECIMAL(10,2),
    october DECIMAL(10,2),
    november DECIMAL(10,2),
    december DECIMAL(10,2)
);
GO


-- =======================================================
-- 5. CIF Import Value (Raw)
-- =======================================================

IF OBJECT_ID('bronze.india_cif_import_value', 'U') IS NOT NULL
    DROP TABLE bronze.india_cif_import_value;
GO

CREATE TABLE bronze.india_cif_import_value (
    data_type NVARCHAR(50),
    hts_number NVARCHAR(50),
    _description NVARCHAR(255),
    _year INT,
    country NVARCHAR(50),
    quantity_desc NVARCHAR(50),
    january DECIMAL(10,2),
    february DECIMAL(10,2),
    march DECIMAL(10,2),
    april DECIMAL(10,2),
    may DECIMAL(10,2),
    june DECIMAL(10,2),
    july DECIMAL(10,2),
    august DECIMAL(10,2),
    september DECIMAL(10,2),
    october DECIMAL(10,2),
    november DECIMAL(10,2),
    december DECIMAL(10,2)
);
GO

IF OBJECT_ID('bronze.global_cif_import_value', 'U') IS NOT NULL
    DROP TABLE bronze.global_cif_import_value;
GO

CREATE TABLE bronze.global_cif_import_value (
    data_type NVARCHAR(50),
    hts_number NVARCHAR(50),
    _description NVARCHAR(255),
    _year INT,
    country NVARCHAR(50),
    quantity_desc NVARCHAR(50),
    january DECIMAL(10,2),
    february DECIMAL(10,2),
    march DECIMAL(10,2),
    april DECIMAL(10,2),
    may DECIMAL(10,2),
    june DECIMAL(10,2),
    july DECIMAL(10,2),
    august DECIMAL(10,2),
    september DECIMAL(10,2),
    october DECIMAL(10,2),
    november DECIMAL(10,2),
    december DECIMAL(10,2)
);
GO
