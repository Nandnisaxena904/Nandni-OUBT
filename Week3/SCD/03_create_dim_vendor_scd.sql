CREATE TABLE IF NOT EXISTS mdm.dim_vendor_scd (
vendor_sk BIGSERIAL PRIMARY KEY,
vendor_id BIGINT NOT NULL,
vendor_name VARCHAR(255),
contact_email VARCHAR(255),
active_flag BOOLEAN,


effective_start_date TIMESTAMP NOT NULL,
effective_end_date TIMESTAMP,
is_current BOOLEAN NOT NULL DEFAULT TRUE,
version INT NOT NULL,


approval_status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
approved_by VARCHAR(100),
approved_at TIMESTAMP,
approval_reason VARCHAR(255),


source_system VARCHAR(50),
batch_id VARCHAR(50),
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


CREATE UNIQUE INDEX uq_vendor_current
ON mdm.dim_vendor_scd (vendor_id)
WHERE is_current = TRUE;