# quality-loop skills

Two composable ZCode skills distilled from a five-round quality-hardening campaign on a
44k-line production app (UI audit score 11/20 → 18.5/20, detector findings 16 → 0,
`npm audit` → 0 vulnerabilities, 30+ correctness/perf/security findings fixed through
nested audit→report→fix→re-audit loops).

| Skill | What it does |
|---|---|
| **`quality-loop`** | The convergence loop: multi-dimension audit → severity-tagged report → batched fixes with gates → independent verification → re-audit — with inner loops, bounded rounds, and honest residuals. Works standalone or wraps `$impeccable` (UI) / `$improve` (code). |
| **`quality-agent`** | The autonomous feature agent: plan → implement → quality-loop until the report converges → one structured report. No approval pauses; every choice logged in a DECISIONS list the user reviews afterwards. |

## Install

Requires [ZCode](https://zcode.ai) with skill support.

```bash
# User-level (available in every project):
git clone <this-repo> && cd quality-loop
./install.sh

# …or project-level (available in one project):
./install.sh --project /path/to/your/project

# …or manually:
cp -r skills/quality-loop skills/quality-agent ~/.agents/skills/
```

Restart ZCode (or start a new session) and verify with `/skills` — you should see
`quality-loop` and `quality-agent`.

## Usage

**Hardening an existing codebase:**

> "ဒီ project ကို quality-loop နဲ့ စစ်ပြီး ပြင် — မပြေလည်တာ မကျန်အထိ loop လုပ်ပါ"

**A feature, end-to-end, hands-off:**

> "quality-agent: add CSV export to the question bank — include tests and make it clean"

The agent plans (best-option selection, all choices logged), implements, runs the
quality loop until the audit report converges, then delivers a single report containing
the plan-as-executed, the DECISIONS log, quality-round evidence, and residuals.

> For true hands-off operation run the session in full-automatic (yolo) permission
> mode — the skills decide *what* to do; your permission mode decides *whether the
> tools they call need approval*.

## What the loop catches (why bother)

From one real campaign: a whitespace-collapse bug inside animated hero spans that code
review missed; an unhandled-rejection path that made paper export fail silently offline;
a concurrent-join race that dropped chat-room members; a stale-transcript repaint that
cross-contaminated stored conversations; tolerance-vs-rounding interactions that silently
widened numeric grading. All found by the loop, not by the original implementation pass.

## Layout

```
skills/
├── quality-loop/
│   ├── SKILL.md                  ← the convergence-loop playbook
│   └── references/
│       ├── report-format.md      ← per-round report template
│       └── agent-prompts.md      ← 5 reusable subagent prompt skeletons
└── quality-agent/
    └── SKILL.md                  ← autonomous feature execution (uses quality-loop)
```

## License

MIT — see [LICENSE](LICENSE).
