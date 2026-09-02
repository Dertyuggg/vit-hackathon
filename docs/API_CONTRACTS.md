# API Contracts — Edge Functions

Write each function's contract here **before** implementing it (per `.agents/rules/coding-standards.md` and the `new-feature` workflow). Keep this file the single source of truth for request/response shapes — don't let the code and this doc drift apart.

---

## `voice-ingest`

**Purpose:** accept a recorded audio clip from the frontend, run ASR, return a transcript. Does not write to the ledger yet — that's a separate confirmed step.

**Request:**
```ts
{
  merchantId: string;       // UUID
  audio: Blob | base64;     // format TBD based on chosen ASR provider's input requirements
  dialectCode: string;      // e.g. "hi-IN-bhojpuri" — matches merchants.dialect_code
}
```

**Response (success):**
```ts
{
  transcript: string;
  confidence: number;       // 0-1, from the ASR provider if it exposes one
  provider: "ai4bharat" | "whisper" | "bhashini";
}
```

**Response (error):** `{ error: string; code: "ASR_UNAVAILABLE" | "AUDIO_TOO_SHORT" | "INVALID_INPUT" }`

**Status:** not yet implemented. Depends on `CONTEXT.md` Open Decisions #1 and #3.

---

## `nlu-extract`

**Purpose:** take a transcript, return structured sale data per `docs/NLU_APPROACH.md`.

**Request:**
```ts
{ transcript: string; dialectCode: string; }
```

**Response:** the `ExtractedSale` shape defined in `docs/NLU_APPROACH.md`.

**Status:** not yet implemented.

---

## `payment-link`

**Purpose:** given a confirmed ledger entry, create a Razorpay payment link and persist it.

**Request:**
```ts
{ ledgerEntryId: string; amount: number; buyerPhone: string; }
```

**Response (success):**
```ts
{ paymentLinkId: string; shortUrl: string; status: "created"; }
```

**Response (error):** `{ error: string; code: "RAZORPAY_ERROR" | "INVALID_AMOUNT" | "LEDGER_ENTRY_NOT_FOUND" }`

**Status:** not yet implemented. Golden Rule: test mode only until explicitly told otherwise — see `.agents/rules/stop-and-ask.md` #4.

---

## `sms-send`

**Purpose:** send the buyer an SMS containing the payment link, in the appropriate regional language template.

**Request:**
```ts
{ buyerPhone: string; templateId: string; paymentUrl: string; merchantName: string; }
```

**Response:** `{ status: "sent" | "failed"; providerMessageId?: string; error?: string; }`

**Status:** not yet implemented. Provider not yet chosen — see `CONTEXT.md` Open Decision #2.

---

## Credit Profile Export (endpoint TBD — likely `credit-profile-export`)

**Purpose:** produce the bank-facing risk-profile export described in `docs/CREDIT_SCORING_LOGIC.md`.

**Status:** not designed yet — write the full contract here once the credit-scoring formula is implemented and the merchant-consent flow (see `docs/DATA_AND_PRIVACY.md`) is decided.
