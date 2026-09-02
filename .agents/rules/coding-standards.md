# Rule: Coding Standards

## General

- **TypeScript everywhere** in `apps/web` and `supabase/functions` — no plain `.js` files added going forward. `strict: true` in every `tsconfig.json`.
- **No `any`.** If a type is genuinely unknown (e.g. a raw ASR provider response before validation), type it `unknown` and narrow it, don't silence the checker with `any`.
- Shared types (e.g. the shape of a `LedgerEntry`, an ASR transcript result, a payment-link response) live in `packages/shared` and are imported by both `apps/web` and `supabase/functions` — never duplicated by hand in two places.
- Prefer small, named functions over long inline logic, especially in edge functions where each function should read as: validate input → do the one thing → return typed output.

## React / Frontend

- Functional components + hooks only. No class components.
- One component per file, file name matches component name (`VoiceCaptureButton.tsx` exports `VoiceCaptureButton`).
- State: local `useState` for component-local UI state; `zustand` store only for state genuinely shared across screens (e.g. current merchant session). Don't reach for global state by default.
- **Accessibility is not optional here** — this product's entire premise is serving low-literacy users. Every interactive element needs an `aria-label` in the target dialect/language, sufficient tap-target size (44x44px minimum), and a non-text (icon/audio) affordance alongside any text.
- No inline styles; Tailwind utility classes only, aside from truly dynamic values (e.g. a computed waveform height).

## Supabase / Edge Functions

- Every edge function validates its input against a schema (use `zod`) before doing anything else, and returns a typed, consistent error shape on failure — never a bare 500 with no body.
- Never use the service-role key in any code path that could run in a browser. Service-role key usage is edge-function-only.
- Row Level Security policies are written and tested alongside the migration that creates the table — not added later as an afterthought.
- SQL migrations are additive by default (`ADD COLUMN`, new tables). A migration that drops a column or table requires calling it out explicitly and getting confirmation first, per the `stop-and-ask.md` rule.

## Naming

- Database: `snake_case` tables and columns, plural table names (`ledger_entries`, not `ledgerEntry`).
- TypeScript: `camelCase` variables/functions, `PascalCase` types/components, `SCREAMING_SNAKE_CASE` for true constants.
- Files: `kebab-case.ts` for non-component files, `PascalCase.tsx` for components.

## Comments & Documentation

- Comment the *why*, not the *what* — the code should already say what it does.
- Any function implementing a piece of business logic described in `docs/` (e.g. credit-scoring math, NLU extraction rules) should have a one-line comment linking back to the doc: `// see docs/CREDIT_SCORING_LOGIC.md §2`.
- Public-facing edge function endpoints get their contract documented in `docs/API_CONTRACTS.md` before or alongside implementation, not after.

## Testing

- MVP-stage: prioritize a handful of meaningful tests over broad shallow coverage. At minimum, test:
  - The NLU extraction function against a set of real (or realistic) sample transcripts, including messy/ambiguous ones
  - The ledger-write path for the append-only guarantee (attempt an update/delete and confirm it's rejected or simply not exposed)
  - The payment-link edge function's error handling when Razorpay returns an error
- Use `vitest` for frontend/shared unit tests. Don't introduce a second test runner without reason.

## Formatting

- Prettier + ESLint, default configs unless the human asks for specific overrides. Run `pnpm lint` and `pnpm format` before every commit — this should be close to automatic, not a separate manual step to remember.
