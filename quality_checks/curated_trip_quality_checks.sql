-- ======================================================
-- Data Quality Checks for nyc_taxi_curated_db.curated_nyc_taxi
-- ======================================================

-- 1. Check if there are any NULL vendor IDs
SELECT
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS vendorid_not_null_check
FROM nyc_taxi_curated_db.curated_nyc_taxi
WHERE vendorid IS NULL;

-- 2. Check if pickup and dropoff timestamps are valid (dropoff after pickup)
SELECT
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS pickup_before_dropoff_check
FROM nyc_taxi_curated_db.curated_nyc_taxi
WHERE tpep_dropoff_datetime < tpep_pickup_datetime;

-- 3. Check if passenger count is positive
SELECT
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS passenger_count_positive_check
FROM nyc_taxi_curated_db.curated_nyc_taxi
WHERE passenger_count <= 0;

-- 4. Check if trip distance is positive
SELECT
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS trip_distance_positive_check
FROM nyc_taxi_curated_db.curated_nyc_taxi
WHERE trip_distance <= 0;

-- 5. Check if fare amount is non-negative
SELECT
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS fare_amount_non_negative_check
FROM nyc_taxi_curated_db.curated_nyc_taxi
WHERE fare_amount < 0;

-- 6. Check if total_amount is consistent (>= fare + extra + tax + tip + toll + surcharge)
SELECT
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS total_amount_consistency_check
FROM nyc_taxi_curated_db.curated_nyc_taxi
WHERE total_amount < (fare_amount + extra + mta_tax + tip_amount + tolls_amount + improvement_surcharge + congestion_surcharge);

-- 7. Check if payment type is valid (assuming codes 1-4 are valid)
SELECT
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS payment_type_valid_check
FROM nyc_taxi_curated_db.curated_nyc_taxi
WHERE payment_type NOT IN (1, 2, 3, 4);

-- 8. Check if store_and_fwd_flag is valid (Y/N)
SELECT
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS store_and_fwd_flag_valid_check
FROM nyc_taxi_curated_db.curated_nyc_taxi
WHERE store_and_fwd_flag NOT IN ('Y', 'N');

-- 9. Check for duplicate trips (vendorid + pickup datetime + dropoff datetime + pulocationid + dolocationid)
SELECT
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS duplicate_trip_check
FROM (
    SELECT vendorid, tpep_pickup_datetime, tpep_dropoff_datetime, pulocationid, dolocationid
    FROM nyc_taxi_curated_db.curated_nyc_taxi
    GROUP BY vendorid, tpep_pickup_datetime, tpep_dropoff_datetime, pulocationid, dolocationid
    HAVING COUNT(*) > 1
) duplicates;

-- 10. Check if tip amount is non-negative
SELECT
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS tip_amount_non_negative_check
FROM nyc_taxi_curated_db.curated_nyc_taxi
WHERE tip_amount < 0;

-- 11. Check if trip duration is positive
SELECT
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS trip_duration_positive_check
FROM nyc_taxi_curated_db.curated_nyc_taxi
WHERE trip_duration_minutes <= 0;

-- 12. Optional: Check if pickup and dropoff zone names are not NULL
SELECT
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS pickup_zone_not_null_check
FROM nyc_taxi_curated_db.curated_nyc_taxi
WHERE pickup_zone_name IS NULL;

SELECT
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS dropoff_zone_not_null_check
FROM nyc_taxi_curated_db.curated_nyc_taxi
WHERE dropoff_zone_name IS NULL;
