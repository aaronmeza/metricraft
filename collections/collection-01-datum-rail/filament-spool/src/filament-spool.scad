// metricraft-spool v1.0.3 (build006) — Heptachord + Dog‑Leg Core + Quarter‑Turn Cams
// Bambu P1S + AMS — parametric reusable spool
// Flange: A) heptachord (vertex‑mid)  ·  B) dragoncrest (geometric dragon)
// Core: dogleg hub‑wall (desiccant chamber = 55 mm ID)
// New in build006: quarter‑turn bayonet cams (flange↔core + cover↔flange), cam test coupons.
//
// Units: millimeters. OpenSCAD trig = DEGREES.  $fn tuned for visual smoothness.


// filament-spool.scad style and part selector (integrate this with other paths)
// styles: heptachord | dragoncrest
style = is_undef(style) ? "heptachord" : style;   // CLI: -D style="dragoncrest"
which = is_undef(which) ? "flange" : which;       // CLI: -D which="core"

use <style-map.scad>;

module spool_part(which, style) {
  if (which == "flange") flange(style);
  else if (which == "core") core(style);
  else if (which == "cover") cover(style);
  else if (which == "cam_flange2core") cam_flange2core(style);
  else if (which == "cam_cover2flange") cam_cover2flange(style);
  else assert(false, str("unknown part: ", which));
}

spool_part(which, style);

///////////////////////////////////////////////////////


// --------------------------------------
//               TOKENS
// --------------------------------------
spool_od          = 198.5;     // AMS-safe OD
spool_width       = 65;        // assembled width (flange + core + flange)
hub_id            = 55;        // DESICCANT CHAMBER ID in dogleg mode (also flange bore)
flange_t          = 2.4;       // flange web thickness
rim_land_w        = 15.0;       // roller track width (solid)
rim_land_t        = 2.6;       // roller track thickness
 tie_ring_r_ratio  = 0.70;      // tie ring radial ratio (fraction of r_outer)
 tie_ring_w        = 3.0;       // tie ring width
hub_boss_w        = 6.0;       // flange hub boss ring radial width (r_hub_o = r_hub_i + hub_boss_w)

// Flange selector
// dragoncrest not designed yet
flange_style      = "heptachord";   // "heptachord" | "dragoncrest"

// Core selector (single core for this collection)
core_style        = "dogleg";       // fixed for this collection

// Core — shared
core_len          = spool_width - 2*flange_t;  // axial length between flanges

// Core — DOGLEG hub wall
vessel_wall_t     = 2.0;       // constant hub‑wall thickness (target ~2.4)
baffle_count      = 3;         // number of dog‑legs (3 chosen for airflow)
baffle_rot_deg    = 180/baffle_count;     // aesthetic rotation so facets align
baffle_dogleg_sweep_deg = 17;  // tangential sweep at inner end ("hook" angle)
baffle_tip_gap    = 15.0;      // how far finger tips stop short of chamber center (mm)
inner_r           = hub_id/2 + vessel_wall_t;   // inner keep radius (wall stays outside this)
outer_r           = 62;        // OUTER bound where the wall lives (size to taste)
// Dog‑leg VOID geometry controls (length‑driven)
dogleg_slot_w         = 4.0;   // VOID width (air path)
dog_start_overrun_mm  = 10;    // slot begins this far OUTSIDE the wall (guaranteed through‑cut)
dog_outer_run_mm      = 21;    // straight run from start toward the elbow
dog_inner_run_mm      = 7;    // straight run from elbow toward the tip
dog_elbow_bias_mm     = 2;     // + moves elbow toward tip (steals from outer, adds to inner)

// Perforation controls
perforation_mode      = "holes";  // "holes" | "helix" | "none"
// -- round radial drills (3D subtract after extrusion)
hole_d                = 1.3;   // hole diameter (mm)
hole_arc_pitch_deg    = 14;    // angular spacing between holes (deg)
hole_rows             = 10;     // number of Z rows
hole_row_dz           = 6.0;   // vertical spacing between rows (mm)
hole_row_stagger_deg  = 0.5*hole_arc_pitch_deg; // alternate row phase
hole_overrun_mm       = 1;   // how much each drill overshoots wall thickness
hole_radial_bias      = 0.3;     // + pushes hole center outward, − inward (mm)

// -- helical lattice (optional)
helix_count           = 3;     // number of helical cuts around
helix_w               = 1.6;   // width of each helical cut (mm)
helix_turns           = 1.3;   // total twists across usable height (rev)
helix_z_margin        = 0.8;   // extra vertical keep‑clear beyond cam margins

// Keep‑clear for cams
cam_z_margin          = 3.2;   // at both top and bottom of core wall

// ---------- Quarter‑turn cam tunables ----------
// (A) Flange ↔ Core
enable_core_cam       = true;  // set false to disable bayonet between flange & core
cam_count             = 3;     // cams equally spaced (3 recommended)
cam_slot_len_deg      = 75;    // rotation travel inside flange (deg) – < 90
cam_entry_gap_deg     = 16;    // entry mouth width at the bore (deg)
cam_band_w            = 2.9;   // radial slot width in flange (mm)
cam_clear_radial      = 0.25;  // radial clearance (each side) between lug & slot (mm)
cam_clear_axial       = 0.25;  // axial (Z) clearance (mm)
cam_lug_axial_t       = min(1.8, flange_t - 0.4); // lug height (must fit under flange roof)
cam_stop_land_deg     = 3;     // uncut land at end of slot (rotation stop)
cam_lead_chamfer_mm   = 0.4;   // tiny edge break on lug leading edge
cam_slot_inset        = 0.35;  // keep slot a hair away from boss edges

// (B) Cover ↔ Flange (optional small cam around the bore)
enable_cover_cam      = true; // set true to cut cover slots in flange & generate cover
cov_cam_count         = 3;
cov_cam_band_w        = 2.6;
cov_cam_slot_len_deg  = 70;
cov_cam_entry_gap_deg = 20;
cov_cam_axial_t       = 1.8;
cov_cam_clear         = 0.25;
cover_diam            = 64;    // separate cover OD
cover_thick           = 2.2;   // cover plate thickness
cover_lip_h           = 0.8;   // small sealing lip height
cover_lip_r_add       = 0.6;   // lip overhang beyond bore

// Access features (shared)
starter_bore_d    = 2.8;
starter_bore_angle= 15;
pocket_d          = 24;
pocket_depth      = 14;
cap_protrusion    = 1.0;
bayonet_lug_w     = 3.0;
bayonet_lug_len   = 6.5;
o_ring_clearance  = 0.25;

// Quality
$fn = 128;

// --------------------------------------
//               UTILS
// --------------------------------------
function rad(a)=a*PI/180;
function polar(r,a)=[r*cos(a), r*sin(a)];
module ring(ro,ri){ difference(){ circle(ro); circle(ri); } }

function vsub(a,b)=[a[0]-b[0],a[1]-b[1]];
function vlen(v)=sqrt(v[0]*v[0]+v[1]*v[1]);
function vunit(v)=let(l=vlen(v)) (l==0?[0,0]:[v[0]/l,v[1]/l]);
function vperp(u)=[-u[1],u[0]];

module capsule2d(p1,p2,w){
  u=vunit(vsub(p2,p1)); n=vperp(u);
  A=[p1[0]+n[0]*w/2,p1[1]+n[1]*w/2];
  B=[p2[0]+n[0]*w/2,p2[1]+n[1]*w/2];
  C=[p2[0]-n[0]*w/2,p2[1]-n[1]*w/2];
  D=[p1[0]-n[0]*w/2,p1[1]-n[1]*w/2];
  union(){ polygon([A,B,C,D]); translate(p1) circle(w/2); translate(p2) circle(w/2); }
}

// Arc capsule along circle radius rr from angle a1→a2 (degrees), width w
module arc_capsule2d(rr, a1, a2, w){
  steps = max(10, floor(abs(a2-a1)/3));
  for (k=[0:steps-1]){
    a = a1 + (a2-a1)*k/steps;
    b = a1 + (a2-a1)*(k+1)/steps;
    hull(){
      translate([rr*cos(a), rr*sin(a)]) circle(w/2);
      translate([rr*cos(b), rr*sin(b)]) circle(w/2);
    }
  }
}

// Tapered capsule between two points (w1 at p1 → w2 at p2)
module taper_capsule2d(p1,p2,w1,w2){
  u=vunit(vsub(p2,p1)); n=vperp(u);
  A=[p1[0]+n[0]*w1/2,p1[1]+n[1]*w1/2];
  B=[p2[0]+n[0]*w2/2,p2[1]+n[1]*w2/2];
  C=[p2[0]-n[0]*w2/2,p2[1]-n[1]*w2/2];
  D=[p1[0]-n[0]*w1/2,p1[1]-n[1]*w1/2];
  union(){ polygon([A,B,C,D]); translate(p1) circle(w1/2); translate(p2) circle(w2/2); }
}

function regular_ngon_points(n,r,rot_deg=0)=[
  for(i=[0:n-1]) let(a=rot_deg+360*i/n) [r*cos(a),r*sin(a)]
];

// --------------------------------------
//       FLANGE — Heptachord (vertex‑mid)
// --------------------------------------
module flange_heptachord(show_debug=false){
  r_outer=spool_od/2;
  r_inner=r_outer-rim_land_w;
  r_hub_i=hub_id/2;
  r_hub_o=r_hub_i+hub_boss_w;

  hepta_r_ratio=0.62;    // location of heptagon ring (fraction of OD/2)
  hepta_ring_w=14.0;      // width of the heptagon structural ring
  chord_w_outer_h=5.0;   // spoke width at heptagon (to rim)
  chord_w_outer_r=15.0;   // spoke width at rim end
  chord_w_inner_h=5.0;   // spoke width at heptagon (to hub)
  chord_w_inner_c=5.0;   // spoke width at hub end
  chord_diag_w=3.6;      // width of chords

  tie_r=tie_ring_r_ratio*r_outer;
  tie_w=tie_ring_w;
  hepta_r=hepta_r_ratio*r_outer;
  hepta_rot=180/7;

  hepta_pts   = regular_ngon_points(7, hepta_r,                rot_deg=hepta_rot);
  outer_hepta = regular_ngon_points(7, hepta_r+hepta_ring_w/2, rot_deg=hepta_rot);
  inner_hepta = regular_ngon_points(7, hepta_r-hepta_ring_w/2, rot_deg=hepta_rot);

  rim_overlap=0.8; hub_overlap=0.6;
  hepta_to_rim=[for(p=hepta_pts) let(s=(r_inner+rim_overlap)/hepta_r) [p[0]*s,p[1]*s]];
  hepta_to_hub=[for(p=hepta_pts) let(s=(r_hub_o-hub_overlap)/hepta_r)[p[0]*s,p[1]*s]];

  module heptachord_web_2d(){
    union(){
      // Heptagon ring
      difference(){ polygon(outer_hepta); polygon(inner_hepta); }
      // Tie and hub rings
      ring(tie_r+tie_w/2,tie_r-tie_w/2);
      ring(r_hub_o,r_hub_i);
      // Radial spokes
      for(i=[0:6]) taper_capsule2d(hepta_pts[i], hepta_to_rim[i], chord_w_outer_h, chord_w_outer_r);
      for(i=[0:6]) taper_capsule2d(hepta_pts[i], hepta_to_hub[i], chord_w_inner_h, chord_w_inner_c);
      // Vertex‑mid chords (only)
      for(i=[0:6]){ j=(i+2)%7;
        m=[(hepta_pts[j][0]+hepta_pts[(j+1)%7][0])/2,(hepta_pts[j][1]+hepta_pts[(j+1)%7][1])/2];
        capsule2d(hepta_pts[i], m, chord_diag_w);
      }
    }
  }

  difference(){
    union(){
      linear_extrude(height=rim_land_t) ring(r_outer,r_inner);
      linear_extrude(height=flange_t)   heptachord_web_2d();
    }
    // Quarter‑turn cam slots for core lugs
    if (enable_core_cam)
      flange_cam_slots_3d(r_hub_i + cam_slot_inset, r_hub_o - cam_slot_inset);
    // Optional cover slots around the bore
    if (enable_cover_cam)
      flange_cover_cam_slots_3d(r_hub_i + 0.35, r_hub_i + 0.35 + 4.2);
    // Bore
    translate([0,0,-0.1]) cylinder(h=flange_t+rim_land_t+0.2, r=r_hub_i, $fn=128);
  }

  if(show_debug) color([1,0,0,0.25]) translate([0,0,rim_land_t])
    linear_extrude(height=0.4) ring(r_outer-0.6, r_outer-rim_land_w+0.6);
}

// --------------------------------------
//     FLANGE — Dragoncrest (geometric dragon)
// --------------------------------------
// Low‑poly dragon “wireframe” bars arranged in balanced pairs.
// The bars are POSITIVE material (wall path), not voids.
module flange_dragoncrest(show_debug=false){
  r_outer=spool_od/2;
  r_inner=r_outer-rim_land_w;
  r_hub_i=hub_id/2;
  r_hub_o=r_hub_i+hub_boss_w;
  tie_r=tie_ring_r_ratio*r_outer;
  tie_w=tie_ring_w;

  web_w = 3.2;       // bar width of wireframe

  // --- helpers to draw polylines as constant‑width bars
  module wire_segments_2d(segments,w){
    for (s=segments) capsule2d(s[0], s[1], w);
  }
  function segments_from_points(pts, closed=false) =
    closed ? [for(i=[0:len(pts)-1]) [pts[i], pts[(i+1)%len(pts)]]] : [for(i=[0:len(pts)-2]) [pts[i], pts[i+1]]];

  // --- stylized low‑poly dragon made from a few polylines (head, spine, tail, jaw, horn)
  function dragon_polylines() = [
    // head/jaw
    [[-0.35,0.10],[-0.18,0.12],[ -0.02,0.09],[0.10,0.05],[0.18,0.00],[0.12,-0.04],[0.00,-0.02],[-0.10,0.02],[-0.22,0.06]],
    [[0.12,-0.04],[0.18,-0.10],[0.24,-0.17],[0.28,-0.24],[0.20,-0.26],[0.14,-0.20],[0.10,-0.12]],
    // eye ridge
    [[-0.10,0.06],[0.00,0.10],[0.08,0.08]],
    // neck + spine triangles
    [[-0.18,0.12],[-0.22,0.00],[-0.12,-0.18],[0.02,-0.32],[0.16,-0.40],[0.30,-0.46]],
    // back spikes
    [[-0.12,-0.18],[-0.06,-0.08],[0.02,-0.20]],
    [[0.02,-0.32],[0.10,-0.22],[0.18,-0.34]],
    // tail coil
    [[0.30,-0.46],[0.22,-0.60],[0.08,-0.70],[-0.06,-0.72],[-0.16,-0.66],[-0.22,-0.54],[-0.16,-0.46],[-0.04,-0.42],[0.08,-0.46]],
    // fore‑leg suggestion
    [[-0.06,-0.40],[-0.14,-0.48],[-0.18,-0.58]]
  ];

  module dragon_wire_2d(){
    // Place motif in the structural annulus, not at origin
    r_hub_o = hub_id/2 + hub_boss_w;
    r_center = (r_hub_o + r_inner)/2;                // radial center of usable band
    band_span = (r_inner - r_hub_o);                 // thickness of the annulus
    motif_scale = 0.85*band_span;                    // scale unit motif to band

    union(){
      for(rep=[0:1])
        rotate(rep*180)
          translate([r_center,0])
            scale([motif_scale,motif_scale,1])
              for(poly = dragon_polylines())
                wire_segments_2d(segments_from_points([for(p=poly) [p[0],p[1]]]), web_w);
    }
  }

  module dragon_web_2d(){
    union(){
      // Core rings for structure
      ring(hub_id/2+hub_boss_w,hub_id/2);
      ring(tie_r+tie_w/2, tie_r-tie_w/2);
      // Wireframe dragon bars (clipped to usable annulus)
      intersection(){
        dragon_wire_2d();
        // keep only between hub boss and inner rim land
        difference(){ circle(r_inner-0.6); circle(hub_id/2+hub_boss_w+0.6); }
      }
    }
  }

  difference(){
    union(){
      linear_extrude(height=rim_land_t) ring(r_outer,r_inner); // roller band (solid)
      linear_extrude(height=flange_t)   dragon_web_2d();       // web with wall bars
    }
    if (enable_core_cam)
      flange_cam_slots_3d(hub_id/2 + cam_slot_inset, hub_id/2 + hub_boss_w - cam_slot_inset);
    if (enable_cover_cam)
      flange_cover_cam_slots_3d(hub_id/2 + 0.35, hub_id/2 + 0.35 + 4.2);
    translate([0,0,-0.1]) cylinder(h=flange_t+rim_land_t+0.2, r=hub_id/2, $fn=96);
  }

  if(show_debug) color([1,0,0,0.25]) translate([0,0,rim_land_t])
    linear_extrude(height=0.4) ring(r_outer-0.6, r_outer-rim_land_w+0.6);
}

// --------------------------------------
//          CORE — DOGLEG HUB WALL
// --------------------------------------
desiccant_r = hub_id/2;   // 55 mm chamber ID

// Helper: thin annulus
module _annulus(ro, ri){ difference(){ circle(ro); circle(ri); } }

// Full annulus (constant thickness) as its own 2D module
module hub_annulus_2d(){
  r_in  = desiccant_r;
  r_out = desiccant_r + vessel_wall_t;
  _annulus(r_out, r_in);
}

// 2D union of VOID shapes (two capsules + rounded elbow per baffle)
// Explicit, length-based control + elbow bias. Slots can extend beyond the wall.
module dogleg_voids_2d(n=baffle_count){
  r_in  = desiccant_r;
  // apply elbow bias (can be negative)
  outer_run = max(0, dog_outer_run_mm - dog_elbow_bias_mm);
  inner_run = max(0, dog_inner_run_mm + dog_elbow_bias_mm);

  wv = dogleg_slot_w; // slot width = exactly what you set

  union(){
    for(i=[0:n-1]){
      ang = baffle_rot_deg + i*360/n;              // degrees

      // centerline radii
      r_start = desiccant_r + vessel_wall_t + dog_start_overrun_mm; // starts outside the wall
      r_elbow = r_start - outer_run;               // after outer straight
      r_tip_t = r_elbow - inner_run;               // naive tip radius
      r_tip   = max(r_in - baffle_tip_gap, r_tip_t); // clamp to maintain center clearance

      // points
      p_out   = [ r_start*cos(ang),                      r_start*sin(ang) ];
      p_elbow = [ r_elbow*cos(ang),                      r_elbow*sin(ang) ];
      p_tip   = [ r_tip*cos(ang + baffle_dogleg_sweep_deg),
                  r_tip*sin(ang + baffle_dogleg_sweep_deg) ];

      // VOID geometry (two capsules + rounded elbow)
      capsule2d(p_out,  p_elbow, wv);
      capsule2d(p_elbow,p_tip,   wv);
      translate(p_elbow) circle(wv/2);
    }
  }
}

// ---------- B) Constant-width wall around those voids ----------
module wall_around_voids_raw(){
  // morphological “tube”: (voids ⊕ wall/2) ⊖ (voids ⊖ wall/2)
  difference(){
    offset(delta= +vessel_wall_t/2-.5) dogleg_voids_2d();
    offset(delta= -vessel_wall_t/2) dogleg_voids_2d();
  }
}

module wall_around_voids_clipped(){
  // keep within a thin band just outside the chamber edge
  inner_clip = inner_r - vessel_wall_t*10;      // breathing room
  outer_clip = inner_r - 1;                     // near the inner rim of base annulus
  intersection(){
    wall_around_voids_raw();
    difference(){ circle(outer_clip); circle(inner_clip); }
  }
}

// 2D: final hub-wall path = annulus + wrap band (for previews only)
module hub_wall_path_2d(){
  union(){ hub_annulus_2d(); wall_around_voids_clipped(); }
}



// 1) Generic drill field at a given mid-radius (reuses hole_* tunables)
module _radial_drills_at_radius(r_mid = desiccant_r + vessel_wall_t/2 + hole_radial_bias,orientation=0){
  cnt = max(5, floor(360 / hole_arc_pitch_deg));
  len = vessel_wall_t + 2*hole_overrun_mm;   // across wall thickness + a little overrun
  for (row = [0:hole_rows-1]){
    z = cam_z_margin + (row+1)*hole_row_dz;
    if (z < core_len - cam_z_margin){
      phase = (row % 2 == 1) ? hole_row_stagger_deg : 0;
      for (i = [0:cnt-1]){
        ang = phase + i*360/cnt;
        rotate([0,0,ang])
          translate([r_mid,0,z])
            rotate([orientation,90,0])
              cylinder(h=len, r=hole_d/2, center=true, $fn=16);
      }
    }
  }
}

// ---- 3D perforators ----
// Round radial drills (preferred) — applied to BOTH annulus and dog‑leg band
module perforation_radial_drills(r_mid = desiccant_r + vessel_wall_t/2 + hole_radial_bias,orientation=0){
  //r_mid = desiccant_r + vessel_wall_t/2 + hole_radial_bias;
  cnt   = max(3, floor(360 / hole_arc_pitch_deg));
  len   = vessel_wall_t + 2*hole_overrun_mm;   // across wall thickness plus overrun
  // rows stacked in Z, staggered in angle for strength
  for(row=[0:hole_rows-1]){
    z = cam_z_margin + (row+1)*hole_row_dz;
    if (z < core_len - cam_z_margin){
      phase = (row % 2 == 1) ? hole_row_stagger_deg : 0;
      for(i=[0:cnt-1]){
        ang = phase + i*360/cnt;
        rotate([0,0,ang])
          translate([r_mid*2,0,z])
            rotate([orientation,90,0])
              cylinder(h=len, r=hole_d/2, center=true, $fn=28);
      }
    }
  }
}


// 2) Same drill field, at both the annulus mid-thickness AND the dog-leg band
module perforation_radial_drills_both(){
  // Annulus (mid of the constant-thickness wall)
  _radial_drills_at_radius(desiccant_r + vessel_wall_t/2 + hole_radial_bias,0);

  // Perforations before elbow of dogleg
  //_torus_at_radius(desiccant_r - 5);
  
    // Perorations past elbow of dogleg
  //_torus_drills_at_radius(desiccant_r - 10);
  _radial_drills_at_radius(desiccant_r - 13 + hole_radial_bias,90+baffle_dogleg_sweep_deg);
}

// Helical lattice (optional)
module perforation_helix(){
  usable_h = max(0.1, core_len - 2*cam_z_margin - 2*helix_z_margin);
  r_mid = desiccant_r + vessel_wall_t/2;
  translate([0,0,cam_z_margin+helix_z_margin])
    for(i=[0:helix_count-1]){
      ang0 = i*360/helix_count;
      rotate([0,0,ang0])
        translate([r_mid,0,0])
          linear_extrude(height=usable_h, twist=helix_turns*360, slices=round(usable_h*3))
            square([helix_w, vessel_wall_t + 1.2], center=true);
    }
}

// ---------- Quarter‑turn cams (geometry) ----------
// Flange cam slots (subtract)
module _flange_cam_ring_2d(r_in, r_out){
  r_mid = (r_in + r_out)/2;
  for (i=[0:cam_count-1]){
    base_ang = i*360/cam_count;
    // entry mouth (radial keyhole)
    entry_a1 = base_ang - cam_entry_gap_deg/2;
    entry_a2 = base_ang + cam_entry_gap_deg/2;
    mouth_w  = max(1.6, cam_band_w - 0.6);
    p_bore = [r_in*cos(base_ang), r_in*sin(base_ang)];
    p_band = [r_mid*cos(base_ang), r_mid*sin(base_ang)];
    capsule2d(p_bore, p_band, mouth_w);
    // travel arc
    arc_a1 = base_ang + 2;
    arc_a2 = base_ang + cam_slot_len_deg - cam_stop_land_deg;
    arc_capsule2d(r_mid, arc_a1, arc_a2, cam_band_w);
  }
}
module flange_cam_slots_3d(r_in, r_out){
  linear_extrude(height=flange_t + 0.3)
    _flange_cam_ring_2d(r_in, r_out);
}

// Core lugs (union)
module _core_cam_lug_arc_2d(r_mid, a_center, lug_len_deg, w){
  a1 = a_center - lug_len_deg/2;
  a2 = a_center + lug_len_deg/2;
  arc_capsule2d(r_mid, a1, a2, w);
}
module core_cam_lugs_3d(z0, zt){
  r_hub_i = hub_id/2;
  r_hub_o = r_hub_i + hub_boss_w;
  r_mid   = ( (r_hub_i + cam_clear_radial) + (r_hub_o - cam_clear_radial) )/2;
  lug_w   = cam_band_w - 2*cam_clear_radial;
  lug_len = cam_slot_len_deg - 2*cam_stop_land_deg - 2;
  translate([0,0,z0])
    linear_extrude(height=max(0.1, zt - z0 - cam_clear_axial))
      union(){
        for (i=[0:cam_count-1]){
          base = i*360/cam_count;
          _core_cam_lug_arc_2d(r_mid, base + (lug_len/2), lug_len, lug_w);
        }
      }
}

// Cover cam slots (separate tunables)
module _cover_cam_ring_2d(r_in, r_out){
  r_mid = (r_in + r_out)/2;
  for (i=[0:cov_cam_count-1]){
    base_ang = i*360/cov_cam_count;
    mouth_w  = max(1.4, cov_cam_band_w - 0.6);
    p_bore = [r_in*cos(base_ang), r_in*sin(base_ang)];
    p_band = [r_mid*cos(base_ang), r_mid*sin(base_ang)];
    capsule2d(p_bore, p_band, mouth_w);
    arc_a1 = base_ang + 2;  arc_a2 = base_ang + cov_cam_slot_len_deg - 3;
    arc_capsule2d(r_mid, arc_a1, arc_a2, cov_cam_band_w);
  }
}
module flange_cover_cam_slots_3d(r_in, r_out){
  linear_extrude(height=flange_t + 0.2)
    _cover_cam_ring_2d(r_in, r_out);
}

// Separate face cover with mating lugs
module core_cover_plate(){
  r_cov = cover_diam/2;
  r_in  = hub_id/2 + 0.35;
  r_out = r_in + 4.2;
  r_mid = (r_in + r_out)/2;
  lug_w = cov_cam_band_w - 2*cov_cam_clear;
  lug_len = cov_cam_slot_len_deg - 4;
  // disk
  difference(){ cylinder(h=cover_thick, r=r_cov, $fn=32); }
  // sealing lip
  translate([0,0,0]) cylinder(h=cover_lip_h, r=hub_id/2 + cover_lip_r_add, $fn=32);
  // lugs on the back
  translate([0,0,max(0.1, cover_thick - cov_cam_axial_t)])
    linear_extrude(height=cov_cam_axial_t)
      for (i=[0:cov_cam_count-1]){
        base = i*360/cov_cam_count;
        _core_cam_lug_arc_2d(r_mid, base + (lug_len/2), lug_len, lug_w);
      }
}

// ---- 3D core wall — annulus FULL HEIGHT + dog‑leg band shorter (capped top/bottom)
// Also applies perforations to both, so dog‑leg walls share the same holes.
module core_dogleg_only(){
  difference(){
    union(){
      // 1) Base annulus: full height (creates TOP/BOTTOM CAPS over dog‑leg voids)
      linear_extrude(height=core_len) hub_annulus_2d();
      // 2) Dog‑leg wrap band: inner height only
      translate([0,0,cam_z_margin])
        linear_extrude(height=max(0.2, core_len - 2*cam_z_margin))
          wall_around_voids_clipped();
      // 3) Bayonet lugs (top & bottom)
      if (enable_core_cam){
        core_cam_lugs_3d(0, cam_lug_axial_t);
        core_cam_lugs_3d(core_len - cam_lug_axial_t, core_len);
      }
    }
    // Perforations (shared settings) — they avoid the lug slabs because of cam_z_margin
    if (perforation_mode == "holes")
      perforation_radial_drills_both(); // change to "both" path
      //_radial_drills_at_radius();
      
    else if (perforation_mode == "helix")
      perforation_helix();
  }
}

module flange(style){
  flange_heptachord(); // replace later - just for clean build
}

module core(style){
  core_dogleg_final(); // replace later - just for clean build
}


module cover(style) {
core_cover_plate(); // replace later - just for clean build
}


module cam_flange2core(style) {
  core_cover_plate(); // replace later - just for clean build
}


module cam_cover2flange(style) {
 core_cover_plate(); // replace later - just for clean build
}


// Access features into chamber (unchanged)
module core_starter(){
  r = desiccant_r - 2;
  zpos = core_len*0.25;
  translate([r,0,zpos]) rotate([0,starter_bore_angle,90])
    cylinder(h=desiccant_r*2, r=starter_bore_d/2, center=true, $fn=64);
}
module core_face_pocket(){
  translate([0,0, core_len-0.01]) union(){
    cylinder(h=pocket_depth+0.2, r=pocket_d/2 + 0.1, $fn=24);
    lug_r = pocket_d/2 + o_ring_clearance;
    for(n=[0:2]) rotate([0,0,n*120])
      translate([lug_r, -bayonet_lug_w/2, (pocket_depth-1.2)])
        cube([bayonet_lug_len, bayonet_lug_w, 1.4]);
  }
}
module core_dogleg_final(){
  difference(){ core_dogleg_only(); union(){ core_starter(); core_face_pocket(); } }
}

// --------------------------------------
//          DEBUG HELPERS (2D/3D)
// --------------------------------------
module dogleg_step0_slots(){   color([0.2,0.8,0.5,0.5]) dogleg_voids_2d(); }
module dogleg_step1_wall2d(){  color([0.95,0.75,0.12]) hub_wall_path_2d(); }
module dogleg_step2a_annulus_only(){ color([0.95,0.75,0.12,0.9]) linear_extrude(height=core_len) hub_annulus_2d(); }
module dogleg_step2b_dogleg_band_only(){ color([0.95,0.45,0.12,0.9]) translate([0,0,cam_z_margin]) linear_extrude(height=max(0.2, core_len - 2*cam_z_margin)) wall_around_voids_clipped(); }
module dogleg_step3_extrude(){ color([0.95,0.75,0.12,0.95]) core_dogleg_only(); }
module dogleg_step4_final(){   core_dogleg_final(); }
module hub_chamber_debug(){ color([0,0,0,0.35]) linear_extrude(height=0.4) difference(){ circle(desiccant_r+0.5); circle(desiccant_r-0.5); } }


module perforation_cyliders(){ color([0.95,0.75,0.12,0.95]) perforation_radial_drills_both();}

// ---------- CAM TEST COUPONS ----------
// A small sector that contains one flange slot & one core lug to tune clearances.
cam_coupon_arc_deg = 70;   // sector sweep for coupons

module coupon_cam_slot_sector(){
  r_hub_i = hub_id/2; r_hub_o = r_hub_i + hub_boss_w;
  // thin flange slice with slots
  rotate([0,0,-cam_coupon_arc_deg/2])
    linear_extrude(height=flange_t)
      intersection(){
        difference(){ circle(r_hub_o+1.0); circle(r_hub_i-0.2); }
        // sector mask
        polygon([
          [0,0], [ (r_hub_o+1.2)*cos(cam_coupon_arc_deg), (r_hub_o+1.2)*sin(cam_coupon_arc_deg) ], [r_hub_o+1.2,0]
        ]);
      }
  // subtract actual slot shapes
  translate([0,0,-0.1])
    flange_cam_slots_3d(r_hub_i + cam_slot_inset, r_hub_o - cam_slot_inset);
}

module coupon_cam_lug_sector(){
  r_hub_i = hub_id/2; r_hub_o = r_hub_i + hub_boss_w;
  // base ring slice to carry the lugs
  rotate([0,0,-cam_coupon_arc_deg/2])
    linear_extrude(height=cam_lug_axial_t)
      intersection(){
        difference(){ circle(r_hub_o); circle(r_hub_i); }
        polygon([
          [0,0], [ (r_hub_o+1.0)*cos(cam_coupon_arc_deg), (r_hub_o+1.0)*sin(cam_coupon_arc_deg) ], [r_hub_o+1.0,0]
        ]);
      }
  // add lugs into that slice
  core_cam_lugs_3d(0, cam_lug_axial_t);
}

// --------------------------------------
//          ASSEMBLY PREVIEW
// --------------------------------------
module flange_by_style(){
  if (flange_style == "heptachord")
    flange_heptachord();
  else
    flange_dragoncrest();
}

module core_by_style(){
  core_dogleg_final();
}

module assembly_preview(){
  color([0.15,0.15,0.18,0.75]) flange_by_style();
  translate([0,0,flange_t]) core_by_style();
  color([0.15,0.15,0.18,0.75]) translate([0,0,flange_t+core_len]) mirror([0,0,1]) flange_by_style();
}

// --------------------------------------
//           EXPORT/DEBUG SWITCHES
// --------------------------------------
// Flanges:
// flange_heptachord();
// flange_dragoncrest();

// Core — DOGLEG:
// dogleg_step0_slots();
// dogleg_step1_wall2d();
// dogleg_step2a_annulus_only();
// dogleg_step2b_dogleg_band_only();
// dogleg_step3_extrude();
// perforation_cylinders();
// dogleg_step4_final();

// Cams — coupons & cover:
// coupon_cam_slot_sector();
// coupon_cam_lug_sector();
// core_cover_plate();



// Assembly (optional):
// assembly_preview();
