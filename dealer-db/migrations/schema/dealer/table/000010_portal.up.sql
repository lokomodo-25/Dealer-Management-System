-- =====================================================
-- DEALER: Customer Portal — Tracking, Notifications, Feedback
-- =====================================================

-- Customer portal accounts (login via OTP)
CREATE TABLE dealer.customer_portal_accounts (
    id              UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
    customer_id     UUID        NOT NULL UNIQUE REFERENCES dealer.customers(id) ON DELETE CASCADE,
    telepon         VARCHAR(20) NOT NULL UNIQUE,
    otp_code        VARCHAR(10),
    otp_expires_at  TIMESTAMPTZ,
    last_login_at   TIMESTAMPTZ,
    is_active       BOOLEAN     NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_portal_accounts_telepon ON dealer.customer_portal_accounts(telepon);

-- Order tracking (per-SPK)
CREATE TABLE dealer.order_tracking (
    id              UUID                        PRIMARY KEY DEFAULT uuid_generate_v4(),
    spk_id          UUID                        NOT NULL UNIQUE REFERENCES dealer.spk(id) ON DELETE CASCADE,
    tenant_id       UUID                        NOT NULL REFERENCES auth.tenants(id) ON DELETE RESTRICT,
    tracking_token  VARCHAR(64)                 NOT NULL UNIQUE,
    tracking_type   dealer.tracking_type_enum   NOT NULL DEFAULT 'READY_STOCK',
    current_stage   dealer.tracking_stage_enum  NOT NULL DEFAULT 'SPK_DIBUAT',
    progress_pct    SMALLINT                    NOT NULL DEFAULT 0 CHECK (progress_pct BETWEEN 0 AND 100),
    estimasi_selesai DATE,
    is_completed    BOOLEAN                     NOT NULL DEFAULT FALSE,
    completed_at    TIMESTAMPTZ,
    created_at      TIMESTAMPTZ                 NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ                 NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_order_tracking_spk   ON dealer.order_tracking(spk_id);
CREATE INDEX idx_order_tracking_token ON dealer.order_tracking(tracking_token);
CREATE INDEX idx_order_tracking_tenant ON dealer.order_tracking(tenant_id, is_completed);

-- Tracking stage history
CREATE TABLE dealer.tracking_stage_logs (
    id          UUID                        PRIMARY KEY DEFAULT uuid_generate_v4(),
    tracking_id UUID                        NOT NULL REFERENCES dealer.order_tracking(id) ON DELETE CASCADE,
    stage       dealer.tracking_stage_enum  NOT NULL,
    catatan     TEXT,
    created_by  UUID                        REFERENCES auth.users(id) ON DELETE SET NULL,
    created_at  TIMESTAMPTZ                 NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_stage_logs_tracking ON dealer.tracking_stage_logs(tracking_id, created_at DESC);

-- PO/Indent tracking details
CREATE TABLE dealer.po_indent_tracking (
    id                  UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
    tracking_id         UUID        NOT NULL UNIQUE REFERENCES dealer.order_tracking(id) ON DELETE CASCADE,
    no_po_atpm          VARCHAR(50),
    tanggal_po_kirim    DATE,
    tanggal_konfirmasi  DATE,
    estimasi_produksi   DATE,
    estimasi_tiba       DATE,
    tanggal_tiba        DATE,
    catatan_atpm        TEXT,
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Tracking document links (BPKB, STNK, etc.)
CREATE TABLE dealer.tracking_document_links (
    id              UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
    tracking_id     UUID        NOT NULL REFERENCES dealer.order_tracking(id) ON DELETE CASCADE,
    nama_dokumen    VARCHAR(80) NOT NULL,
    dokumen_url     TEXT        NOT NULL,
    is_public       BOOLEAN     NOT NULL DEFAULT FALSE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_doc_links_tracking ON dealer.tracking_document_links(tracking_id);

-- Notification templates
CREATE TABLE dealer.notification_templates (
    id          UUID                                PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id   UUID                                NOT NULL REFERENCES auth.tenants(id) ON DELETE CASCADE,
    kode        VARCHAR(50)                         NOT NULL,
    channel     dealer.notification_channel_enum    NOT NULL,
    judul       VARCHAR(150),
    body_template TEXT                              NOT NULL,
    is_active   BOOLEAN                             NOT NULL DEFAULT TRUE,
    created_at  TIMESTAMPTZ                         NOT NULL DEFAULT NOW(),
    UNIQUE(tenant_id, kode, channel)
);

CREATE INDEX idx_notif_templates_tenant ON dealer.notification_templates(tenant_id);

-- Notification queue
CREATE TABLE dealer.customer_notifications (
    id              UUID                                    PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id       UUID                                    NOT NULL REFERENCES auth.tenants(id) ON DELETE RESTRICT,
    customer_id     UUID                                    NOT NULL REFERENCES dealer.customers(id) ON DELETE CASCADE,
    template_id     UUID                                    REFERENCES dealer.notification_templates(id) ON DELETE SET NULL,
    channel         dealer.notification_channel_enum        NOT NULL,
    recipient       VARCHAR(100)                            NOT NULL,
    judul           VARCHAR(150),
    body            TEXT                                    NOT NULL,
    status          dealer.notification_status_enum         NOT NULL DEFAULT 'PENDING',
    sent_at         TIMESTAMPTZ,
    error_message   TEXT,
    retry_count     SMALLINT                                NOT NULL DEFAULT 0,
    created_at      TIMESTAMPTZ                             NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_notifications_pending  ON dealer.customer_notifications(status, created_at) WHERE status = 'PENDING';
CREATE INDEX idx_notifications_customer ON dealer.customer_notifications(customer_id);
CREATE INDEX idx_notifications_tenant   ON dealer.customer_notifications(tenant_id, created_at DESC);

-- Customer feedback (NPS/CSAT)
CREATE TABLE dealer.customer_feedback (
    id              UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
    spk_id          UUID        REFERENCES dealer.spk(id) ON DELETE SET NULL,
    customer_id     UUID        NOT NULL REFERENCES dealer.customers(id) ON DELETE CASCADE,
    tenant_id       UUID        NOT NULL REFERENCES auth.tenants(id) ON DELETE RESTRICT,
    nps_score       SMALLINT    CHECK (nps_score BETWEEN 0 AND 10),
    csat_score      SMALLINT    CHECK (csat_score BETWEEN 1 AND 5),
    komentar        TEXT,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_feedback_tenant   ON dealer.customer_feedback(tenant_id, created_at DESC);
CREATE INDEX idx_feedback_customer ON dealer.customer_feedback(customer_id);

-- Service reminders (auto-generated)
CREATE TABLE dealer.service_reminders (
    id              UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
    customer_id     UUID        NOT NULL REFERENCES dealer.customers(id) ON DELETE CASCADE,
    tenant_id       UUID        NOT NULL REFERENCES auth.tenants(id) ON DELETE RESTRICT,
    unit_id         UUID        REFERENCES dealer.vehicle_units(id) ON DELETE SET NULL,
    jenis_servis    VARCHAR(80) NOT NULL DEFAULT 'Service Berkala',
    scheduled_date  DATE        NOT NULL,
    notified_at     TIMESTAMPTZ,
    is_booked       BOOLEAN     NOT NULL DEFAULT FALSE,
    booking_id      UUID        REFERENCES dealer.service_bookings(id) ON DELETE SET NULL,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_reminders_scheduled ON dealer.service_reminders(scheduled_date) WHERE notified_at IS NULL;
CREATE INDEX idx_reminders_customer  ON dealer.service_reminders(customer_id);

COMMENT ON TABLE dealer.order_tracking IS 'READY_STOCK: 5 stage. PO_INDENT: 9 stage (tambah PO→ATPM→produksi→tiba)';
COMMENT ON TABLE dealer.customer_notifications IS 'Queue untuk background job WA/Email/Push sender';
