CREATE TABLE nyc_taxi_curated_db.daily_zone_summary
WITH (
    format = 'PARQUET',
    external_location = 's3://my-data-lake-lab-nandnioubt/curated/aggregates/daily_zone_summary/',
    parquet_compression = 'SNAPPY'
)
AS
SELECT
    pickup_zone_name,
    dropoff_zone_name,
    pickup_day_of_week,
    COUNT(*)                         AS total_trips,
    AVG(trip_distance)               AS avg_trip_distance,
    AVG(fare_amount)                 AS avg_fare_amount,
    SUM(tip_amount)                  AS total_tip_amount
FROM nyc_taxi_curated_db.curated_nyc_taxi
GROUP BY
    pickup_zone_name,
    dropoff_zone_name,
    pickup_day_of_week;
