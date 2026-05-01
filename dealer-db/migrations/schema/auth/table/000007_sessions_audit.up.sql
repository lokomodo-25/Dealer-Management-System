-- =====================================================
-- AUTH: User sessions & audit log
-- =====================================================

-- Sessions (JWT refresh token store)
CREATE TABLE auth.user_sessions (
    id              UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id         UUID        NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    tenant_id       UUID        NOT NULL REFERENCES auth.tenants(id) ON DELETE CASCADE,
    refresh_token   TEXT        NOT NULL UNIQUE,
    device_info     JSONB,
    ip_address      INET,
    user_agent      TEXT,
    expires_at      TIMESTAMPTZ NOT NULL,
    last_active_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    is_revoked      BOOLEAN     NOT NULL DEFAULT FALSE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_sessions_user_id       ON auth.user_sessions(user_id);
CREATE INDEX idx_sessions_tenant_id     ON auth.user_sessions(tenant_id);
CREATE INDEX idx_sessions_refresh_token ON auth.user_sessions(refresh_token);
CREATE INDEX idx_sessions_expires_at    ON auth.user_sessions(expires_at);
CREATE INDEX idx_sessions_active        ON auth.user_sessions(user_id, is_revoked, expires_at);

-- Audit log (partitioned by month for performance)
CREATE TABLE auth.audit_logs (
    id          UUID        NOT NULL DEFAULT uuid_generate_v4(),
    tenant_id   UUID        NOT NULL,
    user_id     UUID,
    branch_id   UUID,
    action      auth.action_enum NOT NULL,
    resource    VARCHAR(80) NOT NULL,
    resource_id UUID,
    old_data    JSONB,
    new_data    JSONB,
    ip_address  INET,
    user_agent  TEXT,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
) PARTITION BY RANGE (created_at);

-- Current month + next month partitions (more created by app on schedule)
CREATE TABLE auth.audit_logs_2025_01 PARTITION OF auth.audit_logs
    FOR VALUES FROM ('2025-01-01') TO ('2025-02-01');
CREATE TABLE auth.audit_logs_2025_02 PARTITION OF auth.audit_logs
    FOR VALUES FROM ('2025-02-01') TO ('2025-03-01');
CREATE TABLE auth.audit_logs_2025_03 PARTITION OF auth.audit_logs
    FOR VALUES FROM ('2025-03-01') TO ('2025-04-01');
CREATE TABLE auth.audit_logs_2025_04 PARTITION OF auth.audit_logs
    FOR VALUES FROM ('2025-04-01') TO ('2025-05-01');
CREATE TABLE auth.audit_logs_2025_05 PARTITION OF auth.audit_logs
    FOR VALUES FROM ('2025-05-01') TO ('2025-06-01');
CREATE TABLE auth.audit_logs_2025_06 PARTITION OF auth.audit_logs
    FOR VALUES FROM ('2025-06-01') TO ('2025-07-01');
CREATE TABLE auth.audit_logs_2025_07 PARTITION OF auth.audit_logs
    FOR VALUES FROM ('2025-07-01') TO ('2025-08-01');
CREATE TABLE auth.audit_logs_2025_08 PARTITION OF auth.audit_logs
    FOR VALUES FROM ('2025-08-01') TO ('2025-09-01');
CREATE TABLE auth.audit_logs_2025_09 PARTITION OF auth.audit_logs
    FOR VALUES FROM ('2025-09-01') TO ('2025-10-01');
CREATE TABLE auth.audit_logs_2025_10 PARTITION OF auth.audit_logs
    FOR VALUES FROM ('2025-10-01') TO ('2025-11-01');
CREATE TABLE auth.audit_logs_2025_11 PARTITION OF auth.audit_logs
    FOR VALUES FROM ('2025-11-01') TO ('2025-12-01');
CREATE TABLE auth.audit_logs_2025_12 PARTITION OF auth.audit_logs
    FOR VALUES FROM ('2025-12-01') TO ('2026-01-01');
CREATE TABLE auth.audit_logs_2026_01 PARTITION OF auth.audit_logs
    FOR VALUES FROM ('2026-01-01') TO ('2026-02-01');
CREATE TABLE auth.audit_logs_2026_02 PARTITION OF auth.audit_logs
    FOR VALUES FROM ('2026-02-01') TO ('2026-03-01');
CREATE TABLE auth.audit_logs_2026_03 PARTITION OF auth.audit_logs
    FOR VALUES FROM ('2026-03-01') TO ('2026-04-01');
CREATE TABLE auth.audit_logs_2026_04 PARTITION OF auth.audit_logs
    FOR VALUES FROM ('2026-04-01') TO ('2026-05-01');
CREATE TABLE auth.audit_logs_2026_05 PARTITION OF auth.audit_logs
    FOR VALUES FROM ('2026-05-01') TO ('2026-06-01');
CREATE TABLE auth.audit_logs_2026_06 PARTITION OF auth.audit_logs
    FOR VALUES FROM ('2026-06-01') TO ('2026-07-01');
CREATE TABLE auth.audit_logs_2026_12 PARTITION OF auth.audit_logs
    FOR VALUES FROM ('2026-12-01') TO ('2027-01-01');
-- Default partition catches anything outside defined ranges
CREATE TABLE auth.audit_logs_default PARTITION OF auth.audit_logs DEFAULT;

CREATE INDEX idx_audit_logs_tenant_id   ON auth.audit_logs(tenant_id, created_at);
CREATE INDEX idx_audit_logs_user_id     ON auth.audit_logs(user_id, created_at);
CREATE INDEX idx_audit_logs_resource    ON auth.audit_logs(resource, resource_id);

COMMENT ON TABLE auth.audit_logs IS 'Partitioned audit trail — partisi baru dibuat tiap bulan via cron/app';
