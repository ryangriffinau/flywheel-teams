#!/usr/bin/env bash
# One-time setup for a clone of flywheel-teams: activates the committed git hooks and creates the
# machine-level confidentiality term list if it is missing. Safe to re-run.
set -euo pipefail
root=$(git -C "$(dirname "$0")" rev-parse --show-toplevel)
git -C "$root" config core.hooksPath .githooks
printf 'core.hooksPath = .githooks\n'

terms="${FWT_CONFIDENTIAL_TERMS:-${XDG_CONFIG_HOME:-$HOME/.config}/flywheel-teams/confidential-terms}"
if [ ! -e "$terms" ]; then
  mkdir -p "$(dirname "$terms")"
  touch "$terms"
  printf 'created %s (empty). Add one confidential term per line; the pre-push hook refuses pushes that contain any of them.\n' "$terms"
else
  printf '%s exists (%s terms)\n' "$terms" "$(grep -c -v '^[[:space:]]*$' "$terms" || true)"
fi

for tool in br bv ntm dcg jq shellcheck; do
  if command -v "$tool" >/dev/null 2>&1; then printf 'found %s\n' "$tool"; else printf 'missing %s\n' "$tool"; fi
done
