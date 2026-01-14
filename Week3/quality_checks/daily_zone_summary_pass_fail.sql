WITH quality_checks AS (
    SELECT 'ROW_COUNT_CHECK' AS check_name, status
    FROM (
        SELECT
            CASE WHEN COUNT(*) > 0 THEN 'PASS' ELSE 'FAIL' END AS status
        FROM nyc_taxi_curated_db.daily_zone_summary
    )

    UNION ALL

    SELECT 'NULL_CHECK', status
    FROM (
        SELECT
            CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS status
        FROM nyc_taxi_curated_db.daily_zone_summary
        WHERE
            pickup_zone_name IS NULL
            OR dropoff_zone_name IS NULL
            OR pickup_day_of_week IS NULL
    )

    UNION ALL

    SELECT 'DUPLICATE_CHECK', status
    FROM (
        SELECT
            CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS status
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
    )

    UNION ALL

    SELECT 'NEGATIVE_VALUE_CHECK', status
    FROM (
        SELECT
            CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS status
        FROM nyc_taxi_curated_db.daily_zone_summary
        WHERE
            total_trips < 0
            OR avg_trip_distance < 0
            OR avg_fare_amount < 0
            OR total_tip_amount < 0
    )
),

final_decision AS (
    SELECT
        CASE
            WHEN COUNT_IF(status = 'FAIL') > 0 THEN 'FAIL'
            ELSE 'PASS'
        END AS overall_status
    FROM quality_checks
)

SELECT * FROM quality_checks
UNION ALL
SELECT 'OVERALL_STATUS', overall_status
FROM final_decision;
