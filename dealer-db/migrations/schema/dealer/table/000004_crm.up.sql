-- =====================================================
-- DEALER: CRM — Customers, Prospects, Activities, Test Drives
-- =====================================================

CREATE TABLE dealer.customers (
    id                  UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id           UUID        NOT NULL REFERENCES auth.tenants(id) ON DELETE RESTRICT,
    branch_id           UUID        NOT NULL REFERENCES auth.branches(id) ON DELETE RESTRICT,
    nama_lengkap        VARCHAR(100) NOT NULL,
    nik                 VARCHAR(20),
    telepon             VARCHAR(20)  NOT NULL,
    email               VARCHAR(100),
    alamat              TEXT,
    kota                VARCHAR(50),
    provinsi            VARCHAR(50),
    tanggal_lahir       DATE,
    pekerjaan           VARCHAR(80),
    total_unit_beli     SMALLINT    NOT NULL DEFAULT 0,
    is_blacklisted      BOOLEAN     NOT NULL DEFAULT FALSE,
    blacklist_reason    TEXT,
    catatan             TEXT,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at          TIMESTAMPTZ
);

CREATE INDEX idx_customers_tenant      ON dealer.customers(tenant_id);
CREATE INDEX idx_customers_branch      ON dealer.customers(branch_id);
CREATE INDEX idx_customers_nik         ON dealer.customers(nik) WHERE nik IS NOT NULL;
CREATE INDEX idx_customers_telepon     ON dealer.customers(telepon);
CREATE INDEX idx_customers_search      ON dealer.customers USING gin(to_tsvector('indonesian', nama_lengkap || ' ' || COALESCE(telepon,'') || ' ' || COALESCE(nik,'')));

CREATE TABLE dealer.prospects (
    id                  UUID                        PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id           UUID                        NOT NULL REFERENCES auth.tenants(id) ON DELETE RESTRICT,
    branch_id           UUID                        NOT NULL REFERENCES auth.branches(id) ON DELETE RESTRICT,
    customer_id         UUID                        REFERENCES dealer.customers(id) ON DELETE SET NULL,
    sales_id            UUID                        NOT NULL REFERENCES auth.users(id) ON DELETE RESTRICT,
    no_prospect         VARCHAR(30)                 NOT NULL UNIQUE,
    stage               dealer.prospect_stage_enum  NOT NULL DEFAULT 'COLD',
    model_minat_id      UUID                        REFERENCES dealer.vehicle_models(id) ON DELETE SET NULL,
    warna_minat         VARCHAR(50),
    metode_bayar        dealer.payment_method_enum,
    estimasi_dp         NUMERIC(15,0),
    tenor_bulan         SMALLINT,
    target_closing_date DATE,
    lost_reason         TEXT,
    lost_competitor     VARCHAR(100),
    next_followup_at    TIMESTAMPTZ,
    catatan             TEXT,
    created_at          TIMESTAMPTZ                 NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ                 NOT NULL DEFAULT NOW(),
    deleted_at          TIMESTAMPTZ
);

CREATE INDEX idx_prospects_tenant     ON dealer.prospects(tenant_id);
CREATE INDEX idx_prospects_branch     ON dealer.prospects(branch_id);
CREATE INDEX idx_prospects_sales      ON dealer.prospects(sales_id);
CREATE INDEX idx_prospects_stage      ON dealer.prospects(tenant_id, stage) WHERE deleted_at IS NULL;
CREATE INDEX idx_prospects_followup   ON dealer.prospects(next_followup_at) WHERE stage NOT IN ('SERAH','LOST') AND deleted_at IS NULL;

CREATE TABLE dealer.prospect_activities (
    id              UUID                        PRIMARY KEY DEFAULT uuid_generate_v4(),
    prospect_id     UUID                        NOT NULL REFERENCES dealer.prospects(id) ON DELETE CASCADE,
    user_id         UUID                        NOT NULL REFERENCES auth.users(id) ON DELETE RESTRICT,
    activity_type   dealer.activity_type_enum   NOT NULL,
    catatan         TEXT,
    next_followup_at TIMESTAMPTZ,
    created_at      TIMESTAMPTZ                 NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_activities_prospect ON dealer.prospect_activities(prospect_id);
CREATE INDEX idx_activities_created  ON dealer.prospect_activities(prospect_id, created_at DESC);

CREATE TABLE dealer.test_drives (
    id              UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
    prospect_id     UUID        NOT NULL REFERENCES dealer.prospects(id) ON DELETE CASCADE,
    unit_id         UUID        REFERENCES dealer.vehicle_units(id) ON DELETE SET NULL,
    sales_id        UUID        NOT NULL REFERENCES auth.users(id) ON DELETE RESTRICT,
    scheduled_at    TIMESTAMPTZ NOT NULL,
    completed_at    TIMESTAMPTZ,
    rating          SMALLINT    CHECK (rating BETWEEN 1 AND 5),
    feedback        TEXT,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_test_drives_prospect  ON dealer.test_drives(prospect_id);
CREATE INDEX idx_test_drives_scheduled ON dealer.test_drives(scheduled_at);

COMMENT ON TABLE dealer.prospects IS 'Pipeline CRM: COLD→WARM→HOT→SPK→SERAH→LOST';
COMMENT ON COLUMN dealer.customers.total_unit_beli IS 'Auto-increment via trigger saat serah_terima selesai';
