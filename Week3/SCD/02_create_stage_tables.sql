CREATE TABLE IF NOT EXISTS mdm.dim_vendor_stage (
vendor_id INT NOT NULL,
vendor_name VARCHAR(255),
contact_email VARCHAR(255),
active_flag BOOLEAN,
source_system VARCHAR(50),
batch_id VARCHAR(50),
load_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


CREATE TABLE IF NOT EXISTS mdm.stg_rate_code (
rate_code_id INT NOT NULL,
rate_code_desc TEXT NOT NULL,
source_system VARCHAR(50),
batch_id VARCHAR(50),
load_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


CREATE TABLE IF NOT EXISTS mdm.stg_zone (
location_id INT NOT NULL,
zone_name TEXT NOT NULL,
borough TEXT,
source_system VARCHAR(50),
batch_id VARCHAR(50),
load_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);