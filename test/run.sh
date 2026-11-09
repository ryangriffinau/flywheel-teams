#!/usr/bin/env bash
# Runs every test in test/*.test.sh, then shellcheck over the repository's scripts.
#
# Each test file is a bash script that exits non-zero on failure and prints what it checked. Tests
# run under the bash on PATH and, when /bin/bash is version 3.2 (macOS), under /bin/bash too, so
# the 3.2 compatibility rule in AGENTS.md is exercised. An empty suite fails: a run over zero tests
# is not a pass. Negative-control mutants under test/mutants/ are run by the tests that own them.
set -euo pipefail
root=$(cd "$(dirname "$0")/.." && pwd)
cd "$root"

failed=0
count=0
shells="bash"
if [ -x /bin/bash ] && [ "$(/bin/bash -c 'printf %s "${BASH_VERSINFO[0]}"')" = "3" ] \
   && [ "$(command -v bash)" != "/bin/bash" ]; then
  shells="bash /bin/bash"
fi

for t in test/*.test.sh; do
  [ -e "$t" ] || continue
  count=$((count + 1))
  for sh in $shells; do
    printf '==> %s (%s)\n' "$t" "$sh"
    if "$sh" "$t"; then printf '    ok\n'; else printf '    FAILED\n'; failed=$((failed + 1)); fi
  done
done

if [ "$count" -eq 0 ]; then
  printf 'run.sh: FAILED, no test files (test/*.test.sh)\n' >&2
  failed=$((failed + 1))
fi

files=$(find . -path ./.git -prune -o -type f \( -name '*.sh' -o -path './bin/*' -o -path './hooks/*' -o -path './.githooks/*' \) -print | sort)
if [ -z "$files" ]; then
  printf 'run.sh: FAILED, no scripts found for shellcheck\n' >&2
  failed=$((failed + 1))
elif command -v shellcheck >/dev/null 2>&1; then
  printf '==> shellcheck\n'
  # shellcheck disable=SC2086
  if shellcheck -x $files; then printf '    ok\n'; else printf '    FAILED\n'; failed=$((failed + 1)); fi
else
  printf 'run.sh: shellcheck not installed; skipped\n' >&2
fi

printf 'run.sh: %d test file(s), %d failure(s)\n' "$count" "$failed"
[ "$failed" -eq 0 ]
