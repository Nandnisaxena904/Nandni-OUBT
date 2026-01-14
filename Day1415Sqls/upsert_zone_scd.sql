-- Procedure: upsert_zone_scd
DROP FUNCTION mdm.upsert_zone_scd(p_zone_name TEXT,p_batch_id TEXT);

CREATE OR REPLACE FUNCTION mdm.upsert_zone_scd(
    p_zone_name TEXT,
    p_batch_id TEXT
)
RETURNS INT AS
$$
DECLARE
    v_location_sk INT;
BEGIN
    -- Check if current row exists
    SELECT location_sk
    INTO v_location_sk
    FROM mdm.dim_zone_scd
    WHERE zone_name = p_zone_name
      AND is_current = TRUE
    LIMIT 1;

    IF v_location_sk IS NULL THEN
        -- Insert new row
        INSERT INTO mdm.dim_zone_scd (
            zone_name,
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
            p_zone_name,
            TRUE,
            now(),
            TRUE,
            COALESCE(
                (SELECT MAX(version) FROM mdm.dim_zone_scd WHERE zone_name = p_zone_name), 0
            ) + 1,
            'PENDING',
            'NYC_TAXI',
            p_batch_id,
            now(),
            now()
        )
        RETURNING location_sk INTO v_location_sk;
    END IF;

    RETURN v_location_sk;
END;
$$
LANGUAGE plpgsql;
