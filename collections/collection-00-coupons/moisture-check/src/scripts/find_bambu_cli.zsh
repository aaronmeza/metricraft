#!/bin/zsh
set -euo pipefail
typeset -a CANDIDATES
CANDIDATES=(
  "/Applications/Bambu Studio.app/Contents/MacOS/bambu-studio"
  "/Applications/BambuStudio.app/Contents/MacOS/bambu-studio"
  "$HOME/Applications/Bambu Studio.app/Contents/MacOS/bambu-studio"
)
for p in $CANDIDATES; do
  [[ -x "$p" ]] && { print -r -- "$p"; exit 0 }
done

# Try by bundle identifiers (name-agnostic)
bundle_ids=(
  "com.bambulab.BambuStudio"
  "com.bambulab.BambuStudioBeta"
)
for bid in $bundle_ids; do
  app_path="$(/usr/bin/mdfind "kMDItemCFBundleIdentifier == " | head -n1 || true)"
  if [[ -n "${app_path:-}" && -d "$app_path" ]]; then
    # Prefer bambu-studio, else whatever is executable in MacOS/
    bin_dir="$app_path/Contents/MacOS"
    if [[ -x "$bin_dir/bambu-studio" ]]; then
      print -r -- "$bin_dir/bambu-studio"; exit 0
    else
      cand="$(/bin/ls -1 "$bin_dir" 2>/dev/null | head -n1 || true)"
      [[ -n "${cand:-}" && -x "$bin_dir/$cand" ]] && { print -r -- "$bin_dir/$cand"; exit 0 }
    fi
  fi
done

exit 1
