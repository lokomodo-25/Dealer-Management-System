# CLAUDE.md — Dealer & Showroom Management System
> File ini dibaca otomatis oleh Claude Code. Berisi konteks penuh proyek agar tidak perlu dijelaskan ulang setiap sesi.

---

## Gambaran Proyek

Sistem manajemen dealer / showroom kendaraan bermotor untuk pasar **Indonesia**. Dibangun sebagai **multi-panel WebApp** yang terintegrasi langsung dengan PostgreSQL — **tanpa Supabase**, self-hosted penuh.

Proyek ini mencakup dua sisi:
- **Sisi dealer** (internal): Admin, Sales/CRM, Finance, Service/Bengkel, Inventory/Gudang, HR
- **Sisi customer** (eksternal): Customer Portal dengan order tracking, notifikasi, dan feedback

---

## Keputusan Arsitektur yang Sudah Ditetapkan

### Database
- **Engine**: PostgreSQL 16 (self-hosted, bukan Supabase)
- **Migration**: `go-migrate` — satu-satunya tool yang boleh mengubah schema
- **ORM query**: Prisma (CRUD standar) + Drizzle (query kompleks/JOIN banyak) — keduanya dipakai, **tidak** untuk migrate
- **Connection pooling**: PgBouncer untuk production
- **Auth**: NextAuth.js v5 (JWT strategy) — bukan Supabase Auth
- **File storage**: Cloudflare R2 — bukan Supabase Storage
- **Realtime**: Server-Sent Events atau polling — bukan Supabase Realtime

### Multi-Tenancy
- Satu deployment melayani banyak dealer (tenant)
- Setiap tabel bisnis wajib punya kolom `tenant_id`
- Row Level Security (RLS) aktif langsung di PostgreSQL
- Isolasi tenant via: `SET LOCAL app.current_tenant_id = '{uuid}'` di setiap request

### RBAC (Role-Based Access Control)
10 system roles yang sudah didefinisikan:
```
SUPER_ADMIN → ADMIN → SALES_MANAGER → SALES
                                     → FINANCE
                                     → SERVICE_MGR → MEKANIK
                                     → GUDANG
                                     → HR
                                     → VIEWER
```
- Satu user bisa punya role berbeda di cabang berbeda (tabel `user_branch_roles`)
- `branch_id = NULL` di `user_branch_roles` = akses semua cabang dalam tenant
- Permission scope: `ALL` | `OWN_BRANCH` | `OWN_DATA`

---

## Status Migrasi Database

### File yang sudah ada di `dealer-db/migrations/`:

| File | Status | Isi |
|------|--------|-----|
| `V1__rbac_users_tenants.sql` | Selesai | Extensions, enums RBAC, tenants, branches, users, roles, permissions, role_permissions, user_branch_roles, user_sessions, audit_logs (partitioned) |
| `V2__crm_spk_units.sql` | Selesai | vehicle_models, vehicle_units, customers, prospects, prospect_activities, test_drives, spk, spk_accessories, serah_terima |
| `V3__finance_inventory_service_portal.sql` | Selesai | financing_applications, invoices, commission_rules/ledger, spare_parts, part_stocks, stock_movements, service_bookings, work_orders, wo_jobs, wo_parts, service_ratings, employees, sales_targets, attendances, customer_portal_accounts, order_tracking, tracking_stage_logs, po_indent_tracking, tracking_document_links, notification_templates, customer_notifications, customer_feedback, service_reminders |

### Seed data yang sudah ada di `dealer-db/seeds/`:
- `S01_foundation.sql` — 3 tenants, 4 branches, 10 roles, 9 users dengan role assignment
- `S02_master_data_transactions.sql` — 7 vehicle models, 10 unit stok, 10 customers, 7 prospects, 3 SPK (berbagai status), 2 WO, 10 spare parts, commission rules, customer portal accounts, feedback, notification templates

### Default credentials (dev only, password: `Admin1234!`):
| Email | Role |
|-------|------|
| superadmin@autostar.id | SUPER_ADMIN |
| admin.bdg@autostar.id | ADMIN |
| budi.santoso@autostar.id | SALES |
| finance.bdg@autostar.id | FINANCE |
| foreman.bdg@autostar.id | SERVICE_MGR |
| mekanik1.bdg@autostar.id | MEKANIK |
| gudang.bdg@autostar.id | GUDANG |

---

## Trigger Database Kritis (Jangan Diubah Tanpa Pertimbangan)

```
spk_approve_reserve_unit     → SPK APPROVED: unit status → RESERVED
                               SPK BATAL: unit status → READY
serah_terima_finalize        → BAST insert: unit → SOLD, customer.total_unit_beli++, SPK → SELESAI
spk_create_tracking          → SPK APPROVED: auto-buat order_tracking + log stage pertama
serah_terima_update_tracking → BAST insert: order_tracking → SELESAI (100%)
wo_parts_deduct_stock        → WO parts insert: qty_on_hand berkurang + stock_movements log
update_sales_target_realisasi→ SPK SELESAI: sales_targets.realisasi_unit/revenue ++
```

---

## Entitas Utama & Relasinya

```
tenants (1) ──── (N) branches
tenants (1) ──── (N) roles
users   (N) ──── (M) branches + roles  [via user_branch_roles]

vehicle_units ← INTI → spk → serah_terima
                         ↓
                 financing_applications
                 invoices
                 commission_ledger
                 order_tracking → tracking_stage_logs
                                → po_indent_tracking (jika INDENT)

customers → prospects → prospect_activities
customers → spk
customers → work_orders
customers → customer_portal_accounts → customer_notifications
customers → customer_feedback

vehicle_units → work_orders → wo_jobs (per mekanik)
                            → wo_parts → stock_movements (auto deduct)
```

---

## Enum Status Kritis

```sql
-- Unit kendaraan
unit_status_enum: INDENT | TRANSIT | READY | RESERVED | SOLD | WIP | DEMO | RETUR

-- SPK
spk_status_enum: DRAFT | WAITING_APPROVAL | APPROVED | DP_PAID | PROSES_DOK | SIAP_SERAH | SELESAI | BATAL

-- Work Order
wo_status_enum: BOOKING | ANTRIAN | PROSES | QC | SELESAI | INVOICE | BATAL

-- Order Tracking (Customer Portal)
tracking_stage_enum:
  SPK_DIBUAT → DP_DITERIMA → [jika INDENT: PO_DIKIRIM_ATPM → KONFIRMASI_ATPM →
  PROSES_PRODUKSI → PENGIRIMAN_KE_DEALER → UNIT_TIBA_DEALER] →
  PERSIAPAN_PDI → PROSES_DOKUMEN → SIAP_SERAH → SERAH_TERIMA → SELESAI

-- Financing
financing_status_enum: DRAFT | SUBMITTED | SURVEY | APPROVED | REJECTED | CAIR | BATAL
```

---

## Nomor Dokumen Auto-Generate (Format)

| Dokumen | Format | Contoh |
|---------|--------|--------|
| No. Prospect | `PRO-{KODE_CAB}-{YY}{MM}-{SEQ3}` | PRO-BDG-2501-001 |
| No. SPK | `{KODE_CAB}-{YY}{MM}-{SEQ5}` | BDG-2501-00001 |
| No. WO | `WO-{KODE_CAB}-{YY}{MM}-{SEQ3}` | WO-BDG-2502-001 |
| No. BAST | `BAST-{KODE_CAB}-{YY}{MM}-{SEQ5}` | BAST-BDG-2501-00001 |
| No. Invoice | format sama dengan SPK, prefix INV | INV-BDG-2501-00001 |
| NIK Karyawan | `EMP-{KODE_CAB}-{SEQ3}` | EMP-BDG-001 |

Sequence di-generate di application layer, bukan DB sequence, agar bisa prefix per cabang.

---

## Konteks Bisnis Indonesia (Penting untuk Logic Aplikasi)

- **OTR** (On The Road): Harga sudah termasuk pajak, BBNKB, STNK, plat nomor
- **BPKB**: Buku Pemilik Kendaraan Bermotor — dokumen kepemilikan utama
- **STNK**: Surat Tanda Nomor Kendaraan — dokumen operasional
- **BBNKB**: Bea Balik Nama Kendaraan Bermotor — pajak mutasi nama
- **SPK**: Surat Pesanan Kendaraan — kontrak jual beli
- **BAST**: Berita Acara Serah Terima — dokumen resmi serah terima unit
- **PKB**: Perawatan Kendaraan Berkala — sinonim WO untuk servis berkala
- **PPN**: 11% (tarif berlaku saat ini)
- **PPh 21**: Dipotong dari komisi sales
- **Leasing lokal**: BCA Finance, Adira, FIF, BAF, Oto Finance, Mandiri Tunas
- **ATPM**: Agen Tunggal Pemegang Merek (Toyota, Honda, dll) — sumber unit indent

---

## Customer Portal — Fitur Khusus

Dua mode akses:
1. **Tanpa login** — via `tracking_token` (link WA): bisa lihat status dan stage log
2. **Dengan login** (OTP ke nomor HP): bisa download dokumen, buat booking servis, lihat riwayat

Dua jalur order tracking:
- **READY_STOCK**: 5 stage (SPK → PDI → Dokumen → Siap serah → Selesai)
- **PO_INDENT**: 9 stage (tambah: PO ke ATPM → konfirmasi → produksi → pengiriman → tiba)

Notifikasi otomatis via trigger database → queue di `customer_notifications` → background job kirim ke WA/Email/Push.

---

## Tech Stack (Sudah Ditetapkan)

### Frontend
| Tool | Versi | Keterangan |
|------|-------|------------|
| **Next.js** | 14+ (App Router) | Framework utama. Gunakan App Router — bukan Pages Router. Server Components untuk halaman data-heavy, Client Components hanya jika ada interaktivitas. |
| **TypeScript** | 5+ | Strict mode aktif. Semua props, return type, dan API response harus typed. |
| **Tailwind CSS** | 3+ | Utility-first. Jangan tulis CSS custom kecuali benar-benar perlu. Gunakan `cn()` dari `clsx` + `tailwind-merge` untuk conditional classes. |
| **shadcn/ui** | Latest | Component library di atas Radix UI + Tailwind. Install per-komponen (`npx shadcn-ui@latest add button`), bukan install semua sekaligus. Komponen hidup di `components/ui/` dan boleh dimodifikasi langsung. |

### Database & ORM
| Tool | Keterangan |
|------|------------|
| **PostgreSQL 16** | Engine utama. Self-hosted. |
| **Prisma ORM** | Untuk operasi CRUD standar, type generation, dan query builder. Schema di `prisma/schema.prisma`. |
| **Drizzle ORM** | Untuk query kompleks, raw SQL yang perlu type-safety, atau query dengan banyak JOIN. Bisa dipakai berdampingan dengan Prisma — Drizzle untuk "heavy query", Prisma untuk CRUD. |
| **go-migrate** | **Satu-satunya tool untuk migrasi schema**. Jangan gunakan `prisma migrate` atau `drizzle-kit push` untuk mengubah schema production. Semua perubahan schema melalui file SQL di `dealer-db/migrations/`. |

> **Penting — pemisahan tanggung jawab:**
> - `go-migrate` → mengubah schema database (DDL: CREATE TABLE, ALTER, INDEX, dll)
> - `Prisma` / `Drizzle` → hanya untuk query data (DML: SELECT, INSERT, UPDATE, DELETE)
> - Jangan pernah jalankan `prisma db push` atau `drizzle-kit push` ke database yang sudah ada migration-nya

### Tooling Migrasi: go-migrate
```bash
# Install
go install -tags 'postgres' github.com/golang-migrate/migrate/v4/cmd/migrate@latest

# Jalankan semua migrasi pending
migrate -path dealer-db/migrations -database "postgres://dealer_app:dealer_dev_2025@localhost:5432/dealer_db?sslmode=disable" up

# Rollback 1 step
migrate -path dealer-db/migrations -database "..." down 1

# Cek versi aktif
migrate -path dealer-db/migrations -database "..." version

# Buat file migrasi baru
migrate create -ext sql -dir dealer-db/migrations -seq nama_migrasi
# → menghasilkan: {timestamp}_nama_migrasi.up.sql dan {timestamp}_nama_migrasi.down.sql
```

> **Catatan format file go-migrate:** File migrasi yang sudah ada menggunakan format `V{n}__nama.sql` (Flyway-style). Untuk go-migrate, file baru harus mengikuti format `{timestamp}_{nama}.up.sql` dan `{timestamp}_{nama}.down.sql`. Pertimbangkan untuk rename file yang ada atau gunakan flag `-path` custom.

### Auth & Infrastruktur
| Tool | Keterangan |
|------|------------|
| **NextAuth.js v5** | Auth. Gunakan JWT strategy + credentials provider untuk login email/password. Simpan `tenantId`, `branchId`, `roleCode` dalam JWT payload. |
| **Cloudflare R2** | File storage (foto unit, dokumen KTP, BAST, dll). Kompatibel dengan S3 SDK. |
| **Fonnte / WABA** | Notifikasi WhatsApp. Fonnte untuk awal (lebih mudah), WABA resmi untuk production skala besar. |
| **PgBouncer** | Connection pooling untuk production. Tidak diperlukan saat development. |

---

## Struktur Folder Aplikasi (Konvensi)

```
dealer-management/
├── CLAUDE.md
├── dealer-db/                    # Semua hal terkait database
│   ├── migrations/               # File SQL go-migrate
│   ├── seeds/                    # Data dummy
│   ├── scripts/
│   └── docker-compose.yml
└── apps/
    └── web/                      # Next.js app
        ├── app/                  # App Router
        │   ├── (auth)/           # Route group: halaman login/register
        │   ├── (dealer)/         # Route group: semua panel dealer (butuh auth)
        │   │   ├── dashboard/
        │   │   ├── showroom/
        │   │   ├── crm/
        │   │   ├── spk/
        │   │   ├── finance/
        │   │   ├── service/
        │   │   ├── inventory/
        │   │   └── hr/
        │   ├── (portal)/         # Route group: customer portal (auth berbeda)
        │   │   ├── track/[token]/  # Akses tanpa login via token
        │   │   └── my/             # Halaman customer yang login
        │   └── api/              # API Routes / Route Handlers
        │       ├── auth/
        │       ├── units/
        │       ├── spk/
        │       ├── tracking/
        │       └── ...
        ├── components/
        │   ├── ui/               # shadcn components (jangan diubah strukturnya)
        │   ├── shared/           # Komponen yang dipakai banyak panel
        │   └── panels/           # Komponen spesifik per panel
        ├── lib/
        │   ├── db/               # Prisma client + Drizzle instance
        │   │   ├── prisma.ts
        │   │   └── drizzle.ts
        │   ├── auth.ts           # NextAuth config
        │   ├── permissions.ts    # Helper cek RBAC permission
        │   └── utils.ts          # cn(), formatRupiah(), dll
        ├── types/                # TypeScript types & interfaces
        │   ├── database.ts       # Types dari Prisma generate
        │   └── api.ts            # Request/response types
        └── prisma/
            └── schema.prisma     # Prisma schema (reflect-only, jangan push)
```

---

## Cara Setup Database Lokal

```bash
# 1. Jalankan PostgreSQL
cd dealer-db
docker compose up -d

# 2. Jalankan migrasi via go-migrate
migrate \
  -path dealer-db/migrations \
  -database "postgres://dealer_app:dealer_dev_2025@localhost:5432/dealer_db?sslmode=disable" \
  up

# 3. Jalankan seed (manual via psql)
psql -h localhost -p 5432 -U dealer_app -d dealer_db -f dealer-db/seeds/S01_foundation.sql
psql -h localhost -p 5432 -U dealer_app -d dealer_db -f dealer-db/seeds/S02_master_data_transactions.sql

# 4. Koneksi langsung
psql -h localhost -p 5432 -U dealer_app -d dealer_db
# pgAdmin: http://localhost:5050 (admin@dealer.local / admin123)
```

Connection string untuk aplikasi:
```bash
# .env.local
DATABASE_URL="postgresql://dealer_app:dealer_dev_2025@localhost:5432/dealer_db"
DIRECT_URL="postgresql://dealer_app:dealer_dev_2025@localhost:5432/dealer_db"
```

### Setup Prisma (introspect dari schema yang sudah ada)
```bash
cd apps/web

# Install
npm install prisma @prisma/client
npx prisma init --datasource-provider postgresql

# Introspect schema dari DB yang sudah ada (jangan push!)
npx prisma db pull

# Generate Prisma Client
npx prisma generate
```

### Setup Drizzle (untuk query kompleks)
```bash
npm install drizzle-orm pg
npm install -D drizzle-kit @types/pg

# drizzle.config.ts
# introspect jika perlu, tapi utamanya pakai sebagai query builder saja
```

---

## Conventions yang Harus Diikuti

### Database
- Semua tabel bisnis: wajib ada `tenant_id`, `created_at`, `updated_at`
- Soft delete: gunakan `deleted_at TIMESTAMPTZ` — jangan hard delete di tabel transaksi
- UUID v4 untuk semua primary key (bukan integer auto-increment)
- Enum didefinisikan di PostgreSQL, bukan hanya di aplikasi
- Semua trigger dalam bahasa `plpgsql`, didefinisikan di migration file
- Index wajib untuk: `tenant_id`, `branch_id`, FK yang sering di-JOIN, kolom status yang sering difilter
- **Jangan** jalankan `prisma db push`, `prisma migrate dev`, atau `drizzle-kit push` — semua perubahan schema via go-migrate

### go-migrate
- File migrasi baru: `migrate create -ext sql -dir dealer-db/migrations -seq nama_migrasi`
- Selalu buat file `.down.sql` untuk rollback — wajib diisi, bukan dikosongkan
- Jalankan `migrate up` sebelum mulai coding di hari yang sama jika ada migration baru
- Jangan edit file migrasi yang sudah pernah dijalankan ke database manapun

### Prisma
- Jalankan `prisma db pull` + `prisma generate` setelah setiap go-migrate berhasil
- Gunakan Prisma untuk: findMany, findUnique, create, update, delete — operasi per-tabel
- Jangan gunakan Prisma untuk query dengan 4+ JOIN atau aggregasi kompleks — pakai Drizzle

### Drizzle
- Gunakan untuk: query BI/dashboard, laporan dengan banyak JOIN, aggregasi GROUP BY
- Tulis sebagai raw SQL dengan Drizzle's `sql` template literal untuk query yang sangat kompleks
- Schema Drizzle cukup untuk tabel yang sering di-query kompleks — tidak perlu semua tabel

### Next.js & TypeScript
- App Router — selalu, bukan Pages Router
- Server Components by default; tambahkan `'use client'` hanya jika ada state/event handler
- Semua API response harus punya type — definisikan di `types/api.ts`
- Gunakan `formatRupiah()` untuk semua tampilan angka mata uang — jangan format manual
- Gunakan `cn()` (clsx + tailwind-merge) untuk semua conditional class Tailwind

### shadcn/ui
- Install komponen per kebutuhan: `npx shadcn-ui@latest add {component}`
- Komponen di `components/ui/` boleh dimodifikasi untuk kebutuhan proyek
- Gunakan `variants` dari shadcn untuk variasi komponen — jangan buat komponen duplikat

---

## Roadmap Implementasi Berikutnya

**Phase 1 (sekarang)**: Validasi schema DB → Setup go-migrate → `prisma db pull` (introspect) → API Auth (login, JWT, refresh token)

**Phase 2**: API core — Unit listing, SPK CRUD, Customer portal tracking endpoint

**Phase 3**: Frontend panels — mulai dari Showroom Panel (paling sering dipakai sales)

**Phase 4**: Notifikasi WA, BI dashboard, laporan export

---

*Terakhir diupdate: Berdasarkan sesi desain lengkap di Claude.ai — mencakup ERD, RBAC, Customer Portal, dan migrasi database.*
