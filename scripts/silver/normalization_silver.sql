/*
=================================================================================
 Script: Normalization for description and asscoiated hts_numbers
 Purpose:
   - Create a central table in the Silver schema for storing unique HTS codes 
     and their associated descriptions.
   - Populate it from all Bronze layer source tables (India + Global).
   - This will help in building a normalized dimension table later.
=================================================================================
*/

IF OBJECT_ID('silver.hts_description', 'U') IS NOT NULL
    DROP TABLE silver.hts_description;
GO

CREATE TABLE silver.hts_description (
    hts_key INT IDENTITY(1,1) PRIMARY KEY,
    hts_number NVARCHAR(50) NOT NULL,
    _description NVARCHAR(255) NOT NULL
);
GO


INSERT INTO silver.hts_description (hts_number, _description)
SELECT DISTINCT hts_number, _description
FROM (
    SELECT hts_number, _description FROM bronze.india_calculated_duties
    UNION
    SELECT hts_number, _description FROM bronze.global_calculated_duties
    UNION
    SELECT hts_number, _description FROM bronze.india_customs_value
    UNION
    SELECT hts_number, _description FROM bronze.global_customs_value
    UNION
    SELECT hts_number, _description FROM bronze.india_first_unit_quantity
    UNION
    SELECT hts_number, _description FROM bronze.global_first_unit_quantity
    UNION
    SELECT hts_number, _description FROM bronze.india_charges_insurance_freight
    UNION
    SELECT hts_number, _description FROM bronze.global_charges_insurance_freight
    UNION
    SELECT hts_number, _description FROM bronze.india_cif_import_value
    UNION
    SELECT hts_number, _description FROM bronze.global_cif_import_value
) t;
