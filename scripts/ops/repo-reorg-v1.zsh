#!/usr/bin/env zsh
set -euo pipefail

# Config
BRANCH="chore/repo-layout-v1"
DRY="${DRY_RUN:-0}"     # export DRY_RUN=1 to print actions without changing files
ROOT="$(git rev-parse --show-toplevel 2>/dev/null || true)"

if [[ -z "$ROOT" ]]; then
  echo "Run inside the metricraft git repository." >&2
  exit 1
fi

cd "$ROOT"

# Guard: ensure clean working tree
if ! git diff --quiet || ! git diff --cached --quiet; then
  echo "Working tree not clean. Commit or stash changes, then re-run." >&2
  exit 1
fi

run() {
  if [[ "$DRY" = "1" ]]; then
    echo "[dry] $*"
  else
    eval "$*"
  fi
}

# Create branch
if ! git rev-parse --verify --quiet "$BRANCH" >/dev/null; then
  run "git checkout -b '$BRANCH'"
else
  run "git checkout '$BRANCH'"
fi

# Ensure top-level directories exist
dirs=(
  "assets"
  "collections"
  "docs/decisions"
  "lib/openscad"
  "lib/vendor"
  "scripts/models"
  "scripts/ops"
  "templates/3mf"
  "templates/readme-object"
  "web/apps/www/src/pages"
  "web/apps/docs"
  "web/apps/api/src"
  "web/packages/ui"
  "web/packages/config"
  "ops"
  ".github/workflows"
)
for d in "${dirs[@]}"; do
  [[ -d "$d" ]] || run "mkdir -p '$d'"
  # .gitkeep for empty dirs
  if [[ -z "$(ls -A "$d" 2>/dev/null || true)" ]]; then
    run "touch '$d/.gitkeep'"
  fi
done

# Fix doubly nested 'collections' paths like:
# /collections/.../src/collections/collection-XX-*/...
echo "Scanning for doubly-nested collection paths…"
while IFS= read -r nested; do
  # e.g., nested="/collections/c-00/foo/src/collections/collection-00-coupons/bar.scad"
  parent="$(dirname "$nested")"
  # Move children up to src/
  src_dir="$(echo "$nested" | sed -E 's#(.*)/src/collections/collection-[^/]+/\?#\1/src/#')"
  src_dir="${src_dir%/*}/" # ensure trailing slash
  # Determine the base of the nested subtree
  base="${nested%/}"
  # shellcheck disable=SC2207
  children=($(git ls-files -- "$base" 2>/dev/null || true))
  if [[ ${#children[@]} -eq 0 ]]; then
    children=($(find "$base" -type f 2>/dev/null || true))
  fi
  for f in "${children[@]}"; do
    rel="${f#$base/}"
    dest="${src_dir}${rel}"
    run "mkdir -p \"$(dirname "$dest")\""
    if git ls-files --error-unmatch "$f" >/dev/null 2>&1; then
      run "git mv -f \"$f\" \"$dest\""
    else
      run "mv -f \"$f\" \"$dest\""
      run "git add -A \"$dest\""
    fi
  done
  # Remove now-empty nested directory
  run "git rm -r \"$base\" 2>/dev/null || true"
done < <(find collections -type d -path '*/src/collections/collection-*' 2>/dev/null)

# Standardize minimal SKU layout if missing key dirs
echo "Normalizing SKU layouts…"
while IFS= read -r sku; do
  for sub in src stl 3mf plates images tests; do
    [[ -d "$sku/$sub" ]] || run "mkdir -p \"$sku/$sub\" && touch \"$sku/$sub/.gitkeep\""
  done
  [[ -f "$sku/README.md" ]] || run "printf '%s\n' '# ${sku:t}' > \"$sku/README.md\""
  [[ -f "$sku/CHANGELOG.md" ]] || run "printf '%s\n' '# Changelog\n' > \"$sku/CHANGELOG.md\""
done < <(find collections -maxdepth 3 -mindepth 3 -type d 2>/dev/null | grep -E '/collections/collection-[0-9]{2}-[^/]+/[^/]+$' || true)

# Scaffold web/apps/api (ClickUp connector mapping)
API_SRC="web/apps/api/src"
run "printf '%s\n' 'import { Hono } from \"hono\";\nimport { cors } from \"hono/cors\";\nconst app = new Hono();\napp.use(\"*\", cors());\napp.get(\"/healthz\", c => c.json({ ok: true, ts: Date.now() }));\nexport default app;\n' > \"$API_SRC/index.ts\""

run "printf '%s\n' '// route table placeholder\nexport const routes = [];\n' > \"$API_SRC/routes.ts\""
run "printf '%s\n' '// clickup client placeholder\nexport const clickup = {} as any;\n' > \"$API_SRC/clickup.ts\""
run "printf '%s\n' '// hmac signing placeholder\nexport const sign = () => {};\n' > \"$API_SRC/sign.ts\""
run "printf '%s\n' '// access jwt placeholder\nexport const requireAccess = () => {};\n' > \"$API_SRC/auth.ts\""
run "printf '%s\n' '// kv cache placeholder\nexport const cache = {} as any;\n' > \"$API_SRC/data-cache.ts\""
run "printf '%s\n' '// webhook handler placeholder\nexport const handleWebhook = () => {};\n' > \"$API_SRC/webhook.ts\""
run "printf '%s\n' '// util placeholder\nexport const noop = () => {};\n' > \"$API_SRC/utils.ts\""

run "mkdir -p \"$API_SRC/do\" \"$API_SRC/queues\""
run "printf '%s\n' 'export class CacheCoordinator {}\n' > \"$API_SRC/do/cache-coordinator.ts\""
run "printf '%s\n' 'export const webhookConsumer = () => {};\n' > \"$API_SRC/queues/webhook-consumer.ts\""
run "printf '%s\n' 'export const bulkImportConsumer = () => {};\n' > \"$API_SRC/queues/bulk-import-consumer.ts\""

# wrangler.toml skeleton
WRANGLER="web/apps/api/wrangler.toml"
if [[ ! -f "$WRANGLER" ]]; then
  run "cat > \"$WRANGLER\" <<'TOML'
name = \"metricraft-api\"
main = \"src/index.ts\"
compatibility_date = \"2025-08-15\"

[[kv_namespaces]]
binding = \"KV_SIGNED_URLS\"
id = \"TBD\"
preview_id = \"TBD\"

[[r2_buckets]]
binding = \"R2_PUBLIC_ASSETS\"
bucket_name = \"metricraft-public\"

[vars]
SIGNED_URL_TTL_SECONDS = \"600\"
TOML"
fi

# Minimal Astro placeholders
WWW_INDEX="web/apps/www/src/pages/index.astro"
if [[ ! -f "$WWW_INDEX" ]]; then
  run "cat > \"$WWW_INDEX\" <<'ASTRO'
---
// minimal marketing placeholder
const title = 'Metricraft';
---
<html lang=\"en\"><head><meta charset=\"utf-8\" /><title>{title}</title></head>
<body>
  <main>
    <h1>Metricraft</h1>
    <p>Precision, parametric, and printable.</p>
    <p><a href=\"https://docs.metricraft.works\">Docs</a></p>
  </main>
</body></html>
ASTRO"
fi

# Docs placeholder (starlight will populate later)
run "touch web/apps/docs/.gitkeep"

# CI workflow placeholders
if [[ ! -f '.github/workflows/web.yml' ]]; then
  run "cat > .github/workflows/web.yml <<'YML'
name: web
on:
  push: { branches: [ main ] }
  pull_request: {}
jobs:
  noop:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: echo 'Web workflows stub (Pages projects configured in Cloudflare UI).'
YML"
fi

if [[ ! -f '.github/workflows/worker.yml' ]]; then
  run "cat > .github/workflows/worker.yml <<'YML'
name: worker
on:
  push: { branches: [ main ] }
  pull_request: {}
jobs:
  noop:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: echo 'Worker deploy handled by wrangler in later step.'
YML"
fi


# Makefile additions (append if missing)
if ! grep -q '^models:' Makefile 2>/dev/null; then
  {
    printf '\nmodels:\n\t./scripts/models/export.zsh\n'
    printf '\nweb-build:\n\t( cd web/apps/www && true ) && ( cd web/apps/docs && true )\n'
  } >> Makefile
fi


# Stub export script
if [[ ! -f "scripts/models/export.zsh" ]]; then
  run "cat > scripts/models/export.zsh <<'ZSH'
#!/usr/bin/env zsh
set -euo pipefail
command -v openscad >/dev/null || { echo 'openscad not found'; exit 1; }
ROOT=\"\$(git rev-parse --show-toplevel)\"
find \"\$ROOT/collections\" -type f -name '*.scad' | while read -r scad; do
  sku_dir=\"\$(dirname \"\$scad\")/..\"
  sku_dir=\"\$(cd \"\$sku_dir\" && pwd)\"
  out_dir=\"\$sku_dir/stl\"
  mkdir -p \"\$out_dir\"
  base=\"\${scad:t:r}\"
  out=\"\$out_dir/\$base.stl\"
  echo \"→ Exporting \$scad → \$out\"
  openscad -o \"\$out\" \"\$scad\" --export-format binstl
done
ZSH"
  run "chmod +x scripts/models/export.zsh"
fi

# Finalize commit
run "git add -A"
if ! git diff --cached --quiet; then
  run "git commit -m 'chore(repo): layout v1 scaffold, path normalization, web/api stubs'"
else
  echo "No changes to commit."
fi

# Push & PR
if command -v gh >/dev/null 2>&1; then
  run "git push -u origin '$BRANCH'"
  run "gh pr create --fill --title 'Repo layout v1: scaffold + path fixes' --body 'Holistic layout + path normalization; adds web/api scaffolds and CI stubs.' || true"
else
  echo "gh CLI not found. Manually open a PR for branch: $BRANCH"
fi

echo "Done."

