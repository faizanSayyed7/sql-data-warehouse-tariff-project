/*
===============================================================================
Stored Procedure: silver.load_standardized_imports (Bronze -> Silver)
===============================================================================
Script Purpose:
    This stored procedure performs the ETL process to populate the single 
    'silver.standardized_imports' table from ALL 10 tables in the 'bronze' schema.
	
Actions Performed:
    1.  TRUNCATES the Silver target table for a full reload.
    2.  CONSOLIDATES all 10 bronze tables into a single source CTE.
    3.  STANDARDIZES (Unpivots) the 12 month columns into atomic rows.
    4.  DERIVES required columns ('import_date', 'unit_of_measure').
    5.  CLEANSES the data by filtering all rows where metric_value is 0 or NULL.
		
Usage Example:
    EXEC silver.load_standardized_imports;
===============================================================================
*/
CREATE OR ALTER PROCEDURE silver.load_standardized_imports
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME; 
    
    BEGIN TRY
        SET @batch_start_time = GETDATE();
        PRINT '================================================';
        PRINT 'Loading Silver Layer (Standardized Atomic Table)';
        PRINT '================================================';

        -- 1. Truncate target table
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: silver.standardized_imports';
        TRUNCATE TABLE silver.standardized_imports;

        -- 2. Consolidate, transform, and insert in one operation.
        -- The PRINT must come BEFORE the WITH statement.
        PRINT '>> Building CTE and inserting standardized data from 10 bronze tables...';
        
        -- The WITH clause must be the first statement in the batch, so we terminate the previous PRINT with a semicolon.
        ;WITH All_Bronze_Data AS (
            -- Metric 1: Calculated Duties
            SELECT 'Calculated Duties' AS metric_type, data_type, hts_number, _description, _year, country, quantity_desc, january, february, march, april, may, june, july, august, september, october, november, december FROM bronze.india_calculated_duties
            UNION ALL
            SELECT 'Calculated Duties' AS metric_type, data_type, hts_number, _description, _year, country, quantity_desc, january, february, march, april, may, june, july, august, september, october, november, december FROM bronze.global_calculated_duties
            UNION ALL
            -- Metric 2: Customs Value
            SELECT 'Customs Value' AS metric_type, data_type, hts_number, _description, _year, country, quantity_desc, january, february, march, april, may, june, july, august, september, october, november, december FROM bronze.india_customs_value
            UNION ALL
            SELECT 'Customs Value' AS metric_type, data_type, hts_number, _description, _year, country, quantity_desc, january, february, march, april, may, june, july, august, september, october, november, december FROM bronze.global_customs_value
            UNION ALL
            -- Metric 3: First Unit Quantity
            SELECT 'First Unit Quantity' AS metric_type, data_type, hts_number, _description, _year, country, quantity_desc, january, february, march, april, may, june, july, august, september, october, november, december FROM bronze.india_first_unit_quantity
            UNION ALL
            SELECT 'First Unit Quantity' AS metric_type, data_type, hts_number, _description, _year, country, quantity_desc, january, february, march, april, may, june, july, august, september, october, november, december FROM bronze.global_first_unit_quantity
            UNION ALL
            -- Metric 4: Charges, Insurance & Freight
            SELECT 'Charges Insurance Freight' AS metric_type, data_type, hts_number, _description, _year, country, quantity_desc, january, february, march, april, may, june, july, august, september, october, november, december FROM bronze.india_charges_insurance_freight
            UNION ALL
            SELECT 'Charges Insurance Freight' AS metric_type, data_type, hts_number, _description, _year, country, quantity_desc, january, february, march, april, may, june, july, august, september, october, november, december FROM bronze.global_charges_insurance_freight
            UNION ALL
            -- Metric 5: CIF Import Value
            SELECT 'CIF Import Value' AS metric_type, data_type, hts_number, _description, _year, country, quantity_desc, january, february, march, april, may, june, july, august, september, october, november, december FROM bronze.india_cif_import_value
            UNION ALL
            SELECT 'CIF Import Value' AS metric_type, data_type, hts_number, _description, _year, country, quantity_desc, january, february, march, april, may, june, july, august, september, october, november, december FROM bronze.global_cif_import_value
        )
        
        INSERT INTO silver.standardized_imports (
            import_date,
            hts_number,
            _description,
            country,
            unit_of_measure,
            metric_type,
            metric_value
        
        )
        SELECT 
            -- === DERIVED COLUMNS ===
            DATEFROMPARTS(src._year, unpvt.month_num, 1) AS import_date, 
            
            -- === STANDARDIZED COLUMNS ===
            TRIM(src.hts_number) AS hts_number,
            TRIM(src._description) AS description,
            TRIM(src.country) AS country,
            TRIM(REPLACE(src.quantity_desc, 'Value for:', '')) AS unit_of_measure, 

            -- === METRIC COLUMNS ===
            src.metric_type,
            unpvt.metric_value
            
        FROM 
            All_Bronze_Data AS src
        
        -- === THE UNPIVOT (Standardization Step) ===
        CROSS APPLY (
            VALUES
                (1,  src.january), (2,  src.february), (3,  src.march),
                (4,  src.april), (5,  src.may), (6,  src.june),
                (7,  src.july), (8,  src.august), (9,  src.september),
                (10, src.october), (11, src.november), (12, src.december)
        ) AS unpvt(month_num, metric_value)

        -- === THE CLEANSING STEP ===
        WHERE 
            unpvt.metric_value != 0 AND unpvt.metric_value IS NOT NULL; -- This semicolon terminates the entire INSERT...SELECT...WHERE block.


        -- Log completion
        DECLARE @row_count INT = @@ROWCOUNT;
        -- Now the code block is valid, @end_time will be recognized.
        SET @end_time = GETDATE(); 
        PRINT '>> Insert complete. ' + CAST(@row_count AS NVARCHAR) + ' unpivoted rows inserted.';
        PRINT '>> -----------------------------------------';


        SET @batch_end_time = GETDATE();
        PRINT '==========================================';
        PRINT 'Loading Silver Layer is Completed';
        PRINT '    - Total Load Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
        PRINT '==========================================';

    END TRY
    BEGIN CATCH
        PRINT '====================================================';
        PRINT 'ERROR OCCURRED DURING LOADING SILVER LAYER';
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS NVARCHAR);
        PRINT 'Error Line: ' + CAST(ERROR_LINE() AS NVARCHAR);
        PRINT '====================================================';
        RAISERROR ('Silver load failed', 16, 1); -- Re-throw the error
    END CATCH
END;
GO
