# NLU Approach — Extracting Structured Sales Data From a Transcript

Once ASR produces a transcript (e.g. "Ramesh ko pचास kilo chawal do hazaar mein becha"), this layer extracts:

```ts
type ExtractedSale = {
  itemDescription: string;   // "rice" / "chawal"
  quantity: number;          // 50
  unit: string;              // "kilo" / "kg"
  unitPriceOrTotal: number;  // 2000 — ambiguous whether unit or total, see below
  priceType: "total" | "unit"; // best guess, confirm with merchant if uncertain
  buyerName: string | null;  // "Ramesh" — null if not mentioned
  confidence: "high" | "medium" | "low";
};
```

## Two-Tier Approach

**Tier 1 — rule-based extraction (default, fast, free, explainable).**
Pattern-match on quantity+unit (number + known unit word), price (number + currency word/symbol), and buyer name (proper noun near a "to"/"ko"/dative-marker pattern) using a small dictionary of unit words and number words per the target dialect. This handles the common, well-formed case cheaply and its failures are predictable/debuggable — important for a live demo where an LLM's occasional creative misfire would be worse than a rule-based miss.

**Tier 2 — LLM-based fallback for messy transcripts.**
When Tier 1 extraction is missing a required field or confidence is low, send the transcript to an LLM with a tightly constrained prompt asking only for the same structured JSON shape above, in the same target language/dialect as the transcript. This catches phrasing Tier 1's patterns didn't anticipate.

Do not skip straight to "always use an LLM" — for a live low-connectivity hackathon demo, an LLM call is a slower, less predictable, non-free dependency for what is often a simple pattern match. Use it as the safety net, not the primary path.

## Ambiguity Handling

Real speech is often ambiguous about whether a stated price is a unit price or a total (as in the deck's own example — "50 kilos of rice ... for 2000 rupees" reads naturally as a total, but a merchant could equally mean 2000/kg). When `priceType` confidence is not high:
- Default to treating the stated number as a **total**, since that matches the deck's canonical example and is the more common phrasing pattern in casual sales speech.
- Surface the interpreted total back to the merchant via a short audio playback/confirmation step ("50 kilo rice, 2000 rupees total, correct?") before writing the ledger entry — this single confirmation step does more for trust and accuracy than any amount of parser cleverness, and keeps the product's "no typing needed" promise intact (a yes/no voice or single-tap confirm, not a form).

## What Goes in the Ledger vs What's Discarded

Always store the **raw transcript** alongside the extracted structured fields in `ledger_entries.raw_transcript` (see `SETUP.md` §4 schema) — never discard it. If extraction logic is disputed or improved later, the raw transcript lets past entries be re-processed rather than being permanently lossy.

## Where the Model/Rules Live

`supabase/functions/nlu-extract` is the edge function boundary. Keep the rule-based extractor and the LLM fallback as swappable strategies behind one interface, so improving either doesn't require touching the calling code.
