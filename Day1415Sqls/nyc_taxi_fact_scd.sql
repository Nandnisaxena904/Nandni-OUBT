CREATE TABLE IF NOT EXISTS mdm.nyc_taxi_fact_scd (
    trip_id BIGSERIAL PRIMARY KEY,
    vendor_sk INT,
    rate_code_sk INT,
    pickup_location_sk INT,
    dropoff_location_sk INT,
    tpep_pickup_datetime TIMESTAMP,
    tpep_dropoff_datetime TIMESTAMP,
    passenger_count INT,
    trip_distance DOUBLE PRECISION,
    fare_amount DOUBLE PRECISION,
    tip_amount DOUBLE PRECISION,
    total_amount DOUBLE PRECISION,
    batch_id TEXT,
    created_at TIMESTAMP DEFAULT now()
);

---------------------------------------------
INSERT INTO mdm.nyc_taxi_fact_scd (
    vendor_sk,
    rate_code_sk,
    pickup_location_sk,
    dropoff_location_sk,
    tpep_pickup_datetime,
    tpep_dropoff_datetime,
    passenger_count,
    trip_distance,
    fare_amount,
    tip_amount,
    total_amount,
    batch_id,
    created_at
)
SELECT
    v.vendor_sk,
    r.rate_code_id AS rate_code_sk,
    p.zone_sk AS pickup_location_sk,    -- corrected from location_sk
    d.zone_sk AS dropoff_location_sk,   -- corrected from location_sk
    to_timestamp(tpep_pickup_datetime/1000000000) AS tpep_pickup_datetime,
    to_timestamp(tpep_dropoff_datetime/1000000000) AS tpep_dropoff_datetime,
    passenger_count,
    trip_distance,
    fare_amount,
    tip_amount,
    total_amount,
    'INIT_LOAD_001' AS batch_id,
    now() AS created_at
FROM mdm.stg_nyc_taxi_curated st
LEFT JOIN mdm.dim_vendor_scd v
    ON st.vendor_name = v.vendor_name AND v.is_current = TRUE
LEFT JOIN mdm.dim_rate_code_scd r
    ON st.rate_code_desc = r.rate_code_desc AND r.is_current = TRUE
LEFT JOIN mdm.dim_zone_scd p
    ON st.pickup_zone_name = p.zone_name AND p.is_current = TRUE
LEFT JOIN mdm.dim_zone_scd d
    ON st.dropoff_zone_name = d.zone_name AND d.is_current = TRUE;

------
SELECT COUNT(*) FROM mdm.nyc_taxi_fact_scd;
SELECT * FROM mdm.nyc_taxi_fact_scd LIMIT 10;
