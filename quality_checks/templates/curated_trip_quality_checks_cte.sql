-- ======================================================
-- Data Quality Checks for nyc_taxi_curated_db.curated_nyc_taxi
-- Using modular CTEs in one SQL file
-- ======================================================

WITH
-- 1. Null check: passenger_count
passenger_count_null AS (
    SELECT CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS passenger_count_not_null
    FROM nyc_taxi_curated_db.curated_nyc_taxi
    WHERE passenger_count IS NULL
),

-- 2. Positive numeric check: trip_distance
trip_distance_positive AS (
    SELECT CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS trip_distance_positive_check
    FROM nyc_taxi_curated_db.curated_nyc_taxi
    WHERE trip_distance <= 0
),

-- 3. Positive numeric check: fare_amount
fare_amount_positive AS (
    SELECT CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS fare_amount_non_negative_check
    FROM nyc_taxi_curated_db.curated_nyc_taxi
    WHERE fare_amount < 0
),

-- 4. Positive numeric check: total_amount consistency
total_amount_consistency AS (
    SELECT CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS total_amount_consistency_check
    FROM nyc_taxi_curated_db.curated_nyc_taxi
    WHERE total_amount < (fare_amount + extra + mta_tax + tip_amount + tolls_amount + improvement_surcharge + congestion_surcharge)
),

-- 5. Positive numeric check: tip_amount
tip_amount_positive AS (
    SELECT CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS tip_amount_non_negative_check
    FROM nyc_taxi_curated_db.curated_nyc_taxi
    WHERE tip_amount < 0
),

-- 6. Positive numeric check: trip_duration_minutes
trip_duration_positive AS (
    SELECT CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS trip_duration_positive_check
    FROM nyc_taxi_curated_db.curated_nyc_taxi
    WHERE trip_duration_minutes <= 0
),

-- 7. Timestamp check: pickup before dropoff
pickup_before_dropoff AS (
    SELECT CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS pickup_before_dropoff_check
    FROM nyc_taxi_curated_db.curated_nyc_taxi
    WHERE tpep_dropoff_datetime < tpep_pickup_datetime
),

-- 8. Categorical check: payment_type valid
payment_type_valid AS (
    SELECT CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS payment_type_valid_check
    FROM nyc_taxi_curated_db.curated_nyc_taxi
    WHERE payment_type NOT IN (1, 2, 3, 4)
),

-- 9. Categorical check: store_and_fwd_flag valid
store_and_fwd_valid AS (
    SELECT CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS store_and_fwd_flag_valid_check
    FROM nyc_taxi_curated_db.curated_nyc_taxi
    WHERE store_and_fwd_flag NOT IN ('Y','N')
),

-- 10. Duplicate check: trip
duplicate_trip AS (
    SELECT CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS duplicate_trip_check
    FROM (
        SELECT vendorid, tpep_pickup_datetime, tpep_dropoff_datetime, pulocationid, dolocationid
        FROM nyc_taxi_curated_db.curated_nyc_taxi
        GROUP BY vendorid, tpep_pickup_datetime, tpep_dropoff_datetime, pulocationid, dolocationid
        HAVING COUNT(*) > 1
    ) duplicates
),

-- 11. Zone not null check: pickup
pickup_zone_not_null AS (
    SELECT CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS pickup_zone_not_null_check
    FROM nyc_taxi_curated_db.curated_nyc_taxi
    WHERE pickup_zone_name IS NULL
),

-- 12. Zone not null check: dropoff
dropoff_zone_not_null AS (
    SELECT CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS dropoff_zone_not_null_check
    FROM nyc_taxi_curated_db.curated_nyc_taxi
    WHERE dropoff_zone_name IS NULL
)

-- ======================================================
-- Combine all checks into one final row
-- ======================================================
SELECT
    passenger_count_not_null,
    trip_distance_positive_check,
    fare_amount_non_negative_check,
    total_amount_consistency_check,
    tip_amount_non_negative_check,
    trip_duration_positive_check,
    pickup_before_dropoff_check,
    payment_type_valid_check,
    store_and_fwd_flag_valid_check,
    duplicate_trip_check,
    pickup_zone_not_null_check,
    dropoff_zone_not_null_check
FROM passenger_count_null
CROSS JOIN trip_distance_positive
CROSS JOIN fare_amount_positive
CROSS JOIN total_amount_consistency
CROSS JOIN tip_amount_positive
CROSS JOIN trip_duration_positive
CROSS JOIN pickup_before_dropoff
CROSS JOIN payment_type_valid
CROSS JOIN store_and_fwd_valid
CROSS JOIN duplicate_trip
CROSS JOIN pickup_zone_not_null
CROSS JOIN dropoff_zone_not_null;
