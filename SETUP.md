# SETUP.md — Swara Environment Setup

Follow this top to bottom on a fresh machine. Antigravity should run these steps itself when asked to "set up the project" rather than asking the human to do it manually, except for steps explicitly marked **[HUMAN]**.

---

## 1. Prerequisites

| Tool | Version | Check with |
|---|---|---|
| Node.js | 20 LTS or newer | `node -v` |
| pnpm | 9.x | `pnpm -v` (install: `npm install -g pnpm`) |
| Python | 3.11+ (only needed if self-hosting AI4Bharat ASR) | `python3 --version` |
| Git | any recent | `git --version` |
| Supabase CLI | latest | `supabase --version` (install: `npm install -g supabase`) |
| Antigravity IDE | latest | already installed if you're reading this inside it |

**[HUMAN]** Create accounts before starting (all have free tiers sufficient for a hackathon):
- [Supabase](https://supabase.com) — backend
- [Razorpay](https://razorpay.com) — payments (test mode keys are enough)
- [Vercel](https://vercel.com) — frontend hosting
- SMS provider — [MSG91](https://msg91.com) or [Twilio](https://twilio.com) (pick per `CONTEXT.md` Open Decision #2)
- Hugging Face account (free) if self-hosting AI4Bharat models, to pull model weights

---

## 2. Repository Bootstrap

```bash
mkdir swara && cd swara
git init
git checkout -b develop

pnpm init
pnpm add -D typescript @types/node

# Frontend app (PWA)
pnpm create vite@latest apps/web -- --template react-ts
cd apps/web
pnpm install
pnpm add -D tailwindcss postcss autoprefixer vite-plugin-pwa
pnpm exec tailwindcss init -p
cd ../..
```

Then create the folders that don't come from a scaffold tool:

```bash
mkdir -p supabase/migrations supabase/functions packages/shared docs .agents/rules .antigravity/workflows
```

Copy `AGENTS.md`, `CONTEXT.md`, this `SETUP.md`, and every file under `docs/`, `.agents/`, and `.antigravity/` (all provided alongside this file) into the repo root / matching subfolders.

---

## 3. Frontend Dependencies (`apps/web`)

```bash
pnpm add react-router-dom zustand
pnpm add @supabase/supabase-js
pnpm add clsx
pnpm add -D @types/react @types/react-dom eslint prettier eslint-config-prettier
```

Notes:
- `zustand` for lightweight client state — this app has few screens, don't reach for Redux.
- `@supabase/supabase-js` is the only client needed to talk to Supabase Auth, DB, and Storage from the browser.
- Audio recording uses the browser's native `MediaRecorder` API — no extra package needed for capture. If waveform visualization is wanted later, add `wavesurfer.js` then, not upfront.

Configure Tailwind (`apps/web/tailwind.config.js`) to scan `./index.html` and `./src/**/*.{ts,tsx}`.

Add PWA config in `vite.config.ts` via `vite-plugin-pwa` so the app is installable on Android home screens — this matters for the target users, who will not use a browser bookmark.

---

## 4. Backend: Supabase

```bash
supabase login          # [HUMAN] opens browser for auth
supabase init
supabase link --project-ref <your-project-ref>   # [HUMAN] get ref from Supabase dashboard
```

Initial schema — create `supabase/migrations/0001_init.sql` with (at minimum) these tables. Do not treat this as final DDL — refine with the human, but this is the right starting shape:

- `merchants` (id, phone, display_name, dialect_code, created_at)
- `buyers` (id, phone, name, created_at)
- `ledger_entries` (id, merchant_id, buyer_id, item_description, quantity, unit, unit_price, total_amount, raw_transcript, currency, created_at) — **append-only, no updated_at, no soft-delete column that implies mutation**
- `payment_links` (id, ledger_entry_id, razorpay_link_id, razorpay_short_url, status, created_at)

Apply with:
```bash
supabase db push
```

Enable Row Level Security on every table before writing any client-facing query. A merchant must only ever be able to read their own `ledger_entries`.

### Edge Functions

```bash
supabase functions new voice-ingest
supabase functions new nlu-extract
supabase functions new payment-link
supabase functions new sms-send
```

Each function gets its own `docs/API_CONTRACTS.md` entry describing its input/output shape before it's implemented — write the contract first, then the code.

---

## 5. ASR Setup

Two paths — pick based on `CONTEXT.md` Open Decision #3.

### Path A — Hosted API (fastest for a hackathon demo)
No install needed beyond an API key. Options to evaluate:
- **Bhashini** (Government of India's DPI for languages) — free/discounted API covering ASR for 22 scheduled languages, mission-aligned with this product's framing
- A commercial Indic ASR API (e.g., Sarvam AI's Saarika) — commercial, but often lower latency and easier auth than a government API

### Path B — Self-hosted AI4Bharat model
```bash
pip install torch torchaudio
git clone https://github.com/AI4Bharat/NeMo.git && cd NeMo && git checkout nemo-v2 && bash reinstall.sh
```
Then pull a model checkpoint from Hugging Face, e.g. `ai4bharat/indic-conformer-600m-multilingual`. This needs a GPU for real-time-ish inference — check whether the hackathon provides one before committing to this path. If not, use Path A for the demo and note Path B as the production plan.

Either way, do **not** default to plain OpenAI `whisper-1`/`large-v3` as the primary transcription path for regional dialect audio — see `docs/ASR_DECISION.md` for why.

---

## 6. Environment Variables

Create `.env.example` at repo root (never commit the real `.env`):

```
# Supabase
VITE_SUPABASE_URL=
VITE_SUPABASE_ANON_KEY=
SUPABASE_SERVICE_ROLE_KEY=          # server-side / edge functions only, NEVER in the frontend bundle

# Razorpay
RAZORPAY_KEY_ID=
RAZORPAY_KEY_SECRET=

# SMS (fill in whichever provider was chosen)
MSG91_AUTH_KEY=
MSG91_SENDER_ID=
# or
TWILIO_ACCOUNT_SID=
TWILIO_AUTH_TOKEN=
TWILIO_FROM_NUMBER=

# ASR
BHASHINI_API_KEY=
BHASHINI_UDYAT_KEY=
# or, if self-hosting, no key needed — set:
ASR_MODEL_ENDPOINT=
```

Add `.env` to `.gitignore` immediately, before it's ever created — verify with `git check-ignore .env` returning a match.

---

## 7. Running Locally

```bash
# Terminal 1 — Supabase local stack (optional; can also point straight at hosted project)
supabase start

# Terminal 2 — frontend
cd apps/web && pnpm dev

# Terminal 3 — serve edge functions locally
supabase functions serve
```

---

## 8. Verification Checklist

Run through this once setup is "done" — don't declare setup complete until every line here is checked:

- [ ] `pnpm install` at repo root succeeds with no errors
- [ ] `pnpm --filter web dev` starts and the app loads at `localhost:5173`
- [ ] `supabase status` shows all local services running (if using local stack)
- [ ] A row can be inserted into `ledger_entries` via the Supabase dashboard and read back from the frontend
- [ ] `.env` exists locally, is populated, and `git status` does NOT show it as trackable
- [ ] `pnpm lint` passes with zero errors
- [ ] A test audio clip can round-trip through whichever ASR path was chosen and return a transcript
