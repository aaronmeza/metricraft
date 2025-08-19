/*
metricraft — 00-coupons / moisture-check (v1.0.0)
License: Remixes allowed / Non‑Commercial (see /docs/LICENSE)

WHAT
  Ultra‑small coupon to sanity‑check filament moisture in <10 min, <4 g material.
  Two tests: (1) stringing + bridge mast, (2) single‑perimeter thin‑wall tube.

WHY
  Moisture increases melt viscosity variance → stringing, popping, pinholes, poor bridges.
  This coupon gives a fast, visual + audible pass/fail without wasting a big print.

PRINT INSTRUCTIONS (P1S, 0.4 mm nozzle default)
  • Plate: PLA/PETG default profile. Layer height 0.20 mm.
  • Per‑object overrides:
      – thinwall_tube: Walls = 1 loop, Infill = 0%, Top = 0, Bottom = 2.
      – string_bridge_mast: Walls = 2, Infill = 0%, Top = 3, Bottom = 2.
  • Cooling: PLA 100% fan; PETG 30–50% fan.
  • Travel: disable "Avoid crossing walls" for mast (to force retracted travels).
  • Seam: set to REAR and orient the plate arrow so seams land on keep‑out faces.
  • Brim: 2–3 mm brim on thinwall_tube only (improves adhesion, still minimal material).

ACCEPTANCE CRITERIA (PLA reference)
  • Stringing/Bridge Mast: ≤ a few wispy hairs; no bead chains; bridges sag ≤1 mm.
  • Thin‑Wall Tube: smooth wall ~0.42–0.48 mm measured with calipers; no pinholes.
  If fail → dry 2–3 h @ 50–55 °C, cool sealed, reprint. Stop when pass or mass plateau.

OBJECT NAMES (for 3MF):
  01-string-bridge-mast, 02-thinwall-tube, readme-plate (optional)

NOTES
  – Keep geometry small to encourage aggressive travel between posts (provokes stringing if wet).
  – Bridge bars at two heights expose moisture‑related sag and surface bubbling.
  – Thin‑wall uses a single perimeter to reveal bubbles/pockmarks from steam.

PARAMETERS
*/

// ===== User‑tunable =====
nozzle_d = 0.40;           // mm
layer_h  = 0.20;           // mm (for comments; model is geometric)
post_d   = 3.6;            // vertical post diameter
mast_h   = 30;             // mm tower height
post_gap = 20;             // mm clear span between post centers for bridges
base_t   = 0.8;            // mm foot thickness under each post/tube
bridge_w = 2.0;            // mm bridge bar thickness
bridge_z = [15, 25];       // mm bridge heights
label_depth = 0.4;         // mm label emboss height
with_labels = false;       // optional small labels to aid identification

// Plate layout
spacing = 14;              // mm spacing between test groups

// ===== Helpers =====
module _foot_square(x=12,y=12,t=base_t){
  translate([-x/2,-y/2,0]) cube([x,y,t]);
}

module _post(){
  // round post on a small square foot for adhesion
  union(){
    _foot_square();
    translate([0,0,base_t]) cylinder(h=mast_h, d=post_d, $fn=48);
  }
}

module _bridge_bar(len){
  // simple rectangular bridge between posts
  translate([-len/2,-bridge_w/2,0]) cube([len, bridge_w, bridge_w]);
}

module string_bridge_mast(){
  /* Two pairs of posts with bridges at multiple heights to exercise retractions
     and check sag/voids. Intentional gaps provoke travel moves. */
  len = post_gap + post_d; // overall span edge‑to‑edge
  // left pair
  translate([-len/2, 0, 0]) _post();
  translate([-len/2 + post_gap, 0, 0]) _post();
  // right pair, offset forward to prevent accidental merging of toolpaths
  translate([len/2, 4, 0]) _post();
  translate([len/2 - post_gap, 4, 0]) _post();

  // bridges on left pair
  for(z=bridge_z)
    translate([-len/2 + post_gap/2, 0, base_t + z]) _bridge_bar(post_gap);

  // bridges on right pair
  for(z=bridge_z)
    translate([len/2 - post_gap/2, 4, base_t + z]) _bridge_bar(post_gap);

  if(with_labels)
    translate([0,-10,base_t]) linear_extrude(height=label_depth)
      text("string-bridge-mast", size=4, halign="center", valign="center");
}

module thinwall_tube(){
  /* Single‑perimeter tube: OD chosen so slicer emits exactly one loop.
     Wall thickness ~ nozzle_d; shows bubbles/pitting when wet. */
  od = 12; id = od - (nozzle_d*2); // target ~0.4 mm wall
  union(){
    _foot_square(x=18,y=18);
    translate([0,0,base_t]) difference(){
      cylinder(h=20, d=od, $fn=96);
      cylinder(h=20+0.1, d=id, $fn=96);
    }
  }
  if(with_labels)
    translate([0,-12,base_t]) linear_extrude(height=label_depth)
      text("thinwall-tube", size=4, halign="center", valign="center");
}

// ===== Plate assembly =====
module plate_readme(){
  // Tiny 0.6 mm tag to carry README basics; optional
  sz=[52,18,0.6];
  translate([-sz[0]/2,-sz[1]/2,0]) cube(sz);
  translate([0,0,0.6]) linear_extrude(height=0.6)
    text("metricraft moisture check v1.0.0", size=4, halign="center", valign="center");
}

module moisture_check_plate(include_readme=false){
  // Arrange objects compactly within ~80x60 mm
  translate([-20, 0, 0]) string_bridge_mast();
  translate([ 28, 0, 0]) thinwall_tube();
  if(include_readme)
    translate([0, -26, 0]) plate_readme();
}

// === Render ===
moisture_check_plate(include_readme=false);
