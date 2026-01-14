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