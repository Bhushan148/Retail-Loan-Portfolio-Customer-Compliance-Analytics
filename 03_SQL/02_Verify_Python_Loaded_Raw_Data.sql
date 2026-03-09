/* ============================================================
   FILE: 02_Verify_Python_Loaded_Raw_Data.sql
   PURPOSE:
   Verify Python-loaded raw data before starting SQL
   transformations.
   ============================================================ */

-- ============================================================
-- Verify raw tables exist
-- ============================================================
SELECT table_schema, table_name
FROM information_schema.tables
WHERE table_schema = 'raw'
ORDER BY table_name;

-- ============================================================
-- Row counts from raw tables
-- ============================================================
SELECT 'raw.dim_branch' AS table_name, COUNT(*) AS row_count FROM raw.dim_branch
UNION ALL
SELECT 'raw.dim_customer', COUNT(*) FROM raw.dim_customer
UNION ALL
SELECT 'raw.dim_geography', COUNT(*) FROM raw.dim_geography
UNION ALL
SELECT 'raw.dim_kyc', COUNT(*) FROM raw.dim_kyc
UNION ALL
SELECT 'raw.dim_loan_product', COUNT(*) FROM raw.dim_loan_product
UNION ALL
SELECT 'raw.fact_loan', COUNT(*) FROM raw.fact_loan;

-- ============================================================
-- Sample preview
-- ============================================================
SELECT * FROM raw.dim_branch;
SELECT * FROM raw.dim_customer;
SELECT * FROM raw.dim_geography;
SELECT * FROM raw.dim_kyc;
SELECT * FROM raw.dim_loan_product;
SELECT * FROM raw.fact_loan;

-- ============================================================
-- Null / blank key checks
-- ============================================================
SELECT COUNT(*) AS null_branch_id_count
FROM raw.dim_branch
WHERE "Branch_ID" IS NULL OR TRIM("Branch_ID") = '';

SELECT COUNT(*) AS null_customer_id_count
FROM raw.dim_customer
WHERE "Customer_ID" IS NULL OR TRIM("Customer_ID") = '';

SELECT COUNT(*) AS null_geography_id_count
FROM raw.dim_geography
WHERE "Geography_ID" IS NULL OR TRIM("Geography_ID") = '';

SELECT COUNT(*) AS null_loan_product_id_count
FROM raw.dim_loan_product
WHERE "Loan_Product_ID" IS NULL OR TRIM("Loan_Product_ID") = '';

SELECT COUNT(*) AS null_loan_id_count
FROM raw.fact_loan
WHERE "Loan_ID" IS NULL OR TRIM("Loan_ID") = '';

-- ============================================================
-- Duplicate checks
-- ============================================================
SELECT "Branch_ID", COUNT(*)
FROM raw.dim_branch
GROUP BY "Branch_ID"
HAVING COUNT(*) > 1;

SELECT "Customer_ID", COUNT(*)
FROM raw.dim_customer
GROUP BY "Customer_ID"
HAVING COUNT(*) > 1;

SELECT "Geography_ID", COUNT(*)
FROM raw.dim_geography
GROUP BY "Geography_ID"
HAVING COUNT(*) > 1;

SELECT "Loan_Product_ID", COUNT(*)
FROM raw.dim_loan_product
GROUP BY "Loan_Product_ID"
HAVING COUNT(*) > 1;

SELECT "Loan_ID", COUNT(*)
FROM raw.fact_loan
GROUP BY "Loan_ID"
HAVING COUNT(*) > 1;