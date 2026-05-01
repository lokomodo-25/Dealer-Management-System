-- =====================================================
-- PUBLIC: Shared Utility Functions
-- =====================================================

-- Trigger function: auto-update updated_at on row change
CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;

-- Hash password using pgcrypto bcrypt
CREATE OR REPLACE FUNCTION public.hash_password(plain_password TEXT)
RETURNS TEXT
LANGUAGE plpgsql AS $$
BEGIN
    RETURN crypt(plain_password, gen_salt('bf', 12));
END;
$$;

-- Verify password
CREATE OR REPLACE FUNCTION public.verify_password(plain_password TEXT, hashed TEXT)
RETURNS BOOLEAN
LANGUAGE plpgsql AS $$
BEGIN
    RETURN hashed = crypt(plain_password, hashed);
END;
$$;

-- Generate document sequence number with zero-padding
-- Usage: public.next_doc_seq('BDG', 'spk', 2501, 5) → '00001'
CREATE OR REPLACE FUNCTION public.next_doc_seq(
    p_tenant_id UUID,
    p_branch_code VARCHAR,
    p_doc_type VARCHAR,
    p_year_month VARCHAR,  -- e.g. '2501'
    p_pad INT DEFAULT 5
)
RETURNS TEXT
LANGUAGE plpgsql AS $$
DECLARE
    v_seq INT;
    v_key TEXT;
BEGIN
    v_key := p_branch_code || '.' || p_doc_type || '.' || p_year_month || '.' || p_tenant_id::TEXT;

    -- Upsert sequence counter in public.doc_sequences
    INSERT INTO public.doc_sequences (seq_key, tenant_id, last_seq)
    VALUES (v_key, p_tenant_id, 1)
    ON CONFLICT (seq_key) DO UPDATE
        SET last_seq = public.doc_sequences.last_seq + 1
    RETURNING last_seq INTO v_seq;

    RETURN lpad(v_seq::TEXT, p_pad, '0');
END;
$$;

-- Normalize search text (lowercase + unaccent)
CREATE OR REPLACE FUNCTION public.normalize_search(input TEXT)
RETURNS TEXT
LANGUAGE sql IMMUTABLE AS $$
    SELECT lower(unaccent(trim(input)));
$$;
