-- =====================================================
-- DEALER: Document number generators
-- =====================================================

-- Generate SPK number: {KODE_CAB}-{YYMM}-{SEQ5}  e.g. BDG-2501-00001
CREATE OR REPLACE FUNCTION dealer.gen_no_spk(
    p_tenant_id     UUID,
    p_branch_id     UUID
)
RETURNS TEXT
LANGUAGE plpgsql AS $$
DECLARE
    v_kode_cabang   VARCHAR;
    v_year_month    TEXT;
    v_seq           TEXT;
BEGIN
    SELECT kode_cabang INTO v_kode_cabang FROM auth.branches WHERE id = p_branch_id;
    v_year_month := to_char(NOW(), 'YYMM');
    v_seq := public.next_doc_seq(p_tenant_id, v_kode_cabang, 'spk', v_year_month, 5);
    RETURN v_kode_cabang || '-' || v_year_month || '-' || v_seq;
END;
$$;

-- Generate WO number: WO-{KODE_CAB}-{YYMM}-{SEQ3}  e.g. WO-BDG-2502-001
CREATE OR REPLACE FUNCTION dealer.gen_no_wo(
    p_tenant_id     UUID,
    p_branch_id     UUID
)
RETURNS TEXT
LANGUAGE plpgsql AS $$
DECLARE
    v_kode_cabang   VARCHAR;
    v_year_month    TEXT;
    v_seq           TEXT;
BEGIN
    SELECT kode_cabang INTO v_kode_cabang FROM auth.branches WHERE id = p_branch_id;
    v_year_month := to_char(NOW(), 'YYMM');
    v_seq := public.next_doc_seq(p_tenant_id, v_kode_cabang, 'wo', v_year_month, 3);
    RETURN 'WO-' || v_kode_cabang || '-' || v_year_month || '-' || v_seq;
END;
$$;

-- Generate BAST number: BAST-{KODE_CAB}-{YYMM}-{SEQ5}
CREATE OR REPLACE FUNCTION dealer.gen_no_bast(
    p_tenant_id     UUID,
    p_branch_id     UUID
)
RETURNS TEXT
LANGUAGE plpgsql AS $$
DECLARE
    v_kode_cabang   VARCHAR;
    v_year_month    TEXT;
    v_seq           TEXT;
BEGIN
    SELECT kode_cabang INTO v_kode_cabang FROM auth.branches WHERE id = p_branch_id;
    v_year_month := to_char(NOW(), 'YYMM');
    v_seq := public.next_doc_seq(p_tenant_id, v_kode_cabang, 'bast', v_year_month, 5);
    RETURN 'BAST-' || v_kode_cabang || '-' || v_year_month || '-' || v_seq;
END;
$$;

-- Generate Invoice number: INV-{KODE_CAB}-{YYMM}-{SEQ5}
CREATE OR REPLACE FUNCTION dealer.gen_no_invoice(
    p_tenant_id     UUID,
    p_branch_id     UUID
)
RETURNS TEXT
LANGUAGE plpgsql AS $$
DECLARE
    v_kode_cabang   VARCHAR;
    v_year_month    TEXT;
    v_seq           TEXT;
BEGIN
    SELECT kode_cabang INTO v_kode_cabang FROM auth.branches WHERE id = p_branch_id;
    v_year_month := to_char(NOW(), 'YYMM');
    v_seq := public.next_doc_seq(p_tenant_id, v_kode_cabang, 'invoice', v_year_month, 5);
    RETURN 'INV-' || v_kode_cabang || '-' || v_year_month || '-' || v_seq;
END;
$$;

-- Generate Prospect number: PRO-{KODE_CAB}-{YYMM}-{SEQ3}
CREATE OR REPLACE FUNCTION dealer.gen_no_prospect(
    p_tenant_id     UUID,
    p_branch_id     UUID
)
RETURNS TEXT
LANGUAGE plpgsql AS $$
DECLARE
    v_kode_cabang   VARCHAR;
    v_year_month    TEXT;
    v_seq           TEXT;
BEGIN
    SELECT kode_cabang INTO v_kode_cabang FROM auth.branches WHERE id = p_branch_id;
    v_year_month := to_char(NOW(), 'YYMM');
    v_seq := public.next_doc_seq(p_tenant_id, v_kode_cabang, 'prospect', v_year_month, 3);
    RETURN 'PRO-' || v_kode_cabang || '-' || v_year_month || '-' || v_seq;
END;
$$;

-- Generate Employee NIK: EMP-{KODE_CAB}-{SEQ3}
CREATE OR REPLACE FUNCTION dealer.gen_nik_karyawan(
    p_tenant_id     UUID,
    p_branch_id     UUID
)
RETURNS TEXT
LANGUAGE plpgsql AS $$
DECLARE
    v_kode_cabang   VARCHAR;
    v_seq           TEXT;
BEGIN
    SELECT kode_cabang INTO v_kode_cabang FROM auth.branches WHERE id = p_branch_id;
    v_seq := public.next_doc_seq(p_tenant_id, v_kode_cabang, 'emp', 'GLOBAL', 3);
    RETURN 'EMP-' || v_kode_cabang || '-' || v_seq;
END;
$$;

-- Generate tracking token (random 32-char hex)
CREATE OR REPLACE FUNCTION dealer.gen_tracking_token()
RETURNS TEXT
LANGUAGE sql AS $$
    SELECT encode(gen_random_bytes(32), 'hex');
$$;
