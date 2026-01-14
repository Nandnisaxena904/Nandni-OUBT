CREATE TABLE IF NOT EXISTS mdm.dim_zone_scd (
zone_sk SERIAL PRIMARY KEY,
location_id INT NOT NULL,
zone_name TEXT NOT NULL,
borough TEXT,
active_flag BOOLEAN DEFAULT TRUE,
effective_start_date TIMESTAMP DEFAULT now(),
effective_end_date TIMESTAMP,
is_current BOOLEAN DEFAULT TRUE,
version INT DEFAULT 1,
source_system TEXT,
batch_id TEXT,
created_at TIMESTAMP DEFAULT now(),
updated_at TIMESTAMP DEFAULT now()
);


CREATE UNIQUE INDEX uq_zone_current
ON mdm.dim_zone_scd (location_id)
WHERE is_current = TRUE;