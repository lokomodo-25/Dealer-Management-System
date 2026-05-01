BEGIN;
DELETE FROM auth.role_permissions;
DELETE FROM auth.permissions;
DELETE FROM auth.roles WHERE is_system = TRUE;
COMMIT;
