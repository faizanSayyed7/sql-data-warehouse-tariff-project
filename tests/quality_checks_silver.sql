/*
===============================================================================
Quality Checks - Silver Layer (Trade Data)
===============================================================================
Script Purpose:
    This script performs various quality checks for data consistency, accuracy, 
    and standardization on the 'silver.standardized_imports' table. It checks for:
    - Null or duplicate keys (testing the table's grain).
    - Unwanted spaces (validating our TRIM function worked).
    - Data standardization and consistency (profiling distinct values).
    - Invalid business rules (e.g., negative/zero values, invalid dates).

Usage Notes:
    - Run these checks after the 'silver.load_standardized_imports' procedure.
    - Investigate and resolve any queries that return results (unless noted).
===============================================================================
*/

-- ====================================================================
-- Checking 'silver.standardized_imports'
-- ====================================================================

-- 1. Check for Key Uniqueness (Grain Integrity)
-- The "unique key" or grain of our table is the combination of all descriptive columns.
-- This query checks if any combination is duplicated.
-- Expectation: No Results
SELECT
    import_date,
    hts_number,
    country,
    metric_type,
    unit_of_measure,
    COUNT(*) AS row_count
FROM 
    silver.standardized_imports
GROUP BY
    import_date,
    hts_number,
    country,
    metric_type,
    unit_of_measure
HAVING 
    COUNT(*) > 1;

-- ----------------------------------------------------
-- 2. Check for NULLs in Key Columns
-- All key columns used for joining should be NOT NULL.
-- Expectation: No Results (all queries should return 0)
SELECT COUNT(*) AS null_import_dates FROM silver.standardized_imports WHERE import_date IS NULL;
SELECT COUNT(*) AS null_hts_numbers FROM silver.standardized_imports WHERE hts_number IS NULL;
SELECT COUNT(*) AS null_countries FROM silver.standardized_imports WHERE country IS NULL;
SELECT COUNT(*) AS null_metric_types FROM silver.standardized_imports WHERE metric_type IS NULL;

-- ----------------------------------------------------
-- 3. Check for Unwanted Spaces (Validate ETL Cleansing)
-- Our Silver ETL procedure should have applied TRIM() to all text columns. 
-- This query validates that the ETL step worked.
-- Expectation: No Results
SELECT 'hts_number' AS column_with_spaces FROM silver.standardized_imports WHERE hts_number != TRIM(hts_number);

SELECT 'description' AS column_with_spaces FROM silver.standardized_imports WHERE description != TRIM(description);

SELECT 'country' AS column_with_spaces FROM silver.standardized_imports WHERE country != TRIM(country);

SELECT 'unit_of_measure' AS column_with_spaces FROM silver.standardized_imports WHERE unit_of_measure != TRIM(unit_of_measure);

-- ----------------------------------------------------
-- 4. Check Business Rule: Invalid Metric Values
-- Silver ETL explicitly filters all 0 values. This check confirms that rule worked.
-- Also check for negative values, as import metrics should never be negative.
-- Expectation: No Results
SELECT
    metric_value,
    COUNT(*) AS num_invalid_records
FROM 
    silver.standardized_imports
WHERE 
    metric_value <= 0 
GROUP BY
    metric_value;

-- ----------------------------------------------------
-- 5. Check Business Rule: Invalid Date Range
-- Our data is 2018-2025. This query looks for any dates outside that expected analytical range,
-- which would indicate an error in the DATEFROMPARTS logic.
-- Expectation: No Results
SELECT 
    import_date,
    COUNT(*) AS num_records_out_of_range
FROM 
    silver.standardized_imports
WHERE 
    YEAR(import_date) < 2018 OR YEAR(import_date) > 2025
GROUP BY
    import_date;

-- ====================================================================
-- Data Standardization & Consistency Checks (Profiling)
-- These queries are for profiling, not pass/fail.
-- Review these lists to ensure they match business expectations.
-- ====================================================================

-- 6. Check Standardization: Country
-- Expectation: Should only list 'India', 'China', 'Vietnam', 'Bangladesh'.
SELECT DISTINCT 
    country 
FROM silver.standardized_imports
ORDER BY country;

-- ----------------------------------------------------
-- 7. Check Standardization: Metric Type
-- Expectation: Should list our 5 hard-coded metric types.
SELECT DISTINCT 
    metric_type 
FROM silver.standardized_imports
ORDER BY metric_type;

-- ----------------------------------------------------
-- 8. Check Standardization: Unit of Measure
-- Expectation: Review this list. It should show clean values like 'kilograms', 'Value US$',
-- and NOT dirty data like 'Value for: kilograms'.
SELECT 
    unit_of_measure,
    COUNT(*) AS num_records
FROM 
    silver.standardized_imports
GROUP BY 
    unit_of_measure
ORDER BY 
    num_records DESC;
