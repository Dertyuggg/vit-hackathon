# Master Prompt — Paste This Into Antigravity

Use this once, in a fresh Antigravity workspace, after you've copied all the generated files (`AGENTS.md`, `CONTEXT.md`, `SETUP.md`, `.agents/`, `.antigravity/`, `docs/`) into the project root. This prompt tells the agent to read everything, set the project up, and confirm before writing code.

---

```
You are working on Swara, a voice-native micro-commerce and credit engine for
rural Indian micro-entrepreneurs. This workspace already contains the full
project documentation and rule set — do not start writing application code
yet. Your first job is to onboard yourself onto this project correctly.

Do the following, in order:

1. Read AGENTS.md in full. This is your standing contract for this project —
   follow it for the rest of this session and every session after.

2. Read CONTEXT.md in full. This is the project's living memory. Pay close
   attention to "Current State," "Open Decisions," and "Decision History" —
   these tell you exactly where the project stands and what has already been
   decided versus what is still undecided.

3. Read every file under .agents/rules/ — these are hard rules on git
   branching, commit/push discipline, coding standards, and situations where
   you must stop and ask me before proceeding rather than deciding alone.

4. Read every file under .antigravity/workflows/ — these are the sequences
   you should follow for "new feature" and "fix bug" style requests going
   forward.

5. Read every file under docs/ — this is domain and technical context:
   the pitch deck summary, the ASR technology decision and why plain Whisper
   was replaced with AI4Bharat's Indic models, the NLU extraction approach,
   the credit-scoring formula design, the data/privacy rules, and the API
   contracts for each backend function (currently mostly skeletons — you'll
   fill these in as we build).

6. Read SETUP.md and then actually set the project up: scaffold the
   repository structure exactly as described in AGENTS.md section 4,
   initialize git with a "develop" branch (never commit to "main" directly —
   see .agents/rules/git-branching.md), scaffold the React+Vite+TypeScript
   frontend in apps/web, install the dependencies listed in SETUP.md, and
   create the supabase/ and packages/shared/ folder structure. Do NOT run
   any command that requires my credentials (Supabase login, account
   creation) — pause and tell me exactly what you need me to do by hand for
   those steps, using the [HUMAN] markers in SETUP.md as your guide.

7. Once setup is scaffolded, give me a short status report covering:
   - What you set up successfully
   - What's blocked on me (accounts, credentials, decisions)
   - The single most important open decision from CONTEXT.md that you think
     we should resolve first (I expect this to be the target dialect
     choice, but confirm your own reasoning)

8. Do not write any feature code (voice capture UI, ASR integration, NLU
   extraction, payment flow) until I've responded to your status report and
   we've resolved at least the dialect decision. This is intentional — I'd
   rather confirm the foundation is right than have you build ahead of a
   decision that changes the ASR/NLU work.

Throughout all of this: if you're ever unsure whether something is
correct — a library API, a Supabase behavior, a Razorpay endpoint shape —
say so explicitly and check rather than presenting a guess confidently.
This project touches real payments and a real financial-inclusion claim,
so I'd much rather you flag uncertainty than paper over it. I want
comprehensive, complete work, not shortcuts — but "comprehensive" includes
being honest about what's unverified.
```

---

## After This Runs

Once the agent reports back, the realistic next few conversation turns are:

1. Answer its dialect question (this unblocks `CONTEXT.md` Open Decision #1).
2. Do the `[HUMAN]`-marked account setup steps yourself (Supabase, Razorpay, Vercel, SMS provider, Hugging Face if self-hosting ASR).
3. Tell the agent which SMS provider to use (Open Decision #2) and which ASR delivery mode (Open Decision #3, hosted API vs self-hosted).
4. Then say something like "start on the voice capture UI" and let it follow `.antigravity/workflows/new-feature.md` on its own.

If you start a new Antigravity session later (new day, new chat), you generally do **not** need to re-paste this whole master prompt — `AGENTS.md` is read automatically at the root of the workspace on every session, and its own section 5 ("Session Startup Checklist") tells the agent to read `CONTEXT.md` and pick up where it left off. Re-use this master prompt only if you're bootstrapping a brand new workspace/repo from scratch again.
