#!/usr/bin/env zsh
set -euo pipefail

# deps
command -v openscad >/dev/null || { echo 'openscad not found'; exit 1; }
command -v jq       >/dev/null || { echo 'jq not found (brew install jq)'; exit 1; }

ROOT="$(git rev-parse --show-toplevel)"

# find all export manifests
find "$ROOT/collections" -maxdepth 3 -type f -name export.config.json | while IFS= read -r cfg; do
  base="$(dirname "$cfg")"
  scad_rel="$(jq -r '.scad' "$cfg")"
  scad="$base/$scad_rel"
  fn="$(jq -r '.openscad.fn // 64' "$cfg")"

  # styles as zsh array (newline-split)
  styles=("${(@f)$(jq -r '.styles[]' "$cfg")}")

  # iterate each part as compact JSON objects
  jq -c '.parts[]' "$cfg" | while IFS= read -r part; do
    name="$(jq -r '.name'  <<<"$part")"   # e.g. "cams/flange2core" or "flange"
    which="$(jq -r '.which' <<<"$part")"

    for style in "${styles[@]}"; do
      # optional STYLE filter: export only one style if env var is set
      if [[ -n "${STYLE:-}" && "$style" != "$STYLE" ]]; then
        continue
      fi

      # split name into subdir + leaf, safe for names without '/'
      subdir="${name%/*}"
      leaf="${name##*/}"
      outdir="$base/stl/$style"
      [[ "$subdir" != "$name" ]] && outdir="$outdir/$subdir"
      mkdir -p "$outdir"

      out="$outdir/$leaf.stl"
      echo "→ $scad  -D style=\"$style\" -D which=\"$which\"  →  $out"

      openscad -o "$out" "$scad" --export-format binstl \
        -D "style=\"$style\"" -D "which=\"$which\"" -D "\$fn=$fn"
    done
  done
done
