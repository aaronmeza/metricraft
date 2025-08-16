// metricraft-spool v1.0.3 (build004)
// Bambu P1S + AMS — parametric reusable spool
// Flange: A) heptachord (vertex‑mid)  ·  B) dragoncrest (geometric dragon)
// Core: dogleg hub‑wall (desiccant chamber = 55 mm ID)
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
desiccant_r = hub_id/2;   // 55 mm chamber ID
 

// Flange selector
flange_style      = "heptachord";   // "heptachord" | "dragoncrest"

// Core selector (single core for this collection)
core_style        = "dogleg";       // fixed for this collection

// Core — shared
core_len          = spool_width - 2*flange_t;  // axial length between flanges

// Core — DOGLEG hub wall (MVP)
vessel_wall_t     = 2;       // constant hub‑wall thickness (target ~2.4)
baffle_count      = 3;         // number of dog‑legs (3 per your latest)
baffle_rot_deg    = 180/baffle_count; // aesthetic rotation so facets align
baffle_dogleg_sweep_deg = 17;  // tangential sweep at inner end ("hook" angle)
baffle_tip_gap    = 15.0;      // how far finger tips stop short of chamber center (mm)
inner_r           = hub_id/2 + vessel_wall_t;   // inner keep radius (wall stays outside this)
outer_r           = 62;        // OUTER bound where the wall lives (size to taste)
// Dog‑leg VOID geometry controls (length‑driven)
dogleg_slot_w         = 3.5;   // VOID width (air path)
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
hole_radial_bias      = .5;     // + pushes hole center outward, − inward (mm)

// -- legacy helical lattice (kept as an option)
helix_count           = 3;     // number of helical cuts around
helix_w               = 1.6;   // width of each helical cut (mm)
helix_turns           = 1.3;   // total twists across usable height (rev)
helix_z_margin        = 0.8;   // extra vertical keep‑clear beyond cam margins

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

function regular_ngon_points(n,r,rot_deg=0)=
  [ for(i=[0:n-1]) let(a=rot_deg+360*i/n) [r*cos(a),r*sin(a)] ];

// --------------------------------------
//       FLANGE — Heptachord (vertex‑mid)
// --------------------------------------
module flange_heptachord(show_debug=false){
  r_outer=spool_od/2;
  r_inner=r_outer-rim_land_w;
  r_hub_i=hub_id/2;
  r_hub_o=r_hub_i+6;

  hepta_r_ratio=0.62;    // location of heptagon ring (fraction of OD/2)
  hepta_ring_w=7;      // width of the heptagon structural ring
  chord_w_outer_h=2.0;   // spoke width at heptagon (to rim)
  chord_w_outer_r=15.0;   // spoke width at rim end
  chord_w_inner_h=7.0;   // spoke width at heptagon (to hub)
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
  r_hub_o=r_hub_i+6;
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
      ring(r_hub_o,r_hub_i);
      ring(tie_r+tie_w/2, tie_r-tie_w/2);
      // Wireframe dragon bars (clipped to usable annulus)
      intersection(){
        dragon_wire_2d();
        // keep only between hub boss and inner rim land
        difference(){ circle(r_inner-0.6); circle(r_hub_o+0.6); }
      }
    }
  }

  difference(){
    union(){
      linear_extrude(height=rim_land_t) ring(r_outer,r_inner); // roller band (solid)
      linear_extrude(height=flange_t)   dragon_web_2d();       // web with wall bars
    }
    translate([0,0,-0.1]) cylinder(h=flange_t+rim_land_t+0.2, r=r_hub_i, $fn=128);
  }

  if(show_debug) color([1,0,0,0.25]) translate([0,0,rim_land_t])
    linear_extrude(height=0.4) ring(r_outer-0.6, r_outer-rim_land_w+0.6);
}

// --------------------------------------
//          CORE — DOGLEG HUB WALL
// --------------------------------------


// Helper: thin annulus
module _annulus(ro, ri){ difference(){ circle(ro); circle(ri); } }

// 2D union of VOID shapes (two capsules + rounded elbow per baffle)
// Explicit, length-based control + elbow bias. Slots can extend beyond the wall.
module dogleg_voids_2d(n=baffle_count){
  

  // apply elbow bias (can be negative)
  outer_run = max(0, dog_outer_run_mm - dog_elbow_bias_mm);
  inner_run = max(0, dog_inner_run_mm + dog_elbow_bias_mm);

  wv = dogleg_slot_w; // slot width exactly as set
  r_out = desiccant_r + vessel_wall_t;
  union(){
    for(i=[0:n-1]){
      ang = baffle_rot_deg + i*360/n;              // degrees

      // centerline radii (start slightly outside the wall for guaranteed through‑cut)
      r_start = r_out + dog_start_overrun_mm;      // begins outside the wall
      r_elbow = r_start - outer_run;               // after outer straight
      r_tip_t = r_elbow - inner_run;               // naive tip radius
      r_tip   = max(desiccant_r - baffle_tip_gap, r_tip_t); // clamp to maintain center clearance

      // points
      p_out   = [ r_start*cos(ang),                      r_start*sin(ang) ];
      p_elbow = [ r_elbow*cos(ang),                      r_elbow*sin(ang) ];
      p_tip   = [ r_tip*cos(ang + baffle_dogleg_sweep_deg),
                  r_tip*sin(ang + baffle_dogleg_sweep_deg) ];

      // VOID geometry (two capsules + rounded elbow)
      capsule2d(p_out,  p_elbow, wv);
      capsule2d(p_elbow,p_tip,   wv);
      translate(p_elbow) circle(wv/2);

       // echo effective lengths for debug
       echo(str("dogleg#", i, " startR=", r_start, " elbowR=", r_elbow,
                " tipR=", r_tip, " eff_outer=", r_start - r_elbow,
                " eff_inner=", r_elbow - r_tip));
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
  // keep within [inner_clip, outer_clip]
  inner_clip = inner_r - vessel_wall_t*10;  // generous interior clip
  outer_clip = inner_r;                 // just inside the wall’s outer edge
  intersection(){
    wall_around_voids_raw();
    difference(){ circle(outer_clip); circle(inner_clip); }
  }
}


module dogleg_voids_clipped(){
// keep within [inner_clip, outer_clip]
  inner_clip = inner_r - vessel_wall_t*10;  // generous interior clip
  outer_clip = inner_r;                 // just inside the wall’s outer edge
  intersection(){
    dogleg_voids_2d();
    difference(){ circle(outer_clip); circle(inner_clip); }
  }
}


module wall_around_voids_extruded(){
 // keep within cam buffer
  // the wall itself
    translate([0,0,cam_z_margin*2])
      linear_extrude(height=max(0.2, core_len - 2*cam_z_margin))
        wall_around_voids_clipped();
 
 }
 
module dogleg_voids_extruded(){
  translate([0,0,cam_z_margin*2])
      linear_extrude(height=max(0.2, core_len - 2*cam_z_margin))
        dogleg_voids_clipped();
}
 

module annulus_extruded(){
   r_in  = desiccant_r;
  r_out = desiccant_r + vessel_wall_t;
   translate([0,0,cam_z_margin])
      linear_extrude(height=core_len)
        _annulus(r_out, r_in);
}

module dogleg_face_top(){
// add faces to doglegs
  translate([0,0,core_len-.4])
      linear_extrude(height=.4)
        dogleg_voids_clipped();
}

module dogleg_face_bottom(){
// add faces to doglegs
translate([0,0,cam_z_margin*2])
  linear_extrude(height=.4) dogleg_voids_clipped();
  
}
 
 // === Perforate the extruded dog-leg baffles the same way as the annulus ===

// 1) Generic drill field at a given mid-radius (reuses your hole_* tunables)
module _radial_drills_at_radius(r_mid, orientation){
  cnt = max(5, floor(360 / hole_arc_pitch_deg));
  len = vessel_wall_t + 2*hole_overrun_mm;   // across wall + a little overrun
  for (row = [0:hole_rows-1]){
    z = cam_z_margin + (row+1)*hole_row_dz;
    if (z < core_len - cam_z_margin){
      phase = (row % 2 == 1) ? hole_row_stagger_deg : 0;
      for (i = [0:cnt-1]){
        ang = phase + i*360/cnt;
        rotate([0,0,ang])
          translate([r_mid,0,z])
            rotate([orientation,90,0])
              cylinder(h=len, r=hole_d/2, center=true, $fn=128);
      }
    }
  }
}

// 2) Same drill field, at both the annulus mid-thickness AND the dog-leg band
module perforation_radial_drills_both(){
  // Annulus (mid of the constant-thickness wall)
  _radial_drills_at_radius(desiccant_r + vessel_wall_t/2 + hole_radial_bias,00);

  // Dog-leg wrap band hugs the OUTER edge of the annulus (≈ inner_r − ~0.6)
  // Tweak the 0.6 if you adjust the clip in wall_around_voids_clipped().
  _radial_drills_at_radius(desiccant_r - 5 + hole_radial_bias,90);
  
    // Dog-leg wrap band hugs the OUTER edge of the annulus (≈ inner_r − ~0.6)
  // Tweak the 0.6 if you adjust the clip in wall_around_voids_clipped().
  _radial_drills_at_radius(desiccant_r - 10 + hole_radial_bias,90+baffle_dogleg_sweep_deg);
  _radial_drills_at_radius(desiccant_r - 14 + hole_radial_bias,90+baffle_dogleg_sweep_deg);
}

// 3) Wrap your existing dog-leg solid with perforations
module dogleg_voids_3d_perforated(){
  difference(){
    wall_around_voids_extruded();                // <-- your current extruded/capped baffles
    perforation_radial_drills_both(); // <-- subtract holes (same pattern as annulus)
  }
}

 
 
 
// 3D: final hub-wall path = annulus + wrap band
module full_hub(){
  r_in  = desiccant_r;
  r_out = desiccant_r + vessel_wall_t;
 union(){difference(){
  union(){ annulus_extruded(); wall_around_voids_extruded(); };dogleg_voids_extruded();}
  dogleg_face_top(); dogleg_face_bottom();};
}

// Optional 2D vents (legacy; not used when perforation_mode="holes")
module wall_vents_2d(){
  r_mid = desiccant_r + vessel_wall_t/2;
  circ = 2*PI*r_mid;
  cnt  = max(3, floor(circ / 6.0));   // legacy defaults
  arc_span = 360 * (3.0 / circ);      // deg
  w = vessel_wall_t + 0.6;            // ensure cut crosses full thickness
  union(){
    for(i=[0:cnt-1]){
      ang = i*360/cnt;
      arc_capsule2d(r_mid, ang - arc_span/2, ang + arc_span/2, w);
    }
  }
}

// ---- 3D perforators ----
// Round radial drills (preferred)
module perforation_radial_drills(){
  r_mid = desiccant_r + vessel_wall_t/2 + hole_radial_bias;
  cnt   = max(3, floor(360 / hole_arc_pitch_deg));
  len   = vessel_wall_t + 2*hole_overrun_mm;   // across wall thickness plus overrun
  // rows stacked in Z, staggered in angle for strength
  for(row=[0:hole_rows-1]){
    z = cam_z_margin + (row+1)*hole_row_dz;
    if (z < core_len){
      phase = (row % 2 == 1) ? hole_row_stagger_deg : 0;
      for(i=[0:cnt-1]){
        ang = phase + i*360/cnt;
        rotate([0,0,ang])
          translate([r_mid,0,z])
            rotate([0,90,0])
              cylinder(h=len, r=hole_d/2, center=true, $fn=128);
      }
    }
  }
  
  
  
}



// Helical lattice (legacy option)
module perforation_helix(){
  usable_h = max(0.1, core_len - 2*cam_z_margin - 2*helix_z_margin);
  r_mid = desiccant_r + vessel_wall_t/2;
  translate([0,0,cam_z_margin+helix_z_margin])
    for(i=[0:helix_count-1]){
      ang0 = i*360/helix_count;
      rotate([0,0,ang0])
        translate([r_mid,0,0])
          linear_extrude(height=usable_h, twist=helix_turns*360, slices=max(12, floor(usable_h*3)))
            square([helix_w, vessel_wall_t + 1.2], center=true);
    }
}

// 3D core wall (perforations applied post‑extrude)
module core_dogleg_only(){
  
  
  translate([0,0,-cam_z_margin])
  difference(){

   full_hub();
    // subtract perforations
    if (perforation_mode == "holes")
      perforation_radial_drills_both();
    else if (perforation_mode == "helix")
      perforation_helix();
  }
}

// Access features into chamber (unchanged)
module core_starter(){
  r = desiccant_r - 2;
  zpos = core_len*0.25;
  translate([r,0,zpos]) rotate([0,starter_bore_angle,90])
    cylinder(h=desiccant_r*2, r=starter_bore_d/2, center=true, $fn=128);
}
module core_face_pocket(){
  translate([0,0, core_len-0.01]) union(){
    cylinder(h=pocket_depth+0.2, r=pocket_d/2 + 0.1, $fn=128);
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
module dogleg_step0_slots(){      color([0.2,0.8,0.5,0.5]) dogleg_voids_3d_perforated(); }
module dogleg_step1_wrap_raw(){   color([0.2,0.5,1,0.35]) wall_around_voids_raw(); }
module dogleg_step1_wrap_clip(){  color([0.1,0.7,1,0.55]) wall_around_voids_clipped(); }
module dogleg_step2_wall2d(){     color([0.95,0.75,0.12]) full_hub(); }
module dogleg_step2b_wall3d(){    color([0.95,0.75,0.12]) wall_around_voids_extruded(); }
module core_radial_drills(){    color([0.95,0.75,0.12]) perforation_radial_drills_both(); }

module dogleg_voids(){           color([0.95,0.75,0.12]) dogleg_voids_3d_perforated(); }


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

module core_by_style(){
  // single core for this collection
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
// Uncomment ONE at a time:

// Flanges:
// flange_heptachord();
// flange_dragoncrest();

// Core — DOGLEG + wall‑around‑voids + HELICAL lattice:
//dogleg_step0_slots();
//dogleg_step1_wrap_raw();
//dogleg_step1_wrap_clip();
//dogleg_step2b_wall3d(); // baffles?
//dogleg_step2_wall2d();  // ?? hub no perforations?
//core_radial_drills();   // the holes subtracted from the hub
//dogleg_step3_extrude(); // final core; no spool flanges
//dogleg_step4_final();

// Assembly:
assembly_preview();