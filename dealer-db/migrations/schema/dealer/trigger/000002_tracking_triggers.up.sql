-- =====================================================
-- DEALER TRIGGERS: Order tracking auto-create
-- =====================================================

-- spk_create_tracking
-- SPK APPROVED → auto-create order_tracking + first stage log
CREATE OR REPLACE FUNCTION dealer._trg_spk_create_tracking()
RETURNS TRIGGER
LANGUAGE plpgsql AS $$
DECLARE
    v_token TEXT;
    v_tracking_id UUID;
    v_tracking_type dealer.tracking_type_enum;
BEGIN
    -- Only trigger on APPROVED transition, only once
    IF NEW.status = 'APPROVED' AND OLD.status != 'APPROVED' THEN
        IF EXISTS (SELECT 1 FROM dealer.order_tracking WHERE spk_id = NEW.id) THEN
            RETURN NEW;
        END IF;

        v_token := dealer.gen_tracking_token();

        -- INDENT if unit status was INDENT before reserve, else READY_STOCK
        -- We check unit status pre-reservation via warna minat or via model (simplified: check if unit was ever INDENT)
        v_tracking_type := 'READY_STOCK'; -- Application layer sets INDENT for indent orders

        INSERT INTO dealer.order_tracking (
            spk_id, tenant_id, tracking_token, tracking_type, current_stage, progress_pct
        ) VALUES (
            NEW.id, NEW.tenant_id, v_token, v_tracking_type, 'SPK_DIBUAT',
            dealer.stage_to_pct('SPK_DIBUAT', v_tracking_type)
        )
        RETURNING id INTO v_tracking_id;

        INSERT INTO dealer.tracking_stage_logs (tracking_id, stage, catatan, created_by)
        VALUES (v_tracking_id, 'SPK_DIBUAT', 'SPK disetujui', NEW.approved_by);
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_spk_create_tracking
    AFTER UPDATE OF status ON dealer.spk
    FOR EACH ROW EXECUTE FUNCTION dealer._trg_spk_create_tracking();

-- serah_terima_update_tracking
-- BAST INSERT → order_tracking.current_stage = SELESAI (100%)
CREATE OR REPLACE FUNCTION dealer._trg_serah_terima_update_tracking()
RETURNS TRIGGER
LANGUAGE plpgsql AS $$
BEGIN
    PERFORM dealer.advance_tracking_stage(
        NEW.spk_id,
        'SELESAI',
        'Unit diserahterimakan. BAST: ' || NEW.no_bast,
        NEW.delivered_by
    );
    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_serah_terima_update_tracking
    AFTER INSERT ON dealer.serah_terima
    FOR EACH ROW EXECUTE FUNCTION dealer._trg_serah_terima_update_tracking();
