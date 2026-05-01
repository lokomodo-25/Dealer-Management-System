-- =====================================================
-- DEALER: HR — Employees, Sales Targets, Attendance
-- =====================================================

CREATE TABLE dealer.employees (
    id              UUID                        PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id       UUID                        NOT NULL REFERENCES auth.tenants(id) ON DELETE RESTRICT,
    branch_id       UUID                        NOT NULL REFERENCES auth.branches(id) ON DELETE RESTRICT,
    user_id         UUID                        UNIQUE REFERENCES auth.users(id) ON DELETE SET NULL,
    nik_karyawan    VARCHAR(20)                 NOT NULL UNIQUE,
    nama_lengkap    VARCHAR(100)                NOT NULL,
    departemen      auth.employee_dept_enum     NOT NULL,
    jabatan         VARCHAR(80),
    tanggal_masuk   DATE                        NOT NULL,
    tanggal_keluar  DATE,
    gaji_pokok      NUMERIC(15,0),
    no_bpjs_tk      VARCHAR(20),
    no_bpjs_kes     VARCHAR(20),
    catatan         TEXT,
    is_active       BOOLEAN                     NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMPTZ                 NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ                 NOT NULL DEFAULT NOW(),
    deleted_at      TIMESTAMPTZ
);

CREATE INDEX idx_employees_tenant ON dealer.employees(tenant_id);
CREATE INDEX idx_employees_branch ON dealer.employees(branch_id);
CREATE INDEX idx_employees_dept   ON dealer.employees(branch_id, departemen);

-- Monthly sales targets
CREATE TABLE dealer.sales_targets (
    id                  UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id           UUID        NOT NULL REFERENCES auth.tenants(id) ON DELETE RESTRICT,
    branch_id           UUID        NOT NULL REFERENCES auth.branches(id) ON DELETE RESTRICT,
    sales_id            UUID        NOT NULL REFERENCES auth.users(id) ON DELETE RESTRICT,
    tahun               SMALLINT    NOT NULL,
    bulan               SMALLINT    NOT NULL CHECK (bulan BETWEEN 1 AND 12),
    target_unit         INT         NOT NULL DEFAULT 0,
    target_revenue      NUMERIC(15,0) NOT NULL DEFAULT 0,
    realisasi_unit      INT         NOT NULL DEFAULT 0,
    realisasi_revenue   NUMERIC(15,0) NOT NULL DEFAULT 0,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(branch_id, sales_id, tahun, bulan)
);

CREATE INDEX idx_sales_targets_sales  ON dealer.sales_targets(sales_id);
CREATE INDEX idx_sales_targets_period ON dealer.sales_targets(branch_id, tahun, bulan);

-- Daily attendance
CREATE TABLE dealer.attendances (
    id              UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id       UUID        NOT NULL REFERENCES auth.tenants(id) ON DELETE RESTRICT,
    employee_id     UUID        NOT NULL REFERENCES dealer.employees(id) ON DELETE CASCADE,
    tanggal         DATE        NOT NULL,
    jam_masuk       TIME,
    jam_keluar      TIME,
    status          VARCHAR(20) NOT NULL DEFAULT 'HADIR',
    catatan         TEXT,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(employee_id, tanggal)
);

CREATE INDEX idx_attendances_employee ON dealer.attendances(employee_id);
CREATE INDEX idx_attendances_tanggal  ON dealer.attendances(tenant_id, tanggal);

COMMENT ON COLUMN dealer.sales_targets.realisasi_unit IS 'Auto-increment via trigger update_sales_target_realisasi saat SPK SELESAI';
