#!/usr/bin/env zsh
set -euo pipefail

git checkout -b chore/repo-fixes-structure

# 1) Flatten the moisture-check double nesting
base="collections/collection-00-coupons/moisture-check"
nest="$base/src/collections/collection-00-coupons/moisture-check"

for sub in bambu docs src stl; do
  if [[ -d "$nest/$sub" ]]; then
    mkdir -p "$base/$sub"
    # move contents up
    find "$nest/$sub" -mindepth 1 -maxdepth 1 -print0 | while IFS= read -r -d '' f; do
      git mv "$f" "$base/$sub/" || { mv "$f" "$base/$sub/"; git add -A "$base/$sub/"; }
    done
  fi
done

# remove empty nested tree if it exists
if [[ -d "$nest" ]]; then
  git rm -r "$base/src/collections" || true
fi

# 2) Normalize 'stls' -> 'stl' in coupon packs
for d in collections/collection-00-coupons/coupon-pack-v*/stls; do
  [[ -d "$d" ]] || continue
  git mv "$d" "${d%stls}stl"
done

# 3) Move stray 3mf out of stl; fix heptachord naming
spool="collections/collection-01-datum-rail/filament-spool"
if [[ -f "$spool/stl/heptachord-flange.3mf" ]]; then
  mkdir -p "$spool/3mf"
  git mv "$spool/stl/heptachord-flange.3mf" "$spool/3mf/" || true
fi

# 4) Optional typo fix: heptacord -> heptachord (only if you want the consistent name now)
if [[ -f "$spool/src/heptacord.scad" && ! -f "$spool/src/heptachord.scad" ]]; then
  git mv "$spool/src/heptacord.scad" "$spool/src/heptachord.scad"
  # If other files reference the old name, we can sed them in a follow-up PR.
fi

# 5) Commit
git add -A
git commit -m "chore(repo): flatten moisture-check nesting, normalize stl dirs, move 3mf, fix heptachord name"

# 6) Push + PR if gh is available
if command -v gh >/dev/null 2>&1; then
  git push -u origin chore/repo-fixes-structure
  gh pr create --fill --title "Repo fixes: flatten moisture-check, normalize stl, heptachord rename" \
               --body "Removes double nesting, standardizes stl/, moves stray 3mf, optional heptachord rename."
else
  echo "Branch pushed. Open PR for 'chore/repo-fixes-structure' when ready."
fi

# 7) Sanity checks
echo "--- sanity checks ---"
test -f web/apps/api/wrangler.toml && echo "wrangler present"
if find collections -path '*/src/collections/collection-*' | grep .; then
  echo "Still found nested paths (review above list)."
else
  echo "No nested collection paths detected."
fi

