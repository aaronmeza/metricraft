// metricraft-spool v1.0.0 (rc1)
// Bambu P1S + AMS — parametric reusable spool
// Flange style: B — Lissajous swirl (3 interleaved S-curve ribbons)
// Core: desiccant wave-core with face bayonet pocket + starter bore
//
// Notes:
// - Designed to be sliced in Bambu Studio 2.2.0.85
// - Units: millimeters
// - No external libraries; OpenSCAD 2021+ recommended
//
// --------------------------------------
//               TOKENS
// --------------------------------------

spool_od          = 198.5;   // outer diameter, AMS-safe
spool_width       = 65;      // assembled width (flange + core + flange)
hub_id            = 55;      // inner bore nominal
flange_t          = 2.4;     // flange web thickness
rim_land_w        = 9.0;     // solid roller track width
rim_land_t        = 2.6;     // a smidge thicker than web
tie_ring_r_ratio  = 0.70;    // tie ring at 70% radius
tie_ring_w        = 3.0;

// Heptachord chord style selector (v0.1 = "straight")
heptachord_chord_style = "dual";  // options: "straight" | "vertex-mid" | "arc"

spokes_count      = 3;       // 3 interleaved ribbons
ribbon_w_hub      = 4.5;     // ribbon width at hub (diameter units for hull stroke)
ribbon_w_rim      = 3.2;     // width near rim
swirl_amp_deg     = 28;      // swirl amplitude (angular), degrees
// a 2:1 “Lissajous feel”: theta = 2*pi*t + A*sin(4*pi*t)

// Core (desiccant wave)
wrap_diam         = 100;     // nominal filament wrap diameter (outer of core)
core_wall_t       = 1.8;     // wave shell wall thickness (web thickness of shell)
core_wave_amp     = 3.2;     // radial amplitude of wave (peak-to-center)
core_wave_pitch   = 11;      // circumferential pitch (mm along arc between peaks)
vent_slot_w       = 1.0;     // slot width through shell
core_len          = spool_width - 2*flange_t;     // core axial length between flanges
rib_count         = 6;       // radial ribs tying hub to shell

// Bead pocket (face)
pocket_d          = 24;      // pocket inner diameter for silica beads
pocket_depth      = 14;      // depth
cap_protrusion    = 1.0;     // how far the cap protrudes beyond flange face
bayonet_lug_w     = 3.0;
bayonet_lug_len   = 6.5;
o_ring_clearance  = 0.25;    // radial clearance

// Starter bore
starter_bore_d    = 2.8;
starter_bore_angle= 15;      // degrees relative to tangent

// Quality
$fn = 96;

// --------------------------------------
//          UTILS
// --------------------------------------
function rad(a) = a*PI/180;
function polar(r,a) = [r*cos(a), r*sin(a)];
module ring(r_outer, r_inner){ difference(){ circle(r_outer); circle(r_inner); } }

// Arc capsule along circle radius rr from angle a1→a2 (degrees), width w
module arc_capsule2d(rr, a1, a2, w){
  steps = 28;
  pts = [ for (k=[0:steps]) let(a = a1 + (a2-a1)*k/steps) [ rr*cos(a), rr*sin(a) ] ];
  // sweep with hull-of-circles
  for (k=[0:len(pts)-2]) hull(){ translate(pts[k]) circle(w/2); translate(pts[k+1]) circle(w/2); }
}

module ribbon_from_points(pts, r){
  for(i=[0:len(pts)-2]){
    hull(){
      translate(pts[i]) circle(r);
      translate(pts[i+1]) circle(r);
    }
  }
}

// Extra utils for geometric flanges
// Geometry helpers with explicit math (no shortcuts)
function vsub(a,b) = [a[0]-b[0], a[1]-b[1]];
function vlen(v) = sqrt(v[0]*v[0] + v[1]*v[1]);
function vunit(v) = let(l=vlen(v)) (l==0 ? [0,0] : [v[0]/l, v[1]/l]);
function vperp(u) = [-u[1], u[0]];

// Constant-width capsule between two points
module capsule2d(p1, p2, w){
  u = vunit(vsub(p2,p1));
  n = vperp(u);
  A = [p1[0] + n[0]*w/2, p1[1] + n[1]*w/2];
  B = [p2[0] + n[0]*w/2, p2[1] + n[1]*w/2];
  C = [p2[0] - n[0]*w/2, p2[1] - n[1]*w/2];
  D = [p1[0] - n[0]*w/2, p1[1] - n[1]*w/2];
  union(){ polygon([A,B,C,D]); translate(p1) circle(w/2); translate(p2) circle(w/2); }
}

// Tapered capsule between two points (w1 at p1 → w2 at p2)
module taper_capsule2d(p1, p2, w1, w2){
  u = vunit(vsub(p2,p1));
  n = vperp(u);
  A = [p1[0] + n[0]*w1/2, p1[1] + n[1]*w1/2];
  B = [p2[0] + n[0]*w2/2, p2[1] + n[1]*w2/2];
  C = [p2[0] - n[0]*w2/2, p2[1] - n[1]*w2/2];
  D = [p1[0] - n[0]*w1/2, p1[1] - n[1]*w1/2];
  union(){ polygon([A,B,C,D]); translate(p1) circle(w1/2); translate(p2) circle(w2/2); }
}

// Regular n‑gon points (counterclockwise), rotation in DEGREES (OpenSCAD trig is degrees)
function regular_ngon_points(n, r, rot_deg=0) = [
  for (i=[0:n-1]) let(a = rot_deg + 360*i/n) [ r*cos(a), r*sin(a) ]
];

// --------------------------------------
//          FLANGE — Lissajous swirl
// --------------------------------------
module flange_lissajous(show_debug=false){
  r_outer = spool_od/2;
  r_inner = r_outer - rim_land_w;        // inner edge of rim land
  r_hub_i = hub_id/2;                    // bore radius
  r_hub_o = r_hub_i + 6;                 // small hub boss ring for strength

  difference(){
    union(){
      // 1) Rim land: solid roller track (thicker)
      linear_extrude(height=rim_land_t)
        ring(r_outer, r_inner);

      // 2) Hub boss ring (no full web disk!)
      linear_extrude(height=flange_t)
        ring(r_hub_o, r_hub_i);

      // 3) Tie ring at ~70% radius
      tie_r = tie_ring_r_ratio * r_outer;
      linear_extrude(height=flange_t)
        ring(tie_r + tie_ring_w/2, tie_r - tie_ring_w/2);

      // 4) Ribbons — now actually EXTRUDED (fix)
      for(k=[0:spokes_count-1]){
        rotate([0,0, k*360/spokes_count])
          linear_extrude(height=flange_t)
            lissa_ribbon2d(r_hub_o+1.0, r_inner-0.8,
                           ribbon_w_hub/2, ribbon_w_rim/2,
                           swirl_amp_deg);
      }
    }

    // Bore the hub through all features
    translate([0,0,-0.1]) cylinder(h=flange_t+rim_land_t+0.2, r=r_hub_i, $fn=96);
  }

  if(show_debug){
    // Visual seam keep-out suggestion on rim land
    color([1,0,0,0.25]) translate([0,0,rim_land_t])
      linear_extrude(height=0.4) ring(r_outer-0.6, r_outer- rim_land_w + 0.6);
  }
}

// Variable-width Lissajous ribbon (pure 2D). Returns filled area to extrude.
// Variable-width Lissajous ribbon (pure 2D). Returns filled area to extrude.
module lissa_ribbon2d(r_start, r_end, r_half_hub, r_half_rim, amp_deg){
  steps = 120; // smoother path
  // Centerline via list-comprehension (valid OpenSCAD).
  pts = [ for(i=[0:steps])
            let(t = i/steps,
                r = r_start + (r_end - r_start)*t,
                theta = 2*PI*t + rad(amp_deg)*sin(4*PI*t))
            [ r*cos(theta), r*sin(theta) ] ];
  // Variable width stroke by hulling consecutive discs with lerped radii.
  for(i=[0:len(pts)-2]){
    t  = i/(len(pts)-1);
    t2 = (i+1)/(len(pts)-1);
    rA = r_half_hub + (r_half_rim - r_half_hub)*t;
    rB = r_half_hub + (r_half_rim - r_half_hub)*t2;
    hull(){
      translate(pts[i])   circle(rA);
      translate(pts[i+1]) circle(rB);
    }
  }
}

// --------------------------------------
//          FLANGE — Hepta‑chord truss (geometric)
// --------------------------------------
module flange_heptachord(show_debug=false){
  // ---- Radii and bands ----
  r_outer = spool_od/2;                 // flange OD/2
  r_inner = r_outer - rim_land_w;       // inner edge of rim land (roller track)
  r_hub_i = hub_id/2;                   // hub bore radius
  r_hub_o = r_hub_i + 6;                // hub boss ring outer radius (6 mm wide boss)

  // ---- Heptagon + truss parameters (explicit) ----
  hepta_r_ratio   = 0.62;   // location of heptagon ring (fraction of OD/2)
  hepta_ring_w    = 6.0;    // width of the heptagon structural ring
  chord_w_outer_h = 5.0;    // spoke width at heptagon (to rim)
  chord_w_outer_r = 4.0;    // spoke width at rim end
  chord_w_inner_h = 5.0;    // spoke width at heptagon (to hub)
  chord_w_inner_c = 4.0;    // spoke width at hub end
  chord_diag_w    = 3.6;    // width of skip-1 chords

  tie_r = tie_ring_r_ratio * r_outer;   // tie ring radius (~70% of OD/2)
  tie_w = tie_ring_w;                   // tie ring width

  hepta_r   = hepta_r_ratio * r_outer;  // heptagon center radius
  hepta_rot = 180/7; // degrees                     // rotate heptagon for aesthetics

  // ---- Exact heptagon points (flat-sided) ----
  hepta_pts   = regular_ngon_points(7, hepta_r,                      rot=hepta_rot);
  outer_hepta = regular_ngon_points(7, hepta_r + hepta_ring_w/2,     rot=hepta_rot);
  inner_hepta = regular_ngon_points(7, hepta_r - hepta_ring_w/2,     rot=hepta_rot);

  // Targets on rim and hub; add small overlaps so parts fuse
  rim_overlap = 0.8;  hub_overlap = 0.6;
  hepta_to_rim = [ for(p=hepta_pts) let(s=(r_inner + rim_overlap)/hepta_r) [p[0]*s, p[1]*s] ];
  hepta_to_hub = [ for(p=hepta_pts) let(s=(r_hub_o - hub_overlap)/hepta_r) [p[0]*s, p[1]*s] ];

  // ---- Build a single 2D web EXPLICITLY (no base annulus) ----
// We only add material for ring + spokes + chords so big windows stay open.
module heptachord_web_2d(){
  union(){
    // Heptagon structural ring
    difference(){ polygon(outer_hepta); polygon(inner_hepta); }

    // Tie ring (circular)
    ring(tie_r + tie_w/2, tie_r - tie_w/2);

    // Hub boss ring
    ring(r_hub_o, r_hub_i);

    // Radial spokes outward & inward
    for(i=[0:6]) taper_capsule2d(hepta_pts[i], hepta_to_rim[i], chord_w_outer_h, chord_w_outer_r);
    for(i=[0:6]) taper_capsule2d(hepta_pts[i], hepta_to_hub[i], chord_w_inner_h, chord_w_inner_c);

    // ----- CHORD STYLE SWITCHER -----
    style = heptachord_chord_style;
    if (style == "straight") {
      // skip-1 straight chords (v0.1)
      for(i=[0:6]) capsule2d(hepta_pts[i], hepta_pts[(i+2)%7], chord_diag_w);
    } else if (style == "vertex-mid") {
      // vertex to midpoint of next-but-one edge
      for(i=[0:6]){
        j = (i+2)%7;
        m = [(hepta_pts[j][0]+hepta_pts[(j+1)%7][0])/2,
             (hepta_pts[j][1]+hepta_pts[(j+1)%7][1])/2];
        capsule2d(hepta_pts[i], m, chord_diag_w);
      }
    } else if (style == "arc") {
      // curved chords as circular arcs along tie_r (no center crossing)
      for(i=[0:6]){
        a1 = atan2(hepta_pts[i][1], hepta_pts[i][0]);
        a2 = atan2(hepta_pts[(i+2)%7][1], hepta_pts[(i+2)%7][0]);
        arc_capsule2d(tie_r - 0.2, a1, a2, chord_diag_w);
      }
    } else if (style == "half") {
      // curved chords as circular arcs along tie_r (no center crossing)
      // add one-time inner ring in the union:
      ring(r_hub_i + 2.2, r_hub_i + 0.8);  // ~1.4 mm wide inner hoop

      // chords from alternating vertices only
      for (i=[0:6]) if (i%2==0)
        capsule2d(hepta_pts[i], hepta_pts[(i+2)%7], chord_diag_w);

    } else if (style == "dual") {
        inner2_r = hepta_r - 7;  // second ring ~7 mm inboard
        outer2 = regular_ngon_points(7, inner2_r + 2.5/2, rot=hepta_rot);
        inner2 = regular_ngon_points(7, inner2_r - 2.5/2, rot=hepta_rot);
        difference(){ polygon(outer2); polygon(inner2); }           // add second ring

        // rungs between rings at each vertex
        for (i=[0:6]) capsule2d(
          [(hepta_pts[i][0]), (hepta_pts[i][1])],
          [hepta_pts[i][0]*inner2_r/hepta_r, hepta_pts[i][1]*inner2_r/hepta_r],
          3.2
        );


    }
  }
}

  // ---- 3D: stack rim land (thicker) and web (flange thickness) ----
  difference(){
    union(){
      linear_extrude(height=rim_land_t) ring(r_outer, r_inner);      // roller band
      linear_extrude(height=flange_t) heptachord_web_2d();           // explicit web
    }
    translate([0,0,-0.1]) cylinder(h=flange_t+rim_land_t+0.2, r=r_hub_i, $fn=96); // bore
  }

  if(show_debug){
    color([1,0,0,0.25]) translate([0,0,rim_land_t])
      linear_extrude(height=0.4) ring(r_outer-0.6, r_outer- rim_land_w + 0.6);
  }
}

// --- SIMPLE STEP-BY-STEP DEBUG RENDERERS ---
// These stages are color‑coded and Z‑offset so you can SEE each layer clearly.
// They use local parameters so nothing is undefined.

module step1_rim_only(){
  color([0.82,0.72,0.12])
    linear_extrude(height=rim_land_t) ring(spool_od/2, spool_od/2 - rim_land_w);
}

module step2_heptagon_only(){
  // Bold, lifted heptagon ring + vertex markers so it cannot hide (DEGREE trig)
  h_rw    = 12.0;                // ring width (mm)
  h_ratio = 0.62;                // center radius as fraction of OD/2
  h_rot   = 180/7;               // degrees
  rmid = h_ratio*(spool_od/2);
  echo("heptagon mid radius:", rmid, " ring w:", h_rw);
  translate([0,0,10]){
    color([0.1,0.45,0.95])
      linear_extrude(height=flange_t)
        difference(){
          polygon(regular_ngon_points(7, rmid + h_rw/2, rot_deg=h_rot));
          polygon(regular_ngon_points(7, rmid - h_rw/2, rot_deg=h_rot));
        }
    pts = regular_ngon_points(7, rmid, rot_deg=h_rot);
    for(p = pts)
      translate([p[0], p[1], flange_t/2]) color([0.95,0.2,0.2]) sphere(r=1.6, $fn=48);
    color([0.2,0.2,0.2]) translate([-1.5,-1.5,0]) cube([3,3,0.8]);
  }
}

module step3_add_spokes_only(){
  // Outward spokes only, lifted again
  h_ratio = 0.62; rmid = h_ratio*(spool_od/2);
  pts = regular_ngon_points(7, rmid, rot=180/7);
  rim_r = (spool_od/2 - rim_land_w) + 0.8;
  translate([0,0,2*flange_t + 2])
    color([0.12,0.7,0.3])
      for(i=[0:6])
        linear_extrude(height=flange_t)
          taper_capsule2d(pts[i], [pts[i][0]*rim_r/rmid, pts[i][1]*rim_r/rmid], 6.0, 4.0);
}

module step4_add_inner_spokes_only(){
  // Inward spokes only
  h_ratio = 0.62; rmid = h_ratio*(spool_od/2);
  pts = regular_ngon_points(7, rmid, rot=180/7);
  hub_o = hub_id/2 + 6;
  translate([0,0,3*flange_t + 3])
    color([0.9,0.35,0.1])
      for(i=[0:6])
        linear_extrude(height=flange_t)
          taper_capsule2d(pts[i], [pts[i][0]*hub_o/rmid, pts[i][1]*hub_o/rmid], 6.0, 4.0);
}

module step5_add_chords_only(){
  // Skip‑1 heptagon chords
  h_ratio = 0.62; rmid = h_ratio*(spool_od/2);
  pts = regular_ngon_points(7, rmid, rot=180/7);
  translate([0,0,4*flange_t + 4])
    color([0.6,0.2,0.8])
      for(i=[0:6])
        linear_extrude(height=flange_t)
          capsule2d(pts[i], pts[(i+2)%7], 4.0);
}

module debug_stack_all(){
  // Puts all layers in a visible stack for sanity
  step1_rim_only();
  step2_heptagon_only();
  step3_add_spokes_only();
  step4_add_inner_spokes_only();
  step5_add_chords_only();
}

// --------------------------------------
//          CORE — desiccant wave
// --------------------------------------
module core_wave_desiccant(){
  r_wrap    = wrap_diam/2;
  r_hub     = hub_id/2 + 2.5;
  len       = core_len;

  wave_count = max(6, floor( (2*PI*r_wrap)/core_wave_pitch ));

  module wavy_ring_2d(r_base, amp){
    pts=[];
    N = 360;
    for(i=[0:N]){
      ang = i/N * 2*PI;
      r = r_base + amp*sin(wave_count*ang);
      pts = concat(pts, [ [r*cos(ang), r*sin(ang)] ]);
    }
    polygon(pts);
  }

  difference(){
    linear_extrude(height=len)
      difference(){
        offset(r=0) wavy_ring_2d(r_wrap, core_wave_amp);
        circle(r_wrap - core_wall_t);
      }
    for(j=[0:wave_count-1]){
      ang = j*(360/wave_count);
      rotate([0,0,ang])
        translate([r_wrap, 0, len*0.15])
          cube([vent_slot_w, 6, len*0.70], center=true);
    }
  }

  cylinder(h=len, r=r_hub);

  for(k=[0:rib_count-1]){
    ang = k*360/rib_count;
    rotate([0,0,ang])
      translate([r_hub, -1.5, 0])
        cube([ (r_wrap - core_wall_t) - r_hub , 3.0, len ]);
  }

  starter_bore();
  bead_pocket_face();
}

module starter_bore(){
  r = wrap_diam/2 - 2;
  zpos = core_len*0.25;
  translate([r,0,zpos])
    rotate([0, starter_bore_angle, 90])
      cylinder(h=wrap_diam, r=starter_bore_d/2, center=true);
}

module bead_pocket_face(){
  translate([0,0, core_len-0.01]){
    difference(){
      cylinder(h=pocket_depth, r=pocket_d/2 + 0.01);
    }
    lug_r = pocket_d/2 + o_ring_clearance;
    for(n=[0:2]){
      ang = n*120;
      rotate([0,0,ang])
        translate([lug_r, -bayonet_lug_w/2, pocket_depth-1.2])
          cube([bayonet_lug_len, bayonet_lug_w, 1.2]);
    }
  }
}

module pocket_cap(){
  cap_r = pocket_d/2 + 1.0;
  cap_t = 2.0;
  union(){
    cylinder(h=cap_t, r=cap_r);
    cylinder(h=cap_t+1.2, r=pocket_d/2 - 0.3);
    for(n=[0:2]){
      ang=n*120;
      rotate([0,0,ang])
        translate([pocket_d/2 - 0.4, -bayonet_lug_w/2, cap_t-0.6])
          cube([bayonet_lug_len, bayonet_lug_w, 0.6]);
    }
    translate([0,0,cap_t]) cylinder(h=cap_protrusion, r=10);
  }
}

// --------------------------------------
//           COUPONS
// --------------------------------------
module coupon_vent_slice(){
  arc_deg = 40;
  save_fn = $fn;
  $fn = 64;
  difference(){
    rotate_extrude(angle=arc_deg)
      translate([wrap_diam/2,0,0])
        square([core_wall_t*2, 30], center=true);
    slot_count = ceil(arc_deg / (360/max(6, floor((2*PI*(wrap_diam/2))/core_wave_pitch))));
    for(i=[0:slot_count-1]){
      rot = i*(arc_deg/slot_count) - arc_deg/2 + (arc_deg/slot_count)/2;
      rotate([0,0,rot])
        translate([wrap_diam/2,0,0])
          cube([vent_slot_w, 32, 35], center=true);
    }
  }
  $fn = save_fn;
}

module coupon_pocket_quarter(){
  linear_extrude(height=flange_t+2)
    intersection(){
      circle(wrap_diam/2 + 12);
      square([wrap_diam/2+12, wrap_diam/2+12]);
    }
  translate([0,0,flange_t+2]) pocket_cap();
}

module coupon_starter_bore(){
  rot_span = 60;
  difference(){
    rotate([0,0,-rot_span/2])
      linear_extrude(height=core_len*0.4)
        intersection(){
          circle(wrap_diam/2 + 6);
          square([wrap_diam/2+6, wrap_diam/2+6]);
        }
    starter_bore();
  }
}

// --------------------------------------
//          ASSEMBLY PREVIEW
// --------------------------------------
module assembly_preview(){
  color([0.15,0.15,0.18,0.75]) translate([0,0,0]) flange_lissajous();
  color([0.95,0.95,0.98,0.7]) translate([0,0,flange_t]) core_wave_desiccant();
  color([0.15,0.15,0.18,0.75]) translate([0,0,flange_t+core_len]) mirror([0,0,1]) flange_lissajous();
}

// Export guide: uncomment ONE of these and F6, then STL export
// --- Debug quick picks (one at a time) ---
// debug_stack_all();
// step1_rim_only();
// step2_heptagon_only();
// step3_add_spokes_only();
// step4_add_inner_spokes_only();
// step5_add_chords_only();

// --- Final options ---
 flange_heptachord();
// flange_lissajous();
// core_wave_desiccant();
// pocket_cap();
// coupon_vent_slice();
// coupon_pocket_quarter();
// coupon_starter_bore();
