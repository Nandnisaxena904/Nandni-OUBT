-- Expire current records
UPDATE mdm.dim_vendor_scd t
SET is_current = FALSE,
active_flag = FALSE,
effective_end_date = now(),
updated_at = now()
FROM mdm.dim_vendor_stage s
WHERE t.vendor_id = s.vendor_id
AND t.is_current = TRUE;


-- Insert new versions
INSERT INTO mdm.dim_vendor_scd (
vendor_id, vendor_name, contact_email,
active_flag, effective_start_date,
is_current, version,
source_system, batch_id
)
SELECT
s.vendor_id,
s.vendor_name,
s.contact_email,
TRUE,
now(),
TRUE,
COALESCE(MAX(d.version),0) + 1,
s.source_system,
s.batch_id
FROM mdm.dim_vendor_stage s
LEFT JOIN mdm.dim_vendor_scd d
ON s.vendor_id = d.vendor_id
GROUP BY s.vendor_id, s.vendor_name, s.contact_email,
s.source_system, s.batch_id;