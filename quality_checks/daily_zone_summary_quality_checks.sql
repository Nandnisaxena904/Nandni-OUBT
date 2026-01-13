WITH
-- 1️ Row count check
row_count_check AS (
    SELECT
        'ROW_COUNT_CHECK' AS check_name,
        CASE
            WHEN COUNT(*) > 0 THEN 'PASS'
            ELSE 'FAIL'
        END AS status
    FROM nyc_taxi_curated_db.daily_zone_summary
),

-- 2️ Null check on key dimensions
null_check AS (
    SELECT
        'NULL_CHECK' AS check_name,
        CASE
            WHEN COUNT(*) = 0 THEN 'PASS'
            ELSE 'FAIL'
        END AS status
    FROM nyc_taxi_curated_db.daily_zone_summary
    WHERE
        pickup_zone_name IS NULL
        OR dropoff_zone_name IS NULL
        OR pickup_day_of_week IS NULL
),

-- 3️ Duplicate check on grain
duplicate_check AS (
    SELECT
        'DUPLICATE_CHECK' AS check_name,
        CASE
            WHEN COUNT(*) = 0 THEN 'PASS'
            ELSE 'FAIL'
        END AS status
    FROM (
        SELECT
            pickup_zone_name,
            dropoff_zone_name,
            pickup_day_of_week,
            COUNT(*) AS cnt
        FROM nyc_taxi_curated_db.daily_zone_summary
        GROUP BY
            pickup_zone_name,
            dropoff_zone_name,
            pickup_day_of_week
        HAVING COUNT(*) > 1
    )
),

-- 4️ Negative value check
negative_value_check AS (
    SELECT
        'NEGATIVE_VALUE_CHECK' AS check_name,
        CASE
            WHEN COUNT(*) = 0 THEN 'PASS'
            ELSE 'FAIL'
        END AS status
    FROM nyc_taxi_curated_db.daily_zone_summary
    WHERE
        total_trips < 0
        OR avg_trip_distance < 0
        OR avg_fare_amount < 0
        OR total_tip_amount < 0
)

--  Final unified result
SELECT * FROM row_count_check
UNION ALL
SELECT * FROM null_check
UNION ALL
SELECT * FROM duplicate_check
UNION ALL
SELECT * FROM negative_value_check;
