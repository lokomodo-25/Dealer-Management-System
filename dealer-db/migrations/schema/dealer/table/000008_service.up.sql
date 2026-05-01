-- =====================================================
-- DEALER: Service — Bookings, Work Orders, Jobs, Parts
-- =====================================================

CREATE TABLE dealer.service_bookings (
    id              UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id       UUID        NOT NULL REFERENCES auth.tenants(id) ON DELETE RESTRICT,
    branch_id       UUID        NOT NULL REFERENCES auth.branches(id) ON DELETE RESTRICT,
    customer_id     UUID        NOT NULL REFERENCES dealer.customers(id) ON DELETE RESTRICT,
    unit_id         UUID        REFERENCES dealer.vehicle_units(id) ON DELETE SET NULL,
    nomor_polisi    VARCHAR(15),
    jenis_servis    VARCHAR(80) NOT NULL,
    keluhan         TEXT,
    scheduled_at    TIMESTAMPTZ NOT NULL,
    is_confirmed    BOOLEAN     NOT NULL DEFAULT FALSE,
    cancelled_at    TIMESTAMPTZ,
    cancel_reason   TEXT,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_bookings_tenant    ON dealer.service_bookings(tenant_id);
CREATE INDEX idx_bookings_branch    ON dealer.service_bookings(branch_id);
CREATE INDEX idx_bookings_scheduled ON dealer.service_bookings(branch_id, scheduled_at);

CREATE TABLE dealer.work_orders (
    id              UUID                    PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id       UUID                    NOT NULL REFERENCES auth.tenants(id) ON DELETE RESTRICT,
    branch_id       UUID                    NOT NULL REFERENCES auth.branches(id) ON DELETE RESTRICT,
    no_wo           VARCHAR(30)             NOT NULL UNIQUE,
    booking_id      UUID                    REFERENCES dealer.service_bookings(id) ON DELETE SET NULL,
    customer_id     UUID                    NOT NULL REFERENCES dealer.customers(id) ON DELETE RESTRICT,
    unit_id         UUID                    REFERENCES dealer.vehicle_units(id) ON DELETE SET NULL,
    nomor_polisi    VARCHAR(15),
    nomor_rangka    VARCHAR(50),
    km_masuk        INT                     NOT NULL DEFAULT 0,
    km_keluar       INT,
    status          dealer.wo_status_enum   NOT NULL DEFAULT 'ANTRIAN',
    jenis_servis    VARCHAR(80)             NOT NULL,
    keluhan         TEXT,
    diagnosa        TEXT,
    estimasi_selesai TIMESTAMPTZ,
    mulai_at        TIMESTAMPTZ,
    selesai_at      TIMESTAMPTZ,
    total_jasa      NUMERIC(15,0)           NOT NULL DEFAULT 0,
    total_parts     NUMERIC(15,0)           NOT NULL DEFAULT 0,
    total_invoice   NUMERIC(15,0)           NOT NULL DEFAULT 0,
    ppn_amount      NUMERIC(15,0)           NOT NULL DEFAULT 0,
    catatan_bengkel TEXT,
    created_by      UUID                    REFERENCES auth.users(id) ON DELETE SET NULL,
    created_at      TIMESTAMPTZ             NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ             NOT NULL DEFAULT NOW(),
    deleted_at      TIMESTAMPTZ
);

CREATE INDEX idx_wo_tenant  ON dealer.work_orders(tenant_id);
CREATE INDEX idx_wo_branch  ON dealer.work_orders(branch_id);
CREATE INDEX idx_wo_no      ON dealer.work_orders(no_wo);
CREATE INDEX idx_wo_status  ON dealer.work_orders(tenant_id, status) WHERE deleted_at IS NULL;
CREATE INDEX idx_wo_customer ON dealer.work_orders(customer_id);

-- WO jobs (per mekanik)
CREATE TABLE dealer.wo_jobs (
    id              UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
    wo_id           UUID        NOT NULL REFERENCES dealer.work_orders(id) ON DELETE CASCADE,
    mekanik_id      UUID        NOT NULL REFERENCES auth.users(id) ON DELETE RESTRICT,
    deskripsi       TEXT        NOT NULL,
    harga_jasa      NUMERIC(15,0) NOT NULL DEFAULT 0,
    durasi_menit    INT,
    selesai_at      TIMESTAMPTZ,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_wo_jobs_wo      ON dealer.wo_jobs(wo_id);
CREATE INDEX idx_wo_jobs_mekanik ON dealer.wo_jobs(mekanik_id);

-- WO parts usage
CREATE TABLE dealer.wo_parts (
    id          UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
    wo_id       UUID        NOT NULL REFERENCES dealer.work_orders(id) ON DELETE CASCADE,
    part_id     UUID        NOT NULL REFERENCES dealer.spare_parts(id) ON DELETE RESTRICT,
    qty         INT         NOT NULL,
    harga_satuan NUMERIC(15,0) NOT NULL,
    subtotal    NUMERIC(15,0) NOT NULL,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_wo_parts_wo   ON dealer.wo_parts(wo_id);
CREATE INDEX idx_wo_parts_part ON dealer.wo_parts(part_id);

-- Service rating (customer feedback post-WO)
CREATE TABLE dealer.service_ratings (
    id          UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
    wo_id       UUID        NOT NULL UNIQUE REFERENCES dealer.work_orders(id) ON DELETE CASCADE,
    customer_id UUID        NOT NULL REFERENCES dealer.customers(id) ON DELETE RESTRICT,
    rating      SMALLINT    NOT NULL CHECK (rating BETWEEN 1 AND 5),
    komentar    TEXT,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE dealer.wo_parts IS 'Insert ke tabel ini trigger deduct stock otomatis via wo_parts_deduct_stock';
