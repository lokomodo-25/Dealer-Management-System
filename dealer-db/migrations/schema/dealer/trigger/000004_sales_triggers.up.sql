-- =====================================================
-- DEALER TRIGGERS: Sales target realization counter
-- =====================================================

-- update_sales_target_realisasi
-- SPK → SELESAI: increment sales_targets.realisasi_unit and realisasi_revenue
CREATE OR REPLACE FUNCTION dealer._trg_update_sales_target_realisasi()
RETURNS TRIGGER
LANGUAGE plpgsql AS $$
DECLARE
    v_tahun SMALLINT;
    v_bulan SMALLINT;
BEGIN
    IF NEW.status = 'SELESAI' AND OLD.status != 'SELESAI' THEN
        v_tahun := EXTRACT(YEAR FROM NOW())::SMALLINT;
        v_bulan := EXTRACT(MONTH FROM NOW())::SMALLINT;

        UPDATE dealer.sales_targets
        SET
            realisasi_unit    = realisasi_unit + 1,
            realisasi_revenue = realisasi_revenue + NEW.harga_deal,
            updated_at        = NOW()
        WHERE
            sales_id  = NEW.sales_id
            AND branch_id = NEW.branch_id
            AND tahun = v_tahun
            AND bulan = v_bulan;
        -- No error if no target row — sales may not have a target set yet
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_update_sales_target_realisasi
    AFTER UPDATE OF status ON dealer.spk
    FOR EACH ROW EXECUTE FUNCTION dealer._trg_update_sales_target_realisasi();
