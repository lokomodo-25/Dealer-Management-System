-- =====================================================
-- DEALER TRIGGERS: SPK status → unit reservation
-- =====================================================

-- spk_approve_reserve_unit
-- SPK APPROVED → unit.status = RESERVED
-- SPK BATAL    → unit.status = READY (only if was RESERVED by this SPK)
CREATE OR REPLACE FUNCTION dealer._trg_spk_approve_reserve_unit()
RETURNS TRIGGER
LANGUAGE plpgsql AS $$
BEGIN
    IF NEW.status = 'APPROVED' AND OLD.status != 'APPROVED' THEN
        UPDATE dealer.vehicle_units
        SET status = 'RESERVED', updated_at = NOW()
        WHERE id = NEW.unit_id AND status = 'READY';

        IF NOT FOUND THEN
            RAISE EXCEPTION 'Unit % is not READY. Cannot approve SPK.', NEW.unit_id;
        END IF;

    ELSIF NEW.status = 'BATAL' AND OLD.status NOT IN ('BATAL','SELESAI') THEN
        -- Return to READY only if unit was reserved (status = RESERVED)
        UPDATE dealer.vehicle_units
        SET status = 'READY', updated_at = NOW()
        WHERE id = NEW.unit_id AND status = 'RESERVED';
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_spk_approve_reserve_unit
    AFTER UPDATE OF status ON dealer.spk
    FOR EACH ROW EXECUTE FUNCTION dealer._trg_spk_approve_reserve_unit();

-- serah_terima_finalize
-- BAST INSERT → unit = SOLD, customer.total_unit_beli++, SPK = SELESAI
CREATE OR REPLACE FUNCTION dealer._trg_serah_terima_finalize()
RETURNS TRIGGER
LANGUAGE plpgsql AS $$
DECLARE
    v_customer_id UUID;
BEGIN
    -- Get customer from SPK
    SELECT customer_id INTO v_customer_id FROM dealer.spk WHERE id = NEW.spk_id;

    -- Unit → SOLD
    UPDATE dealer.vehicle_units
    SET status = 'SOLD', updated_at = NOW()
    WHERE id = (SELECT unit_id FROM dealer.spk WHERE id = NEW.spk_id);

    -- Customer purchase count++
    UPDATE dealer.customers
    SET total_unit_beli = total_unit_beli + 1, updated_at = NOW()
    WHERE id = v_customer_id;

    -- SPK → SELESAI
    UPDATE dealer.spk
    SET status = 'SELESAI', updated_at = NOW()
    WHERE id = NEW.spk_id;

    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_serah_terima_finalize
    AFTER INSERT ON dealer.serah_terima
    FOR EACH ROW EXECUTE FUNCTION dealer._trg_serah_terima_finalize();
