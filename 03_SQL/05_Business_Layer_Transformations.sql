/* ============================================================
   FILE: 05_Business_Layer_Transformations.sql
   PURPOSE:
   Create business layer tables from staging tables.
   Verification queries are included in the same file.
   ============================================================ */




/* ============================================================
   BUSINESS LAYER (DIM) : Loan Product
   ============================================================ */
CREATE TABLE IF NOT EXISTS business.dim_loan_product AS
SELECT
    -- Keys
    loan_product_id::VARCHAR(10) AS loan_product_key,

    -- Attributes
    loan_type::VARCHAR(80)       AS loan_type,
    loan_category::VARCHAR(20)   AS loan_category,
    interest_type::VARCHAR(40)   AS interest_type
FROM staging.stg_loan_product;

-- Validation
SELECT * FROM staging.stg_loan_product;
SELECT * FROM business.dim_loan_product;




/* ============================================================
   BUSINESS LAYER (DIM) : Branch (Denormalized)
   ============================================================ */
CREATE TABLE IF NOT EXISTS business.dim_branch AS
SELECT
    -- Keys
    b.branch_id::VARCHAR(10)       AS branch_key,

    -- Branch Attributes
    b.branch_name::VARCHAR(80)     AS branch_name,
    b.branch_type::VARCHAR(60)     AS branch_type,

    -- Geography
    g.geography_id::VARCHAR(10)    AS geography_key,
    g.state::VARCHAR(60)           AS state,
    g.city::VARCHAR(60)            AS city,
    g.region::VARCHAR(20)          AS region,
    g.zone::VARCHAR(20)            AS zone,
    g.tier_category::VARCHAR(20)   AS tier_category
FROM staging.stg_branch b
LEFT JOIN staging.stg_geography g
    ON g.geography_id = b.geography_id;

-- Validation
SELECT * FROM staging.stg_branch;
SELECT * FROM staging.stg_geography;
SELECT * FROM business.dim_branch;




/* ============================================================
   BUSINESS LAYER (DIM) : Customer (Denormalized)
   ============================================================ */
CREATE TABLE IF NOT EXISTS business.dim_customer AS
SELECT
    -- Keys
    c.customer_id::VARCHAR(20)       AS customer_key,

    -- Geography
    g.geography_id::VARCHAR(10)      AS geography_key,
    g.state::VARCHAR(60)             AS state,
    g.city::VARCHAR(60)              AS city,
    g.tier_category::VARCHAR(20)     AS tier_category,

    -- Core Demographics
    c.gender::VARCHAR(10)            AS gender,
    c.marital_status::VARCHAR(20)    AS marital_status,
    c.occupation_type::VARCHAR(60)   AS occupation_type,
    c.date_of_birth::DATE            AS date_of_birth,
    c.customer_since_date::DATE      AS customer_since_date,
    c.annual_income::NUMERIC(18,2)   AS annual_income,

    -- Compliance (KYC)
    k.pan_number::VARCHAR(50)        AS pan_number,
    k.kyc_status::VARCHAR(50)        AS kyc_status,
    k.pan_verified_flag::SMALLINT    AS pan_verified_flag,
    k.kyc_last_update_date::DATE     AS kyc_last_update_date,
    k.pan_status::TEXT               AS pan_status,

    -- Derived: Compliance Flags
    CASE
        WHEN k.pan_number IS NULL OR TRIM(k.pan_number) = '' THEN 0
        ELSE 1
    END::SMALLINT AS pan_present_flag,

    CASE
        WHEN k.pan_verified_flag = 1 THEN 1
        ELSE 0
    END::SMALLINT AS kyc_verified_flag,

    -- Derived: Customer Analytics
    DATE_PART('year', AGE(CURRENT_DATE, c.date_of_birth))::INT AS customer_age_years,

    (
        DATE_PART('year', AGE(CURRENT_DATE, c.customer_since_date)) * 12
        + DATE_PART('month', AGE(CURRENT_DATE, c.customer_since_date))
    )::INT AS customer_tenure_months,

    CASE
        WHEN c.annual_income IS NULL THEN 'Unknown'
        WHEN c.annual_income < 200000 THEN '< 2L'
        WHEN c.annual_income < 500000 THEN '2L - 5L'
        WHEN c.annual_income < 1000000 THEN '5L - 10L'
        WHEN c.annual_income < 2000000 THEN '10L - 20L'
        ELSE '20L+'
    END::VARCHAR(20) AS income_band
FROM staging.stg_customer c
LEFT JOIN staging.stg_kyc k
    ON k.customer_id = c.customer_id
LEFT JOIN staging.stg_geography g
    ON g.geography_id = c.geography_id;

-- Validation
SELECT * FROM staging.stg_customer;
SELECT * FROM staging.stg_kyc;
SELECT * FROM staging.stg_geography;
SELECT * FROM business.dim_customer;




/* ============================================================
   BUSINESS LAYER (FACT) : Loan
   ============================================================ */
CREATE TABLE IF NOT EXISTS business.fact_loan AS
SELECT
    -- Keys
    f.loan_id::VARCHAR(20)          AS loan_key,
    f.customer_id::VARCHAR(20)      AS customer_key,
    f.branch_id::VARCHAR(10)        AS branch_key,
    f.loan_product_id::VARCHAR(10)  AS loan_product_key,

    -- Dates
    f.disbursement_date::DATE       AS disbursement_date,
    f.maturity_date::DATE           AS maturity_date,
    f.closure_date::DATE            AS closure_date,

    -- Amounts
    f.loan_amount::NUMERIC(18,2)        AS loan_amount,
    f.emi_amount::NUMERIC(18,2)         AS emi_amount,
    f.outstanding_amount::NUMERIC(18,2) AS outstanding_amount,

    -- Rates / Tenure / Delinquency
    f.interest_rate::NUMERIC(8,3)   AS interest_rate,
    f.loan_term_months::INT         AS loan_term_months,
    f.days_past_due::SMALLINT       AS days_past_due,

    -- Status / Channel
    f.loan_status::VARCHAR(20)          AS loan_status,
    f.disbursement_channel::VARCHAR(40) AS disbursement_channel,

    -- Flags
    f.write_off_flag::SMALLINT      AS write_off_flag,

    -- Derived: Portfolio Flags
    CASE WHEN f.closure_date IS NULL THEN 1 ELSE 0 END::SMALLINT AS active_flag,
    CASE WHEN f.closure_date IS NOT NULL THEN 1 ELSE 0 END::SMALLINT AS closed_flag,

    -- Derived: DPD Buckets
    CASE
        WHEN f.days_past_due IS NULL THEN 'Unknown'
        WHEN f.days_past_due = 0 THEN 'DPD 0'
        WHEN f.days_past_due BETWEEN 1 AND 30 THEN 'DPD 1-30'
        WHEN f.days_past_due BETWEEN 31 AND 60 THEN 'DPD 31-60'
        WHEN f.days_past_due BETWEEN 61 AND 90 THEN 'DPD 61-90'
        ELSE 'DPD 90+'
    END::VARCHAR(20) AS dpd_bucket,

    CASE
        WHEN f.days_past_due IS NULL THEN NULL
        WHEN f.days_past_due >= 90 THEN 1
        ELSE 0
    END::SMALLINT AS npa_risk_flag,

    -- Derived: Outstanding Ratio
    CASE
        WHEN f.loan_amount IS NULL OR f.loan_amount = 0 THEN NULL
        ELSE ROUND((f.outstanding_amount / f.loan_amount)::NUMERIC, 4)
    END::NUMERIC(10,4) AS outstanding_to_principal_ratio
FROM staging.stg_loan f;

-- Validation
SELECT * FROM staging.stg_loan;
SELECT * FROM business.fact_loan;

-- ============================================================
-- Final business row count summary
-- ============================================================
SELECT 'business.dim_loan_product' AS table_name, COUNT(*) AS row_count FROM business.dim_loan_product
UNION ALL
SELECT 'business.dim_branch', COUNT(*) FROM business.dim_branch
UNION ALL
SELECT 'business.dim_customer', COUNT(*) FROM business.dim_customer
UNION ALL
SELECT 'business.fact_loan', COUNT(*) FROM business.fact_loan;