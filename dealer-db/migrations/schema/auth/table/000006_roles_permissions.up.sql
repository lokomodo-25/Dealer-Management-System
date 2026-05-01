-- =====================================================
-- AUTH: Roles, Permissions, RBAC assignment
-- =====================================================

-- Roles (tenant-scoped)
CREATE TABLE auth.roles (
    id              UUID                    PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id       UUID                    REFERENCES auth.tenants(id) ON DELETE CASCADE,
    role_code       auth.role_code_enum     NOT NULL,
    role_name       VARCHAR(80)             NOT NULL,
    description     TEXT,
    is_system       BOOLEAN                 NOT NULL DEFAULT FALSE,
    is_active       BOOLEAN                 NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMPTZ             NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ             NOT NULL DEFAULT NOW(),
    -- NULL tenant_id = system role, visible to all tenants
    UNIQUE(tenant_id, role_code)
);

CREATE INDEX idx_roles_tenant_id    ON auth.roles(tenant_id);
CREATE INDEX idx_roles_role_code    ON auth.roles(role_code);
CREATE INDEX idx_roles_is_system    ON auth.roles(is_system);

-- Permission actions per resource
CREATE TABLE auth.permissions (
    id              UUID                PRIMARY KEY DEFAULT uuid_generate_v4(),
    resource        VARCHAR(80)         NOT NULL,
    action          auth.action_enum    NOT NULL,
    scope           auth.scope_enum     NOT NULL DEFAULT 'ALL',
    description     TEXT,
    created_at      TIMESTAMPTZ         NOT NULL DEFAULT NOW(),
    UNIQUE(resource, action, scope)
);

CREATE INDEX idx_permissions_resource ON auth.permissions(resource);

-- Role ↔ Permission mapping
CREATE TABLE auth.role_permissions (
    role_id         UUID    NOT NULL REFERENCES auth.roles(id) ON DELETE CASCADE,
    permission_id   UUID    NOT NULL REFERENCES auth.permissions(id) ON DELETE CASCADE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (role_id, permission_id)
);

CREATE INDEX idx_role_permissions_role_id       ON auth.role_permissions(role_id);
CREATE INDEX idx_role_permissions_permission_id ON auth.role_permissions(permission_id);

-- User ↔ Branch ↔ Role assignment
-- branch_id NULL = akses semua cabang dalam tenant
CREATE TABLE auth.user_branch_roles (
    id          UUID    PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id     UUID    NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    branch_id   UUID    REFERENCES auth.branches(id) ON DELETE CASCADE,
    role_id     UUID    NOT NULL REFERENCES auth.roles(id) ON DELETE RESTRICT,
    assigned_by UUID    REFERENCES auth.users(id) ON DELETE SET NULL,
    assigned_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(user_id, branch_id, role_id)
);

CREATE INDEX idx_ubr_user_id    ON auth.user_branch_roles(user_id);
CREATE INDEX idx_ubr_branch_id  ON auth.user_branch_roles(branch_id);
CREATE INDEX idx_ubr_role_id    ON auth.user_branch_roles(role_id);

COMMENT ON COLUMN auth.user_branch_roles.branch_id IS 'NULL = akses semua cabang dalam tenant (role global)';
