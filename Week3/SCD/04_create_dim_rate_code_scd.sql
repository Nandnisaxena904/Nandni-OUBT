CREATE TABLE IF NOT EXISTS mdm.dim_rate_code_scd (
rate_code_sk SERIAL PRIMARY KEY,
rate_code_id INT NOT NULL,
rate_code_desc TEXT NOT NULL,
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


CREATE UNIQUE INDEX uq_rate_code_current
ON mdm.dim_rate_code_scd (rate_code_id)
WHERE is_current = TRUE;