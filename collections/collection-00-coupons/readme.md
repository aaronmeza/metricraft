Rails, dovetails, and coupons give us a shared language for fit, alignment, and reliability—so every later part “just works.” Think of it like USB for your printer ecosystem: once the interface is right, everything that plugs into it is easy.

Here’s the idea, clean and actionable:

## The datum-rail system (why it exists)

What it is: A small family of standardized interfaces—e.g., mc-rail-12 (12 mm reference rail) and mc-dovetail-8 (8 mm low-angle dovetail)—with fixed geometries (widths, chamfers/fillets, lead-in chamfers, screw slot spacing).

What it does: Provides a datum (a physical reference) so modules align precisely, swap quickly, and remain serviceable. Rails set where parts sit; dovetails lock them repeatably without fiddly hardware.

Why it matters: Printers, filaments, humidity, and slicers shift dimensions. If the interface is standardized and tuned early, all downstream pieces inherit that reliability.

## The test coupons (how we get repeatable fit fast)

We print tiny, fast coupons to calibrate your filament + environment to our interfaces. Then you make global slicer tweaks (or pick the right clearance flavor), and proceed to big parts with confidence.

## Coupon pack (print this first):

**XY clearance ladder** (sliders at gaps: 0.15, 0.20, 0.25, 0.30, 0.35, 0.40 mm per side)

Goal: Pick the tightest gap that slides smoothly by hand with no binding.

Acceptance: Slides with light thumb pressure; no white-stress marks; no visible ovaling.

**Hole/shaft gauge** (pins/holes from 4–10 mm with 0.1 mm steps)

Goal: Identify press-fit vs slip-fit thresholds for your PETG.

Acceptance: Slip-fit pin can be pushed in/out by hand; press-fit requires firm push, no cracking.

**Rail/dovetail gauge** (short **mc-rail-12** + receivers printed at −0.10, 0.00, +0.10, +0.20, +0.30 mm effective clearance)

Goal: Find the receiver that slides on, no wobble, holds when lifted lightly, yet disassembles without tools.

Acceptance: Slide engages with steady thumb push; assembled joint survives a light shake without falling.

**Snap-fit cantilever** (t08, t12 beams at 25/35 mm length; root fillets r2/r3)

Goal: Verify PETG’s safe elastic range for future clips.

Acceptance: Survives 50 open/close cycles without whitening or permanent set >0.2 mm.

**Ring roundness test** (Ø40 mm, 2 mm wall)

Goal: Check XY scaling/elephant-foot.

Acceptance: OD/ID within ±0.10 mm; bottom edge not flared after skirt removal.