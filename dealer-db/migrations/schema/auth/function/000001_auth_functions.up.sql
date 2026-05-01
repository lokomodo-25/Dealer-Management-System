-- =====================================================
-- AUTH: Business logic functions
-- =====================================================

-- Get all permissions for a user in a specific branch
CREATE OR REPLACE FUNCTION auth.get_user_permissions(
    p_user_id   UUID,
    p_branch_id UUID
)
RETURNS TABLE (resource VARCHAR, action auth.action_enum, scope auth.scope_enum)
LANGUAGE sql STABLE AS $$
    SELECT DISTINCT p.resource, p.action, p.scope
    FROM auth.user_branch_roles ubr
    JOIN auth.role_permissions rp ON rp.role_id = ubr.role_id
    JOIN auth.permissions p ON p.id = rp.permission_id
    WHERE ubr.user_id = p_user_id
      AND (ubr.branch_id = p_branch_id OR ubr.branch_id IS NULL);
$$;

-- Check if user has specific permission
CREATE OR REPLACE FUNCTION auth.user_has_permission(
    p_user_id   UUID,
    p_branch_id UUID,
    p_resource  VARCHAR,
    p_action    auth.action_enum
)
RETURNS BOOLEAN
LANGUAGE sql STABLE AS $$
    SELECT EXISTS (
        SELECT 1
        FROM auth.get_user_permissions(p_user_id, p_branch_id)
        WHERE resource = p_resource AND action = p_action
    );
$$;

-- Get user's primary role code in a branch
CREATE OR REPLACE FUNCTION auth.get_user_role(
    p_user_id   UUID,
    p_branch_id UUID
)
RETURNS auth.role_code_enum
LANGUAGE sql STABLE AS $$
    SELECT r.role_code
    FROM auth.user_branch_roles ubr
    JOIN auth.roles r ON r.id = ubr.role_id
    WHERE ubr.user_id = p_user_id
      AND (ubr.branch_id = p_branch_id OR ubr.branch_id IS NULL)
    ORDER BY ubr.branch_id NULLS LAST
    LIMIT 1;
$$;

-- Validate login: returns user row if credentials valid and account not locked
CREATE OR REPLACE FUNCTION auth.validate_login(
    p_tenant_id UUID,
    p_email     VARCHAR,
    p_password  TEXT
)
RETURNS TABLE (
    user_id     UUID,
    full_name   VARCHAR,
    is_locked   BOOLEAN,
    error_code  TEXT
)
LANGUAGE plpgsql AS $$
DECLARE
    v_user auth.users%ROWTYPE;
BEGIN
    SELECT * INTO v_user
    FROM auth.users
    WHERE tenant_id = p_tenant_id
      AND email = lower(trim(p_email))
      AND deleted_at IS NULL;

    IF NOT FOUND THEN
        RETURN QUERY SELECT NULL::UUID, NULL::VARCHAR, FALSE, 'USER_NOT_FOUND';
        RETURN;
    END IF;

    IF NOT v_user.is_active THEN
        RETURN QUERY SELECT NULL::UUID, NULL::VARCHAR, FALSE, 'USER_INACTIVE';
        RETURN;
    END IF;

    IF v_user.locked_until IS NOT NULL AND v_user.locked_until > NOW() THEN
        RETURN QUERY SELECT NULL::UUID, NULL::VARCHAR, TRUE, 'ACCOUNT_LOCKED';
        RETURN;
    END IF;

    IF NOT public.verify_password(p_password, v_user.password_hash) THEN
        -- Increment failed login counter, lock after 5 attempts
        UPDATE auth.users SET
            failed_login_count = failed_login_count + 1,
            locked_until = CASE WHEN failed_login_count + 1 >= 5
                           THEN NOW() + INTERVAL '30 minutes'
                           ELSE NULL END
        WHERE id = v_user.id;
        RETURN QUERY SELECT NULL::UUID, NULL::VARCHAR, FALSE, 'INVALID_PASSWORD';
        RETURN;
    END IF;

    -- Reset on success
    UPDATE auth.users SET
        failed_login_count = 0,
        locked_until = NULL,
        last_login_at = NOW()
    WHERE id = v_user.id;

    RETURN QUERY SELECT v_user.id, v_user.full_name, FALSE, NULL::TEXT;
END;
$$;

-- Create audit log entry
CREATE OR REPLACE FUNCTION auth.write_audit(
    p_tenant_id     UUID,
    p_user_id       UUID,
    p_branch_id     UUID,
    p_action        auth.action_enum,
    p_resource      VARCHAR,
    p_resource_id   UUID,
    p_old_data      JSONB DEFAULT NULL,
    p_new_data      JSONB DEFAULT NULL,
    p_ip_address    INET DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO auth.audit_logs (
        tenant_id, user_id, branch_id, action, resource,
        resource_id, old_data, new_data, ip_address
    ) VALUES (
        p_tenant_id, p_user_id, p_branch_id, p_action, p_resource,
        p_resource_id, p_old_data, p_new_data, p_ip_address
    );
END;
$$;
