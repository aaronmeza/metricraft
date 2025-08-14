#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GLOSSARY="$ROOT/docs/glossary.md"

if [ ! -f "$GLOSSARY" ]; then
  echo "✗ missing glossary: $GLOSSARY"
  exit 1
fi

# Enforced token families:
#  mc-* | t(08|12|16|24) | r(2|3|6|10) | clearance-(x[...]/z-top/z-bottom) | goal:(strength|translucency|surface)
PATTERN='mc-[a-z0-9-]+|t(08|12|16|24)|r(2|3|6|10)|clearance-(x(-[a-z0-9-]+)?|z-(top|bottom))|goal:(strength|translucency|surface)'

# Gather tracked candidate files
FILES="$(git ls-files '*.md' '*.scad' | grep -v '^docs/glossary\.md$' | grep -v '^docs/templates/')"

# Used tokens (tolerates no matches)
USED="$(echo "$FILES" | xargs -I{} grep -hEo "$PATTERN" {} 2>/dev/null | sort -u || true)"

# Defined tokens: pull code spans from glossary (text between backticks) and filter by PATTERN
DEFINED="$(awk -v RS='`' 'NR%2==0{print}' "$GLOSSARY" | grep -E "^($PATTERN)$" | sort -u || true)"

# Normalize into temp files for comm (handles empty sets)
UT=/tmp/used.$$
DT=/tmp/defined.$$
printf '%s\n' $USED    > "$UT" 2>/dev/null || true
printf '%s\n' $DEFINED > "$DT" 2>/dev/null || true

MISSING="$(comm -23 "$UT" "$DT" || true)"
rm -f "$UT" "$DT"

if [ -n "${MISSING}" ]; then
  echo "✗ Tokens referenced but NOT defined in docs/glossary.md:"
  echo "$MISSING" | sed 's/^/  - /'
  echo "→ Add them to /docs/glossary.md (wrap each token in backticks)."
  exit 1
fi

echo "✓ glossary check: all referenced tokens are defined"
