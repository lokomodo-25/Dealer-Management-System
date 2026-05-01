-- =====================================================
-- AUTH: Branches (Cabang / Lokasi Dealer)
-- =====================================================

CREATE TABLE auth.branches (
    id              UUID                    PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id       UUID                    NOT NULL REFERENCES auth.tenants(id) ON DELETE RESTRICT,
    kode_cabang     VARCHAR(20)             NOT NULL,
    nama_cabang     VARCHAR(100)            NOT NULL,
    tipe            auth.branch_type_enum   NOT NULL DEFAULT 'KEDUANYA',
    alamat          TEXT,
    kota            VARCHAR(50),
    provinsi        VARCHAR(50),
    kode_pos        VARCHAR(10),
    telepon         VARCHAR(20),
    email_cabang    VARCHAR(100),
    koordinat_lat   DECIMAL(10,7),
    koordinat_lng   DECIMAL(10,7),
    is_active       BOOLEAN                 NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMPTZ             NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ             NOT NULL DEFAULT NOW(),
    deleted_at      TIMESTAMPTZ,
    UNIQUE(tenant_id, kode_cabang)
);

CREATE INDEX idx_branches_tenant_id     ON auth.branches(tenant_id);
CREATE INDEX idx_branches_kode_cabang   ON auth.branches(kode_cabang);
CREATE INDEX idx_branches_is_active     ON auth.branches(tenant_id, is_active) WHERE deleted_at IS NULL;

COMMENT ON TABLE auth.branches IS 'Cabang dealer dalam satu tenant';
COMMENT ON COLUMN auth.branches.kode_cabang IS 'Kode unik per-tenant, dipakai sebagai prefix dokumen (BDG, JKT, dll)';
