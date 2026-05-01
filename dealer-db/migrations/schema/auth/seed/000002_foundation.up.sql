-- =====================================================
-- AUTH SEED 02: Tenants, Branches, Users, Role assignments
-- Dev only — password "Admin1234!" hashed with bcrypt cost 12
-- =====================================================

BEGIN;

-- Tenants
INSERT INTO auth.tenants (id, kode_dealer, nama_dealer, nama_pt, npwp, merek_kendaraan, subscription_plan, subscription_exp, max_users) VALUES
    ('11111111-0000-0000-0000-000000000001', 'AUTO-BDG', 'AutoStar Bandung',
     'PT Bintang Otomotif Persada', '01.234.567.8-423.000',
     ARRAY['Toyota','Daihatsu'], 'PROFESSIONAL', '2026-12-31', 50),

    ('11111111-0000-0000-0000-000000000002', 'AUTO-JKT', 'AutoStar Jakarta',
     'PT Bintang Otomotif Persada', '01.234.567.8-010.000',
     ARRAY['Toyota','Daihatsu'], 'PROFESSIONAL', '2026-12-31', 50),

    ('11111111-0000-0000-0000-000000000003', 'HONDA-BGR', 'Honda Bogor Raya',
     'PT Sejahtera Motor Nusantara', '02.345.678.9-215.000',
     ARRAY['Honda'], 'STARTER', '2026-06-30', 15);

-- Branches
INSERT INTO auth.branches (id, tenant_id, kode_cabang, nama_cabang, tipe, alamat, kota, provinsi, telepon) VALUES
    ('22222222-0000-0000-0000-000000000001',
     '11111111-0000-0000-0000-000000000001',
     'BDG', 'AutoStar Bandung — Showroom Utama', 'KEDUANYA',
     'Jl. Soekarno Hatta No. 123, Bandung', 'Bandung', 'Jawa Barat', '022-12345678'),

    ('22222222-0000-0000-0000-000000000002',
     '11111111-0000-0000-0000-000000000001',
     'DAGO', 'AutoStar Bandung — Cabang Dago', 'SHOWROOM',
     'Jl. Ir. H. Djuanda No. 88, Bandung', 'Bandung', 'Jawa Barat', '022-87654321'),

    ('22222222-0000-0000-0000-000000000003',
     '11111111-0000-0000-0000-000000000002',
     'JKT', 'AutoStar Jakarta — Sudirman', 'KEDUANYA',
     'Jl. Sudirman No. 45, Jakarta Pusat', 'Jakarta', 'DKI Jakarta', '021-11223344'),

    ('22222222-0000-0000-0000-000000000004',
     '11111111-0000-0000-0000-000000000003',
     'BGR', 'Honda Bogor Raya — Showroom Utama', 'KEDUANYA',
     'Jl. Pajajaran No. 77, Bogor', 'Bogor', 'Jawa Barat', '0251-9876543');

-- Users (password: Admin1234!)
INSERT INTO auth.users (id, tenant_id, email, password_hash, full_name, phone, is_active, is_verified) VALUES
    ('44444444-0000-0000-0000-000000000001',
     '11111111-0000-0000-0000-000000000001',
     'superadmin@autostar.id',
     '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBpj2bIqS5pXZS',
     'Super Admin System', '08100000000', TRUE, TRUE),

    ('44444444-0000-0000-0000-000000000002',
     '11111111-0000-0000-0000-000000000001',
     'admin.bdg@autostar.id',
     '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBpj2bIqS5pXZS',
     'Hendra Kusuma', '081234560001', TRUE, TRUE),

    ('44444444-0000-0000-0000-000000000003',
     '11111111-0000-0000-0000-000000000001',
     'sales.mgr.bdg@autostar.id',
     '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBpj2bIqS5pXZS',
     'Dewi Rahayu', '081234560002', TRUE, TRUE),

    ('44444444-0000-0000-0000-000000000004',
     '11111111-0000-0000-0000-000000000001',
     'budi.santoso@autostar.id',
     '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBpj2bIqS5pXZS',
     'Budi Santoso', '081234560003', TRUE, TRUE),

    ('44444444-0000-0000-0000-000000000005',
     '11111111-0000-0000-0000-000000000001',
     'sari.indah@autostar.id',
     '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBpj2bIqS5pXZS',
     'Sari Indah Pertiwi', '081234560004', TRUE, TRUE),

    ('44444444-0000-0000-0000-000000000006',
     '11111111-0000-0000-0000-000000000001',
     'finance.bdg@autostar.id',
     '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBpj2bIqS5pXZS',
     'Rina Marlina', '081234560005', TRUE, TRUE),

    ('44444444-0000-0000-0000-000000000007',
     '11111111-0000-0000-0000-000000000001',
     'foreman.bdg@autostar.id',
     '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBpj2bIqS5pXZS',
     'Agus Priyanto', '081234560006', TRUE, TRUE),

    ('44444444-0000-0000-0000-000000000008',
     '11111111-0000-0000-0000-000000000001',
     'mekanik1.bdg@autostar.id',
     '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBpj2bIqS5pXZS',
     'Dedi Mulyadi', '081234560007', TRUE, TRUE),

    ('44444444-0000-0000-0000-000000000009',
     '11111111-0000-0000-0000-000000000001',
     'gudang.bdg@autostar.id',
     '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBpj2bIqS5pXZS',
     'Wahyu Nugroho', '081234560008', TRUE, TRUE);

-- User-Branch-Role assignments
INSERT INTO auth.user_branch_roles (user_id, branch_id, role_id, assigned_by) VALUES
    -- Super Admin: all branches (NULL = global)
    ('44444444-0000-0000-0000-000000000001', NULL, '33333333-0000-0000-0000-000000000001', '44444444-0000-0000-0000-000000000001'),
    -- Admin BDG
    ('44444444-0000-0000-0000-000000000002', '22222222-0000-0000-0000-000000000001', '33333333-0000-0000-0000-000000000002', '44444444-0000-0000-0000-000000000001'),
    -- Sales Manager BDG
    ('44444444-0000-0000-0000-000000000003', '22222222-0000-0000-0000-000000000001', '33333333-0000-0000-0000-000000000003', '44444444-0000-0000-0000-000000000002'),
    -- Sales 1 BDG
    ('44444444-0000-0000-0000-000000000004', '22222222-0000-0000-0000-000000000001', '33333333-0000-0000-0000-000000000004', '44444444-0000-0000-0000-000000000002'),
    -- Sales 2 BDG
    ('44444444-0000-0000-0000-000000000005', '22222222-0000-0000-0000-000000000001', '33333333-0000-0000-0000-000000000004', '44444444-0000-0000-0000-000000000002'),
    -- Finance BDG
    ('44444444-0000-0000-0000-000000000006', '22222222-0000-0000-0000-000000000001', '33333333-0000-0000-0000-000000000005', '44444444-0000-0000-0000-000000000002'),
    -- Foreman BDG
    ('44444444-0000-0000-0000-000000000007', '22222222-0000-0000-0000-000000000001', '33333333-0000-0000-0000-000000000006', '44444444-0000-0000-0000-000000000002'),
    -- Mekanik BDG
    ('44444444-0000-0000-0000-000000000008', '22222222-0000-0000-0000-000000000001', '33333333-0000-0000-0000-000000000007', '44444444-0000-0000-0000-000000000007'),
    -- Gudang BDG
    ('44444444-0000-0000-0000-000000000009', '22222222-0000-0000-0000-000000000001', '33333333-0000-0000-0000-000000000008', '44444444-0000-0000-0000-000000000002');

COMMIT;
