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

## Rules that keep reports honest

- **Every finding carries file:line evidence you personally verified.** Subagent line numbers are leads, not facts.
- **Severity is impact, not effort.** A trivial fix for a real WCAG failure is still P1; a 3-day refactor that changes nothing user-visible is still P3.
- **By-design items get a reason and stay listed** — otherwise the next round re-reports them.
- **Score honesty over score inflation.** An 11/20 that becomes 18/20 through real work is the campaign's story; a dishonest 20/20 destroys the ledger's credibility.
