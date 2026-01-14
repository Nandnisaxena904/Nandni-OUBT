-----SCD Type 2 Load (Vendor Dimension)

CREATE TABLE IF NOT EXISTS mdm.dim_vendor_scd (
    vendor_id SERIAL PRIMARY KEY,
    vendor_name TEXT NOT NULL,
    active_flag BOOLEAN DEFAULT TRUE,
    version INT DEFAULT 1,
    start_date TIMESTAMP DEFAULT now(),
    end_date TIMESTAMP,
    source_system TEXT,
    batch_id TEXT
);


---- chcek column names
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_schema = 'mdm' 
  AND table_name = 'dim_vendor_scd';


----insert new records from staging

-- Step 1: Expire old active records for the same vendor_id
UPDATE mdm.dim_vendor_scd t
SET active_flag = FALSE,
    is_current = FALSE,
    effective_end_date = now(),
    updated_at = now()
FROM mdm.dim_vendor_stage s
WHERE t.vendor_id = s.vendor_id
  AND t.active_flag = TRUE;

-- Step 2: Insert new versioned records from staging
INSERT INTO mdm.dim_vendor_scd (
    vendor_id,
    vendor_name,
    contact_email,
    active_flag,
    effective_start_date,
    effective_end_date,
    is_current,
    version,
    approval_status,
    approved_by,
    approved_at,
    approval_reason,
    source_system,
    batch_id,
    created_at,
    updated_at
)
SELECT 
    s.vendor_id,
    s.vendor_name,
    NULL AS contact_email,
    TRUE AS active_flag,
    now() AS effective_start_date,
    NULL AS effective_end_date,
    TRUE AS is_current,
    COALESCE(MAX(d.version), 0) + 1 AS version,
    'PENDING' AS approval_status,  -- FIXED: use default for NOT NULL
    NULL AS approved_by,
    NULL AS approved_at,
    NULL AS approval_reason,
    s.source_system,
    s.batch_id,
    now() AS created_at,
    now() AS updated_at
FROM mdm.dim_vendor_stage s
LEFT JOIN mdm.dim_vendor_scd d
  ON s.vendor_id = d.vendor_id
GROUP BY s.vendor_id, s.vendor_name, s.source_system, s.batch_id;


-----
SELECT vendor_sk, vendor_id, vendor_name, active_flag, is_current, version, effective_start_date, effective_end_date, approval_status
FROM mdm.dim_vendor_scd
ORDER BY vendor_sk;
