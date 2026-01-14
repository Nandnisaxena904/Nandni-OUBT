-- Procedure: upsert_rate_code_scd

DROP FUNCTION IF EXISTS mdm.upsert_rate_code_scd(p_rate_code_desc TEXT,p_batch_id TEXT);

CREATE OR REPLACE FUNCTION mdm.upsert_rate_code_scd(
    p_rate_code_desc TEXT,
    p_batch_id TEXT
)
RETURNS INT AS
$$
DECLARE
    v_rate_code_id INT;
BEGIN
    -- Check if current row exists
    SELECT rate_code_id
    INTO v_rate_code_id
    FROM mdm.dim_rate_code_scd
    WHERE rate_code_desc = p_rate_code_desc
      AND is_current = TRUE
    LIMIT 1;

    IF v_rate_code_id IS NULL THEN
        -- Insert new row
        INSERT INTO mdm.dim_rate_code_scd (
            rate_code_desc,
            active_flag,
            effective_start_date,
            is_current,
            version,
            approval_status,
            source_system,
            batch_id,
            created_at,
            updated_at
        )
        VALUES (
            p_rate_code_desc,
            TRUE,
            now(),
            TRUE,
            COALESCE(
                (SELECT MAX(version) FROM mdm.dim_rate_code_scd WHERE rate_code_desc = p_rate_code_desc), 0
            ) + 1,
            'PENDING',
            'NYC_TAXI',
            p_batch_id,
            now(),
            now()
        )
        RETURNING rate_code_id INTO v_rate_code_id;
    END IF;

    RETURN v_rate_code_id;
END;
$$
LANGUAGE plpgsql;
