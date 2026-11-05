#!/usr/bin/env bash
# Quality gates runner — detects the project type and runs the standard gate suite.
# Usage:  quality-gates.sh [--fast]     (--fast skips build + dependency audit)
#         quality-gates.sh --help
# Exit 0 = all applicable gates pass. Exit 1 = at least one gate failed.
# Each gate prints PASS/FAIL/SKIP with its own log tail on failure.
set -uo pipefail

FAST=0
[[ "${1:-}" == "--fast" ]] && FAST=1

RESULTS=()
FAILED=0

record() { # record <name> <status> <detail>
  RESULTS+=("$1|$2|$3")
  [[ "$2" == "FAIL" ]] && FAILED=1
}

run_gate() { # run_gate <name> <command...>
  local name="$1"; shift
  if "$@" >/tmp/qg-gate.log 2>&1; then
    record "$name" "PASS" "-"
  else
    record "$name" "FAIL" "last 15 lines in /tmp/qg-gate.log:"
    tail -15 /tmp/qg-gate.log | sed 's/^/    /'
  fi
}

echo "── quality gates $( [[ $FAST == 1 ]] && echo '(fast mode)' ) ─────────────────────────"

if [[ -f go.mod ]]; then
  command -v go >/dev/null 2>&1 && run_gate "go vet" go vet ./... && run_gate "go test" go test ./...
elif [[ -f Cargo.toml ]]; then
  command -v cargo >/dev/null 2>&1 && run_gate "cargo test" cargo test --quiet
elif [[ -f pom.xml ]]; then
  command -v mvn >/dev/null 2>&1 && run_gate "mvn test" mvn -q test
fi

if [[ -f package.json ]]; then
  PM="npm"; [[ -f pnpm-lock.yaml ]] && PM="pnpm"; [[ -f yarn.lock ]] && PM="yarn"
  RUN="$PM run"

  if grep -q '"typecheck"' package.json; then run_gate "typecheck" $RUN typecheck
  elif [[ -f tsconfig.json ]]; then run_gate "tsc" npx tsc --noEmit; fi

  if grep -q '"lint"' package.json; then run_gate "lint" $RUN lint; fi

  if grep -qE '"test"|"test:run"' package.json; then
    if grep -q '"test"' package.json && [[ $FAST == 0 ]]; then run_gate "tests" $PM test
    elif grep -q '"test:run"' package.json; then run_gate "tests" $RUN test:run
    else run_gate "tests" $PM test; fi
  fi

  if [[ $FAST == 0 ]]; then
    if grep -q '"build"' package.json; then run_gate "build" $RUN build; fi
    command -v npm >/dev/null 2>&1 && run_gate "npm audit" npm audit --omit=dev
  fi
fi

echo "────────────────────────────────────"
for r in "${RESULTS[@]}"; do
  IFS='|' read -r name status detail <<< "$r"
  printf "%-12s %s  %s\n" "$status" "$name" "$detail"
done
[[ $FAILED == 0 ]] && echo "ALL GATES PASS" || echo "GATES FAILED"
exit $FAILED
