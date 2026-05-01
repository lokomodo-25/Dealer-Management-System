BEGIN;
DELETE FROM dealer.customer_portal_accounts WHERE customer_id::TEXT LIKE '88888888-%';
DELETE FROM dealer.spk         WHERE id::TEXT LIKE 'aaaaaaaa-%';
DELETE FROM dealer.prospects   WHERE id::TEXT LIKE '99999999-%';
DELETE FROM dealer.customers   WHERE id::TEXT LIKE '88888888-%';
DELETE FROM dealer.vehicle_units WHERE id::TEXT LIKE '66666666-%';
COMMIT;
