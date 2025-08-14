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