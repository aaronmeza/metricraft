git checkout -b chore/spool-style-subdirs

BASE="collections/collection-01-datum-rail/filament-spool"
mkdir -p "$BASE/stl/heptachord/cams" "$BASE/stl/dragoncrest/cams" \
         "$BASE/3mf/heptachord" "$BASE/3mf/dragoncrest" \
         "$BASE/plates/heptachord" "$BASE/plates/dragoncrest"

# Move any STLs at stl/ root into heptachord by default (adjust if needed)
if ls "$BASE/stl"/*.stl >/dev/null 2>&1; then
  git mv "$BASE"/stl/*.stl "$BASE/stl/heptachord/" || true
fi
# Move any cam STLs
if ls "$BASE"/stl/*cam*.stl >/dev/null 2>&1; then
  git mv "$BASE"/stl/*cam*.stl "$BASE/stl/heptachord/cams/" || true
fi
# Move stray 3MFs into heptachord
if ls "$BASE"/3mf/*.3mf >/dev/null 2>&1; then
  git mv "$BASE"/3mf/*.3mf "$BASE/3mf/heptachord/" || true
fi

git add -A
git commit -m "chore(spool): introduce style subdirs under stl/ and 3mf/ (heptachord, dragoncrest)"
# push & PR if desired:
git push -u origin chore/spool-style-subdirs && gh pr create --fill

