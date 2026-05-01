-- =====================================================
-- DEALER: SPK (Surat Pesanan Kendaraan) & BAST
-- =====================================================

CREATE TABLE dealer.spk (
    id                  UUID                        PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id           UUID                        NOT NULL REFERENCES auth.tenants(id) ON DELETE RESTRICT,
    branch_id           UUID                        NOT NULL REFERENCES auth.branches(id) ON DELETE RESTRICT,
    no_spk              VARCHAR(30)                 NOT NULL UNIQUE,
    customer_id         UUID                        NOT NULL REFERENCES dealer.customers(id) ON DELETE RESTRICT,
    unit_id             UUID                        NOT NULL REFERENCES dealer.vehicle_units(id) ON DELETE RESTRICT,
    sales_id            UUID                        NOT NULL REFERENCES auth.users(id) ON DELETE RESTRICT,
    prospect_id         UUID                        REFERENCES dealer.prospects(id) ON DELETE SET NULL,
    status              dealer.spk_status_enum      NOT NULL DEFAULT 'DRAFT',
    metode_bayar        dealer.payment_method_enum  NOT NULL,
    harga_otr           NUMERIC(15,0)               NOT NULL,
    diskon              NUMERIC(15,0)               NOT NULL DEFAULT 0,
    harga_deal          NUMERIC(15,0)               NOT NULL,
    dp_amount           NUMERIC(15,0)               NOT NULL DEFAULT 0,
    dp_date             DATE,
    dp_proof_url        TEXT,
    leasing_company     VARCHAR(80),
    tenor_bulan         SMALLINT,
    angsuran_per_bulan  NUMERIC(15,0),
    catatan_approve     TEXT,
    approved_by         UUID                        REFERENCES auth.users(id) ON DELETE SET NULL,
    approved_at         TIMESTAMPTZ,
    cancelled_by        UUID                        REFERENCES auth.users(id) ON DELETE SET NULL,
    cancelled_at        TIMESTAMPTZ,
    cancel_reason       TEXT,
    created_at          TIMESTAMPTZ                 NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ                 NOT NULL DEFAULT NOW(),
    deleted_at          TIMESTAMPTZ
);

CREATE INDEX idx_spk_tenant     ON dealer.spk(tenant_id);
CREATE INDEX idx_spk_branch     ON dealer.spk(branch_id);
CREATE INDEX idx_spk_customer   ON dealer.spk(customer_id);
CREATE INDEX idx_spk_sales      ON dealer.spk(sales_id);
CREATE INDEX idx_spk_status     ON dealer.spk(tenant_id, status) WHERE deleted_at IS NULL;
CREATE INDEX idx_spk_no         ON dealer.spk(no_spk);

-- SPK accessories / bonus
CREATE TABLE dealer.spk_accessories (
    id          UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
    spk_id      UUID        NOT NULL REFERENCES dealer.spk(id) ON DELETE CASCADE,
    nama_item   VARCHAR(100) NOT NULL,
    qty         SMALLINT    NOT NULL DEFAULT 1,
    harga       NUMERIC(15,0) NOT NULL DEFAULT 0,
    is_gratis   BOOLEAN     NOT NULL DEFAULT FALSE,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_spk_acc_spk ON dealer.spk_accessories(spk_id);

-- BAST — Berita Acara Serah Terima
CREATE TABLE dealer.serah_terima (
    id              UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
    spk_id          UUID        NOT NULL UNIQUE REFERENCES dealer.spk(id) ON DELETE RESTRICT,
    tenant_id       UUID        NOT NULL REFERENCES auth.tenants(id) ON DELETE RESTRICT,
    branch_id       UUID        NOT NULL REFERENCES auth.branches(id) ON DELETE RESTRICT,
    no_bast         VARCHAR(30) NOT NULL UNIQUE,
    tanggal_serah   DATE        NOT NULL,
    km_serah        INT         NOT NULL DEFAULT 0,
    kondisi_unit    TEXT,
    -- Dokumen yang diserahkan
    bpkb_diserahkan     BOOLEAN NOT NULL DEFAULT FALSE,
    stnk_diserahkan     BOOLEAN NOT NULL DEFAULT FALSE,
    faktur_diserahkan   BOOLEAN NOT NULL DEFAULT FALSE,
    buku_servis         BOOLEAN NOT NULL DEFAULT FALSE,
    -- STNK info
    no_polisi       VARCHAR(15),
    no_stnk         VARCHAR(30),
    no_bpkb         VARCHAR(30),
    bpkb_estimasi_date DATE,
    -- Tanda tangan & foto
    ttd_customer_url    TEXT,
    ttd_sales_url       TEXT,
    foto_serah_url      TEXT[],
    delivered_by    UUID    REFERENCES auth.users(id) ON DELETE SET NULL,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_serah_terima_spk    ON dealer.serah_terima(spk_id);
CREATE INDEX idx_serah_terima_tenant ON dealer.serah_terima(tenant_id);
CREATE INDEX idx_serah_terima_no     ON dealer.serah_terima(no_bast);

COMMENT ON TABLE dealer.spk IS 'Surat Pesanan Kendaraan — kontrak jual beli unit';
COMMENT ON TABLE dealer.serah_terima IS 'BAST: trigger otomatis ubah unit→SOLD, customer.total_unit_beli++, SPK→SELESAI';
