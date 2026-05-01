-- =====================================================
-- AUTH SEED 01: System roles & permissions
-- =====================================================

BEGIN;

-- 10 system roles (tenant_id NULL = global)
INSERT INTO auth.roles (id, tenant_id, role_code, role_name, description, is_system, is_active) VALUES
    ('33333333-0000-0000-0000-000000000001', NULL, 'SUPER_ADMIN',   'Super Administrator',   'Akses penuh semua tenant dan modul',                   TRUE, TRUE),
    ('33333333-0000-0000-0000-000000000002', NULL, 'ADMIN',         'Administrator',          'Akses penuh 1 tenant, semua cabang',                   TRUE, TRUE),
    ('33333333-0000-0000-0000-000000000003', NULL, 'SALES_MANAGER', 'Sales Manager',          'Kelola tim sales, approve diskon, lihat semua SPK',    TRUE, TRUE),
    ('33333333-0000-0000-0000-000000000004', NULL, 'SALES',         'Sales Advisor',          'Buat SPK, kelola prospek milik sendiri',               TRUE, TRUE),
    ('33333333-0000-0000-0000-000000000005', NULL, 'FINANCE',       'Finance / Admin',        'Proses leasing, invoice, komisi',                      TRUE, TRUE),
    ('33333333-0000-0000-0000-000000000006', NULL, 'SERVICE_MGR',   'Kepala Bengkel',         'Kelola semua WO, assign mekanik',                      TRUE, TRUE),
    ('33333333-0000-0000-0000-000000000007', NULL, 'MEKANIK',       'Mekanik / Teknisi',      'Update WO yang di-assign',                             TRUE, TRUE),
    ('33333333-0000-0000-0000-000000000008', NULL, 'GUDANG',        'Staff Gudang',           'Kelola stok unit dan spare part',                      TRUE, TRUE),
    ('33333333-0000-0000-0000-000000000009', NULL, 'HR',            'HR / Personalia',        'Data karyawan, target, absensi',                       TRUE, TRUE),
    ('33333333-0000-0000-0000-000000000010', NULL, 'VIEWER',        'Viewer / Read Only',     'Hanya baca laporan',                                   TRUE, TRUE);

-- Permissions
INSERT INTO auth.permissions (resource, action, scope, description) VALUES
    -- Inventory
    ('vehicle_models',   'READ',   'ALL',         'Lihat master kendaraan'),
    ('vehicle_models',   'CREATE', 'OWN_BRANCH',  'Tambah master kendaraan'),
    ('vehicle_models',   'UPDATE', 'OWN_BRANCH',  'Edit master kendaraan'),
    ('vehicle_units',    'READ',   'ALL',          'Lihat semua unit stok'),
    ('vehicle_units',    'READ',   'OWN_BRANCH',   'Lihat unit stok cabang sendiri'),
    ('vehicle_units',    'CREATE', 'OWN_BRANCH',   'Tambah unit baru'),
    ('vehicle_units',    'UPDATE', 'OWN_BRANCH',   'Update status unit'),
    -- CRM
    ('prospects',        'CREATE', 'OWN_BRANCH',   'Buat prospek baru'),
    ('prospects',        'READ',   'ALL',           'Lihat semua prospek'),
    ('prospects',        'READ',   'OWN_DATA',      'Lihat prospek milik sendiri'),
    ('prospects',        'UPDATE', 'OWN_DATA',      'Edit prospek milik sendiri'),
    ('customers',        'CREATE', 'OWN_BRANCH',    'Tambah customer baru'),
    ('customers',        'READ',   'OWN_BRANCH',    'Lihat data customer'),
    -- SPK
    ('spk',              'CREATE', 'OWN_BRANCH',    'Buat SPK baru'),
    ('spk',              'READ',   'ALL',            'Lihat semua SPK'),
    ('spk',              'READ',   'OWN_DATA',       'Lihat SPK milik sendiri'),
    ('spk',              'APPROVE','OWN_BRANCH',     'Approve / tolak SPK'),
    ('spk',              'UPDATE', 'OWN_BRANCH',     'Edit SPK'),
    -- Finance
    ('financing',        'CREATE', 'OWN_BRANCH',    'Buat pengajuan leasing'),
    ('financing',        'READ',   'OWN_BRANCH',    'Lihat data leasing'),
    ('invoices',         'CREATE', 'OWN_BRANCH',    'Buat invoice'),
    ('commission',       'APPROVE','OWN_BRANCH',    'Approve komisi sales'),
    ('commission',       'READ',   'OWN_DATA',      'Lihat komisi milik sendiri'),
    -- Service
    ('work_orders',      'CREATE', 'OWN_BRANCH',    'Buat WO baru'),
    ('work_orders',      'READ',   'ALL',            'Lihat semua WO'),
    ('work_orders',      'READ',   'OWN_DATA',       'Lihat WO yang di-assign'),
    ('work_orders',      'UPDATE', 'OWN_DATA',       'Update progress WO'),
    ('work_orders',      'APPROVE','OWN_BRANCH',     'Approve biaya WO'),
    -- Inventory/Gudang
    ('spare_parts',      'READ',   'OWN_BRANCH',    'Lihat stok spare part'),
    ('stock_movements',  'CREATE', 'OWN_BRANCH',    'Input mutasi stok'),
    ('stock_movements',  'UPDATE', 'OWN_BRANCH',    'Terima unit/part masuk'),
    -- HR
    ('employees',        'CREATE', 'OWN_BRANCH',    'Kelola data karyawan'),
    ('employees',        'READ',   'OWN_BRANCH',    'Lihat data karyawan'),
    ('sales_targets',    'UPDATE', 'OWN_BRANCH',    'Set target penjualan'),
    ('attendances',      'READ',   'OWN_BRANCH',    'Lihat absensi'),
    -- Reporting
    ('dashboard',        'READ',   'ALL',            'Lihat dashboard eksekutif semua cabang'),
    ('dashboard',        'READ',   'OWN_BRANCH',     'Lihat dashboard cabang sendiri'),
    ('reports',          'EXPORT', 'OWN_BRANCH',     'Export laporan'),
    -- RBAC admin
    ('users',            'CREATE', 'ALL',             'Kelola semua user'),
    ('users',            'CREATE', 'OWN_BRANCH',      'Kelola user dalam cabang'),
    ('roles',            'UPDATE', 'ALL',              'Kelola role dan permission');

COMMIT;
