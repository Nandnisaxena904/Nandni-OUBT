-- Create schema for master data
CREATE SCHEMA IF NOT EXISTS mdm;

-- Create schema for audit & version tracking
CREATE SCHEMA IF NOT EXISTS audit;

SELECT schema_name
FROM information_schema.schemata
WHERE schema_name IN ('mdm', 'audit');

----
CREATE TABLE IF NOT EXISTS mdm.dim_vendor_stage (
    vendor_id        INT            NOT NULL,
    vendor_name      VARCHAR(255),
    contact_email    VARCHAR(255),
    active_flag      BOOLEAN,
    source_system    VARCHAR(50),
    batch_id         VARCHAR(50),
    load_date        TIMESTAMP       DEFAULT CURRENT_TIMESTAMP
);

describe table mdm.dim_vendor_stage;

--------
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_schema = 'mdm'
  AND table_name = 'dim_vendor_stage'
ORDER BY ordinal_position;

-------------Create SCD table----

CREATE TABLE IF NOT EXISTS mdm.dim_vendor_scd (
    vendor_sk              BIGSERIAL PRIMARY KEY,
    vendor_id              BIGINT      NOT NULL,

    vendor_name            VARCHAR(255),
    contact_email          VARCHAR(255),
    active_flag            BOOLEAN,

    effective_start_date   TIMESTAMP   NOT NULL,
    effective_end_date     TIMESTAMP,
    is_current             BOOLEAN     NOT NULL DEFAULT TRUE,
    version                INT         NOT NULL,

    approval_status        VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    approved_by            VARCHAR(100),
    approved_at            TIMESTAMP,
    approval_reason        VARCHAR(255),

    source_system          VARCHAR(50),
    batch_id               VARCHAR(50),

    created_at             TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at             TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP
);

SELECT column_name, data_type
FROM information_schema.columns
WHERE table_schema = 'mdm'
  AND table_name = 'dim_vendor_scd'
ORDER BY ordinal_position;

------Unique Version per Business Key
ALTER TABLE mdm.dim_vendor_scd
ADD CONSTRAINT uq_vendor_version
UNIQUE (vendor_id, version);

----PostgreSQL partial unique index
CREATE UNIQUE INDEX uq_vendor_current
ON mdm.dim_vendor_scd (vendor_id)
WHERE is_current = TRUE;

--Effective Date Validity
ALTER TABLE mdm.dim_vendor_scd
ADD CONSTRAINT chk_effective_dates
CHECK (
    effective_end_date IS NULL
    OR effective_start_date < effective_end_date
);

---Current Record Lookup
CREATE INDEX idx_vendor_current_lookup
ON mdm.dim_vendor_scd (vendor_id, is_current);

---Historical Version Lookup
CREATE INDEX idx_vendor_version_lookup
ON mdm.dim_vendor_scd (vendor_id, version);

--Approval Workflow Lookup
CREATE INDEX idx_vendor_approval_status
ON mdm.dim_vendor_scd (approval_status);

---Verify Constraints & Indexes
SELECT conname, contype
FROM pg_constraint
WHERE conrelid = 'mdm.dim_vendor_scd'::regclass;

SELECT indexname
FROM pg_indexes
WHERE schemaname = 'mdm'
  AND tablename = 'dim_vendor_scd';




