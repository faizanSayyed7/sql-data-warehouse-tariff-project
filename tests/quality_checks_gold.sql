/*
===============================================================================
Quality Checks - Gold Layer (Star Schema Data Mart)
===============================================================================
Script Purpose:
    This script performs quality checks on the Gold Layer star schema.
    It validates:
    - Dimension Integrity: Primary keys are unique and attributes are standardized.
    - Referential Integrity: Checks for "orphan rows" by ensuring all foreign keys
      in the fact table have a valid match in their corresponding dimension.
    - Data Reconciliation: Confirms that totals in the Gold Fact table match
      the totals from the Silver source table.

Usage Notes:
    - Run these checks after the 'gold.load_gold_layer' procedure is complete.
    - Any query (except for profiling queries) that returns results
      indicates a potential data or ETL logic error.
===============================================================================
*/

-- ====================================================================
-- Checking Dimension Tables (dim_date, dim_product, etc.)
-- ====================================================================

-- 1. Check: dim_date
-- Check for uniqueness on the business key (full_date) and logical range.
-- Expectation: No Results
SELECT 
    full_date, COUNT(*)
FROM gold.dim_date
GROUP BY full_date
HAVING COUNT(*) > 1;

-- Check date range (should match our 2018-2025 recursive CTE)
-- Expectation: No Results
SELECT * FROM gold.dim_date WHERE _year < 2018 OR _year > 2025;


-- 2. Check: dim_product
-- Check for duplicates on the business key (hts_number).
-- Expectation: No Results
SELECT 
    hts_number, COUNT(*)
FROM gold.dim_product
GROUP BY hts_number
HAVING COUNT(*) > 1;

-- Check Enrichment Logic: Validates our HTS parsing logic.
-- Expectation: No Results (all should be valid lengths)
SELECT * FROM gold.dim_product 
WHERE LEN(hts_chapter) != 2 OR LEN(hts_heading) != 4 OR hts_chapter IS NULL;


-- 3. Check: dim_country
-- Check for duplicates on the business key (country_name).
-- Expectation: No Results
SELECT 
    country_name, COUNT(*)
FROM gold.dim_country
GROUP BY country_name
HAVING COUNT(*) > 1;


-- 4. Check: dim_metric_detail
-- Check for duplicates on the composite business key.
-- Expectation: No Results
SELECT 
    metric_type, unit_of_measure, COUNT(*)
FROM gold.dim_metric_detail
GROUP BY metric_type, unit_of_measure
HAVING COUNT(*) > 1;

-- ====================================================================
-- Checking Fact Table (gold.fact_imports)
-- ====================================================================

-- 5. CRITICAL CHECK: Referential Integrity (Orphan Row Check)
-- Our ETL logic uses ISNULL(key, -1) when a join fails. This query
-- searches for any -1 keys in our fact table. Any row returned by
-- this query is an "orphan row" that has a measure but no context.
-- Expectation: No Results
SELECT 
    'Orphan date_key' AS error_type, COUNT(*) AS bad_rows FROM gold.fact_imports WHERE date_key = -1
    UNION ALL
SELECT 
    'Orphan product_key' AS error_type, COUNT(*) AS bad_rows FROM gold.fact_imports WHERE product_key = -1
    UNION ALL
SELECT 
    'Orphan country_key' AS error_type, COUNT(*) AS bad_rows FROM gold.fact_imports WHERE country_key = -1
    UNION ALL
SELECT 
    'Orphan metric_key' AS error_type, COUNT(*) AS bad_rows FROM gold.fact_imports WHERE metric_key = -1
HAVING 
    COUNT(*) > 0;


-- 6. Check: Fact Value Integrity
-- This confirms our "no zeros or negatives" rule persisted all the way from Silver.
-- Expectation: No Results
SELECT 
    metric_value, COUNT(*) AS num_invalid_records
FROM 
    gold.fact_imports
WHERE 
    metric_value <= 0 
GROUP BY 
    metric_value;

-- ====================================================================
-- Data Reconciliation Check (Silver vs. Gold)
-- ====================================================================

-- 7. CRITICAL CHECK: Grand Total Reconciliation
-- This query compares the total value and row count in our final Gold fact table
-- against the totals in our Silver source table. This proves that no data was
-- lost or duplicated during the dimensional loading (join) process.
-- Expectation: Both numbers (Silver_Total, Gold_Total) should be IDENTICAL.
-- Expectation: Both counts (Silver_Rows, Gold_Rows) should be IDENTICAL.

WITH SilverTotals AS (
    SELECT 
        SUM(metric_value) AS silver_total_value,
        COUNT_BIG(*) AS silver_row_count
    FROM silver.standardized_imports
),
GoldTotals AS (
    SELECT 
        SUM(metric_value) AS gold_total_value,
        COUNT_BIG(*) AS gold_row_count
    FROM gold.fact_imports
)
SELECT
    s.silver_total_value,
    g.gold_total_value,
    (g.gold_total_value - s.silver_total_value) AS variance_value,
    s.silver_row_count,
    g.gold_row_count,
    (g.gold_row_count - s.silver_row_count) AS variance_rows
FROM 
    SilverTotals s, GoldTotals g;
