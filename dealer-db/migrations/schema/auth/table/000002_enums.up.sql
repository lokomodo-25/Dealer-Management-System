-- =====================================================
-- AUTH: Enum types
-- =====================================================

CREATE TYPE auth.subscription_plan_enum AS ENUM (
    'STARTER',
    'PROFESSIONAL',
    'ENTERPRISE'
);

CREATE TYPE auth.branch_type_enum AS ENUM (
    'SHOWROOM',
    'BENGKEL',
    'KEDUANYA'
);

CREATE TYPE auth.action_enum AS ENUM (
    'CREATE',
    'READ',
    'UPDATE',
    'DELETE',
    'EXPORT',
    'APPROVE'
);

CREATE TYPE auth.scope_enum AS ENUM (
    'ALL',
    'OWN_BRANCH',
    'OWN_DATA'
);

CREATE TYPE auth.role_code_enum AS ENUM (
    'SUPER_ADMIN',
    'ADMIN',
    'SALES_MANAGER',
    'SALES',
    'FINANCE',
    'SERVICE_MGR',
    'MEKANIK',
    'GUDANG',
    'HR',
    'VIEWER'
);

CREATE TYPE auth.employee_dept_enum AS ENUM (
    'SALES',
    'SERVICE',
    'FINANCE',
    'GUDANG',
    'HR',
    'ADMIN',
    'DIREKSI'
);
