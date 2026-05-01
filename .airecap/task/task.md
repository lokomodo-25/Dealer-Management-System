# Task: Full Application Setup — Dealer Management System
> Created: 2026-05-01 | Status: COMPLETE

---

## What was done

### Phase 1-2: dealer-db structure
- `dealer-db/docker-compose.yml` — PostgreSQL 16 + pgAdmin
- `dealer-db/.env.example`
- `dealer-db/Makefile` — AZCA-style per-schema/per-type migration commands

### Phase 3: Database Migrations — 66 SQL files (33 up + 33 down)
3 schemas × 4 tracks:

**public/table**: extensions (uuid-ossp, pgcrypto, pg_trgm), doc_sequences
**public/function**: set_updated_at, hash_password, next_doc_seq, normalize_search

**auth/table**: schema, enums, tenants, branches, users, roles+permissions, sessions+audit_logs (partitioned)
**auth/function**: validate_login, get_user_permissions, user_has_permission, write_audit
**auth/trigger**: updated_at on all auth tables
**auth/seed**: 10 system roles + 40+ permissions, 3 tenants, 4 branches, 9 users

**dealer/table**: schema, enums (12 types), vehicle_models+units, CRM, SPK+BAST, finance, inventory, service, HR, portal (10 migrations)
**dealer/function**: doc number generators (SPK/WO/BAST/INV/PRO/EMP), calc_angsuran, calc_komisi, stage_to_pct, advance_tracking_stage
**dealer/trigger**: spk_approve_reserve_unit, serah_terima_finalize, spk_create_tracking, serah_terima_update_tracking, wo_parts_deduct_stock, update_sales_target_realisasi, updated_at (17 tables)
**dealer/seed**: 7 vehicle models, 10 spare parts, 10 part stocks, commission rules, 7 notification templates; 10 units, 5 customers, 3 prospects, 3 SPK samples

### Phase 4: Next.js Application
- `apps/web/` — Next.js 14 App Router + TypeScript + Tailwind
- shadcn/ui initialized + components: button, card, input, label, sonner
- `lib/db/prisma.ts` — Prisma singleton
- `lib/db/drizzle.ts` — Drizzle + pg Pool
- `lib/auth.ts` — NextAuth v5 credentials provider, JWT strategy, tenant-aware login
- `lib/permissions.ts` — checkPermission, requirePermission, requireAuth via DB functions
- `lib/utils.ts` — cn, formatRupiah, formatDate, formatDateTime, calcAngsuran
- `types/api.ts` — all status enums + ApiResponse types
- `types/next-auth.d.ts` — session augmentation (tenantId, branchId, roleCode)
- `middleware.ts` — auth guard for dealer routes
- Route groups: `(auth)/login`, `(dealer)/dashboard|showroom|crm|spk|finance|service|inventory|hr`, `(portal)/track/[token]|my`
- `app/api/auth/[...nextauth]/route.ts`
- `prisma/schema.prisma` — configured for db pull
- `drizzle.config.ts`
- `.env.local` template

---

## Next Steps (Phase 2 in roadmap)
1. Start DB: `cd dealer-db && make db.up`
2. Run migrations: `make migrate.all`
3. Introspect: `make prisma.pull`
4. Start dev: `cd apps/web && npm run dev`
5. Implement: Unit listing API → SPK CRUD API → Customer Portal tracking API
