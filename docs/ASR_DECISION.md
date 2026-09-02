# ASR Decision — Why AI4Bharat Over Plain Whisper

The original pitch deck names OpenAI Whisper as the voice engine. This doc records why the actual build plan leads with AI4Bharat's Indic-specific models instead, with Whisper kept only as a fallback — so a future session (or a judge asking a hard question) doesn't have to re-derive this.

## The Core Issue

Plain Whisper (including `large-v3`) was trained on a general multilingual corpus, not specifically on Indian regional dialects and code-switched, colloquial commerce speech. Historically, Indian-language ASR word error rates (WER) were 30-40% before Indic-specific datasets and fine-tuning existed — high enough to make "sold 50 kilos of rice for 2000 rupees" come out as something unrecognizable often enough to break user trust in a one-shot voice UI. Fine-tuned/specialized models bring major Indian languages below 10-12% WER in clean conditions.

## Recommended Approach

**Primary: AI4Bharat's IndicConformer or IndicWhisper.**
- Built by AI4Bharat (IIT Madras), trained on 300,000+ hours of raw speech and 6,000+ hours of transcribed data across 400+ districts, specifically to cover India's linguistic diversity.
- IndicConformer covers all 22 scheduled Indian languages; IndicWhisper is a Whisper fine-tuned on the Vistaar benchmark set (12 languages, 10,700+ hours) and has the lowest WER on the majority of Vistaar's 59 benchmarks.
- MIT-licensed, free to self-host, weights on Hugging Face (e.g. `ai4bharat/indic-conformer-600m-multilingual`).
- This is the same lineage of work behind Bhashini, so choosing it also keeps Swara's ML story aligned with India's own language-AI public infrastructure — a genuinely strong pitch point ("we built on India's own state-of-the-art, not a generic Western model").

**Fallback / comparison baseline: OpenAI Whisper.**
- Keep as a fallback path and as a baseline to measure the AI4Bharat model against on real sample audio — if a specific dialect performs surprisingly better on Whisper in testing, that's worth knowing, not something to assume away.

**For the hackathon demo specifically, two viable delivery modes** (see `CONTEXT.md` Open Decision #3 and `SETUP.md` §5):
- **Hosted API — Bhashini** (Government of India's Digital Public Infrastructure for languages): free/discounted API access to ASR across 22 languages, no GPU needed, fastest path to a working demo, and strengthens the "financial inclusion infrastructure" narrative.
- **Self-hosted AI4Bharat checkpoint**: more control and no per-call cost, but needs GPU inference — only pick this path if the hackathon environment provides one.
- A commercial Indic ASR API (e.g. Sarvam AI's Saarika) is a reasonable third option if Bhashini's onboarding/latency doesn't fit the demo timeline — commercial, but often simpler auth and lower latency.

## What NOT to Do

- Don't hardcode a single dialect's phonetic quirks into a bespoke regex/parser layer instead of using a real ASR model — that isn't the hard problem the pitch claims to solve, and judges in an AI/ML-focused hackathon are likely to probe exactly this.
- Don't claim a specific WER number in the pitch without having actually measured it on real (or realistic) sample audio for the chosen dialect. If asked "what's your accuracy," the honest answer during a hackathon is "here's what we measured on our test set," not a number pulled from a paper's aggregate benchmark.

## Open Item

Final model/API choice is still gated on `CONTEXT.md` Open Decision #1 (which dialect) and #3 (hosted vs self-hosted). Do not wire dialect-specific logic until #1 is answered.
