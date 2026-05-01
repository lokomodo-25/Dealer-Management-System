-- =====================================================
-- DEALER: Finance — Leasing, Invoices, Commission
-- =====================================================

CREATE TABLE dealer.financing_applications (
    id                  UUID                            PRIMARY KEY DEFAULT uuid_generate_v4(),
    spk_id              UUID                            NOT NULL REFERENCES dealer.spk(id) ON DELETE RESTRICT,
    tenant_id           UUID                            NOT NULL REFERENCES auth.tenants(id) ON DELETE RESTRICT,
    branch_id           UUID                            NOT NULL REFERENCES auth.branches(id) ON DELETE RESTRICT,
    leasing_company     VARCHAR(80)                     NOT NULL,
    no_pengajuan        VARCHAR(50),
    status              dealer.financing_status_enum    NOT NULL DEFAULT 'DRAFT',
    otr_amount          NUMERIC(15,0)                   NOT NULL,
    dp_amount           NUMERIC(15,0)                   NOT NULL,
    pokok_pinjaman      NUMERIC(15,0)                   NOT NULL,
    tenor_bulan         SMALLINT                        NOT NULL,
    bunga_persen        NUMERIC(5,2)                    NOT NULL DEFAULT 0,
    angsuran_per_bulan  NUMERIC(15,0)                   NOT NULL,
    tanggal_pengajuan   DATE,
    tanggal_survey      DATE,
    tanggal_approved    DATE,
    tanggal_cair        DATE,
    surveyor_name       VARCHAR(100),
    reject_reason       TEXT,
    catatan             TEXT,
    created_at          TIMESTAMPTZ                     NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ                     NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_financing_spk    ON dealer.financing_applications(spk_id);
CREATE INDEX idx_financing_tenant ON dealer.financing_applications(tenant_id);
CREATE INDEX idx_financing_status ON dealer.financing_applications(tenant_id, status);

-- Invoices
CREATE TABLE dealer.invoices (
    id              UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
    spk_id          UUID        NOT NULL UNIQUE REFERENCES dealer.spk(id) ON DELETE RESTRICT,
    tenant_id       UUID        NOT NULL REFERENCES auth.tenants(id) ON DELETE RESTRICT,
    branch_id       UUID        NOT NULL REFERENCES auth.branches(id) ON DELETE RESTRICT,
    no_invoice      VARCHAR(30) NOT NULL UNIQUE,
    subtotal        NUMERIC(15,0) NOT NULL,
    ppn_persen      NUMERIC(5,2)  NOT NULL DEFAULT 11,
    ppn_amount      NUMERIC(15,0) NOT NULL,
    total           NUMERIC(15,0) NOT NULL,
    tanggal_invoice DATE          NOT NULL DEFAULT CURRENT_DATE,
    tanggal_bayar   DATE,
    pdf_url         TEXT,
    created_at      TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ   NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_invoices_tenant ON dealer.invoices(tenant_id);
CREATE INDEX idx_invoices_no     ON dealer.invoices(no_invoice);

-- Commission rules (per model / global)
CREATE TABLE dealer.commission_rules (
    id              UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id       UUID        NOT NULL REFERENCES auth.tenants(id) ON DELETE RESTRICT,
    model_id        UUID        REFERENCES dealer.vehicle_models(id) ON DELETE CASCADE,
    metode_bayar    dealer.payment_method_enum,
    komisi_persen   NUMERIC(5,2) NOT NULL DEFAULT 0,
    komisi_flat     NUMERIC(15,0) NOT NULL DEFAULT 0,
    berlaku_mulai   DATE          NOT NULL DEFAULT CURRENT_DATE,
    berlaku_sampai  DATE,
    is_active       BOOLEAN       NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMPTZ   NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_comm_rules_tenant ON dealer.commission_rules(tenant_id);
CREATE INDEX idx_comm_rules_model  ON dealer.commission_rules(model_id);

-- Commission ledger (per-SPK)
CREATE TABLE dealer.commission_ledger (
    id              UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
    spk_id          UUID        NOT NULL REFERENCES dealer.spk(id) ON DELETE RESTRICT,
    sales_id        UUID        NOT NULL REFERENCES auth.users(id) ON DELETE RESTRICT,
    tenant_id       UUID        NOT NULL REFERENCES auth.tenants(id) ON DELETE RESTRICT,
    gross_komisi    NUMERIC(15,0) NOT NULL,
    pph21_persen    NUMERIC(5,2)  NOT NULL DEFAULT 5,
    pph21_amount    NUMERIC(15,0) NOT NULL DEFAULT 0,
    net_komisi      NUMERIC(15,0) NOT NULL,
    is_approved     BOOLEAN       NOT NULL DEFAULT FALSE,
    approved_by     UUID          REFERENCES auth.users(id) ON DELETE SET NULL,
    approved_at     TIMESTAMPTZ,
    paid_at         TIMESTAMPTZ,
    created_at      TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ   NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_comm_ledger_sales  ON dealer.commission_ledger(sales_id);
CREATE INDEX idx_comm_ledger_spk    ON dealer.commission_ledger(spk_id);
CREATE INDEX idx_comm_ledger_tenant ON dealer.commission_ledger(tenant_id);

COMMENT ON TABLE dealer.commission_ledger IS 'Komisi per-SPK. PPh 21 dipotong otomatis dari gross komisi sales';
