-- =====================================================================
-- Author: Nandni Saxena
-- Owner: Data Engineering / Analytics Team
-- Purpose: Create daily trip-level business metrics from curated NYC taxi data
-- Source Table: nyc_taxi_curated_db.curated_nyc_taxi
-- Dependencies:
--   - pickup_date derived from tpep_pickup_datetime
--   - vendor_name
-- Quality Expectations:
--   - No negative fare or total amounts
--   - payment_type must be valid
--   - trip_duration_minutes >= 0
-- Refresh Frequency: Daily
-- Created Date: 2026-01-08
-- =====================================================================
WITH base_trips AS (
    SELECT
        vendorid,
        vendor_name,
        CAST(
        from_unixtime(tpep_pickup_datetime / 1000000000) AS DATE) AS pickup_date,
        trip_distance,
        trip_duration_minutes,
        fare_amount,
        tip_amount,
        total_amount,
        payment_type,
        is_valid_payment_type
    FROM nyc_taxi_curated_db.curated_nyc_taxi
    WHERE
        total_amount >= 0
        AND trip_duration_minutes >= 0
),

validated_trips AS (
    SELECT *
    FROM base_trips
    WHERE is_valid_payment_type = 'Y'
),

daily_vendor_metrics AS (
    SELECT
        pickup_date,
        vendorid,
        vendor_name,
        COUNT(*) AS total_trips,
        SUM(total_amount) AS total_revenue,
        AVG(trip_distance) AS avg_trip_distance,
        AVG(trip_duration_minutes) AS avg_trip_duration_minutes,
        SUM(tip_amount) AS total_tips
    FROM validated_trips
    GROUP BY
        pickup_date,
        vendorid,
        vendor_name
)

SELECT *
FROM daily_vendor_metrics;