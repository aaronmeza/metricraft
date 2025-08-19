#!/usr/bin/env zsh
set -euo pipefail
command -v openscad >/dev/null || { echo 'openscad not found'; exit 1; }
ROOT="$(git rev-parse --show-toplevel)"
find "$ROOT/collections" -type f -name '*.scad' | while read -r scad; do
  sku_dir="$(dirname "$scad")/.."
  sku_dir="$(cd "$sku_dir" && pwd)"
  out_dir="$sku_dir/stl"
  mkdir -p "$out_dir"
  base="${scad:t:r}"
  out="$out_dir/$base.stl"
  echo "→ Exporting $scad → $out"
  openscad -o "$out" "$scad" --export-format binstl
done
