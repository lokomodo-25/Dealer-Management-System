BEGIN;
DELETE FROM auth.user_branch_roles WHERE user_id LIKE '44444444-%';
DELETE FROM auth.users       WHERE id::TEXT LIKE '44444444-%';
DELETE FROM auth.branches    WHERE id::TEXT LIKE '22222222-%';
DELETE FROM auth.tenants     WHERE id::TEXT LIKE '11111111-%';
COMMIT;
