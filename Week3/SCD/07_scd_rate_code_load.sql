-- Expire current rate codes
UPDATE mdm.dim_rate_code_scd t
SET is_current = FALSE,
active_flag = FALSE,
effective_end_date = now(),
updated_at = now()
FROM mdm.stg_rate_code s
WHERE t.rate_code_id = s.rate_code_id
AND t.is_current = TRUE
AND t.rate_code_desc <> s.rate_code_desc;


-- Insert new rate code versions
INSERT INTO mdm.dim_rate_code_scd (
rate_code_id, rate_code_desc,
active_flag, effective_start_date,
is_current, version,
source_system, batch_id
)
SELECT
s.rate_code_id,
s.rate_code_desc,
TRUE,
now(),
TRUE,
COALESCE(MAX(d.version),0) + 1,
s.source_system,
s.batch_id
FROM mdm.stg_rate_code s
LEFT JOIN mdm.dim_rate_code_scd d
ON s.rate_code_id = d.rate_code_id
GROUP BY s.rate_code_id, s.rate_code_desc,
s.source_system, s.batch_id;