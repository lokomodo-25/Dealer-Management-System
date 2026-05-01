-- =====================================================
-- DEALER: Business enum types
-- =====================================================

CREATE TYPE dealer.unit_status_enum AS ENUM (
    'INDENT',
    'TRANSIT',
    'READY',
    'RESERVED',
    'SOLD',
    'WIP',
    'DEMO',
    'RETUR'
);

CREATE TYPE dealer.spk_status_enum AS ENUM (
    'DRAFT',
    'WAITING_APPROVAL',
    'APPROVED',
    'DP_PAID',
    'PROSES_DOK',
    'SIAP_SERAH',
    'SELESAI',
    'BATAL'
);

CREATE TYPE dealer.wo_status_enum AS ENUM (
    'BOOKING',
    'ANTRIAN',
    'PROSES',
    'QC',
    'SELESAI',
    'INVOICE',
    'BATAL'
);

CREATE TYPE dealer.tracking_stage_enum AS ENUM (
    'SPK_DIBUAT',
    'DP_DITERIMA',
    'PO_DIKIRIM_ATPM',
    'KONFIRMASI_ATPM',
    'PROSES_PRODUKSI',
    'PENGIRIMAN_KE_DEALER',
    'UNIT_TIBA_DEALER',
    'PERSIAPAN_PDI',
    'PROSES_DOKUMEN',
    'SIAP_SERAH',
    'SERAH_TERIMA',
    'SELESAI'
);

CREATE TYPE dealer.financing_status_enum AS ENUM (
    'DRAFT',
    'SUBMITTED',
    'SURVEY',
    'APPROVED',
    'REJECTED',
    'CAIR',
    'BATAL'
);

CREATE TYPE dealer.payment_method_enum AS ENUM (
    'CASH',
    'KREDIT',
    'TUNAI_BERTAHAP'
);

CREATE TYPE dealer.prospect_stage_enum AS ENUM (
    'COLD',
    'WARM',
    'HOT',
    'SPK',
    'SERAH',
    'LOST'
);

CREATE TYPE dealer.activity_type_enum AS ENUM (
    'CALL',
    'WA',
    'VISIT',
    'TEST_DRIVE',
    'EMAIL',
    'FOLLOW_UP'
);

CREATE TYPE dealer.stock_movement_type_enum AS ENUM (
    'IN',
    'OUT',
    'ADJUSTMENT',
    'RETUR'
);

CREATE TYPE dealer.notification_channel_enum AS ENUM (
    'WA',
    'EMAIL',
    'PUSH'
);

CREATE TYPE dealer.notification_status_enum AS ENUM (
    'PENDING',
    'SENT',
    'FAILED',
    'SKIPPED'
);

CREATE TYPE dealer.tracking_type_enum AS ENUM (
    'READY_STOCK',
    'PO_INDENT'
);
