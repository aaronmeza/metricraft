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