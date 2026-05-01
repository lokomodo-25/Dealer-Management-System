-- =====================================================
-- AUTH: Tenants (Dealer / Perusahaan)
-- =====================================================

CREATE TABLE auth.tenants (
    id                  UUID            PRIMARY KEY DEFAULT uuid_generate_v4(),
    kode_dealer         VARCHAR(20)     NOT NULL UNIQUE,
    nama_dealer         VARCHAR(150)    NOT NULL,
    nama_pt             VARCHAR(200),
    npwp                VARCHAR(20),
    pkp_number          VARCHAR(30),
    merek_kendaraan     TEXT[]          NOT NULL DEFAULT '{}',
    subscription_plan   auth.subscription_plan_enum NOT NULL DEFAULT 'STARTER',
    subscription_exp    DATE,
    max_users           SMALLINT        NOT NULL DEFAULT 10,
    max_branches        SMALLINT        NOT NULL DEFAULT 3,
    logo_url            TEXT,
    timezone            VARCHAR(50)     NOT NULL DEFAULT 'Asia/Jakarta',
    wa_api_key          TEXT,
    wa_sender_number    VARCHAR(20),
    is_active           BOOLEAN         NOT NULL DEFAULT TRUE,
    created_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    deleted_at          TIMESTAMPTZ
);

CREATE INDEX idx_tenants_kode_dealer    ON auth.tenants(kode_dealer);
CREATE INDEX idx_tenants_is_active      ON auth.tenants(is_active) WHERE deleted_at IS NULL;
CREATE INDEX idx_tenants_deleted_at     ON auth.tenants(deleted_at);

COMMENT ON TABLE auth.tenants IS 'Dealer/perusahaan — satu tenant = satu dealer group';
