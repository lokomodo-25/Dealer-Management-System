-- =====================================================
-- DEALER: Business logic functions
-- =====================================================

-- Calculate financing installment (flat rate)
-- Returns monthly installment given OTR, DP, tenor, interest rate
CREATE OR REPLACE FUNCTION dealer.calc_angsuran(
    p_otr           NUMERIC,
    p_dp            NUMERIC,
    p_tenor_bulan   INT,
    p_bunga_persen  NUMERIC  -- annual flat rate
)
RETURNS NUMERIC
LANGUAGE sql IMMUTABLE AS $$
    SELECT ROUND(
        ((p_otr - p_dp) + ((p_otr - p_dp) * (p_bunga_persen / 100) * (p_tenor_bulan / 12.0)))
        / p_tenor_bulan
    );
$$;

-- Calculate commission for a deal
CREATE OR REPLACE FUNCTION dealer.calc_komisi(
    p_tenant_id     UUID,
    p_model_id      UUID,
    p_metode_bayar  dealer.payment_method_enum,
    p_harga_deal    NUMERIC
)
RETURNS NUMERIC
LANGUAGE plpgsql STABLE AS $$
DECLARE
    v_rule dealer.commission_rules%ROWTYPE;
    v_komisi NUMERIC;
BEGIN
    -- Find applicable rule: model-specific first, then global
    SELECT * INTO v_rule
    FROM dealer.commission_rules
    WHERE tenant_id = p_tenant_id
      AND is_active = TRUE
      AND (model_id = p_model_id OR model_id IS NULL)
      AND (metode_bayar = p_metode_bayar OR metode_bayar IS NULL)
      AND berlaku_mulai <= CURRENT_DATE
      AND (berlaku_sampai IS NULL OR berlaku_sampai >= CURRENT_DATE)
    ORDER BY model_id NULLS LAST, metode_bayar NULLS LAST
    LIMIT 1;

    IF NOT FOUND THEN
        RETURN 0;
    END IF;

    v_komisi := COALESCE(v_rule.komisi_flat, 0)
              + ROUND(p_harga_deal * COALESCE(v_rule.komisi_persen, 0) / 100);
    RETURN v_komisi;
END;
$$;

-- Get tracking progress percentage by stage
CREATE OR REPLACE FUNCTION dealer.stage_to_pct(
    p_stage         dealer.tracking_stage_enum,
    p_tracking_type dealer.tracking_type_enum
)
RETURNS SMALLINT
LANGUAGE sql IMMUTABLE AS $$
    SELECT CASE p_tracking_type
        WHEN 'READY_STOCK' THEN
            CASE p_stage
                WHEN 'SPK_DIBUAT'       THEN 10
                WHEN 'DP_DITERIMA'      THEN 20
                WHEN 'PERSIAPAN_PDI'    THEN 50
                WHEN 'PROSES_DOKUMEN'   THEN 70
                WHEN 'SIAP_SERAH'       THEN 85
                WHEN 'SERAH_TERIMA'     THEN 95
                WHEN 'SELESAI'          THEN 100
                ELSE 10
            END
        WHEN 'PO_INDENT' THEN
            CASE p_stage
                WHEN 'SPK_DIBUAT'           THEN 5
                WHEN 'DP_DITERIMA'          THEN 10
                WHEN 'PO_DIKIRIM_ATPM'      THEN 20
                WHEN 'KONFIRMASI_ATPM'      THEN 30
                WHEN 'PROSES_PRODUKSI'      THEN 45
                WHEN 'PENGIRIMAN_KE_DEALER' THEN 60
                WHEN 'UNIT_TIBA_DEALER'     THEN 70
                WHEN 'PERSIAPAN_PDI'        THEN 78
                WHEN 'PROSES_DOKUMEN'       THEN 85
                WHEN 'SIAP_SERAH'           THEN 92
                WHEN 'SERAH_TERIMA'         THEN 97
                WHEN 'SELESAI'              THEN 100
                ELSE 5
            END
    END;
$$;

-- Advance tracking stage and log it
CREATE OR REPLACE FUNCTION dealer.advance_tracking_stage(
    p_spk_id        UUID,
    p_new_stage     dealer.tracking_stage_enum,
    p_catatan       TEXT DEFAULT NULL,
    p_user_id       UUID DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql AS $$
DECLARE
    v_tracking dealer.order_tracking%ROWTYPE;
BEGIN
    SELECT * INTO v_tracking FROM dealer.order_tracking WHERE spk_id = p_spk_id FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'order_tracking not found for spk_id %', p_spk_id;
    END IF;

    UPDATE dealer.order_tracking SET
        current_stage = p_new_stage,
        progress_pct  = dealer.stage_to_pct(p_new_stage, tracking_type),
        is_completed  = (p_new_stage = 'SELESAI'),
        completed_at  = CASE WHEN p_new_stage = 'SELESAI' THEN NOW() ELSE NULL END,
        updated_at    = NOW()
    WHERE id = v_tracking.id;

    INSERT INTO dealer.tracking_stage_logs (tracking_id, stage, catatan, created_by)
    VALUES (v_tracking.id, p_new_stage, p_catatan, p_user_id);
END;
$$;
