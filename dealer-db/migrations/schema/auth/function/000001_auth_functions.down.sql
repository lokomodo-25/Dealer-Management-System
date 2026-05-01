DROP FUNCTION IF EXISTS auth.write_audit(UUID, UUID, UUID, auth.action_enum, VARCHAR, UUID, JSONB, JSONB, INET);
DROP FUNCTION IF EXISTS auth.validate_login(UUID, VARCHAR, TEXT);
DROP FUNCTION IF EXISTS auth.get_user_role(UUID, UUID);
DROP FUNCTION IF EXISTS auth.user_has_permission(UUID, UUID, VARCHAR, auth.action_enum);
DROP FUNCTION IF EXISTS auth.get_user_permissions(UUID, UUID);
