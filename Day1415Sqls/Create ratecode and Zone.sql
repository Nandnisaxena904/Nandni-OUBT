CREATE TABLE mdm.dim_rate_code_scd (
    rate_code_sk SERIAL PRIMARY KEY,        -- surrogate key
    rate_code_id INT NOT NULL,              -- business key
    rate_code_desc TEXT NOT NULL,
    active_flag BOOLEAN DEFAULT TRUE,
    effective_start_date TIMESTAMP DEFAULT now(),
    effective_end_date TIMESTAMP,
    is_current BOOLEAN DEFAULT TRUE,
    version INT DEFAULT 1,
    source_system TEXT,
    batch_id TEXT,
    created_at TIMESTAMP DEFAULT now(),
    updated_at TIMESTAMP DEFAULT now()
);

----create Zone scd table---

CREATE TABLE mdm.dim_zone_scd (
    zone_sk SERIAL PRIMARY KEY,             -- surrogate key
    location_id INT NOT NULL,               -- business key (pickup/dropoff)
    zone_name TEXT NOT NULL,
    borough TEXT,                           -- optional, if you have
    active_flag BOOLEAN DEFAULT TRUE,
    effective_start_date TIMESTAMP DEFAULT now(),
    effective_end_date TIMESTAMP,
    is_current BOOLEAN DEFAULT TRUE,
    version INT DEFAULT 1,
    source_system TEXT,
    batch_id TEXT,
    created_at TIMESTAMP DEFAULT now(),
    updated_at TIMESTAMP DEFAULT now()
);

------

INSERT INTO mdm.dim_rate_code_scd (
    rate_code_id,
    rate_code_desc,
    active_flag,
    effective_start_date,
    effective_end_date,
    is_current,
    version,
    source_system,
    batch_id,
    created_at,
    updated_at
)
SELECT
    ratecodeid AS rate_code_id,
    rate_code_desc,
    TRUE AS active_flag,
    now() AS effective_start_date,
    NULL AS effective_end_date,
    TRUE AS is_current,
    1 AS version,
    'NYC_TAXI' AS source_system,
    'INIT_LOAD_001' AS batch_id,
    now() AS created_at,
    now() AS updated_at
FROM nyc_taxi_curated_db.curated_nyc_taxi
GROUP BY ratecodeid, rate_code_desc;

---

CREATE TABLE staging_rate_code (
    rate_code_id TEXT,
    rate_code_desc TEXT
);

INSERT INTO mdm.dim_rate_code_scd (
    rate_code_id,
    rate_code_desc,
    active_flag,
    effective_start_date,
    is_current,
    version,
    source_system,
    batch_id,
    created_at,
    updated_at
)
SELECT
    CAST(rate_code_id AS INT),
    rate_code_desc,
    TRUE AS active_flag,
    now() AS effective_start_date,
    TRUE AS is_current,
    1 AS version,
    'NYC_TAXI' AS source_system,
    'INIT_LOAD_001' AS batch_id,
    now() AS created_at,
    now() AS updated_at
FROM tmp_rate_code_stage;

-------
SELECT * FROM mdm.dim_vendor_scd ORDER BY vendor_id;
SELECT * FROM mdm.dim_rate_code_scd ORDER BY rate_code_id;
SELECT * FROM mdm.dim_zone_scd ORDER BY location_id;


