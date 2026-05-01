-- =====================================================
-- DEALER: Vehicle models & units
-- =====================================================

CREATE TABLE dealer.vehicle_models (
    id              UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id       UUID        NOT NULL REFERENCES auth.tenants(id) ON DELETE RESTRICT,
    merek           VARCHAR(50) NOT NULL,
    model           VARCHAR(100) NOT NULL,
    tipe            VARCHAR(100),
    tahun_model     SMALLINT    NOT NULL,
    cc_mesin        SMALLINT,
    transmisi       VARCHAR(20),
    bahan_bakar     VARCHAR(20) NOT NULL DEFAULT 'Bensin',
    harga_otr       NUMERIC(15,0) NOT NULL,
    harga_hpp       NUMERIC(15,0),
    warna_tersedia  TEXT[]      NOT NULL DEFAULT '{}',
    foto_url        TEXT[],
    spesifikasi     JSONB,
    is_active       BOOLEAN     NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at      TIMESTAMPTZ
);

CREATE INDEX idx_vehicle_models_tenant      ON dealer.vehicle_models(tenant_id);
CREATE INDEX idx_vehicle_models_merek_model ON dealer.vehicle_models(merek, model);
CREATE INDEX idx_vehicle_models_active      ON dealer.vehicle_models(tenant_id, is_active) WHERE deleted_at IS NULL;

-- Vehicle units (physical stock)
CREATE TABLE dealer.vehicle_units (
    id              UUID                        PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id       UUID                        NOT NULL REFERENCES auth.tenants(id) ON DELETE RESTRICT,
    branch_id       UUID                        NOT NULL REFERENCES auth.branches(id) ON DELETE RESTRICT,
    model_id        UUID                        NOT NULL REFERENCES dealer.vehicle_models(id) ON DELETE RESTRICT,
    nomor_rangka    VARCHAR(50)                 NOT NULL UNIQUE,
    nomor_mesin     VARCHAR(50)                 NOT NULL UNIQUE,
    warna           VARCHAR(50)                 NOT NULL,
    tahun_rakit     SMALLINT                    NOT NULL,
    status          dealer.unit_status_enum     NOT NULL DEFAULT 'READY',
    harga_otr       NUMERIC(15,0)               NOT NULL,
    harga_hpp       NUMERIC(15,0),
    tanggal_masuk   DATE                        NOT NULL DEFAULT CURRENT_DATE,
    lokasi_gudang   VARCHAR(50),
    foto_url        TEXT[],
    catatan         TEXT,
    created_at      TIMESTAMPTZ                 NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ                 NOT NULL DEFAULT NOW(),
    deleted_at      TIMESTAMPTZ
);

CREATE INDEX idx_vehicle_units_tenant      ON dealer.vehicle_units(tenant_id);
CREATE INDEX idx_vehicle_units_branch      ON dealer.vehicle_units(branch_id);
CREATE INDEX idx_vehicle_units_model       ON dealer.vehicle_units(model_id);
CREATE INDEX idx_vehicle_units_status      ON dealer.vehicle_units(tenant_id, status) WHERE deleted_at IS NULL;
CREATE INDEX idx_vehicle_units_rangka      ON dealer.vehicle_units(nomor_rangka);

COMMENT ON TABLE dealer.vehicle_units IS 'Unit fisik kendaraan di stok. Tiap unit = 1 row unik by nomor rangka';
