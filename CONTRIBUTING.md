# Contributing to Metricraft

Welcome! This repo powers the Metricraft *datum-rail* collection for Bambu P1S + AMS/AMS 2 Pro.

## Ground rules
- **Licensing:** Default stance is **Remix allowed / Non-Commercial** unless a model states otherwise.
- **Naming:** `all-lowercase-hyphens` for files/SKUs. **Semver** for versions.
- **Materials:** **PLA-first** for general parts. **PETG-only** (or other heat-tolerant) for heat/structural parts.

## Where work is tracked
- Product issues live in **ClickUp → 01–Product & Publishing → Product Pipeline** (authoritative).
- This repo is for code, specs, and releases. Reference the ClickUp task in PRs (paste link in PR description).

## Repo layout (high level)
- `/docs/project-brief.md` — single source of truth for the project
- `/docs/specs/` — canonical specs (`datum-rail-v1.md`, `dovetail-v1.md`)
- `/docs/decisions/` — dated decision notes (`YYYY-MM-DD-<slug>.md`)
- `/docs/DECISIONS.md` — generated index (see Makefile target)
- `/docs/templates/print-order-checklist.md` — per-SKU checklist
- `/assets/` — renders/photos
- `/web/*` — site(s) when added (public/docs/internal)

## Workflow
1. **Branch:** `feature/<slug>` or `fix/<slug>`.
2. **Decision log (if policy/standard changes):**
   - `make new-decision SLUG=<slug>`
   - Edit the file, then `make decisions-index`
3. **Profiles & specs:**
   - General parts: provide **PLA** profile
   - Heat/structural: provide **PETG** (no PLA)
   - Update specs if tokens or clearances change
4. **Checklists:** include `/docs/templates/print-order-checklist.md` filled for each affected SKU.
5. **Docs:** update `/docs/project-brief.md`, `/docs/specs/*`,*
