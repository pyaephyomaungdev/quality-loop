<div align="center">

# quality-loop

**Two ZCode skills that harden a codebase to convergence:**
audit → report → fix in gated batches → independent verification → re-audit —
looping (with inner loops) until nothing actionable remains.

`quality-loop` · the convergence loop playbook
`quality-agent` · autonomous feature execution (plan → build → harden → report)

[Install](#install) · [Usage](#usage) · [How it works](#how-it-works) · [What it catches](#what-the-loop-catches) · [FAQ](#faq)

</div>

---

## Why

Most "fix everything" attempts die one of three deaths: the model audits but never fixes, fixes
but never re-checks, or declares victory while unhandled-rejection paths and stale closures rot
in the diffs. This skill set exists to prevent all three:

- **Bounded loops with a stop criterion** — defined in round 1, checked in every re-audit, capped at 3 rounds.
- **Reports as the unit of progress** — every round leaves `reports/<topic>-round-N.md` with before/after metrics, severity-tagged findings (P0–P3) with `file:line` evidence, and an honest residual list.
- **Inner loops that actually close** — after every functional batch, an independent verification agent re-checks the fixes and hunts collateral damage; the gaps it finds get fixed and re-verified.
- **An honest ledger** — a per-round record with a "considered and rejected" section, so round 3 never re-reports what round 1 already settled.

Distilled from a five-round campaign on a 44k-line production app:

| Metric | Campaign start | Campaign end |
|---|---|---|
| UI audit score | 11/20 (Acceptable) | **18.5/20 (Excellent)** |
| Mechanical anti-patterns | 16 | **0** |
| Hardcoded colors in UI | 3,146 | **0** (documented exceptions only) |
| `npm audit` | 3 vulnerabilities | **0** |
| First-load JS | 1,587 kB | **1,148 kB** |
| Tests | 1,078 | **1,460+** |
| Bugs caught by the loop's own verification passes | — | **9** |

## The two skills

### `quality-loop` — the convergence loop

Multi-dimension audit → report → fix → re-audit, for a whole codebase or a single surface.

1. **Phase 0** — parallel recon agents, baseline gates, prior-round ledger.
2. **Audit** — one read-only agent per category (correctness, security, perf, tests, tech debt, DX… or UI: a11y, theming, responsive, motion, integrity), plus detector/served-page scans and browser verification at desktop + mobile widths.
3. **Vet & report** — every finding personally verified (subagents over-report), deduped against the ledger, then written as a P0–P3 report with a score table.
4. **Fix in gated batches** — foundation (tokens/primitives/loaders) → mechanical sweeps (parallel per-file agents with mapping tables) → adoption (component swaps, a11y, security) → polish (motion, deps, docs). Gates after every batch; an independent verification agent after every functional batch.
5. **Re-audit** — until the stop criterion holds: score held/improved, zero P0/P1, no new P2 findings, visual pass clean.

### `quality-agent` — autonomous feature execution

Give it a feature request; it runs the whole arc **without approval pauses**:

```
plan (best-option selection, DECISIONS log) → implement → quality-loop until the
report converges → one structured report (plan-as-executed, decisions, quality
evidence, residuals, "try it in 30 seconds")
```

Ambiguities are resolved from the codebase itself; every choice is logged in a DECISIONS
list the user reviews afterwards; only a genuine architectural blocker makes it stop
mid-flight. Long runs write a `PROGRESS.md` at every phase boundary — a fresh session can
resume exactly where it left off. It never commits, pushes, or invents secrets.

## Install

Requires [ZCode](https://zcode.ai) with skill support.

```bash
git clone https://github.com/pyaephyomaungdev/quality-loop.git
cd quality-loop
./install.sh                                  # user-level → ~/.agents/skills/ (all projects)
./install.sh --project /path/to/project       # project-level → <project>/.agents/skills/
```

Or manually: copy `skills/quality-loop` and `skills/quality-agent` into
`~/.agents/skills/` (or `<project>/.agents/skills/`). Restart ZCode and check `/skills`.

## Usage

Copy these prompts. The skills trigger on intent — Burmese and English both work.

### Hardening a whole codebase

```text
ဒီ project ကို quality-loop နဲ့ စစ်ပြီး ပြင် — မပြေလည်တာ မကျန်အထိ loop လုပ်ပါ။
တစ်ပါတ်ပြီးတိုင်း report ထုတ်ပြီး ကျန်တာတွေ ထပ်ပြင်ပေးပါ။
```

```text
Run a full quality campaign on this repo with the quality-loop skill: audit everything
(correctness, security, performance, tests, debt, UX), write the round-1 report, fix the
findings in gated batches, then re-audit and keep looping until nothing actionable remains.
```

### One dimension at a time

```text
quality-loop နဲ့ security + performance ဘက်အာရုံစိုက်ပြီး audit လုပ်ပြင်ပါ။
```

```text
Audit and fix the UI dimension only (accessibility, theming, responsive, motion) —
round report after each fix batch.
```

### A feature, end-to-end, hands-off

```text
quality-agent: add CSV export to the question bank — include tests and make it clean.
```

```text
quality-agent: user က ကြိုက်တဲ့ hobby အပေါ် အခြေခံပြီး motivation message feature ထည့်ပေးပါ —
plan ကနေ test အထိ အားလုံး ကိုယ့်ဘာသာ ဆုံးဖြတ်လုပ်ပြီး report နဲ့ ပြန်ပေးပါ။
```

> **Hands-off note.** The skills decide *what* to do; your permission mode decides *whether
> the tools they call need approval*. For true autonomous runs, use full-automatic (yolo)
> mode. `quality-agent` never commits, pushes, or invents secrets regardless of mode.

## How it works

```
Phase 0  recon agents · baseline gates · prior-round ledger
   │
   ▼
OUTER LOOP (≤ 3 rounds per audit type)
   ├─ AUDIT     1 read-only agent per category + detectors + visual pass
   ├─ VET       verify every finding personally · dedupe vs ledger
   ├─ REPORT    reports/<topic>-round-N.md · score table · P0–P3 · residuals
   ├─ FIX       foundation → mechanical sweeps → adoption → polish
   │      └─ INNER LOOP: gates → verification agent → gaps → fix → re-verify
   └─ RE-AUDIT  stop criterion met? → converged : next round
   │
   ▼
FINAL  full gates · end-to-end verification · docs sync · summary in the user's language
```

The bundled `scripts/quality-gates.sh` runs the applicable gate suite (npm/pnpm/yarn, go,
cargo, maven — auto-detected) and prints a PASS/FAIL table; `--fast` skips build + audit.

## What the loop catches

Real findings from the source campaign — the class of bug that "tests are green" misses:

- **Silent failure paths** — paper export threw an unhandled rejection offline after katex
  became a lazy chunk; no popup, no error, nothing. Caught by a reject-path hunt.
- **Stale-closure races** — a chat reply that settles after a thread switch repainted the new
  conversation with the old one's transcript, then persisted the corruption. Caught by an
  audit of the abort paths, fixed with an `isCurrentThread()` guard on every transcript write.
- **Concurrency gaps behind an overstated comment** — input gates only block during storage
  operations, so concurrent room joins could still interleave during password hashing. Caught
  by re-reading a comment against the runtime's actual guarantee; fixed with a load-bearing
  promise-chain gate.
- **Visual bugs invisible to code review** — animated hero words collapsing together
  (`inline-block` spans trim trailing spaces). Caught by the mobile browser pass.
- **Behavior drift during refactors** — a code-allocation loop that started silently taking
  over legacy rooms after an atomicity refactor changed its semantics. Caught by a fresh
  re-audit of the "newest modules hardest".

## Composition

| Skill | Role in the loop |
|---|---|
| [`$impeccable`](https://github.com/) | UI/design dimensions — audit, polish, harden passes; browser verification at representative sizes |
| [`$improve`](https://github.com/) | Code-audit playbook — its `audit-playbook.md` is handed to the category agents |
| [`$animate-text`](https://github.com/) | Text-motion catalog for polish batches — one authored moment per surface |
| **`quality-agent`** (bundled) | Autonomous execution — hands its output to this loop |

They are optional: the categories in `SKILL.md` are the whole system, and the bundled
`scripts/quality-gates.sh` is the only tooling dependency.

## FAQ

**Does it commit or push my code?**
Never, unless you explicitly say so. It recommends a commit-batch split at the end and leaves
the working tree ready.

**Does it work outside JavaScript?**
Yes — `quality-gates.sh` auto-detects npm/pnpm/yarn, Go, Cargo, and Maven; the audit categories
are language-agnostic. The source campaign was TypeScript + Cloudflare Workers.

**What does it need from me?**
A stop criterion it can enforce, a repo to write `reports/` into, and — for UI work — a way to
run the app. It asks nothing else; that is the point.

**How is this different from just running an audit prompt?**
The audit is one phase. The loop is what happens after: vetting, gated fixes, an independent
verification agent, and re-auditing until the report converges — plus a ledger that stops
findings from being re-reported or forgotten.

## Contributing

Issues and PRs welcome at the repo. Skill changes: keep `SKILL.md` under ~350 lines, put depth
in `references/`, and add any repeated workflow as a script under `scripts/`.

## License

[MIT](LICENSE)
