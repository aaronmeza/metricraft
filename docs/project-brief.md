# Project Brief — Metricraft (datum‑rail collection)

Use this as the single source of truth for the Metricraft project. It’s tailored so you can archive chats freely while keeping durable context.

---

## 1) project-brief.md (filled for Metricraft)

### Project Name

**Name:** Metricraft — *datum‑rail* modular collection for Bambu P1S + AMS/AMS 2 Pro
**Owner:** Aaron Meza
**Stakeholders:** Bambu P1S/AMS owners; MakerWorld remixers; internal test team (you + ChatGPT)
**Repo(s):** [https://github.com/aaronmeza/metricraft](https://github.com/aaronmeza/metricraft)
**Primary doc folder:** `/docs`

### Purpose & Outcomes

* **Problem statement:** P1S/AMS users lack a cohesive, standards‑based set of modular upgrades that print reliably, assemble precisely, and are easy to maintain.
* **Vision (1–2 sentences):** A unified, serviceable ecosystem of rails, dovetails, and fixtures that make Bambu printers more capable—*precise enough for repeatability, simple enough to remix, robust enough for real use*.
* **Measurable outcomes (KPIs):**

  * ≥ 5 core SKUs shipped with v1.0 specs and print‑order checklists
  * ≥ 200 combined downloads/makes per SKU on MakerWorld within 60 days of release
  * ≤ 3% reported print failures (per profile) after v1.1 tuning
  * Turnaround ≤ 72h from bug report → patched profile release

### Scope & Non‑Goals

* **In‑scope:** Bambu **P1S** printer and **AMS/AMS 2 Pro** accessories; rails/dovetails; test coupons; calibration fixtures; spool & storage components; MakerWorld publishing.
* **Explicit non‑goals:** Non‑Bambu ecosystems; purely aesthetic models; closed parametric cores for models flagged as “binary‑release only”.

### Users & Constraints

* **Primary users:** Intermediate P1S owners with AMS who value precise, modular upgrades and predictable print profiles.
* **Key constraints:**

  * Materials: Bambu brand; **PLA‑first** for general parts; **PETG (or other heat‑tolerant materials)** required for structural or heat‑exposed parts (e.g., filament spool, desiccant containers, plate aligner).
  * Slicer used in development: **Bambu Studio 2.2.0.85 (macOS)**.
  * Nozzle used in development: default 0.4 mm OK; OBXidian HF used in tests at conservative speeds.
* **Assumptions / risks:** Thread library drift in OpenSCAD vendors; dimensional drift across filaments; MakerWorld versioning quirks.

### Canonical Definitions

* **datum‑rail:** A standardized rail profile (**mc‑rail‑12**) used as a reference surface for mounting modular parts.
* **dovetail:** The standard joint (**mc‑dovetail‑8**) for slide‑fit attachments compatible with the datum‑rail.
* **serviceable:** Parts designed for disassembly and replacement; fasteners accessible without removing the whole assembly.

### Architecture / Systems (as of 2025‑08‑13)

* **Stack / tooling:** OpenSCAD (parametric), Makefile build scripts, Bambu Studio for slicing, GitHub for versioning and releases, ClickUp for project management.
* **Key integrations / data sources:** MakerWorld listings; ClickUp boards (see structure below); Inventory list (“Inventory — main”).
* **Environments:** Local macOS; CI optional later for STL regen and linting.

### ClickUp — Current Structure (authoritative)

**Space:** `metricraft`

**Folders & Lists:**

1. **01–Product & Publishing**

   * List: **Product Pipeline** *(authoritative issue tracker for products)*
2. **02–Client Work**

   * List: **Client jobs — main workflow**
3. **03–Ops**

   * List: **Open Loops — metricraft**
   * List: **Inventory — main**
   * List: **Maintenance — schedule**
   * List: **R\&D — experiments backlog**
4. **04–Growth**

   * List: **Marketing — MakerWorld + socials**

**Suggested addition (to centralize web/portal work):**
5\. **05–Web & Portals** *(new)*

* List: **Web — site backlog**
* List: **Portal — external**
* List: **Portal — internal**
* List: **Docs & SEO**

> If adopted, keep **Product Pipeline** as the single product issue tracker; web/portal tasks live under **05–Web & Portals**. Reflect this structure in labels/tags for cross‑links.

### Domain & Portals — `metricraft.works`

**DNS:** Cloudflare.
**Email:** `support@metricraft.works`, `hello@metricraft.works`, `legal@metricraft.works`.
**SSL:** Auto via provider; HSTS after smoke tests.

**Public (external) surface:**

* `https://metricraft.works` → marketing site (home, collection pages, MakerWorld links).
* `https://docs.metricraft.works` → public documentation (print‑order checklists, SKU pages, FAQs, troubleshooting).
* `https://cdn.metricraft.works` → static assets (renders, spec PDFs, images).
* `https://status.metricraft.works` → status/changelog (optional at launch; otherwise `/changelog`).

**Internal surface (authenticated):**

* `https://studio.metricraft.works` → internal portal (release checklist, asset staging, SKU publishing workflow, MakerWorld sync helpers).
* `https://admin.metricraft.works` → admin panel (future) for role‑based content, redirects, and link management.
* Auth: GitHub SSO (proposed).
* Source of truth: repo `/docs` + `/assets`; site generated via static site generator (proposed: Astro or Docusaurus).

**Content model (starter):**

* `content/sku/<sku-id>/index.md` — overview, variants, licensing.
* `content/sku/<sku-id>/print-order-checklist.md` — printable checklist (mirrors template below).
* `content/specs/datum-rail-v1.md`, `content/specs/dovetail-v1.md` — canonical specs.
* `content/changelog/YYYY-MM-DD.md` — release notes.

### Design Tokens / Standards

* **Naming rules:** `all-lowercase-hyphens`; semantic versioning (semver).
* **Tokens / dimensions:** `mc-rail-12`, `mc-dovetail-8`, wall `t08/t12/t16/t24`, fillets `r2/r3/r6/r10`, standard clearances per coupon results.
* **Materials / print standards:**

  * **PLA‑first** for general, non‑heat parts (release PLA profiles).
  * **Heat/structural parts:** release **PETG‑only** (or other heat‑tolerant) profiles; do **not** publish PLA for these.
  * **TPU (for AMS)** when flexibility/impact is beneficial; label as “TPU for AMS” profiles.
* **Licensing defaults:** *Remix allowed, non‑commercial* (e.g., CC BY‑NC) unless a model explicitly states otherwise.

### Processes & Cadence

* **Decision log:** `/docs/decisions` (markdown notes, dated filenames).
* **Issue tracker / workflow states:** ClickUp list **Product Pipeline** (custom statuses including *waiting*, *snoozed*, *done*).
* **Rituals:** Weekly mini‑planning; print‑order checklist per SKU; post‑release profile tuning.
* **Release cadence:** Ship v1.0 with PLA for general parts or PETG for heat/structural; fast‑follow v1.1 after feedback.

### Current Milestones (initial draft)

* **M1 — Datum‑rail standard v1.0** — *2025‑08‑22* — Owner: Aaron — **Spec & test coupon released; two reference mounts published.**
* **M2 — Test coupons bundle v1.0** — *2025‑08‑25* — Owner: Aaron — **Clearance/fit matrix; wall/fillet verification; STL + 3MF.**
* **M3 — AMS silica canister PETG v1.1** — *2025‑08‑27* — Owner: Aaron — **Profile tuning for PETG + documentation; MakerWorld notes clarified.**
* **M4 — Filament spool system v0.9** — *2025‑09‑05* — Owner: Aaron — **Parametric spool with serviceable flanges; verified BOM.**

### Links (single source of truth)

* **Roadmap:** `/docs/roadmap.md`
* **Backlog board:** ClickUp — *Product Pipeline*
* **Specs folder:** `/docs/specs`
* **Asset library:** `/assets` (renders, photos)
* **Onboarding doc:** `/docs/onboarding.md`
* **MakerWorld profile:** @aaron.meza (project listings)
* **Website repos (proposed):** `/web/public-site`, `/web/docs-site`, `/web/internal-portal`

### Recently Made Decisions (snapshot)

* **2025‑08‑13** — **PLA‑first** for general parts; **PETG‑only** (or heat‑tolerant) for structural/heat parts. — Rationale: match broader user base; ensure safety for heat‑adjacent components.
* **2025‑08‑12** — Naming: **all‑lowercase‑hyphens**; versions use **semver**. — Rationale: consistency across repo & listings.
* **2025‑08‑12** — MakerWorld is the **primary distribution**; others equal weight later. — Rationale: Bambu ecosystem alignment.
* **2025‑08‑11** — Desiccant canister remix: **allow remixes; non‑commercial**; start at **v1.0**; no open‑port variant yet. — Rationale: translucency + AMS drying focus.

### Open Questions

* Finalize clearance table that maps *mc‑dovetail‑8* fits to PLA vs PETG shrinkage.
* Decide on thread library vendor pinning to avoid OpenSCAD version drift.
* Confirm default project license (CC BY‑NC vs BY‑NC‑SA) and document exceptions per model.
* Define “print‑order checklist” template per SKU (supports MakerWorld description).
* Cloudflare  for DNS + CDN, and pick static site generator for docs (Astro/Docusaurus).

---

## 2) Memory One‑Liners — ready to paste

> Paste each into ChatGPT as **“Remember this: …”**

### Project Identity

* Remember this: In the **Metricraft** project, the primary repo is **[https://github.com/aaronmeza/metricraft](https://github.com/aaronmeza/metricraft)** and docs live in `/docs`.
* Remember this: The Metricraft project owner is **Aaron Meza**; day‑to‑day decisions are delegated to Aaron unless otherwise noted in `/docs/decisions`.

### Naming & Style

* Remember this: Metricraft uses **all-lowercase-hyphens** for files & SKUs; versions follow **semver**.
* Remember this: Project tone in docs is concise, technical, and remix‑friendly.

### Tech & Standards

* Remember this: Metricraft targets **Bambu P1S + AMS/AMS 2 Pro**, sliced in **Bambu Studio 2.2.0.85** on macOS.
* Remember this: **PLA‑first** for general parts; **PETG‑only** (or heat‑tolerant) for structural/heat parts.
* Remember this: Core tokens are **mc-rail-12**, **mc-dovetail-8**, walls **t08/t12/t16/t24**, fillets **r2/r3/r6/r10**; treat as fixed unless `/docs/decisions` says otherwise.

### Definitions

* Remember this: In Metricraft, **“datum‑rail”** refers to the standard **mc‑rail‑12** profile; **“dovetail”** refers to **mc‑dovetail‑8**.

### Constraints & Preferences

* Remember this: Profiles should print reliably on stock 0.4 mm nozzles.
* Remember this: MakerWorld is the **primary distribution channel** for releases.
* Remember this: Unless a model states otherwise, **remixes allowed / non‑commercial** is the default licensing stance.

### Links

* Remember this: The single source of truth for the **roadmap** is `/docs/roadmap.md`; ignore other roadmaps.
* Remember this: Renders/photos live in `/assets`.
* Remember this: Public docs live at **docs.metricraft.works**; internal portal is **studio.metricraft.works** (auth required).

### Cadence

* Remember this: Weekly mini‑planning occurs before releases; post‑release, ship **v1.1** tuning within 72h of feedback.
* Remember this: Pull requests require passing build scripts and attached **print‑order checklist** for affected SKUs.

### Personas (short)

* Remember this: The primary user is a Bambu P1S owner with AMS who values precise, modular upgrades and reliable profiles.

### Escalation / Decisions

* Remember this: Decisions are logged in **/docs/decisions**; the latest dated entry supersedes prior guidance.

---

## 3) Archiving Hygiene (quick checklist)

*

---

## 4) Deliverables to add to the repo

Below are copy‑ready files/templates. Place them as indicated.

### `/docs/templates/print-order-checklist.md`

```markdown
# Print‑Order Checklist — <SKU name>

**SKU:** <sku-id>  
**Version:** v<major.minor.patch>  
**Material Profile:** PLA | PETG | TPU‑for‑AMS  
**Intended Use:** general | heat/structural | flexible

## 1) Pre‑flight
- [ ] Slicer: Bambu Studio v2.2.x (or newer)
- [ ] Nozzle: 0.4 mm (clean; cold‑pull if needed)
- [ ] Filament: correct material selected; dry if PETG/TPU (40–55 °C)
- [ ] Plate: clean; adhesion type set (textured smooth PEI, etc.)

## 2) Calibrations (once per material)
- [ ] Flow/extrusion calibrated  
- [ ] PA/pressure advance tuned  
- [ ] Retraction tuned (stringing acceptable for PETG)

## 3) Slice Settings (author defaults)
- Layer height: <e.g., 0.28 mm>
- Walls: <e.g., 2>
- Top/Bottom: <e.g., 4 / 3>
- Infill: <e.g., 15% grid>
- Supports: <none | tree | normal> (interface: <on/off>)
- Seam: <rear | aligned | random>
- Ironing: <on/off> (top layers only)

## 4) Orientation & Parts
- [ ] Part orientation matches preview  
- [ ] Brims/rafts as specified  
- [ ] Multi‑part print order noted

## 5) Post‑print QA
- [ ] Critical dims within tolerance (±0.15 mm PLA; ±0.25 mm PETG)  
- [ ] Dovetail fit test passed (see spec)  
- [ ] Deburr/clean as needed

## 6) Assembly
- Fasteners: <e.g., M3x8 pan‑head x 4>  
- Torque: snug; do not over‑tighten into plastic  
- Notes: <e.g., press‑fit bearing; use isopropyl on insert>

## 7) Safety & Material Notes
- PLA for general parts only; **do not** use PLA for heat‑adjacent/structural parts  
- PETG required for <list components>; TPU for flexible elements

---

**Changelog**  
- v<1.0.0> — initial release
```

### `/docs/DECISIONS.md` (index)

````markdown
# DECISIONS Index

Canonical index of design/engineering decisions. Individual decisions live in `/docs/decisions/YYYY‑MM‑DD‑<slug>.md`.

## How this index is maintained
- Add a new line under **Log** whenever you add a decision file.  
- Optional: run the helper command to regenerate the list automatically.

### Helper (macOS/Linux)
```bash
ls -1 docs/decisions/*.md \
  | sed 's#docs/##' \
  | sort \
  | awk '{printf("- [%s](%s)
", $0, $0)}' \
  > docs/DECISIONS.md.tmp && mv docs/DECISIONS.md.tmp docs/DECISIONS.md
````

## Log

* 2025‑08‑13 — PLA‑first for general; PETG‑only for heat/structural — [decisions/2025‑08‑13‑materials‑policy.md](decisions/2025‑08‑13‑materials‑policy.md)
* 2025‑08‑12 — Naming & versioning conventions — [decisions/2025‑08‑12‑naming‑semver.md](decisions/2025‑08‑12‑naming‑semver.md)
* 2025‑08‑12 — Distribution channel (MakerWorld) — [decisions/2025‑08‑12‑distribution‑makerworld.md](decisions/2025‑08‑12‑distribution‑makerworld.md)

````

### `/docs/specs/datum-rail-v1.md` (first pass)

```markdown
# Spec: mc‑rail‑12 (Datum‑Rail) — v1.0‑draft

**Status:** Draft (pending coupon validation)  
**Applies to:** Bambu P1S + AMS/AMS 2 Pro ecosystem  
**Interfaces:** mc‑dovetail‑8 modules; M3 fastener grid

## Intent
Provide a consistent reference rail used to mount modular components. Two supported variants: **Solid Rail** (bolt‑on) and **Slotted Rail** (integrated dovetail track).

## Normative Dimensions (all mm)
- Nominal rail width **W**: **12.00**  
- Nominal rail height **H**: **6.00**  
- Corner fillet **r**: **1.00**  
- Centerline chamfers: 0.5 × 45° (visual datum)

### Variant A — Solid Rail (bolt‑on)
- Hole grid: **M3** clearance Ø **3.40**, countersink optional  
- Grid pitch (along rail): **24.00**  
- Edge setback to hole center: **6.00**  
- Recommended insert: M3 heat‑set (DIN 16903) where applicable

### Variant B — Slotted Rail (integrated dovetail)
- Slot accepts **mc‑dovetail‑8 male** profile  
- Slot mouth width **Ws**: see mc‑dovetail‑8 (female mouth recommendations)  
- Slot depth: **3.60**  
- Retention lip: **0.60** per side (min)

## Materials & Printing
- **PLA** allowed for non‑structural rails under ambient conditions.  
- **PETG** required for rails carrying load or near heat sources.  
- Orientation: print rail **on its side** to maximize layer adhesion across width; enable **ironing off**.  
- Tolerances: ±0.15 (PLA), ±0.25 (PETG) on width/height; hole diameters per slicer compensation.

## Quality Gates
- Flatness over 150 mm span: ≤ 0.30  
- Straightness over 150 mm span: ≤ 0.30  
- Dovetail slider test: frictional but smooth travel with no binding

## Notes
- All dims are **pre‑compensation**. Apply slicer/thickness compensation per coupon results.  
- Keep fillets consistent with tokens `r2/r3/r6/r10` where aesthetics warrant.
````

### `/docs/specs/dovetail-v1.md` (first pass)

```markdown
# Spec: mc‑dovetail‑8 — v1.0‑draft

**Status:** Draft (pending coupon validation)  
**Purpose:** Sliding attachment compatible with mc‑rail‑12 (slotted variant) and clamp‑on fixtures.

## Geometry (male)
- Base width **Wm**: **8.00**  
- Top width **Tm**: **6.00**  
- Height **Hm**: **3.50**  
- Side draft per face: ≈ **8°** (derived from 1.00 mm per side over 3.50 mm rise)  
- Edge fillet **r**: **0.50**

## Geometry (female)
- Mouth width **Wf (PLA)**: **8.10**  
- Mouth width **Wf (PETG)**: **8.20**  
- Depth **Hf**: **3.60**  
- Relief chamfer at mouth: 0.3 × 45°  
- Clearance behind stop: **0.20** (PLA), **0.30** (PETG)

> These values target a smooth slide‑fit with light hand force after minor deburring.

## Fit Classes
- **Class S (Slide):** default; minimal play; printable without supports.  
- **Class T (Tight):** reduce Wf by 0.05; intended for locking inserts.  
- **Class L (Loose):** increase Wf by 0.10; for dusty/contaminated environments.

## Printing Guidance
- **PLA:** best dimensional stability; aim for 0.20–0.28 layers; 2 walls; 3 top/3 bottom.  
- **PETG:** allow an extra 0.10–0.15 in clearances; expect minor stringing; light deburr.  
- Orient male with dovetail **upwards** to preserve edge definition; female on **side** for stronger slot lips.

## Verification (coupon)
- Print male/female pair in both PLA and PETG using default profiles.  
- Record required insertion force (qualitative) and dimensional results.  
- Adjust **Wf** in 0.05 mm steps per material until **Class S** achieved.

## Safety/Use Notes
- Do not cantilever heavy loads on a single 8 mm dovetail without secondary fasteners.  
- For structural mounts, use **two** dovetail engagements spaced ≥ 24 mm and add **M3** bolts.
```

---

### How to use

1. Commit this brief to `/docs/project-brief.md` in the repo.
2. Paste the One‑Liners into ChatGPT Memories.
3. Add the templates/specs to `/docs` as shown.
4. Optionally add the **05–Web & Portals** folder in ClickUp and move web/portal tasks there.
5. Archive chats guilt‑free—durable context lives here, in Memories, and in your repo.
