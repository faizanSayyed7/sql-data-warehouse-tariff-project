/*
===============================================================================
DDL Script: Create Silver Tables
===============================================================================
Script Purpose:
    This script creates the primary standardized table in the 'silver' schema 
    for the textile import project. This follows the "Lakehouse" pattern where
    Silver holds the single, unified, atomic source of truth.

    This table consolidates ALL 10 bronze tables (5 metrics x 2 regions) 
    into a single, standardized "long" (unpivoted) format.

Table Grain: 
    One row per HTS Code, per Country, per Date, per Metric Type... WHERE an event occurred (value > 0).
===============================================================================
*/

IF OBJECT_ID('silver.standardized_imports', 'U') IS NOT NULL
BEGIN
    DROP TABLE silver.standardized_imports;
    PRINT '>> Dropped existing table: silver.standardized_imports';
END
GO

CREATE TABLE silver.standardized_imports (
    import_date     DATE NOT NULL,                  -- Derived from Year + Month columns
    hts_number      NVARCHAR(50) NOT NULL,
    _description     NVARCHAR(255),
    country         NVARCHAR(50) NOT NULL,
    unit_of_measure NVARCHAR(50),                   -- Derived (cleansed) from quantity_desc
    metric_type     NVARCHAR(50) NOT NULL,          -- Derived (hard-coded) from the source file
    metric_value    DECIMAL(18, 2),                 -- The actual value from the source month column
    dwh_create_date DATETIME2 DEFAULT GETDATE()     -- Meta Data Column
);

GO

-- Added Clustered Index. it is critical for the Gold layer's performance.
-- Clustered on the fields that will be used to query/join, starting with date.

CREATE CLUSTERED INDEX cix_standardized_imports 
ON silver.standardized_imports (import_date ASC, country ASC, hts_number ASC, metric_type ASC);
PRINT '>> Created clustered index on silver.standardized_imports';
GO
