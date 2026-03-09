/* ============================================================
   FILE: 03_Staging_Layer_Transformations.sql
   PURPOSE:
   Create staging tables from raw source tables.
   Verification queries are included in the same file.
   ============================================================ */




/* ============================================================
   STAGING LAYER TRANSFORMATIONS (Table 01)
   - Source: raw.dim_branch
   ============================================================ */
CREATE TABLE IF NOT EXISTS staging.stg_dim_branch AS
SELECT
    -- Primary Identifiers
    UPPER(TRIM("Branch_ID"))::VARCHAR(10)       AS branch_id,
    UPPER(TRIM("Geography_ID"))::VARCHAR(10)    AS geography_id,

    -- Descriptive Attributes
    INITCAP(TRIM("Branch_Name"))::VARCHAR(80)   AS branch_name,
    INITCAP(TRIM("Branch_Type"))::VARCHAR(60)   AS branch_type
FROM raw.dim_branch;

-- Validation
SELECT * FROM raw.dim_branch;
SELECT * FROM staging.stg_dim_branch;




/* ============================================================
   STAGING LAYER TRANSFORMATIONS (Table 02)
   - Source: raw.dim_customer
   ============================================================ */
CREATE TABLE IF NOT EXISTS staging.stg_dim_customer AS
SELECT
    -- Primary Identifiers
    UPPER(TRIM("Customer_ID"))::VARCHAR(20)           AS customer_id,
    UPPER(TRIM("Geography_ID"))::VARCHAR(10)          AS geography_id,

    -- Dates
    TO_DATE(TRIM("Date_of_Birth"), 'YYYY-MM-DD')::DATE        AS date_of_birth,
    TO_DATE(TRIM("Customer_Since_Date"), 'YYYY-MM-DD')::DATE  AS customer_since_date,

    -- Demographics
    INITCAP(TRIM("Gender"))::VARCHAR(10)              AS gender,
    INITCAP(TRIM("Marital_Status"))::VARCHAR(20)      AS marital_status,
    INITCAP(TRIM("Occupation_Type"))::VARCHAR(60)     AS occupation_type,

    -- Financials
    NULLIF(TRIM("Annual_Income"), '')::NUMERIC(18,2)  AS annual_income
FROM raw.dim_customer;

-- Validation
SELECT * FROM raw.dim_customer;
SELECT * FROM staging.stg_dim_customer;




/* ============================================================
   STAGING LAYER TRANSFORMATIONS (Table 03)
   - Source: raw.dim_geography
   ============================================================ */
CREATE TABLE IF NOT EXISTS staging.stg_dim_geography AS
SELECT
    -- Primary Identifiers
    UPPER(TRIM("Geography_ID"))::VARCHAR(10) AS geography_id,

    -- Location Attributes
    INITCAP(TRIM("State"))::VARCHAR(60)        AS state,
    INITCAP(TRIM("City"))::VARCHAR(60)         AS city,
    INITCAP(TRIM("Geo_Region"))::VARCHAR(60)   AS region,
    INITCAP(TRIM("Zone"))::VARCHAR(60)         AS zone,
    INITCAP(TRIM("Tier_Category"))::VARCHAR(20) AS tier_category
FROM raw.dim_geography;

-- Validation
SELECT * FROM raw.dim_geography;
SELECT * FROM staging.stg_dim_geography;




/* ============================================================
   STAGING LAYER TRANSFORMATIONS (Table 04)
   - Source: raw.dim_kyc
   ============================================================ */
CREATE TABLE IF NOT EXISTS staging.stg_dim_kyc AS
SELECT
    -- Primary Identifiers
    UPPER(TRIM("Customer_ID"))::VARCHAR(20) AS customer_id,

    -- PAN Details
    NULLIF(UPPER(TRIM("PAN_Number")), '')::VARCHAR(50) AS pan_number,

    -- KYC Status
    INITCAP(TRIM("KYC_Status"))::VARCHAR(50) AS kyc_status,

    -- Flags
    CASE
        WHEN UPPER(TRIM("PAN_Verified_Flag")) IN ('YES','Y','TRUE','T','1') THEN 1
        WHEN UPPER(TRIM("PAN_Verified_Flag")) IN ('NO','N','FALSE','F','0') THEN 0
        ELSE NULL
    END::SMALLINT AS pan_verified_flag,

    -- Dates
    TO_DATE(TRIM("KYC_Last_Update_Date"), 'YYYY-MM-DD')::DATE AS kyc_last_update_date
FROM raw.dim_kyc;

-- Validation
SELECT * FROM raw.dim_kyc;
SELECT * FROM staging.stg_dim_kyc;




/* ============================================================
   STAGING LAYER TRANSFORMATIONS (Table 05)
   - Source: raw.dim_loan_product
   ============================================================ */
CREATE TABLE IF NOT EXISTS staging.stg_dim_loan_product AS
SELECT
    -- Primary Identifiers
    UPPER(TRIM("Loan_Product_ID"))::VARCHAR(10) AS loan_product_id,

    -- Loan Attributes
    INITCAP(TRIM("Loan_Type"))::VARCHAR(80)     AS loan_type,
    INITCAP(TRIM("Loan_Category"))::VARCHAR(20) AS loan_category,
    INITCAP(TRIM("Interest_Type"))::VARCHAR(40) AS interest_type
FROM raw.dim_loan_product;

-- Validation
SELECT * FROM raw.dim_loan_product;
SELECT * FROM staging.stg_dim_loan_product;




/* ============================================================
   STAGING LAYER TRANSFORMATIONS (Table 06)
   - Source: raw.fact_loan
   ============================================================ */
CREATE TABLE IF NOT EXISTS staging.stg_fact_loan AS
SELECT
    -- Primary Identifiers
    UPPER(TRIM("Loan_ID"))::VARCHAR(20)          AS loan_id,
    UPPER(TRIM("Customer_ID"))::VARCHAR(20)      AS customer_id,
    UPPER(TRIM("Branch_ID"))::VARCHAR(10)        AS branch_id,
    UPPER(TRIM("Loan_Product_ID"))::VARCHAR(10)  AS loan_product_id,

    -- Dates
    TO_DATE(TRIM("Disbursement_Date"), 'YYYY-MM-DD')::DATE              AS disbursement_date,
    TO_DATE(TRIM("Maturity_Date"), 'YYYY-MM-DD')::DATE                  AS maturity_date,
    TO_DATE(NULLIF(TRIM("Closure_Date"), ''), 'YYYY-MM-DD')::DATE       AS closure_date,

    -- Amounts
    NULLIF(TRIM("Loan_Amount"), '')::NUMERIC(18,2)          AS loan_amount,
    NULLIF(TRIM("EMI_Amount"), '')::NUMERIC(18,2)           AS emi_amount,
    NULLIF(TRIM("Outstanding_Amount"), '')::NUMERIC(18,2)   AS outstanding_amount,

    -- Rates / Tenure / Delinquency
    NULLIF(TRIM("Interest_Rate"), '')::NUMERIC(8,3)         AS interest_rate,
    NULLIF(TRIM("Loan_Term_Months"), '')::INT               AS loan_term_months,
    NULLIF(TRIM("Days_Past_Due"), '')::SMALLINT             AS days_past_due,

    -- Status / Channel
    INITCAP(TRIM("Loan_Status"))::VARCHAR(20)               AS loan_status,
    INITCAP(TRIM("Disbursement_Channel"))::VARCHAR(40)      AS disbursement_channel,

    -- Flags
    CASE
        WHEN UPPER(TRIM("Write_Off_Flag")) IN ('YES','Y','TRUE','T','1') THEN 1
        WHEN UPPER(TRIM("Write_Off_Flag")) IN ('NO','N','FALSE','F','0') THEN 0
        ELSE NULL
    END::SMALLINT AS write_off_flag
FROM raw.fact_loan;

-- Validation
SELECT * FROM raw.fact_loan;
SELECT * FROM staging.stg_fact_loan;