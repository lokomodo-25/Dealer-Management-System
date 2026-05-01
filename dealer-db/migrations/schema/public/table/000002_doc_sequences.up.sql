-- =====================================================
-- PUBLIC: Document sequence counter table
-- Used by public.next_doc_seq() for per-branch/type numbering
-- =====================================================

CREATE TABLE IF NOT EXISTS public.doc_sequences (
    seq_key     TEXT        NOT NULL,
    tenant_id   UUID        NOT NULL,
    last_seq    INT         NOT NULL DEFAULT 0,
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (seq_key)
);

CREATE INDEX IF NOT EXISTS idx_doc_sequences_tenant ON public.doc_sequences(tenant_id);
