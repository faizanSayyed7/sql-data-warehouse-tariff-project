/*
===============================================================================
Stored Procedure: bronze.load_bronze_trade_data
===============================================================================
Script Purpose:
    This stored procedure loads trade data into the 'bronze' schema from external
    CSV files for India and Global regions.

    - It truncates the bronze tables before loading new data.
    - It uses the `BULK INSERT` command to load data from CSV files.
    - NOTE: Source .xlsx files must be converted to .csv format before execution.

Usage Example:
    EXEC bronze.load_bronze_trade_data;
===============================================================================
*/
CREATE OR ALTER PROCEDURE bronze.load_bronze_trade_data
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;

    BEGIN TRY
        SET @batch_start_time = GETDATE();
        PRINT '============================================';
        PRINT 'LOADING BRONZE LAYER (TRADE DATA)';
        PRINT '============================================';

        ---
        --- 1. LOADING INDIA DATA
        ---
        PRINT '--------------------------------------------';
        PRINT 'LOADING INDIA TRADE TABLES';
        PRINT '--------------------------------------------';

        -- bronze.india_calculated_duties
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: bronze.india_calculated_duties';
        TRUNCATE TABLE bronze.india_calculated_duties;
        PRINT '>> Inserting Data Into: bronze.india_calculated_duties';
        BULK INSERT bronze.india_calculated_duties
        FROM 'D:\datasets\India_data\CalculatedDuties_India.csv'
        WITH (FIRSTROW=2, FIELDTERMINATOR = ',', TABLOCK, ROWTERMINATOR = '0x0a');
        SET @end_time = GETDATE();
        PRINT '>> LOAD DURATION: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -----------------------------------------';

        -- bronze.india_customs_value
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: bronze.india_customs_value';
        TRUNCATE TABLE bronze.india_customs_value;
        PRINT '>> Inserting Data Into: bronze.india_customs_value';
        BULK INSERT bronze.india_customs_value
        FROM 'D:\datasets\India_data\CustomsValue_India.csv'
        WITH (FIRSTROW=2, FIELDTERMINATOR = ',', TABLOCK, ROWTERMINATOR = '0x0a');
        SET @end_time = GETDATE();
        PRINT '>> LOAD DURATION: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -----------------------------------------';

        -- bronze.india_first_unit_quantity
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: bronze.india_first_unit_quantity';
        TRUNCATE TABLE bronze.india_first_unit_quantity;
        PRINT '>> Inserting Data Into: bronze.india_first_unit_quantity';
        BULK INSERT bronze.india_first_unit_quantity
        FROM 'D:\datasets\India_data\FirstUnitofQuantity_India.csv'
        WITH (FIRSTROW=2, FIELDTERMINATOR = ',', TABLOCK, ROWTERMINATOR = '0x0a');
        SET @end_time = GETDATE();
        PRINT '>> LOAD DURATION: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -----------------------------------------';

        -- bronze.india_charges_insurance_freight
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: bronze.india_charges_insurance_freight';
        TRUNCATE TABLE bronze.india_charges_insurance_freight;
        PRINT '>> Inserting Data Into: bronze.india_charges_insurance_freight';
        BULK INSERT bronze.india_charges_insurance_freight
        FROM 'D:\datasets\India_data\Charges,Insurance,andFreight_India.csv'
        WITH (FIRSTROW=2, FIELDTERMINATOR = ',', TABLOCK, ROWTERMINATOR = '0x0a');
        SET @end_time = GETDATE();
        PRINT '>> LOAD DURATION: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -----------------------------------------';

        -- bronze.india_cif_import_value
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: bronze.india_cif_import_value';
        TRUNCATE TABLE bronze.india_cif_import_value;
        PRINT '>> Inserting Data Into: bronze.india_cif_import_value';
        BULK INSERT bronze.india_cif_import_value
        FROM 'D:\datasets\India_data\CIFImportValue_India.csv'
        WITH (FIRSTROW=2, FIELDTERMINATOR = ',', TABLOCK, ROWTERMINATOR = '0x0a');
        SET @end_time = GETDATE();
        PRINT '>> LOAD DURATION: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -----------------------------------------';


        ---
        --- 2. LOADING GLOBAL DATA (Bangladesh, China, Vietnam)
        ---
        PRINT '--------------------------------------------';
        PRINT 'LOADING GLOBAL TRADE TABLES';
        PRINT '--------------------------------------------';

        -- bronze.global_calculated_duties
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: bronze.global_calculated_duties';
        TRUNCATE TABLE bronze.global_calculated_duties;
        PRINT '>> Inserting Data Into: bronze.global_calculated_duties';
        BULK INSERT bronze.global_calculated_duties FROM 'D:\datasets\global\Bangladesh_data\CalculatedDuties_Bangladesh.csv' WITH (FIRSTROW=2, FIELDTERMINATOR = ',', TABLOCK, ROWTERMINATOR = '0x0a');
        BULK INSERT bronze.global_calculated_duties FROM 'D:\datasets\global\China_data\CalculatedDuties_China.csv' WITH (FIRSTROW=2, FIELDTERMINATOR = ',', TABLOCK, ROWTERMINATOR = '0x0a');
        BULK INSERT bronze.global_calculated_duties FROM 'D:\datasets\global\Vietnam_data\CalculatedDuties_Vietnam.csv' WITH (FIRSTROW=2, FIELDTERMINATOR = ',', TABLOCK, ROWTERMINATOR = '0x0a');
        SET @end_time = GETDATE();
        PRINT '>> LOAD DURATION: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -----------------------------------------';

        -- bronze.global_customs_value
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: bronze.global_customs_value';
        TRUNCATE TABLE bronze.global_customs_value;
        PRINT '>> Inserting Data Into: bronze.global_customs_value';
        BULK INSERT bronze.global_customs_value FROM 'D:\datasets\global\Bangladesh_data\CustomsValue_Bangladesh.csv' WITH (FIRSTROW=2, FIELDTERMINATOR = ',', TABLOCK, ROWTERMINATOR = '0x0a');
        BULK INSERT bronze.global_customs_value FROM 'D:\datasets\global\China_data\CustomsValue_China.csv' WITH (FIRSTROW=2, FIELDTERMINATOR = ',', TABLOCK, ROWTERMINATOR = '0x0a');
        BULK INSERT bronze.global_customs_value FROM 'D:\datasets\global\Vietnam_data\CustomsValue_Vietnam.csv' WITH (FIRSTROW=2, FIELDTERMINATOR = ',', TABLOCK, ROWTERMINATOR = '0x0a');
        SET @end_time = GETDATE();
        PRINT '>> LOAD DURATION: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -----------------------------------------';

        -- bronze.global_first_unit_quantity
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: bronze.global_first_unit_quantity';
        TRUNCATE TABLE bronze.global_first_unit_quantity;
        PRINT '>> Inserting Data Into: bronze.global_first_unit_quantity';
        BULK INSERT bronze.global_first_unit_quantity FROM 'D:\datasets\global\Bangladesh_data\FirstUnitofQuantity_Bangladesh.csv' WITH (FIRSTROW=2, FIELDTERMINATOR = ',', TABLOCK, ROWTERMINATOR = '0x0a');
        BULK INSERT bronze.global_first_unit_quantity FROM 'D:\datasets\global\China_data\FirstUnitofQuantity_China.csv' WITH (FIRSTROW=2, FIELDTERMINATOR = ',', TABLOCK, ROWTERMINATOR = '0x0a');
        BULK INSERT bronze.global_first_unit_quantity FROM 'D:\datasets\global\Vietnam_data\FirstUnitofQuantity_Vietnam.csv' WITH (FIRSTROW=2, FIELDTERMINATOR = ',', TABLOCK, ROWTERMINATOR = '0x0a');
        SET @end_time = GETDATE();
        PRINT '>> LOAD DURATION: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -----------------------------------------';

        -- bronze.global_charges_insurance_freight
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: bronze.global_charges_insurance_freight';
        TRUNCATE TABLE bronze.global_charges_insurance_freight;
        PRINT '>> Inserting Data Into: bronze.global_charges_insurance_freight';
        BULK INSERT bronze.global_charges_insurance_freight FROM 'D:\datasets\global\Bangladesh_data\Charges,Insurance,andFreight_Bangladesh.csv' WITH (FIRSTROW=2, FIELDTERMINATOR = ',', TABLOCK, ROWTERMINATOR = '0x0a');
        BULK INSERT bronze.global_charges_insurance_freight FROM 'D:\datasets\global\China_data\Charges,Insurance,andFreight_China.csv' WITH (FIRSTROW=2, FIELDTERMINATOR = ',', TABLOCK, ROWTERMINATOR = '0x0a');
        BULK INSERT bronze.global_charges_insurance_freight FROM 'D:\datasets\global\Vietnam_data\Charges,Insurance,andFreight_Vietnam.csv' WITH (FIRSTROW=2, FIELDTERMINATOR = ',', TABLOCK, ROWTERMINATOR = '0x0a');
        SET @end_time = GETDATE();
        PRINT '>> LOAD DURATION: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -----------------------------------------';

        -- bronze.global_cif_import_value
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: bronze.global_cif_import_value';
        TRUNCATE TABLE bronze.global_cif_import_value;
        PRINT '>> Inserting Data Into: bronze.global_cif_import_value';
        BULK INSERT bronze.global_cif_import_value FROM 'D:\datasets\global\Bangladesh_data\CIFImportValue_Bangladesh.csv' WITH (FIRSTROW=2, FIELDTERMINATOR = ',', TABLOCK, ROWTERMINATOR = '0x0a');
        BULK INSERT bronze.global_cif_import_value FROM 'D:\datasets\global\China_data\CIFImportValue_China.csv' WITH (FIRSTROW=2, FIELDTERMINATOR = ',', TABLOCK, ROWTERMINATOR = '0x0a');
        BULK INSERT bronze.global_cif_import_value FROM 'D:\datasets\global\Vietnam_data\CIFImportValue_Vietnam.csv' WITH (FIRSTROW=2, FIELDTERMINATOR = ',', TABLOCK, ROWTERMINATOR = '0x0a');
        SET @end_time = GETDATE();
        PRINT '>> LOAD DURATION: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -----------------------------------------';


        SET @batch_end_time = GETDATE();
        PRINT '============================================';
        PRINT 'BRONZE LAYER LOAD COMPLETE';
        PRINT '>> TOTAL DURATION: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
        PRINT '============================================';

    END TRY
    BEGIN CATCH
        PRINT '==============================================';
        PRINT 'ERROR OCCURRED DURING BRONZE LAYER LOAD';
        PRINT 'ERROR MESSAGE: ' + ERROR_MESSAGE();
        PRINT 'ERROR NUMBER: ' + CAST(ERROR_NUMBER() AS NVARCHAR);
        PRINT 'ERROR STATE: ' + CAST(ERROR_STATE() AS NVARCHAR);
        PRINT '==============================================';
    END CATCH
END;
GO
