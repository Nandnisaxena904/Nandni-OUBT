INSERT INTO mdm.nyc_taxi_fact_scd (
vendor_sk, rate_code_sk,
pickup_location_sk, dropoff_location_sk,
tpep_pickup_datetime, tpep_dropoff_datetime,
passenger_count, trip_distance,
fare_amount, tip_amount, total_amount,
batch_id
)
SELECT
v.vendor_sk,
r.rate_code_sk,
p.zone_sk,
d.zone_sk,
to_timestamp(st.tpep_pickup_datetime/1000000000),
to_timestamp(st.tpep_dropoff_datetime/1000000000),
st.passenger_count,
st.trip_distance,
st.fare_amount,
st.tip_amount,
st.total_amount,
'INIT_LOAD'
FROM mdm.stg_nyc_taxi_curated st
LEFT JOIN mdm.dim_vendor_scd v
ON st.vendor_name = v.vendor_name AND v.is_current = TRUE
LEFT JOIN mdm.dim_rate_code_scd r
ON st.rate_code_desc = r.rate_code_desc AND r.is_current = TRUE
LEFT JOIN mdm.dim_zone_scd p
ON st.pickup_zone_name = p.zone_name AND p.is_current = TRUE
LEFT JOIN mdm.dim_zone_scd d
ON st.dropoff_zone_name = d.zone_name AND d.is_current = TRUE;