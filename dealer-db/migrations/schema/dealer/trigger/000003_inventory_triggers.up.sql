-- =====================================================
-- DEALER TRIGGERS: WO parts stock deduction
-- =====================================================

-- wo_parts_deduct_stock
-- wo_parts INSERT → part_stocks.qty_on_hand -= qty + log stock_movement
CREATE OR REPLACE FUNCTION dealer._trg_wo_parts_deduct_stock()
RETURNS TRIGGER
LANGUAGE plpgsql AS $$
DECLARE
    v_branch_id UUID;
    v_tenant_id UUID;
    v_qty_before INT;
    v_qty_after INT;
BEGIN
    SELECT branch_id, tenant_id INTO v_branch_id, v_tenant_id
    FROM dealer.work_orders WHERE id = NEW.wo_id;

    SELECT qty_on_hand INTO v_qty_before
    FROM dealer.part_stocks
    WHERE part_id = NEW.part_id AND branch_id = v_branch_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Stock record not found for part % at branch %', NEW.part_id, v_branch_id;
    END IF;

    IF v_qty_before < NEW.qty THEN
        RAISE EXCEPTION 'Insufficient stock: part % has % but WO needs %', NEW.part_id, v_qty_before, NEW.qty;
    END IF;

    v_qty_after := v_qty_before - NEW.qty;

    UPDATE dealer.part_stocks
    SET qty_on_hand = v_qty_after, updated_at = NOW()
    WHERE part_id = NEW.part_id AND branch_id = v_branch_id;

    INSERT INTO dealer.stock_movements (
        part_id, branch_id, tenant_id, movement_type,
        qty, qty_before, qty_after, reference_type, reference_id
    ) VALUES (
        NEW.part_id, v_branch_id, v_tenant_id, 'OUT',
        NEW.qty, v_qty_before, v_qty_after, 'work_order', NEW.wo_id
    );

    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_wo_parts_deduct_stock
    AFTER INSERT ON dealer.wo_parts
    FOR EACH ROW EXECUTE FUNCTION dealer._trg_wo_parts_deduct_stock();
