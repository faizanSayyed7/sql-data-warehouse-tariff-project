/*
===============================================================================
Stored Procedure: gold.load_gold_layer (Silver -> Gold) 
===============================================================================
Script Purpose:
    This stored procedure populates the entire Gold Layer Star Schema from 
    the unified 'silver.standardized_imports' table.
    (Updated to remove 'day_name' logic from dim_date load).

Actions Performed:
    1.  Loads all 4 Dimension tables first (Date, Product, Country, Metric).
    2.  Loads the central 'gold.fact_imports' table by looking up surrogate keys.

Usage Example:
    EXEC gold.load_gold_layer;
===============================================================================
*/
CREATE OR ALTER PROCEDURE gold.load_gold_layer
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @start_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME; 
    
    BEGIN TRY
        SET @batch_start_time = GETDATE();
        PRINT '================================================';
        PRINT 'Loading Gold Layer (Star Schema Data Mart)';
        PRINT '================================================';

        -- ===============================================
        -- 1. LOAD DIMENSION TABLES
        -- ===============================================

        PRINT '------------------------------------------------';
        PRINT 'Loading Dimension Tables';
        PRINT '------------------------------------------------';

        -- Dimension: dim_date 
        SET @start_time = GETDATE();
        PRINT '>> Truncating and loading Table: gold.dim_date';
        TRUNCATE TABLE gold.dim_date;
        
        ;WITH DateSeries AS (
            SELECT CAST('2018-01-01' AS DATE) AS MyDate
            UNION ALL
            SELECT DATEADD(DAY, 1, MyDate)
            FROM DateSeries
            WHERE MyDate < '2025-12-31'
        )
        INSERT INTO gold.dim_date (
            date_key, full_date, day_of_month, 
            month_number, month_name, quarter_number, quarter_name, 
            _year, year_month
        )
        SELECT
            CAST(FORMAT(MyDate, 'yyyyMMdd') AS INT) AS date_key,
            MyDate AS full_date,
            DAY(MyDate) AS day_of_month,
            MONTH(MyDate) AS month_number,
            DATENAME(MONTH, MyDate) AS month_name,
            DATEPART(QUARTER, MyDate) AS quarter_number,
            'Q' + CAST(DATEPART(QUARTER, MyDate) AS NCHAR(1)) AS quarter_name,
            YEAR(MyDate) AS year,
            FORMAT(MyDate, 'yyyy-MM') AS year_month
        FROM DateSeries
        OPTION (MAXRECURSION 0); 

        PRINT '>> Load Duration: ' + CAST(DATEDIFF(MILLISECOND, @start_time, GETDATE()) AS NVARCHAR) + ' ms. (' + CAST(@@ROWCOUNT AS NVARCHAR) + ' rows)';
        PRINT '>> -------------';


        -- Dimension: dim_product
        SET @start_time = GETDATE();
        PRINT '>> Truncating and loading Table: gold.dim_product';
        TRUNCATE TABLE gold.dim_product;

        INSERT INTO gold.dim_product (
            hts_number,
            _description,
            hts_chapter,
            hts_heading
        )
        SELECT DISTINCT
            hts_number,
            _description,
            SUBSTRING(hts_number, 1, 2) AS hts_chapter,
            SUBSTRING(hts_number, 1, 4) AS hts_heading
        FROM 
            silver.standardized_imports;
            
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(MILLISECOND, @start_time, GETDATE()) AS NVARCHAR) + ' ms. (' + CAST(@@ROWCOUNT AS NVARCHAR) + ' rows)';
        PRINT '>> -------------';


        -- Dimension: dim_country
        SET @start_time = GETDATE();
        PRINT '>> Truncating and loading Table: gold.dim_country';
        TRUNCATE TABLE gold.dim_country;

        INSERT INTO gold.dim_country (country_name)
        SELECT DISTINCT country 
        FROM silver.standardized_imports;
        
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(MILLISECOND, @start_time, GETDATE()) AS NVARCHAR) + ' ms. (' + CAST(@@ROWCOUNT AS NVARCHAR) + ' rows)';
        PRINT '>> -------------';


        -- Dimension: dim_metric_detail
        SET @start_time = GETDATE();
        PRINT '>> Truncating and loading Table: gold.dim_metric_detail';
        TRUNCATE TABLE gold.dim_metric_detail;

        INSERT INTO gold.dim_metric_detail (metric_type, unit_of_measure)
        SELECT DISTINCT metric_type, unit_of_measure 
        FROM silver.standardized_imports;
        
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(MILLISECOND, @start_time, GETDATE()) AS NVARCHAR) + ' ms. (' + CAST(@@ROWCOUNT AS NVARCHAR) + ' rows)';
        PRINT '>> -------------';


        -- ===============================================
        -- 2. LOAD FACT TABLE
        -- ===============================================
        PRINT '------------------------------------------------';
        PRINT 'Loading Fact Table';
        PRINT '------------------------------------------------';

        SET @start_time = GETDATE();
        PRINT '>> Truncating and loading Table: gold.fact_imports';
        TRUNCATE TABLE gold.fact_imports;
        
        INSERT INTO gold.fact_imports (
            date_key,
            product_key,
            country_key,
            metric_key,
            metric_value
        )
        SELECT
            ISNULL(dim_d.date_key, -1) AS date_key,
            ISNULL(dim_p.product_key, -1) AS product_key,
            ISNULL(dim_c.country_key, -1) AS country_key,
            ISNULL(dim_m.metric_key, -1) AS metric_key,
            src.metric_value
        FROM 
            silver.standardized_imports AS src
        LEFT JOIN gold.dim_date AS dim_d 
            ON src.import_date = dim_d.full_date
        LEFT JOIN gold.dim_product AS dim_p 
            ON src.hts_number = dim_p.hts_number
        LEFT JOIN gold.dim_country AS dim_c 
            ON src.country = dim_c.country_name
        LEFT JOIN gold.dim_metric_detail AS dim_m 
            ON src.metric_type = dim_m.metric_type
            AND ISNULL(src.unit_of_measure, '') = ISNULL(dim_m.unit_of_measure, ''); 

        
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, GETDATE()) AS NVARCHAR) + ' seconds. (' + CAST(@@ROWCOUNT AS NVARCHAR) + ' rows)';
        PRINT '>> -------------';


        SET @batch_end_time = GETDATE();
        PRINT '=========================================='
        PRINT 'Loading Gold Layer is Completed';
        PRINT '    - Total Load Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
        PRINT '==========================================';

    END TRY
    BEGIN CATCH
        PRINT '====================================================';
        PRINT 'ERROR OCCURRED DURING LOADING GOLD LAYER';
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS NVARCHAR);
        PRINT 'Error Line: ' + CAST(ERROR_LINE() AS NVARCHAR);
        PRINT '====================================================';
        RAISERROR ('Gold load failed', 16, 1); -- Re-throw the error
    END CATCH
END;
GO


-- ================================================================
-- output 
-- ================================================================
-- Loading Gold Layer (Star Schema Data Mart)
-- ================================================================
-- ------------------------------------------------
-- Loading Dimension Tables
-- ------------------------------------------------
-- >> Truncating and loading Table: gold.dim_date
-- >> Load Duration: 1320 ms. (2922 rows)
-- >> -------------
-- >> Truncating and loading Table: gold.dim_product
-- >> Load Duration: 21050 ms. (4160 rows)
-- >> -------------
-- >> Truncating and loading Table: gold.dim_country
-- >> Load Duration: 3206 ms. (4 rows)
-- >> -------------
-- >> Truncating and loading Table: gold.dim_metric_detail
-- >> Load Duration: 5944 ms. (35 rows)
-- >> -------------
-- ------------------------------------------------
-- Loading Fact Table
-- ------------------------------------------------
-- >> Truncating and loading Table: gold.fact_imports
-- >> Load Duration: 37 seconds. (2503284 rows)
-- >> -------------
-- ==========================================
-- Loading Gold Layer is Completed
--     - Total Load Duration: 68 seconds
-- ==========================================

