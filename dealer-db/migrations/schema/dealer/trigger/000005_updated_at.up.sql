-- =====================================================
-- DEALER TRIGGERS: auto updated_at on all dealer tables
-- =====================================================

CREATE TRIGGER trg_vehicle_models_updated_at
    BEFORE UPDATE ON dealer.vehicle_models
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER trg_vehicle_units_updated_at
    BEFORE UPDATE ON dealer.vehicle_units
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER trg_customers_updated_at
    BEFORE UPDATE ON dealer.customers
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER trg_prospects_updated_at
    BEFORE UPDATE ON dealer.prospects
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER trg_spk_updated_at
    BEFORE UPDATE ON dealer.spk
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER trg_serah_terima_updated_at
    BEFORE UPDATE ON dealer.serah_terima
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER trg_financing_updated_at
    BEFORE UPDATE ON dealer.financing_applications
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER trg_invoices_updated_at
    BEFORE UPDATE ON dealer.invoices
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER trg_commission_ledger_updated_at
    BEFORE UPDATE ON dealer.commission_ledger
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER trg_spare_parts_updated_at
    BEFORE UPDATE ON dealer.spare_parts
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER trg_part_stocks_updated_at
    BEFORE UPDATE ON dealer.part_stocks
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER trg_work_orders_updated_at
    BEFORE UPDATE ON dealer.work_orders
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER trg_employees_updated_at
    BEFORE UPDATE ON dealer.employees
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER trg_sales_targets_updated_at
    BEFORE UPDATE ON dealer.sales_targets
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER trg_order_tracking_updated_at
    BEFORE UPDATE ON dealer.order_tracking
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER trg_portal_accounts_updated_at
    BEFORE UPDATE ON dealer.customer_portal_accounts
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER trg_service_bookings_updated_at
    BEFORE UPDATE ON dealer.service_bookings
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
