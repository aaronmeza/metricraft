# metricraft — moisture-check coupon (v1.0.0)

**What:** Ultra-small coupon to sanity-check filament moisture in <10 min, <4 g.  
**Why:** Moisture drives popping, stringing, and pitted surfaces. This gives a fast yes/no before big prints.

## Objects (3MF names)
- 01-string-bridge-mast
- 02-thinwall-tube
- readme-plate (optional tag)

## Printer / Filament
Bambu P1S, 0.4 mm nozzle, Bambu PLA/PETG/TPU/PC.

## Slicing (Bambu Studio 2.2.0.85)
Global: 0.20 mm LH, 0% infill, Seam=Rear, Supports=Off.  
Per-object:
- 02-thinwall-tube: Walls=1, Top=0, Bottom=2, Brim=2–3 mm.
- 01-string-bridge-mast: Walls=2, Top=3, Bottom=2.
Travel: disable “Avoid crossing walls”.  
Cooling: PLA 100%; PETG 30–50%; TPU 50–80%; PC per profile.

## Acceptance criteria
PLA: wisps OK; ≤1 mm bridge sag; tube 0.42–0.48 mm; no pinholes.  
PETG: wisps OK, **no beaded strings**; ≤2 mm sag; tube glossy, no pitting.  
TPU: micro-hair OK, **no blobs**; ≤3 mm sag; tube continuous, no bubbles.  
PC: near-zero strings; ≤1 mm sag; tube pristine; **no popping**.

**If fail:** dry 2–3 h then retest (PLA 50–55 °C; PETG 60–65 °C; TPU 45–55 °C; PC 70–80 °C via external dryer if AMS can’t recover).

## License
Remixes allowed / Non-Commercial. See `/docs/LICENSE`.

## Safety
Hot surfaces. Small parts—choking hazard.
