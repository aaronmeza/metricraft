# Metricraft Glossary

**version:** 0.1.0
**status:** draft
**scope:** shared terms and design tokens for docs, SCAD params, and release notes.

> Keep entries concise and remix‑friendly. Add new terms when they appear in a README, ADR, coupon, or 3MF plate. Use sentence case for term names; code style for tokens.

---

## Core concepts

**datum‑rail**
A unifying hardware interface used across parts for alignment, attachments, and serviceability. Provides a consistent reference for tolerances and modularity.

**coupon**
A small test piece printed to validate fit/strength (e.g., XY clearance ladder, hole/shaft gauges, snap‑fit cantilever). Each coupon has acceptance criteria in the part README.

**seam keep‑out**
A modeled/annotated zone where slicer seam placement is undesirable (show faces, critical fits). Keep seams away from these regions via geometry or slicing.

---

## Design tokens

Use tokens exactly as written; treat as public API for parts and docs.

### Rails & joints

* `mc-rail-12`
  Metricraft standard rail profile, nominal 12 mm width. Used for slide/locate features and accessory mounts. Baseline material thickness: `t12`.
* `mc-dovetail-8`
  Dovetail geometry sized to mate with `mc-rail-12` accessories; nominal 8 mm engagement depth with tapered lead‑in for easier starts. Baseline clearance: `clearance-x = 0.15 mm` (PETG).

### Wall thickness presets

* `t08` = 0.8 mm
  Thin skins, light panels; not for threaded inserts.
* `t12` = 1.2 mm
  Default shell thickness for general parts on P1S.
* `t16` = 1.6 mm
  Higher stiffness panels, modest lever loads.
* `t24` = 2.4 mm
  Structural ribs/boss collars; heat‑adjacent parts.

### Fillet presets (external)

* `r2` = 2 mm
  Edge break / comfort radius.
* `r3` = 3 mm
  Default external fillet for hand‑contact areas.
* `r6` = 6 mm
  Stronger stress relief near cutouts.
* `r10` = 10 mm
  Large blend on housings/covers; improves print flow on PETG.

### Clearances & gaps (initial)

* `clearance-x` = 0.15 mm (PETG)
  Nominal lateral fit for sliding/snap mating features. Calibrate per filament via XY ladder coupon.
* `clearance-z-top` = 0.10 mm
  Top‑face allowance against mating features; avoids elephant‑foot and top wobble.
* `clearance-z-bottom` = 0.10 mm
  Bottom‑face allowance; mitigates first‑layer squish impact.

> After calibration, reference token variants like `clearance-x-petg-translucent = 0.12 mm` in README overrides when needed.

### Slicing intents

* `goal:strength`
  Prioritize walls/infill; seam hidden; cooling reduced on bridges as needed.
* `goal:translucency`
  Thin walls, aligned paths, 0% sparse infill when possible; ironing as noted.
* `goal:surface`
  Seam relegated to back/underside; top layers increased; ironing optional.

---

## Coupons (standard set)

* **XY clearance ladder**
  Bars/slots stepping `0.05 mm` across a range. **Accept:** target fit at `clearance-x ± 0.05 mm` with finger pressure; no binding across +1 step.
* **hole/shaft gauges**
  Cylinders/bores stepping `0.05 mm`. **Accept:** nominal + clearance seats with light push; nominal negatives do not enter.
* **snap‑fit cantilever**
  Beam + latch with specified deflection. **Accept:** latch survives 10 cycles without whitening/crack; retention meets spec.

---

## Naming & notation

* Filenames and plate names use **all‑lowercase‑hyphens** (e.g., `datum-rail-coupon-plate.3mf`).
* Versions use **semver** (e.g., `v1.2.3`).
* Units default to **SI** unless otherwise noted.

---

## Change control

* Treat token changes as **breaking** unless the mating geometry remains backwards compatible. Record in an ADR and the part CHANGELOG.
* When adjusting a token for a specific filament, document as a **scoped override** in the README and 3MF plate note (e.g., *PETG‑Translucent uses `clearance-x = 0.12 mm`*).

---

## To add next

* Boss/inserts presets (`m3-insert-seat`, `boss-dia-6`, etc.).
* Support interfaces (`sacrificial‑bridge‑0.25`, `fuse‑tab‑0.3`).
* AMS/bed heat‑adjacent rules of thumb (PETG vs. PLA).
