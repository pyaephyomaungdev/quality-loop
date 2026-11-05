# Audit report format

Every round produces one report at `reports/<topic>-round-N.md` (UI audits: `ui-audit-round-N.md`; code audits: `improve-round-N.md` or the topic). Keep ALL rounds — the before/after score columns across files are the campaign's evidence trail.

## Required sections, in order

```markdown
# <Topic> Audit — Round N (date)

Scope: surfaces/categories audited + verification method (detector, browser widths, censuses).
Baseline state: gate results (tests X/X, build, lint, audit).

# Audit Health Score

| # | Dimension | Round N−1 | Round N | Key finding / evidence |
|---|-----------|-----------|---------|------------------------|
| 1..5 | <dimensions> | score | score | most critical item or "--" |
| **Total** | | **nn/20** | **nn/20** | **rating band** |

(For code audits: a findings table instead —
| # | Finding | Category | Impact | Effort | Risk | Evidence |)

## Detector / scan output
Code-level count + page-level per-route counts; advisories split from anti-patterns.

## Findings by severity
### P1 — Major  (each: Location file:line, Category, Impact, Recommendation)
### P2 — Minor
### P3 — Polish

## Positive findings
What works and must survive future passes. (Never skip this — it stops regressions
and keeps the fixes from over-rotating.)

## The loop caught
Bugs found by verification/browser pass DURING the fix phase, fixed in-pass, with the
mechanism. This section is the proof the inner loop earns its keep.

## Stop-criterion check
Criterion from round 1, checked item by item, explicitly: ✓/✗ per line.

## Residual (documented, not drift)
Each item: what, why not fixed now, where it is recorded (ledger entry / doc comment).
"Converged" vs "capped" is stated here.
```

## Metrics snapshot (add after the score table)

A short "before → after" evidence block — numbers survive, prose gets skimmed:

```markdown
| Metric | Round start | Round end |
|---|---|---|
| Tests | 1078 (60 files) | 1138 (65 files) |
| Hardcoded hex in UI chrome | 3,146 | 0 |
| Detector anti-patterns | 16 | 0 |
| npm audit vulnerabilities | 3 | 0 |
| First-load JS | 1,587 kB | 1,148 kB |
```

## "The loop caught" entry format

One line per bug the fix-phase verification or visual pass found (not the original audit):

```markdown
- **[P1] Hero words collapsed** — inline-block spans trimmed trailing whitespace, rendering
  "Yournotes,turned". Caught by the mobile visual pass, fixed by moving spaces outside the
  span. Lesson: `inline-block` eats trailing spaces; put separators between the boxes.
```

Rules: mechanism (why it happened) + how it was caught (which pass) + the transferable lesson.
These entries are what make later campaigns faster — they are the pattern library.

## Rules that keep reports honest

- **Every finding carries file:line evidence you personally verified.** Subagent line numbers are leads, not facts.
- **Severity is impact, not effort.** A trivial fix for a real WCAG failure is still P1; a 3-day refactor that changes nothing user-visible is still P3.
- **By-design items get a reason and stay listed** — otherwise the next round re-reports them.
- **Score honesty over score inflation.** An 11/20 that becomes 18/20 through real work is the campaign's story; a dishonest 20/20 destroys the ledger's credibility.
