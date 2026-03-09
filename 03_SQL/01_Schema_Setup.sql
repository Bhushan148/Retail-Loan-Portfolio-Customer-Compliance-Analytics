/* ============================================================
   FILE: 01_Schema_Setup.sql
   PURPOSE:
   Create required schemas for the ETL pipeline and optionally
   configure the default search path.
   ============================================================ */

-- 1) Layer schemas
CREATE SCHEMA IF NOT EXISTS raw;
CREATE SCHEMA IF NOT EXISTS staging;
CREATE SCHEMA IF NOT EXISTS business;

-- 2) Optional default search path
ALTER ROLE CURRENT_USER SET search_path =
    business,
    staging,
    raw,
    public;

-- 3) Basic check
SELECT * 
FROM raw.dim_geography;