-- =====================================================
-- AUTH: Users
-- =====================================================

CREATE TABLE auth.users (
    id                  UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id           UUID        NOT NULL REFERENCES auth.tenants(id) ON DELETE RESTRICT,
    email               VARCHAR(150) NOT NULL,
    password_hash       TEXT        NOT NULL,
    full_name           VARCHAR(100) NOT NULL,
    phone               VARCHAR(20),
    avatar_url          TEXT,
    is_active           BOOLEAN     NOT NULL DEFAULT TRUE,
    is_verified         BOOLEAN     NOT NULL DEFAULT FALSE,
    last_login_at       TIMESTAMPTZ,
    failed_login_count  SMALLINT    NOT NULL DEFAULT 0,
    locked_until        TIMESTAMPTZ,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at          TIMESTAMPTZ,
    UNIQUE(tenant_id, email)
);

CREATE INDEX idx_users_tenant_id    ON auth.users(tenant_id);
CREATE INDEX idx_users_email        ON auth.users(email);
CREATE INDEX idx_users_is_active    ON auth.users(tenant_id, is_active) WHERE deleted_at IS NULL;
CREATE INDEX idx_users_deleted_at   ON auth.users(deleted_at);

COMMENT ON TABLE auth.users IS 'User internal dealer — email unik per tenant';
COMMENT ON COLUMN auth.users.locked_until IS 'NULL = tidak terkunci. Terisi jika failed_login_count >= 5';
