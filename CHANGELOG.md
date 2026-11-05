# Changelog

## v1.0.0 (2026-11-06)

- `quality-loop`: convergence-loop playbook (audit → report → gated fix batches →
  verification agent → re-audit), delta-focused re-audits, focused-subset rule,
  companion-skill detection table ($impeccable / $improve / $security-audit / $animate-text
  with guided install), guardrails batch (enforced zeros), report format, 5 agent-prompt
  skeletons, 4 fix-batch playbooks, portable `quality-gates.sh`.
- `quality-agent`: autonomous feature execution — plan (best-option selection + DECISIONS
  log) → implement → feature-sized quality loop → single structured report; PROGRESS.md
  resumability; autonomy rules (no commits, reversible-first, no scope creep).
