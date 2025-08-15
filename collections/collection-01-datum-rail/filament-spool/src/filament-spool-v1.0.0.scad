// metricraft-spool v1.0.4 (build004)
// Bambu P1S + AMS — parametric reusable spool
// Flange: A) heptachord (vertex‑mid)  ·  B) dragoncrest (geometric dragon)
// Core: dogleg hub‑wall (55 mm desiccant chamber) + wall‑around‑voids + 3D helical lattice perforation
//
// Units: millimeters. OpenSCAD trig = DEGREES.  $fn tuned for visual smoothness.

// --------------------------------------
//               TOKENS
// --------------------------------------
spool_od          = 198.5;     // AMS-safe OD
spool_width       = 65;        // assembled width (flange + core + flange)
hub_id            = 55;        // DESICCANT CHAMBER ID in dogleg mode
flange_t          = 2.4;       // flange web thickness
rim_land_w        = 9.0;       // roller track width (solid)
rim_land_t        = 2.6;       // roller track thickness
 tie_ring_r_ratio  = 0.70;      // tie ring radial ratio (fraction of r_outer)
 tie_ring_w        = 3.0;       // tie ring width

// Flange selector
flange_style      = "heptachord";   // "heptachord" | "dragoncrest"

// Core selector (single core for this collection)
core_style        = "dogleg";       // fixed for this collection

// Core — shared
core_len          = spool_width - 2*flange_t;  // axial length between flanges

// Core — DOGLEG hub wall (2D wall path)
vessel_wall_t     = 2.4;       // constant hub‑wall thickness (target ~2.4)
baffle_count      = 3;         // hepta theme
baffle_rot_deg    = 180/7;     // aesthetic rotation so facets align
baffle_dogleg_sweep_deg = 17;   // tangential sweep at inner end ("hook" angle)
baffle_tip_gap    = 15.0;      // how far finger tips stop short of chamber center (mm)

// Dog‑leg VOID geometry controls (length‑driven)
dogleg_slot_w         = 4.0;   // VOID width (air path)
dog_start_overrun_mm  = 10;    // slot begins this far OUTSIDE the wall (guaranteed through‑cut)
dog_outer_run_mm      = 21;    // straight run from start toward the elbow
dog_inner_run_mm      = 7;    // straight run from elbow toward the tip
dog_elbow_bias_mm     = 1;     // + moves elbow toward tip (steals from outer, adds to inner)

// Perforation — HELICAL lattice (3D cutter)
helix_enable          = false;  // master switch for helical lattice
helix_slot_w          = 1.8;   // lattice strand/slot thickness (radial)
helix_slot_len        = 8.0;   // tangential size of the strip cross‑section (mm)
helix_pitch_mm        = 12.0;  // axial rise per full revolution (mm / turn)
helix_count           = 3;     // number of strands per handedness around the ring
helix_dual_family     = true;  // true = cross‑lattice (both left & right)
helix_phase_deg       = 0;     // rotate start phase of the strands
helix_z_margin        = 1.2;   // keep‑clear at top/bottom (in addition to cam margin)

// Keep‑clear for future quarter‑turn cam caps
cam_z_margin          = 3.2;   // at both top and bottom of core wall

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
  r_hub_o=r_hub_i+6;

  hepta_r_ratio=0.62;    // location of heptagon ring (fraction of OD/2)
  hepta_ring_w=6.0;      // width of the heptagon structural ring
  chord_w_outer_h=5.0;   // spoke width at heptagon (to rim)
  chord_w_outer_r=4.0;   // spoke width at rim end
  chord_w_inner_h=5.0;   // spoke width at heptagon (to hub)
  chord_w_inner_c=4.0;   // spoke width at hub end
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
      difference(){ polygon(outer_hepta); polygon(inner_hepta); }
      ring(tie_r+tie_w/2,tie_r-tie_w/2);
      ring(r_hub_o,r_hub_i);
      for(i=[0:6]) taper_capsule2d(hepta_pts[i], hepta_to_rim[i], chord_w_outer_h, chord_w_outer_r);
      for(i=[0:6]) taper_capsule2d(hepta_pts[i], hepta_to_hub[i], chord_w_inner_h, chord_w_inner_c);
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
    translate([0,0,-0.1]) cylinder(h=flange_t+rim_land_t+0.2, r=r_hub_i, $fn=96);
  }

  if(show_debug) color([1,0,0,0.25]) translate([0,0,rim_land_t])
    linear_extrude(height=0.4) ring(r_outer-0.6, r_outer-rim_land_w+0.6);
}

// --------------------------------------
//     FLANGE — Dragoncrest (geometric dragon)
// --------------------------------------
module flange_dragoncrest(show_debug=false){
  r_outer=spool_od/2;
  r_inner=r_outer-rim_land_w;
  r_hub_i=hub_id/2;
  r_hub_o=r_hub_i+6;
  tie_r=tie_ring_r_ratio*r_outer;
  tie_w=tie_ring_w;

  web_w = 3.2;       // bar width of wireframe

  module wire_segments_2d(segments,w){ for (s=segments) capsule2d(s[0], s[1], w); }
  function segments_from_points(pts, closed=false) =
    closed ? [for(i=[0:len(pts)-1]) [pts[i], pts[(i+1)%len(pts)]]] : [for(i=[0:len(pts)-2]) [pts[i], pts[i+1]]];

  function dragon_polylines() = [
    [[-0.35,0.10],[-0.18,0.12],[ -0.02,0.09],[0.10,0.05],[0.18,0.00],[0.12,-0.04],[0.00,-0.02],[-0.10,0.02],[-0.22,0.06]],
    [[0.12,-0.04],[0.18,-0.10],[0.24,-0.17],[0.28,-0.24],[0.20,-0.26],[0.14,-0.20],[0.10,-0.12]],
    [[-0.10,0.06],[0.00,0.10],[0.08,0.08]],
    [[-0.18,0.12],[-0.22,0.00],[-0.12,-0.18],[0.02,-0.32],[0.16,-0.40],[0.30,-0.46]],
    [[-0.12,-0.18],[-0.06,-0.08],[0.02,-0.20]],
    [[0.02,-0.32],[0.10,-0.22],[0.18,-0.34]],
    [[0.30,-0.46],[0.22,-0.60],[0.08,-0.70],[-0.06,-0.72],[-0.16,-0.66],[-0.22,-0.54],[-0.16,-0.46],[-0.04,-0.42],[0.08,-0.46]],
    [[-0.06,-0.40],[-0.14,-0.48],[-0.18,-0.58]]
  ];

  module dragon_wire_2d(){
    r_center = (r_hub_o + r_inner)/2;  // radial center of usable band
    band_span = (r_inner - r_hub_o);   // thickness of the annulus
    motif_scale = 0.85*band_span;      // scale unit motif to band

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
      ring(r_hub_o,r_hub_i);
      ring(tie_r+tie_w/2, tie_r-tie_w/2);
      intersection(){
        dragon_wire_2d();
        difference(){ circle(r_inner-0.6); circle(r_hub_o+0.6); }
      }
    }
  }

  difference(){
    union(){
      linear_extrude(height=rim_land_t) ring(r_outer,r_inner);
      linear_extrude(height=flange_t)   dragon_web_2d();
    }
    translate([0,0,-0.1]) cylinder(h=flange_t+rim_land_t+0.2, r=r_hub_i, $fn=96);
  }

  if(show_debug) color([1,0,0,0.25]) translate([0,0,rim_land_t])
    linear_extrude(height=0.4) ring(r_outer-0.6, r_outer-rim_land_w+0.6);
}

// --------------------------------------
//          CORE — DOGLEG HUB WALL (2D)
// --------------------------------------
desiccant_r = hub_id/2;   // 55 mm chamber ID

// Helper: thin annulus
module _annulus(ro, ri){ difference(){ circle(ro); circle(ri); } }

// 2D VOID centerlines — two capsules + rounded elbow per baffle
module dogleg_voids_2d(n=baffle_count){
  r_in  = desiccant_r;
  r_out = desiccant_r + vessel_wall_t;

  outer_run = max(0, dog_outer_run_mm - dog_elbow_bias_mm);
  inner_run = max(0, dog_inner_run_mm + dog_elbow_bias_mm);
  wv = dogleg_slot_w; // VOID width

  union(){
    for(i=[0:n-1]){
      ang = baffle_rot_deg + i*360/n;              // degrees
      r_start = r_out + dog_start_overrun_mm;      // begins outside wall
      r_elbow = r_start - outer_run;               // after outer straight
      r_tip_t = r_elbow - inner_run;               // naive tip radius
      r_tip   = max(r_in - baffle_tip_gap, r_tip_t); // keep clearance

      p_out   = [ r_start*cos(ang), r_start*sin(ang) ];
      p_elbow = [ r_elbow*cos(ang), r_elbow*sin(ang) ];
      p_tip   = [ r_tip*cos(ang + baffle_dogleg_sweep_deg),
                  r_tip*sin(ang + baffle_dogleg_sweep_deg) ];

      capsule2d(p_out,  p_elbow, wv);
      capsule2d(p_elbow,p_tip,   wv);
      translate(p_elbow) circle(wv/2);
    }
  }
}

// AROUND‑VOID band: morphological tube of the voids (⨁t/2 ⊖ ⊖t/2)
module wall_around_voids_raw(){
  difference(){
    offset(+vessel_wall_t/2) dogleg_voids_2d();
    offset(-vessel_wall_t/2) dogleg_voids_2d();
  }
}

// Clip that band to the annulus so it stays within the wall region
module wall_around_voids_clipped(){
  r_in  = desiccant_r-baffle_tip_gap*1.5;
  r_out = desiccant_r + vessel_wall_t-.5;
  intersection(){
    wall_around_voids_raw();
    _annulus(r_out+0.4, r_in-0.4); // small tolerance to ensure fusing
  }
}

// FINAL 2D wall: annulus with through‑voids, PLUS the around‑void band
module hub_wall_path_2d(){
  r_in  = desiccant_r;
  r_out = desiccant_r + vessel_wall_t;
  union(){
    difference(){ _annulus(r_out, r_in); dogleg_voids_2d(); } // through‑voids
    wall_around_voids_clipped();                              // wrap band
  }
}

// --------------------------------------
//   HELICAL LATTICE — 3D perforation cutter
// --------------------------------------
module helical_lattice_cutter(height, r_in, r_out){
  r_mid   = (r_in + r_out)/2;
  turns   = height / helix_pitch_mm;                // revolutions over height
  slicesN = max(40, ceil(abs(turns)*90));           // smooth twist

  module helical_family(handed=1, phase=0){
    union(){
      for(i=[0:helix_count-1])
        rotate([0,0, phase + i*360/helix_count])
          linear_extrude(height=height, twist=handed*turns*360, slices=slicesN)
            translate([r_mid,0,0])
              square([helix_slot_len, helix_slot_w], center=true);
    }
  }

  // clip to the wall band so we don't chew into the chamber or shell
  intersection(){
    difference(){
      cylinder(h=height, r=r_out+0.6, $fn=$fn);
      cylinder(h=height, r=r_in-0.6, $fn=$fn);
    }
    union(){
      helical_family(+1, phase=helix_phase_deg);
      if (helix_dual_family) helical_family(-1, phase=helix_phase_deg + 180/helix_count);
    }
  }
}

// 3D core wall with helical lattice and cam keep‑clear
module core_dogleg_only(){
  wall_h = max(0.2, core_len);
  difference(){
    // Base wall geometry (2D path → 3D)
    //
   linear_extrude(height=wall_h) hub_wall_path_2d();

    // Helical lattice subtraction (optional)
    if (helix_enable){
      cut_h = max(0.01, wall_h - 2*helix_z_margin);
      translate([0,0,cam_z_margin + helix_z_margin])
        helical_lattice_cutter(cut_h, desiccant_r, desiccant_r + vessel_wall_t);
    }
  }
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
    cylinder(h=pocket_depth+0.2, r=pocket_d/2 + 0.1, $fn=96);
    lug_r = pocket_d/2 + o_ring_clearance;
    for(n=[0:2]) rotate([0,0,n*120])
      translate([lug_r, -bayonet_lug_w/2, (pocket_depth-1.2)])
        cube([bayonet_lug_len, bayonet_lug_w, 1.4]);
  }
}
module core_dogleg_final(){
core_dogleg_only();
  //difference(){ core_dogleg_only(); union(){ core_starter(); core_face_pocket(); } }
}

// --------------------------------------
//          DEBUG HELPERS (2D/3D)
// --------------------------------------
module dogleg_step0_slots(){      color([0.2,0.8,0.5,0.5]) dogleg_voids_2d(); }
module dogleg_step1_wrap_raw(){   color([0.2,0.5,1,0.35]) wall_around_voids_raw(); }
module dogleg_step1_wrap_clip(){  color([0.1,0.7,1,0.55]) wall_around_voids_clipped(); }
module dogleg_step2_wall2d(){     color([0.95,0.75,0.12]) hub_wall_path_2d(); }
module dogleg_step3_extrude(){    color([0.95,0.75,0.12]) core_dogleg_only(); }
module dogleg_step4_final(){      core_dogleg_final(); }
module hub_chamber_debug(){ color([0,0,0,0.35]) linear_extrude(height=0.4)
  difference(){ circle(desiccant_r+0.5); circle(desiccant_r-0.5); } }

// --------------------------------------
//          ASSEMBLY PREVIEW
// --------------------------------------
module flange_by_style(){
  if (flange_style == "heptachord")
    flange_heptachord();
  else
    flange_dragoncrest();
}

module core_by_style(){ core_dogleg_final(); }

module assembly_preview(){
  color([0.15,0.15,0.18,0.75]) flange_by_style();
  translate([0,0,flange_t]) core_by_style();
  color([0.15,0.15,0.18,0.75]) translate([0,0,flange_t+core_len]) mirror([0,0,1]) flange_by_style();
}

// --------------------------------------
//           EXPORT/DEBUG SWITCHES
// --------------------------------------
// Uncomment ONE at a time:

// Flanges:
// flange_heptachord();
// flange_dragoncrest();

// Core — DOGLEG + wall‑around‑voids + HELICAL lattice:
// dogleg_step0_slots();
// dogleg_step1_wrap_raw();
 //dogleg_step1_wrap_clip();
 //dogleg_step2_wall2d();
 //dogleg_step3_extrude();
 //dogleg_step4_final();

// Assembly:
 assembly_preview();
