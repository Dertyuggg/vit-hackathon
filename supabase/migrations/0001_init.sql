-- Merchants table
CREATE TABLE public.merchants (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    phone TEXT UNIQUE NOT NULL,
    display_name TEXT,
    dialect_code TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Buyers table
CREATE TABLE public.buyers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    phone TEXT UNIQUE NOT NULL,
    name TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Ledger Entries table (append-only)
CREATE TABLE public.ledger_entries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    merchant_id UUID NOT NULL REFERENCES public.merchants(id),
    buyer_id UUID REFERENCES public.buyers(id),
    item_description TEXT NOT NULL,
    quantity NUMERIC,
    unit TEXT,
    unit_price NUMERIC,
    total_amount NUMERIC NOT NULL,
    raw_transcript TEXT NOT NULL,
    currency TEXT NOT NULL DEFAULT 'INR',
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Payment Links table
CREATE TABLE public.payment_links (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ledger_entry_id UUID NOT NULL REFERENCES public.ledger_entries(id),
    razorpay_link_id TEXT NOT NULL,
    razorpay_short_url TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'created',
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Row Level Security (RLS)
ALTER TABLE public.merchants ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.buyers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ledger_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payment_links ENABLE ROW LEVEL SECURITY;

-- Policies
CREATE POLICY "Merchants can view their own profile"
    ON public.merchants FOR SELECT
    USING (auth.uid() = id);

CREATE POLICY "Merchants can update their own profile"
    ON public.merchants FOR UPDATE
    USING (auth.uid() = id);

-- For buyers, merchants can view buyers they have transactions with, but for now we might keep it simple:
CREATE POLICY "Merchants can view all buyers"
    ON public.buyers FOR SELECT
    TO authenticated
    USING (true);

-- Ledger entries: Merchants can only view and insert their own entries
CREATE POLICY "Merchants can view their own ledger entries"
    ON public.ledger_entries FOR SELECT
    USING (auth.uid() = merchant_id);

CREATE POLICY "Merchants can insert their own ledger entries"
    ON public.ledger_entries FOR INSERT
    WITH CHECK (auth.uid() = merchant_id);

-- Payment links: Merchants can only view payment links for their own ledger entries
CREATE POLICY "Merchants can view payment links for their ledger entries"
    ON public.payment_links FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.ledger_entries
            WHERE ledger_entries.id = payment_links.ledger_entry_id
            AND ledger_entries.merchant_id = auth.uid()
        )
    );
