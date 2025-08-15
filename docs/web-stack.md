
# metricraft web stack decision (v1.0.0)
**date:** 2025-08-15  
**status:** approved (pending verification of CL-TBD-201)  
**owner:** Aaron Meza  
**scope:** `metricraft.works`, `docs.metricraft.works`, `studio.metricraft.works`, `api.metricraft.works`  
**filename suggestion:** `2025-08-15-web-stack-decision.md`

---

## decision
Adopt a split-by-surface architecture on Cloudflare:

- **marketing:** `metricraft.works` — **Astro (SSG)**
- **docs:** `docs.metricraft.works` — **Astro Starlight (SSG)** with static search
- **integrations/api:** `api.metricraft.works` — **Hono on Cloudflare Workers**
- **internal app (later):** `studio.metricraft.works` — **Remix on Workers** behind Cloudflare Access (Google IdP)

**why:** static-first speed and SEO, clean separation of concerns, minimal platform friction (Pages + Workers), and a stable integration layer for ClickUp/Slack/MakerWorld + future MCP connector.

---

## target shape
- **Public surfaces:** fully static (SSG), edge-cached, Core Web Vitals ≥ 90.
- **API surface:** Worker hosting signed-URL service, webhooks, and future ChatGPT/MCP adapter.
- **Auth:** Cloudflare Access with **Google as IdP** (studio only).
- **Content:** Git-based MD/MDX; PRs auto-deploy to Pages; auto OG images; releases RSS.
- **Design system:** Tailwind + shadcn/ui (shared package), consistent OG card templates.
- **Search:** Pagefind (static index) now; Algolia DocSearch optional later.
- **Storage & state:** KV for ephemeral tokens/flags; R2 for public assets; Durable Object for optional rate limiting.

---

## quick-start plan (good-enough to ship)

### scaffold (monorepo under `/web`—**layout is proposed; finalization deferred to CL-TBD-202**)


/web

/apps

/www     # Astro (marketing)

/docs    # Astro Starlight (docs)

/api     # Hono on Workers (integrations)

/packages

/ui      # shared tailwind/shadcn components (optional day-1)

/config  # shared tsconfig/eslint/tailwind presets (optional day-1)

package.json   # workspaces

turbo.json     # pipeline


### commands (one pass)
```bash
# from repo root:
mkdir -p web && cd web
printf '%s\n' '{ "name":"metricraft-web","private":true,"packageManager":"pnpm@9","devDependencies":{"turbo":"^2"}, "workspaces":["apps/*","packages/*"] }' > package.json
printf '%s\n' '{ "pipeline": { "build": { "dependsOn":["^build"] }, "dev": {} } }' > turbo.json

# apps
pnpm dlx create-astro@latest apps/www -- --template minimal --yes
pnpm dlx create-astro@latest apps/docs -- --template starlight --yes
pnpm dlx create-hono@latest apps/api -- --template cloudflare-workers

mkdir -p packages/ui packages/config
pnpm install
````

### minimal Worker (apps/api/src/index.ts)

```ts
import { Hono } from 'hono';
import { cors } from 'hono/cors';

const app = new Hono();
app.use('*', cors());

app.get('/healthz', (c) => c.json({ ok: true, ts: Date.now() }));

app.post('/signed-urls/create', async (c) => {
  // TODO: verify request (Cloudflare Access JWT or one-time nonce)
  const kv = c.env.KV_SIGNED_URLS as KVNamespace;
  const token = crypto.randomUUID();
  const ttl = Number(c.env.SIGNED_URL_TTL_SECONDS || 600);
  await kv.put(`signed:${token}`, '1', { expirationTtl: ttl });
  return c.json({ token, expires_in: ttl });
});

// Stubs for later wiring
app.post('/webhooks/clickup', (c) => c.json({ received: true }));
app.post('/webhooks/slack', (c) => c.json({ received: true }));
app.post('/makerworld/notify', (c) => c.json({ received: true }));

export default app;
```

### wrangler.toml baseline

```toml
name = "metricraft-api"
main = "src/index.ts"
compatibility_date = "2025-08-15"

[[kv_namespaces]]
binding = "KV_SIGNED_URLS"
id = "TBD"
preview_id = "TBD"

[[r2_buckets]]
binding = "R2_PUBLIC_ASSETS"
bucket_name = "metricraft-public"

[vars]
SIGNED_URL_TTL_SECONDS = "600"
```

---

## cloudflare wiring

### pages projects

* **`metricraft-www`** → root `/web/apps/www`, build: `pnpm i && pnpm build`, output: `dist`.
* **`metricraft-docs`** → root `/web/apps/docs`, build: `pnpm i && pnpm build`, output: `dist`.
* Set `PNPM_FLAGS="--frozen-lockfile=false"` on first build if needed.

### worker (api)

* Deploy from `/web/apps/api`: `pnpm run deploy`.
* Provision KV + R2; paste IDs in `wrangler.toml`.
* Route `api.metricraft.works/*` to the Worker.

### dns & domains

* Attach custom domains:

  * Pages → `metricraft.works` and `docs.metricraft.works`
  * Worker → `api.metricraft.works`
* Enable HTTPS; default cache for static assets.

### access (for studio, later)

* Create a Cloudflare Access application for `studio.metricraft.works`.
* IdP: **Google**; policy: org email allowlist.
* Add `CF-Access-JWT-Assertion` verification middleware in Remix.

---

## defaults & niceties

* **Performance:** SSG everywhere; edge caching; images via `<picture>`/`srcset`; defer scripts; prefetch critical routes.
* **Search (docs):** Pagefind with default UI; index generated at build (no external service).
* **OG images:** Satori-based OG image generation at build time; shared template in `/packages/ui/og/`.
* **Releases RSS:** Astro endpoint in `www` to emit `/releases/rss.xml` from MD/MDX frontmatter.
* **Design system:** Tailwind preset + shadcn/ui in `/packages/ui`; icon set via lucide-react.
* **Tooling:** pnpm + Turborepo; TypeScript strict; ESLint + Prettier presets in `/packages/config`.
* **CI/CD:** GitHub Actions — build PRs, deploy `main`; link-check + spell-check on docs.
* **Storage:**

  * KV: ephemeral signed-url tokens; feature flags/toggles
  * R2: hero images/renders and downloadable assets
  * Durable Object (optional): rate limiting per route
* **Security:** short-lived tokens only; no long-lived secrets in PRs; Cloudflare Access for studio; CORS locked to `*.metricraft.works`.

---

## proposed repo layout (not finalized; to be confirmed in CL-TBD-202)

```
/web
  /apps
    /www
    /docs
    /api
  /packages
    /ui
    /config
```

> **Note:** Proposal supports shared UI/config while keeping deploy units isolated. Final structure will be agreed in **CL-TBD-202**.

---

## acceptance criteria (for CL-TBD-202/204 follow-on)

* `https://metricraft.works` live with minimal homepage (LCP < 2.0s on simulated 4G).
* `https://docs.metricraft.works` live with Pagefind search.
* `https://api.metricraft.works/healthz` returns `{ ok: true }`.
* PR to `main` triggers Pages/Worker deploys; releases RSS available.

---

## risks & mitigations

* **Runtime quirks on Workers:** Keep the API in Hono (Workers-native); avoid Node-only libs.
* **Docs scale/IA:** Start with Starlight defaults; add Algolia only if search latency or facets become a need.
* **Design consistency across stacks:** Centralize Tailwind/shadcn presets in `/packages`; publish as an internal package if we split repos later.
* **Auth drift:** Studio gated via Access from day one; add request guards in Worker handlers even for internal routes.

---

## roadmap notes

* **MCP connector:** Thin facade over the Worker; Worker remains source of truth.
* **Studio (Remix):** Only after API stabilizes; targets ClickUp helpers, MakerWorld publishing, dashboards.
* **Internationalization:** Astro’s i18n is optional; revisit after initial content lands.
