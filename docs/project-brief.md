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

* **Problem statement:** P1S/AMS users lack a cohesive, standards‑based set of modular upgrades that print reliably (PETG‑friendly), assemble precisely, and are easy to maintain.
* **Vision (1–2 sentences):** A unified, serviceable ecosystem of rails, dovetails, and fixtures that make Bambu printers more capable—*tough enough for PETG, precise enough for repeatability, simple enough to remix*.
* **Measurable outcomes (KPIs):**

  * ≥ 5 core SKUs shipped with v1.0 specs and print‑order checklists
  * ≥ 200 combined downloads/makes per SKU on MakerWorld within 60 days of release
  * ≤ 3% reported print failures (per profile) after v1.1 tuning
  * Turnaround ≤ 72h from bug report → patched profile release

### Scope & Non‑Goals

* **In‑scope:** Bambu **P1S** printer and **AMS/AMS 2 Pro** accessories; rails/dovetails; test coupons; calibration fixtures; spool & storage components; PETG‑oriented geometries; MakerWorld publishing.
* **Explicit non‑goals:** Non‑Bambu ecosystems; purely aesthetic models; PLA‑only designs for heat‑exposed parts; closed parametric cores for models flagged as “binary‑release only”.

### Users & Constraints

* **Primary users:** Intermediate P1S owners with AMS who value precise, modular upgrades and predictable print profiles.
* **Key constraints:**

  * Environment: basement 50–60 °F, \~60% RH
  * Materials: Bambu brand; **PETG preferred** for durability/heat; also PLA, TPU (AMS‑safe "TPU for AMS").
  * Slicer used for development: **Bambu Studio 2.2.0.85 (macOS)**.
  * Nozzle: default 0.4 mm OK; OBXidian HF used in tests at conservative speeds.
* **Assumptions / risks:** Thread library drift in OpenSCAD vendors; PETG warping; MakerWorld versioning quirks.

### Canonical Definitions

* **datum‑rail:** A standardized rail profile (**mc‑rail‑12**) used as a reference surface for mounting modular parts.
* **dovetail:** The standard joint (**mc‑dovetail‑8**) for slide‑fit attachments compatible with the datum‑rail.
* **serviceable:** Parts designed for disassembly and replacement; fasteners accessible without removing the whole assembly.

### Architecture / Systems (as of 2025‑08‑13)

* **Stack / tooling:** OpenSCAD (parametric), Makefile build scripts, Bambu Studio for slicing, GitHub for versioning and releases. ClickUp for project management
* **Key integrations / data sources:** MakerWorld listings, ClickUp for pipeline (“Product pipeline — MakerWorld & internal”), Inventory list (“Inventory — main”).
* **Environments:** Local macOS; CI optional later for STL regen and linting.

### Design Tokens / Standards

* **Naming rules:** `all-lowercase-hyphens`; semantic versioning (semver).
* **Tokens / dimensions:** `mc-rail-12`, `mc-dovetail-8`, wall `t08/t12/t16/t24`, fillets `r2/r3/r6/r10`, standard clearances per coupon results.
* **Materials/print standards:** Profiles tuned for PETG first; PLA/TPU variants when relevant.
* **Licensing defaults:** *Non‑commercial remix allowed* (e.g., CC BY‑NC) unless a model explicitly states otherwise.

### Processes & Cadence

* **Decision log:** `/docs/decisions` (markdown notes, dated filenames).
* **Issue tracker / workflow states:** ClickUp list “Product Pipeline” (custom statuses including *waiting*, *snoozed*, *done*).
* **Rituals:** Weekly mini‑planning; print‑order checklist per SKU; post‑release profile tuning.
* **Release cadence:** Ship v1.0 with PETG profile; fast‑follow v1.1 after feedback.

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

### Recently Made Decisions (snapshot)

* **2025‑08‑13** — Prefer **PETG** for heat‑adjacent parts; publish PETG‑first profiles. — Rationale: AMS 2 Pro drying use‑case and parts exposed to printer chamber.
* **2025‑08‑12** — Naming: **all‑lowercase‑hyphens**; versions use **semver**. — Rationale: consistency across repo & listings.
* **2025‑08‑12** — MakerWorld is the **primary distribution**; others equal weight later. — Rationale: Bambu ecosystem alignment.
* **2025‑08‑11** — Desiccant canister remix: **allow remixes; non‑commercial**; start at **v1.0**; no open‑port variant yet. — Rationale: translucency + AMS drying focus.
* **2025‑08‑11** — For translucency tests: **0% sparse infill** acceptable when structural loads are minimal. — Rationale: visibility + PETG.

### Open Questions

* Finalize clearance table that maps *mc‑dovetail‑8* fits to PETG vs PLA shrinkage.
* Decide on thread library vendor pinning to avoid OpenSCAD version drift.
* Confirm default project license (CC BY‑NC vs BY‑NC‑SA) and document exceptions per model.
* Define “print‑order checklist” template per SKU (supports MakerWorld description).

---

## 2) Memory One‑Liners — ready to paste

> Paste each into ChatGPT as **“Remember this: …”**

### Project Identity

* Remember this: In the **Metricraft** project, the primary repo is **[https://github.com/aaronmeza/metricraft](https://github.com/aaronmeza/metricraft)** and docs live in `/docs`.
* Remember this: The Metricraft project owner is **Aaron Meza**; day‑to‑day decisions are delegated to Aaron unless otherwise noted in `/docs/decisions`.

### Naming & Style

* Remember this: Metricraft uses **all-lowercase-hyphens** for files, SKUs, and MakerWorld titles; versions follow **semver**.
* Remember this: Project tone in docs is concise, technical, and remix‑friendly.

### Tech & Standards

* Remember this: Metricraft targets **Bambu P1S + AMS/AMS 2 Pro**, sliced in **Bambu Studio (internally for we use version 2.2.0.85** on macOS).
* Remember this: Default material is **PETG** for heat‑adjacent parts; PLA/TPU variants are second‑priority.
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

### Cadence

* Remember this: Weekly mini‑planning occurs before releases; post‑release, ship **v1.1** tuning within 72h of feedback.
* Remember this: Pull requests require passing build scripts and attached **print‑order checklist** for affected SKUs.

### Personas (short)

* Remember this: The primary user is a Bambu P1S owner with AMS who values precise, modular upgrades and reliable PETG prints.

### Escalation / Decisions

* Remember this: Decisions are logged in **/docs/decisions**; the latest dated entry supersedes prior guidance.

---

## 3) Archiving Hygiene (quick checklist)

*

---

## 4) Bonus Snippets

**Capture a decision**

> Remember this: On 2025‑08‑13, we decided  because ; see **/docs/decisions/\*\*\*\*.md** for details.

**Set tone/voice**

> Remember this: For **Metricraft**, write in a concise, technical, remix‑friendly tone aimed at Bambu P1S/AMS users.

**Enforce naming**

> Remember this: In **Metricraft**, all new files and issues must use **all-lowercase-hyphens**.

---

### How to use

1. Commit this brief to `/docs/project-brief.md` in the repo.
2. Paste the One‑Liners into ChatGPT Memories.
3. Archive chats guilt‑free—durable context lives here and in Memories.