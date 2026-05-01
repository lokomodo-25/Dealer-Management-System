DROP FUNCTION IF EXISTS dealer.advance_tracking_stage(UUID, dealer.tracking_stage_enum, TEXT, UUID);
DROP FUNCTION IF EXISTS dealer.stage_to_pct(dealer.tracking_stage_enum, dealer.tracking_type_enum);
DROP FUNCTION IF EXISTS dealer.calc_komisi(UUID, UUID, dealer.payment_method_enum, NUMERIC);
DROP FUNCTION IF EXISTS dealer.calc_angsuran(NUMERIC, NUMERIC, INT, NUMERIC);
