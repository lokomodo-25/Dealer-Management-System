-- =====================================================
-- DEALER SEED 01: Vehicle models, spare parts, notification templates
-- =====================================================

BEGIN;

-- Vehicle models (Toyota & Daihatsu for AutoStar tenant)
INSERT INTO dealer.vehicle_models (id, tenant_id, merek, model, tipe, tahun_model, transmisi, bahan_bakar, cc_mesin, warna_tersedia, harga_otr) VALUES
    ('55555555-0000-0000-0000-000000000001',
     '11111111-0000-0000-0000-000000000001',
     'Toyota','Avanza','1.3 E MT', 2025, 'Manual', 'Bensin', 1329,
     ARRAY['Putih Pearl','Silver Metallic','Abu-abu','Hitam Mica','Merah'],
     215000000),

    ('55555555-0000-0000-0000-000000000002',
     '11111111-0000-0000-0000-000000000001',
     'Toyota','Avanza','1.5 G CVT', 2025, 'Otomatis', 'Bensin', 1496,
     ARRAY['Putih Pearl','Silver Metallic','Abu-abu','Hitam Mica','Merah','Biru'],
     248500000),

    ('55555555-0000-0000-0000-000000000003',
     '11111111-0000-0000-0000-000000000001',
     'Toyota','Innova Reborn','2.0 G AT', 2025, 'Otomatis', 'Bensin', 1998,
     ARRAY['Putih Pearl','Silver','Hitam Mica','Abu-abu Metallic'],
     420000000),

    ('55555555-0000-0000-0000-000000000004',
     '11111111-0000-0000-0000-000000000001',
     'Toyota','Rush','1.5 S TRD', 2025, 'Otomatis', 'Bensin', 1496,
     ARRAY['Putih Pearl','Merah','Hitam','Silver'],
     310000000),

    ('55555555-0000-0000-0000-000000000005',
     '11111111-0000-0000-0000-000000000001',
     'Toyota','Raize','1.0T GR Sport', 2025, 'Otomatis', 'Bensin', 998,
     ARRAY['Merah','Putih','Hitam','Biru','Orange'],
     290000000),

    ('55555555-0000-0000-0000-000000000006',
     '11111111-0000-0000-0000-000000000001',
     'Daihatsu','Xenia','1.3 R MT', 2025, 'Manual', 'Bensin', 1329,
     ARRAY['Putih','Silver','Abu-abu','Hitam'],
     210000000),

    ('55555555-0000-0000-0000-000000000007',
     '11111111-0000-0000-0000-000000000001',
     'Daihatsu','Rocky','1.0T R CVT', 2025, 'Otomatis', 'Bensin', 998,
     ARRAY['Putih','Merah','Hitam','Biru Metallic'],
     258000000);

-- Spare parts
INSERT INTO dealer.spare_parts (id, tenant_id, kode_part, nama_part, satuan, harga_beli, harga_jual) VALUES
    ('77777777-0000-0000-0000-000000000001', '11111111-0000-0000-0000-000000000001',
     'OLI-TOY-0W20-4L', 'Oli Mesin Toyota 0W-20 4L', 'botol', 180000, 250000),
    ('77777777-0000-0000-0000-000000000002', '11111111-0000-0000-0000-000000000001',
     'FILTER-OLI-TOY', 'Filter Oli Toyota Genuine', 'pcs', 65000, 95000),
    ('77777777-0000-0000-0000-000000000003', '11111111-0000-0000-0000-000000000001',
     'FILTER-AC-TOY', 'Filter AC Cabin Toyota', 'pcs', 55000, 85000),
    ('77777777-0000-0000-0000-000000000004', '11111111-0000-0000-0000-000000000001',
     'BUSI-NGK-IRD', 'Busi NGK Iridium', 'pcs', 85000, 125000),
    ('77777777-0000-0000-0000-000000000005', '11111111-0000-0000-0000-000000000001',
     'BRAKE-PAD-F-AVZ', 'Brake Pad Depan Avanza', 'set', 150000, 220000),
    ('77777777-0000-0000-0000-000000000006', '11111111-0000-0000-0000-000000000001',
     'BRAKE-PAD-R-AVZ', 'Brake Pad Belakang Avanza', 'set', 120000, 180000),
    ('77777777-0000-0000-0000-000000000007', '11111111-0000-0000-0000-000000000001',
     'TIMING-BELT-TOY', 'Timing Belt Toyota', 'pcs', 350000, 520000),
    ('77777777-0000-0000-0000-000000000008', '11111111-0000-0000-0000-000000000001',
     'WATER-PUMP-TOY', 'Water Pump Toyota', 'pcs', 420000, 650000),
    ('77777777-0000-0000-0000-000000000009', '11111111-0000-0000-0000-000000000001',
     'WIPER-BLADE-20', 'Wiper Blade 20 inch', 'pcs', 45000, 75000),
    ('77777777-0000-0000-0000-000000000010', '11111111-0000-0000-0000-000000000001',
     'ATF-TOY-1L', 'Oli Transmisi Otomatis Toyota ATF WS 1L', 'botol', 85000, 130000);

-- Part stocks at BDG branch
INSERT INTO dealer.part_stocks (part_id, branch_id, tenant_id, qty_on_hand, reorder_point) VALUES
    ('77777777-0000-0000-0000-000000000001', '22222222-0000-0000-0000-000000000001', '11111111-0000-0000-0000-000000000001', 50, 10),
    ('77777777-0000-0000-0000-000000000002', '22222222-0000-0000-0000-000000000001', '11111111-0000-0000-0000-000000000001', 30, 5),
    ('77777777-0000-0000-0000-000000000003', '22222222-0000-0000-0000-000000000001', '11111111-0000-0000-0000-000000000001', 20, 5),
    ('77777777-0000-0000-0000-000000000004', '22222222-0000-0000-0000-000000000001', '11111111-0000-0000-0000-000000000001', 40, 8),
    ('77777777-0000-0000-0000-000000000005', '22222222-0000-0000-0000-000000000001', '11111111-0000-0000-0000-000000000001', 15, 3),
    ('77777777-0000-0000-0000-000000000006', '22222222-0000-0000-0000-000000000001', '11111111-0000-0000-0000-000000000001', 15, 3),
    ('77777777-0000-0000-0000-000000000007', '22222222-0000-0000-0000-000000000001', '11111111-0000-0000-0000-000000000001', 8, 2),
    ('77777777-0000-0000-0000-000000000008', '22222222-0000-0000-0000-000000000001', '11111111-0000-0000-0000-000000000001', 5, 2),
    ('77777777-0000-0000-0000-000000000009', '22222222-0000-0000-0000-000000000001', '11111111-0000-0000-0000-000000000001', 25, 5),
    ('77777777-0000-0000-0000-000000000010', '22222222-0000-0000-0000-000000000001', '11111111-0000-0000-0000-000000000001', 20, 5);

-- Commission rules
INSERT INTO dealer.commission_rules (tenant_id, model_id, metode_bayar, komisi_persen, komisi_flat, berlaku_mulai) VALUES
    ('11111111-0000-0000-0000-000000000001', NULL, 'CASH',           1.5, 500000, '2025-01-01'),
    ('11111111-0000-0000-0000-000000000001', NULL, 'KREDIT',         1.0, 300000, '2025-01-01'),
    ('11111111-0000-0000-0000-000000000001', NULL, 'TUNAI_BERTAHAP', 1.2, 400000, '2025-01-01');

-- Notification templates
INSERT INTO dealer.notification_templates (tenant_id, kode, channel, judul, body_template) VALUES
    ('11111111-0000-0000-0000-000000000001', 'SPK_APPROVED', 'WA', NULL,
     'Halo {{nama_customer}}, SPK Anda nomor {{no_spk}} telah disetujui. Unit {{model}} siap diproses. Info lebih lanjut: {{tracking_link}}'),

    ('11111111-0000-0000-0000-000000000001', 'DP_REMINDER', 'WA', NULL,
     'Halo {{nama_customer}}, jangan lupa melakukan pembayaran DP untuk SPK {{no_spk}} sebesar {{dp_amount}}. Konfirmasi ke sales Anda.'),

    ('11111111-0000-0000-0000-000000000001', 'UNIT_SIAP_SERAH', 'WA', NULL,
     'Kabar gembira! Unit {{model}} Anda sudah siap diserahterimakan. Silakan hubungi showroom untuk jadwal pengambilan. SPK: {{no_spk}}'),

    ('11111111-0000-0000-0000-000000000001', 'SERAH_TERIMA_DONE', 'WA', NULL,
     'Selamat! Kendaraan {{model}} ({{no_polisi}}) sudah resmi menjadi milik Anda. Terima kasih telah berbelanja di {{nama_dealer}}. BAST: {{no_bast}}'),

    ('11111111-0000-0000-0000-000000000001', 'SERVICE_REMINDER', 'WA', NULL,
     'Halo {{nama_customer}}, kendaraan Anda ({{no_polisi}}) sudah waktunya service berkala. Segera booking di showroom kami. Reply untuk info lebih lanjut.'),

    ('11111111-0000-0000-0000-000000000001', 'WO_SELESAI', 'WA', NULL,
     'Kendaraan Anda ({{no_polisi}}) telah selesai diservis. WO: {{no_wo}}. Total biaya: Rp {{total_invoice}}. Silakan diambil.'),

    ('11111111-0000-0000-0000-000000000001', 'TRACKING_UPDATE', 'WA', NULL,
     'Update pesanan Anda: {{model}} kini dalam tahap "{{stage_label}}". Progress: {{progress_pct}}%. Cek detail: {{tracking_link}}');

COMMIT;
