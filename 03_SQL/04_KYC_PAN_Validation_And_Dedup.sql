/* ============================================================
   FILE: 04_KYC_PAN_Validation_And_Dedup.sql
   PURPOSE:
   Apply PAN validation, update PAN status, correct KYC status
   for invalid or missing PAN cases where appropriate, and
   deduplicate customer rows in staging.stg_kyc.
   Verification queries are included in the same file.
   ============================================================ */

-- ============================================================
-- 0. Check distinct customer count before processing
-- ============================================================
SELECT COUNT(DISTINCT customer_id)
FROM staging.stg_kyc;

-- ============================================================
-- 1. Check current data
-- ============================================================
SELECT *
FROM staging.stg_kyc;

-- ============================================================
-- 2. Helper Function: Check adjacent repetition
-- Returns TRUE if adjacent characters repeat
-- Example: AABCD -> TRUE
-- ============================================================
CREATE OR REPLACE FUNCTION fn_check_adjacent_repetition(p_str TEXT)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
BEGIN
    FOR i IN 1 .. LENGTH(p_str) - 1 LOOP
        IF SUBSTRING(p_str, i, 1) = SUBSTRING(p_str, i + 1, 1) THEN
            RETURN TRUE;
        END IF;
    END LOOP;
    RETURN FALSE;
END;
$$;

-- ============================================================
-- 3. Helper Function: Check sequence
-- Returns TRUE if all characters are sequential
-- Example: ABCDE -> TRUE, 1234 -> TRUE
-- ============================================================
CREATE OR REPLACE FUNCTION fn_check_sequence(p_str TEXT)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
BEGIN
    FOR i IN 1 .. LENGTH(p_str) - 1 LOOP
        IF ASCII(SUBSTRING(p_str, i + 1, 1)) - ASCII(SUBSTRING(p_str, i, 1)) <> 1 THEN
            RETURN FALSE;
        END IF;
    END LOOP;
    RETURN TRUE;
END;
$$;

-- ============================================================
-- 4. Add PAN status column if not exists
-- ============================================================
ALTER TABLE staging.stg_kyc
ADD COLUMN IF NOT EXISTS pan_status TEXT;

-- ============================================================
-- 5. Update PAN validation result
-- ============================================================
UPDATE staging.stg_kyc
SET pan_status =
    CASE
        WHEN pan_number IS NULL OR TRIM(pan_number) = '' THEN NULL
        WHEN LENGTH(UPPER(TRIM(pan_number))) = 10
             AND UPPER(TRIM(pan_number)) ~ '^[A-Z]{5}[0-9]{4}[A-Z]$'
             AND fn_check_adjacent_repetition(SUBSTRING(UPPER(TRIM(pan_number)), 1, 5)) = FALSE
             AND fn_check_sequence(SUBSTRING(UPPER(TRIM(pan_number)), 1, 5)) = FALSE
             AND fn_check_sequence(SUBSTRING(UPPER(TRIM(pan_number)), 6, 4)) = FALSE
        THEN 'Valid'
        ELSE 'Invalid'
    END;

-- ============================================================
-- 6. Update KYC status
-- Rule:
-- - Invalid PAN + Verified -> Requires Reverification
-- - Missing PAN + Verified -> Requires Reverification
-- - Otherwise keep as is
-- ============================================================
UPDATE staging.stg_kyc
SET kyc_status =
    CASE
        WHEN (pan_status = 'Invalid' OR pan_number IS NULL OR TRIM(pan_number) = '')
             AND kyc_status = 'Verified'
        THEN 'Requires Reverification'
        ELSE kyc_status
    END;

-- ============================================================
-- 7. Remove duplicates based on customer_id
-- Keeps one row per customer_id, preferring latest update date
-- ============================================================
DELETE FROM staging.stg_kyc a
USING staging.stg_kyc b
WHERE a.customer_id = b.customer_id
  AND a.ctid < b.ctid
  AND COALESCE(a.kyc_last_update_date, DATE '1900-01-01')
      <= COALESCE(b.kyc_last_update_date, DATE '1900-01-01');

-- ============================================================
-- 8. Verification Queries
-- ============================================================

-- Full table preview
SELECT *
FROM staging.stg_kyc;

-- Distinct customer count after processing
SELECT COUNT(DISTINCT customer_id)
FROM staging.stg_kyc;

-- Duplicate customer check after delete
SELECT customer_id, COUNT(*)
FROM staging.stg_kyc
GROUP BY customer_id
HAVING COUNT(*) > 1;

-- PAN validation summary
SELECT pan_status, COUNT(*) AS record_count
FROM staging.stg_kyc
GROUP BY pan_status
ORDER BY pan_status;

-- KYC status summary
SELECT kyc_status, COUNT(*) AS record_count
FROM staging.stg_kyc
GROUP BY kyc_status
ORDER BY kyc_status;

-- Valid PAN records
SELECT *
FROM staging.stg_kyc
WHERE pan_status = 'Valid';

-- Invalid PAN records
SELECT *
FROM staging.stg_kyc
WHERE pan_status = 'Invalid';

-- Missing PAN records
SELECT *
FROM staging.stg_kyc
WHERE pan_number IS NULL
   OR TRIM(pan_number) = '';

-- Invalid PAN cases moved to Requires Reverification
SELECT *
FROM staging.stg_kyc
WHERE pan_status = 'Invalid'
  AND kyc_status = 'Requires Reverification';

-- Missing PAN cases moved to Requires Reverification
SELECT *
FROM staging.stg_kyc
WHERE (pan_number IS NULL OR TRIM(pan_number) = '')
  AND kyc_status = 'Requires Reverification';

-- Distinct KYC statuses
SELECT DISTINCT kyc_status
FROM staging.stg_kyc
ORDER BY kyc_status;