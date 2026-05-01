-- =====================================================
-- DEALER: Inventory — Spare Parts & Stock
-- =====================================================

CREATE TABLE dealer.spare_parts (
    id              UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id       UUID        NOT NULL REFERENCES auth.tenants(id) ON DELETE RESTRICT,
    kode_part       VARCHAR(50) NOT NULL,
    nama_part       VARCHAR(100) NOT NULL,
    satuan          VARCHAR(20)  NOT NULL DEFAULT 'pcs',
    harga_beli      NUMERIC(15,0) NOT NULL DEFAULT 0,
    harga_jual      NUMERIC(15,0) NOT NULL DEFAULT 0,
    is_active       BOOLEAN      NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    deleted_at      TIMESTAMPTZ,
    UNIQUE(tenant_id, kode_part)
);

CREATE INDEX idx_spare_parts_tenant ON dealer.spare_parts(tenant_id);
CREATE INDEX idx_spare_parts_kode   ON dealer.spare_parts(kode_part);

-- Stock per-branch
CREATE TABLE dealer.part_stocks (
    id              UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
    part_id         UUID        NOT NULL REFERENCES dealer.spare_parts(id) ON DELETE CASCADE,
    branch_id       UUID        NOT NULL REFERENCES auth.branches(id) ON DELETE RESTRICT,
    tenant_id       UUID        NOT NULL REFERENCES auth.tenants(id) ON DELETE RESTRICT,
    qty_on_hand     INT         NOT NULL DEFAULT 0,
    qty_reserved    INT         NOT NULL DEFAULT 0,
    reorder_point   INT         NOT NULL DEFAULT 5,
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(part_id, branch_id)
);

CREATE INDEX idx_part_stocks_branch ON dealer.part_stocks(branch_id);
CREATE INDEX idx_part_stocks_part   ON dealer.part_stocks(part_id);
CREATE INDEX idx_part_stocks_low    ON dealer.part_stocks(branch_id) WHERE qty_on_hand <= reorder_point;

-- Stock movement log
CREATE TABLE dealer.stock_movements (
    id              UUID                                PRIMARY KEY DEFAULT uuid_generate_v4(),
    part_id         UUID                                NOT NULL REFERENCES dealer.spare_parts(id) ON DELETE RESTRICT,
    branch_id       UUID                                NOT NULL REFERENCES auth.branches(id) ON DELETE RESTRICT,
    tenant_id       UUID                                NOT NULL REFERENCES auth.tenants(id) ON DELETE RESTRICT,
    movement_type   dealer.stock_movement_type_enum     NOT NULL,
    qty             INT                                 NOT NULL,
    qty_before      INT                                 NOT NULL,
    qty_after       INT                                 NOT NULL,
    reference_type  VARCHAR(30),
    reference_id    UUID,
    catatan         TEXT,
    created_by      UUID                                REFERENCES auth.users(id) ON DELETE SET NULL,
    created_at      TIMESTAMPTZ                         NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_stock_movements_part   ON dealer.stock_movements(part_id, created_at DESC);
CREATE INDEX idx_stock_movements_branch ON dealer.stock_movements(branch_id, created_at DESC);
CREATE INDEX idx_stock_movements_ref    ON dealer.stock_movements(reference_type, reference_id);

COMMENT ON COLUMN dealer.stock_movements.reference_type IS 'work_order | purchase_order | adjustment';
COMMENT ON COLUMN dealer.part_stocks.qty_reserved IS 'Reserved untuk WO yang masih berjalan';
