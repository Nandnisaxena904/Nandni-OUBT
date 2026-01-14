-- Procedure: insert_fact_trip
CREATE OR REPLACE FUNCTION mdm.insert_fact_trip(
    p_vendor_sk INT,
    p_rate_code_sk INT,
    p_pickup_location_sk INT,
    p_dropoff_location_sk INT,
    p_tpep_pickup TIMESTAMP,
    p_tpep_dropoff TIMESTAMP,
    p_passenger_count INT,
    p_trip_distance DOUBLE PRECISION,
    p_fare_amount DOUBLE PRECISION,
    p_tip_amount DOUBLE PRECISION,
    p_total_amount DOUBLE PRECISION,
    p_batch_id TEXT
)
RETURNS VOID AS $$
BEGIN
    INSERT INTO mdm.nyc_taxi_fact_scd (
        vendor_sk, rate_code_sk, pickup_location_sk, dropoff_location_sk,
        tpep_pickup_datetime, tpep_dropoff_datetime, passenger_count,
        trip_distance, fare_amount, tip_amount, total_amount, batch_id, created_at
    )
    VALUES (
        p_vendor_sk, p_rate_code_sk, p_pickup_location_sk, p_dropoff_location_sk,
        p_tpep_pickup, p_tpep_dropoff, p_passenger_count,
        p_trip_distance, p_fare_amount, p_tip_amount, p_total_amount, p_batch_id, now()
    );
END;
$$ LANGUAGE plpgsql;
