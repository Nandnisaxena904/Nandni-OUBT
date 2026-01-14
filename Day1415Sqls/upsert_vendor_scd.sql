-- Procedure: upsert_vendor_scd
CREATE OR REPLACE FUNCTION mdm.upsert_vendor_scd(p_vendor_name TEXT, p_batch_id TEXT)
RETURNS VOID AS $$
BEGIN
    -- 1. Mark existing record as historical if name exists
    UPDATE mdm.dim_vendor_scd
    SET is_current = FALSE,
        effective_end_date = now(),
        version = version
    WHERE vendor_name = p_vendor_name
      AND is_current = TRUE;

    -- 2. Insert new record
    INSERT INTO mdm.dim_vendor_scd (
        vendor_name, active_flag, effective_start_date,
        is_current, version, source_system, batch_id, created_at, updated_at
    )
    SELECT 
        p_vendor_name,
        TRUE,
        now(),
        TRUE,
        COALESCE(MAX(version), 0) + 1,
        'NYC_TAXI',
        p_batch_id,
        now(),
        now()
    FROM mdm.dim_vendor_scd
    WHERE vendor_name = p_vendor_name;
END;
$$ LANGUAGE plpgsql;
