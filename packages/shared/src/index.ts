// Shared types entry point

export interface Merchant {
  id: string;
  phone: string;
  display_name: string | null;
  dialect_code: string;
  created_at: string;
}

export interface Buyer {
  id: string;
  phone: string;
  name: string | null;
  created_at: string;
}

export interface LedgerEntry {
  id: string;
  merchant_id: string;
  buyer_id: string | null;
  item_description: string;
  quantity: number | null;
  unit: string | null;
  unit_price: number | null;
  total_amount: number;
  raw_transcript: string;
  currency: string;
  created_at: string;
}

export interface PaymentLink {
  id: string;
  ledger_entry_id: string;
  razorpay_link_id: string;
  razorpay_short_url: string;
  status: 'created' | 'paid' | 'expired' | 'cancelled';
  created_at: string;
}
