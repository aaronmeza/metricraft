# <part‑name> <version>

**what:** One‑sentence purpose.  
**why:** Problem it solves and design intent.  
**printer/filament:** Bambu P1S + AMS/AMS 2 Pro; Bambu filaments.  
**defaults:** Bambu Studio 2.2.0.85 unless stated.

## test coupons
- XY clearance ladder: target fit = <spec>; acceptable range = <spec>.
- Hole/shaft gauges: nominal ± clearance; report measured outcomes.
- Snap‑fit cantilever: report deflection and latch integrity per filament.

## slicing
**goal:** strength | translucency | surface.  
**defaults:** layer 0.20 mm; walls 3; infill 15% grid.  
**overrides:** list only what deviates; explain why.

## tolerances
- Initial XY clearance: 0.15 mm (PETG); Z top/bottom: 0.10 mm.  
- Calibrate with provided coupons; adjust per filament.

## seam & overhang notes
- Keep seam off show faces; mark keep‑outs in model images.  
- Overhangs >50° require supports; call out risk zones.

## safety & license
- Hot‑end/AMS proximity notes if heat‑adjacent.  
- License(s): see repo LICENSE or project‑specific license.

## changelog
- See CHANGELOG below or linked file.