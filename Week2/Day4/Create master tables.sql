--------CREATE MASTER TABLES-------

CREATE TABLE taxi_zones (
    zone_id INT PRIMARY KEY,
    zone_name VARCHAR(100) NOT NULL,
    borough VARCHAR(50) NOT NULL,
    created_by VARCHAR(50),
    updated_by VARCHAR(50),
    approved_by VARCHAR(50),
    version INT DEFAULT 1,
created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);



CREATE TABLE rate_codes (
    rate_code_id INT PRIMARY KEY,
    rate_description VARCHAR(100) NOT NULL,
    created_by VARCHAR(50),
    updated_by VARCHAR(50),
    approved_by VARCHAR(50),
    version INT DEFAULT 1,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);


CREATE TABLE vendors (
    vendor_id INT PRIMARY KEY,
    vendor_name VARCHAR(100) NOT NULL,
    created_by VARCHAR(50),
    updated_by VARCHAR(50),
    approved_by VARCHAR(50),
    version INT DEFAULT 1,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

------------------CREATE taxi zone STAGING TABLE--------------------

CREATE TABLE stg_taxi_zones (
    zone_id INT,
    zone_name VARCHAR(100),
    borough VARCHAR(50),
    source_system VARCHAR(50),
    load_timestamp TIMESTAMP DEFAULT NOW()
);

---insert sample data-----

INSERT INTO stg_taxi_zones (zone_id, zone_name, borough, source_system)
VALUES
(1, 'Newark Airport', 'EWR', 'TLC'),
(2, 'JFK Airport', 'Queens', 'TLC'),
(2, 'JFK Airport', 'Queens', 'TLC'),  -- duplicate on purpose
(3, 'Midtown Center', 'Manhattan', 'TLC'),
(3, 'Mid Town Center', 'Manhattan', 'TLC'); -- fuzzy duplicate

-----Detect EXACT duplicates in staging----

select * from stg_taxi_zones
SELECT
    zone_id,
    zone_name,
    borough,
    COUNT(*) AS duplicate_count
FROM stg_taxi_zones
GROUP BY zone_id, zone_name, borough
HAVING COUNT(*) > 1;

--What this does

---Finds exact duplicates

---Uses business keys (zone_id, zone_name, borough)

---This is the simple matching algorithm (exact match)

----------------------------------------------------------

-----DETECT FUZZY (NEAR) DUPLICATES IN STAGING----

SELECT a.zone_name AS zone1, b.zone_name AS zone2
FROM stg_taxi_zones a
JOIN stg_taxi_zones b
ON a.zone_name % b.zone_name --% (Similarity operator): Returns a similarity score (0 to 1).
WHERE a.zone_id = b.zone_id AND a.zone_name <> b.zone_name;

CREATE EXTENSION IF NOT EXISTS pg_trgm;

------Populate master table from staging-----

INSERT INTO taxi_zones (
    zone_id,
    zone_name,
    borough,
    created_by,
    updated_by,
    approved_by,
    version,
    created_at,
    updated_at
)
SELECT
    zone_id,
    MIN(zone_name) AS zone_name,          -- choose one name among duplicates
    borough,
    'system_user' AS created_by,
    'system_user' AS updated_by,
    'admin_user' AS approved_by,
    1 AS version,
    MIN(load_timestamp) AS created_at,    -- earliest timestamp
    MAX(load_timestamp) AS updated_at     -- latest timestamp
FROM stg_taxi_zones
GROUP BY zone_id, borough;

-----SQL to create taxi zone golden record table with survivorship rules----
CREATE TABLE taxi_zones_golden AS
SELECT
    zone_id,
    MAX(zone_name) AS zone_name,
    borough,
    MIN(created_by) AS created_by,
    MAX(updated_by) AS updated_by,
    MAX(approved_by) AS approved_by,
    MAX(version) AS version,
    MIN(created_at) AS created_at,
    MAX(updated_at) AS updated_at
FROM taxi_zones
GROUP BY zone_id, borough;


select count(*) from taxi_zones;
select count(*) from taxi_zones_golden;

select * from taxi_zones_golden
-----------------------------------------------------------------

------------------CREATE vendor STAGING TABLE--------------------

CREATE TABLE stg_vendors (
    vendor_id INT,
    vendor_name VARCHAR(100),
    source_system VARCHAR(50),
    load_timestamp TIMESTAMP DEFAULT NOW()
);

INSERT INTO stg_vendors (vendor_id, vendor_name, source_system)
VALUES
(1, 'Creative Mobile Technologies, LLC', 'TLC'),
(2, 'Curb Mobility, LLC', 'TLC'),
(2, 'Curb Mobility LLC', 'TLC'),  -- fuzzy duplicate
(6, 'Myle Technologies Inc', 'TLC'),
(7, 'Helix', 'TLC');

SELECT * FROM stg_vendors;

-------Detect EXACT duplicates in staging----
SELECT
    vendor_id,
    vendor_name,
    COUNT(*) AS duplicate_count
FROM stg_vendors
GROUP BY vendor_id, vendor_name
HAVING COUNT(*) > 1;


------------SQL to create vendor table----


CREATE TABLE vendors (
    vendor_id INT PRIMARY KEY,
    vendor_name VARCHAR(100) NOT NULL,
    created_by VARCHAR(50),
    updated_by VARCHAR(50),
    approved_by VARCHAR(50),
    version INT DEFAULT 1,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

INSERT INTO vendors (
    vendor_id,
    vendor_name,
    created_by,
    updated_by,
    approved_by,
    version,
    created_at,
    updated_at
)
SELECT
    vendor_id,
    MIN(vendor_name) AS vendor_name,       -- pick one among duplicates
    'system_user' AS created_by,
    'system_user' AS updated_by,
    'admin_user' AS approved_by,
    1 AS version,
    MIN(load_timestamp) AS created_at,
    MAX(load_timestamp) AS updated_at
FROM stg_vendors
GROUP BY vendor_id;

------SQL to create vendor golden table-----

CREATE TABLE vendors_golden AS
SELECT
    vendor_id,
    MAX(vendor_name) AS vendor_name,        -- choose longest name
    MIN(created_by) AS created_by,
    MAX(updated_by) AS updated_by,
    MAX(approved_by) AS approved_by,
    MAX(version) AS version,
    MIN(created_at) AS created_at,
    MAX(updated_at) AS updated_at
FROM vendors
GROUP BY vendor_id;
-----------------------------------------------
----create rate code staging table------

CREATE TABLE stg_rate_codes (
    rate_code_id INT,
    rate_description VARCHAR(100),
    source_system VARCHAR(50),
    load_timestamp TIMESTAMP DEFAULT NOW()
);


INSERT INTO stg_rate_codes (rate_code_id, rate_description, source_system)
VALUES
(1, 'Standard rate', 'TLC'),
(2, 'JFK', 'TLC'),
(3, 'Newark', 'TLC'),
(4, 'Nassau or Westchester', 'TLC'),
(5, 'Negotiated fare', 'TLC'),
(6, 'Group ride', 'TLC'),
(99, 'Null/unknown', 'TLC');



----Populate Rate Codes Master Table from Staging----

INSERT INTO rate_codes (
    rate_code_id,
    rate_description,
    created_by,
    updated_by,
    approved_by,
    version,
    created_at,
    updated_at
)
SELECT
    rate_code_id,
    MIN(rate_description) AS rate_description,
    'system_user' AS created_by,
    'system_user' AS updated_by,
    'admin_user' AS approved_by,
    1 AS version,
    MIN(load_timestamp) AS created_at,
    MAX(load_timestamp) AS updated_at
FROM stg_rate_codes
GROUP BY rate_code_id;

-----Create Rate Codes Golden Table with Survivorship Rules---

CREATE TABLE rate_codes_golden AS
SELECT
    rate_code_id,
    MAX(rate_description) AS rate_description,
    MIN(created_by) AS created_by,
    MAX(updated_by) AS updated_by,
    MAX(approved_by) AS approved_by,
    MAX(version) AS version,
    MIN(created_at) AS created_at,
    MAX(updated_at) AS updated_at
FROM rate_codes
GROUP BY rate_code_id;

-----Staging → Master (with audit columns) → Golden Record (with survivorship rules)----

SELECT COUNT(*) FROM taxi_zones_golden;
SELECT COUNT(*) FROM vendors_golden;
SELECT COUNT(*) FROM rate_codes_golden;








