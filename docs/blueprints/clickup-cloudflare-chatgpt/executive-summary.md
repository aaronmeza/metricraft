# clickup × cloudflare × chatgpt (mcp) — executive summary

**Owner:** Metricraft  
**Scope:** LLM-safe integration between ClickUp and ChatGPT using Cloudflare (Workers/Pages + KV/DO/Queues).  
**Lists in scope:** `open-loops-metricraft`, `product-pipeline` (write-allowed), read across R&D as needed.  
**Goal:** Give ChatGPT a *stable, normalized* API to **read** tasks and to **propose writes** that are executed only after **human confirm** (Access-gated).

---

## Why this / outcomes

- **Speed up daily ops**: morning digests, verify sweeps, quick-add product ideas, and “what changed today” without tab-juggling.  
- **Safety first**: LLM can’t mutate ClickUp directly. Writes require a **one-click confirm** behind Cloudflare Access (Google SSO).  
- **Low-ops, Cloudflare-first**: edge-cached reads, event-driven cache invalidation, no servers to babysit.  
- **Productizable**: clean REST surface + OpenAPI; later add a thin MCP/Connector facade.

---

## High-level design

- **Cloudflare Worker (TypeScript)** exposes `/v1/*` endpoints with a **normalized schema** for tasks/lists/comments/fields.
- **HMAC-signed URLs** (TTL 60–300s) for LLM **reads**; params are allow-listed and tamper-proof.  
- **Writes** (`POST /v1/task`, `/v1/task/{id}/comment`, bulk) return a **confirm_url**; a minimal **Pages** UI executes after Access login.  
- **KV (90s TTL)** caches hot reads; **Durable Object** coordinates invalidation & light rate-limit backpressure; **Queues** ingest webhooks and run bulk jobs.  
- **ClickUp v2**: personal token in v0; pathway to OAuth for multi-tenant/public later. Dropdowns handled by **option-ID ↔ label** maps.

### Architecture (Mermaid)

```mermaid
flowchart LR
  subgraph Chat
    A[ChatGPT (LLM)]
  end

  subgraph Cloudflare
    W[Worker /v1 API\nTypeScript]
    KV[(Workers KV\n90s TTL cache)]
    DO[Durable Object\ncache versioning\n+ RL coordination]
    Q[(Queues)\nwebhook + bulk]
    P[Pages (Confirm UI\n+ CSV upload)\nAccess-protected]
  end

  subgraph ClickUp
    CU[ClickUp API\n(token/OAuth)]
    WH[Webhooks]
  end

  A -- signed GET --> W
  W <--> KV
  W <--> DO
  W -- write -> P
  P -- confirm POST --> W
  W --> CU
  WH --> W
  W --> Q --> DO
  DO --> KV
