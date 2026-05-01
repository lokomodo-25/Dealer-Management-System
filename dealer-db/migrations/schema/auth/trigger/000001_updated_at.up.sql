-- =====================================================
-- AUTH: updated_at triggers on all auth tables
-- =====================================================

CREATE TRIGGER trg_tenants_updated_at
    BEFORE UPDATE ON auth.tenants
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER trg_branches_updated_at
    BEFORE UPDATE ON auth.branches
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER trg_users_updated_at
    BEFORE UPDATE ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER trg_roles_updated_at
    BEFORE UPDATE ON auth.roles
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
