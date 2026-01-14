-- Expire current zones
UPDATE mdm.dim_zone_scd t
SET is_current = FALSE,
active_flag = FALSE,
effective_end_date = now(),
updated_at = now()
FROM mdm.stg_zone s
WHERE t.location_id = s.location_id
AND t.is_current = TRUE
AND t.zone_name <> s.zone_name;


-- Insert new zone versions
INSERT INTO mdm.dim_zone_scd (
location_id, zone_name, borough,
active_flag, effective_start_date,
is_current, version,
source_system, batch_id
)
SELECT
s.location_id,
s.zone_name,
s.borough,
TRUE,
now(),
TRUE,
COALESCE(MAX(d.version),0) + 1,
s.source_system,
s.batch_id
FROM mdm.stg_zone s
LEFT JOIN mdm.dim_zone_scd d
ON s.location_id = d.location_id
GROUP BY s.location_id, s.zone_name, s.borough,
s.source_system, s.batch_id;