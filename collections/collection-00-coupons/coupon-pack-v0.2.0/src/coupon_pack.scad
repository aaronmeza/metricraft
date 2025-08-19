// metricraft coupon-pack v0.2.0
// P1S + AMS | Bambu Studio 2.2.0.85 | basement 50–60°F ~60% RH
// Tokens: mc-rail-12, mc-dovetail-8
// part: "all","all_220","xy_ladder","hole_gauge","snapfit","dovetail_gauge","readme","ams_readme"
part = "xy_ladder";
$fn = 64;

// ----------------- helpers -----------------
module tag(name){ children(); }
module rrect(x,y,r,h){ linear_extrude(h) offset(r=r) square([x-2*r,y-2*r], center=true); }
module text3d(t, h=0.8, s=6, space=1.00){
  linear_extrude(h) text(t, size=s, halign="center", valign="center", spacing=space);
}
module label(t, w=28, h=8, th=1.2){
  difference(){ rrect(w,h,1.2,th); translate([0,0,th]) text3d(t, 0.4, 4.2); }
}

// ----------------- 1) XY clearance ladder -----------------
module xy_ladder(bar_w=10, bar_l=36, bar_h=8, start=0.10, step=0.10, n=5){
  spacing = 18;
  translate([0, 20 + n*spacing/2, 0]) label("xy ladder 0.10–0.50", 60,10);
  translate([-30,0,0]) tag("xy_male_bar") rrect(bar_w, bar_l, 1, bar_h);
  for(i=[0:n-1]){
    clr = start + i*step;
    translate([20, i*spacing, 0])
      tag(str("xy_slot_", clr))
        difference(){
          rrect(bar_w+2*clr+3, bar_l+6, 1.5, bar_h+1.5);
          translate([0,0,0.5]) rrect(bar_w+2*clr, bar_l, 1, bar_h+1.6);
          translate([0, -bar_l*0.38, bar_h+0.8]) text3d(str(clr," mm"), 0.6, 4.5);
        }
  }
}

// ----------------- 2) Hole / shaft gauge -----------------
module hole_gauge(base=60, th=3){
  steps = [3:0.25:10];
  cols = 8;
  rows = ceil(len(steps)/cols);
  translate([0,42,0]) label("holes 3–10 step 0.25 + 5.00 pin",72,10);
  translate([0,0,0]) tag("hole_block") rrect(82, 38, 2, th);
  for(i=[0:len(steps)-1]){
    d = steps[i];
    c = i % cols; r = floor(i/cols);
    translate([-34 + c*10.5, -10 + r*10.5, 0])
      tag(str("hole_",d)) cylinder(h=th+0.2, d=d);
  }
  translate([34,0,0]) tag("pin_5_00") {
    rrect(12, 20, 1.2, th);
    translate([0,0,th]) cylinder(h=12, d=5.00);
  }
}

// ----------------- 3) Snap-fit cantilever -----------------
module snapfit(){
  translate([0,-35,0]) label("snap W6/8/10×T1.6/2.0/2.4 L16",72,10);
  widths=[6,8,10]; ths=[1.6,2.0,2.4]; L=16; base=2.2;
  for(wi=[0:len(widths)-1])
    for(ti=[0:len(ths)-1]){
      w=widths[wi]; t=ths[ti];
      translate([-40 + wi*40, -60 - ti*12, 0])
        tag(str("snap_w",w,"_t",t)){
          rrect(w+10, 8, 0.8, base);
          translate([-(w/2)+0.5,0,base]) cube([1,w, t], center=false);
          translate([-(w/2)+1.5,0,base]) cube([L, w, t], center=false);
          translate([L-(w/2), w/2, base+t-0.01]) rotate([0,90,0]) cylinder(h=3, r1=0.0, r2=1.0);
        }
    }
}

// ----------------- 4) Dovetail / rail gauge -----------------
module mc_rail_12(len=36, h=8, w=12, nose=1){
  union(){
    cube([len,w,h], center=true);
    translate([len/2-1.0,0,0]) cube([nose, w*0.6, h*0.6], center=true);
  }
}
module mc_socket_12(len=40, h=10, w=12, offset=0.0){
  difference(){
    rrect(len+6, w+6, 1.2, h);
    translate([0,0,1]) cube([len+0.2, w+0.2+2*offset, h+2], center=true);
  }
}
module dovetail_gauge(){
  translate([40,22,0]) label("rail/dovetail offsets ±0.10/0.20/0.30",84,10);
  offs=[-0.30,-0.20,-0.10,0.0,+0.10,+0.20,+0.30];
  for(i=[0:len(offs)-1]){
    o=offs[i];
    translate([-50 + i*16, 10, 0]) tag(str("socket_",o)) mc_socket_12(offset=o);
    translate([-50 + i*16, -10, 0]) tag(str("rail_",o)) mc_rail_12();
  }
}

// ----------------- 5) README tiles -----------------
module core_readme_tile(){
  difference(){
    rrect(90, 60, 2, 1.8);
    translate([0,0,0.2]) text3d(
      "metricraft coupon-pack v0.2.0\nPLA: XY 0.20–0.25\nPETG: XY 0.30–0.35\nRun after filament change/dry.\nAccept: 5.00 pin press; PETG 100 cycles.",
      0.8, 4.2, 0.98);
  }
}
module ams_readme_tile(){
  difference(){
    rrect(90, 50, 2, 1.8);
    translate([0,0,0.2]) text3d(
      "AMS tips:\n• Keep desiccant fresh.\n• 5 kg spools: external.\n• PETG: glue stick on smooth PEI.\n• Avoid seams on rails/snap noses.\n• Fan PETG 15–30%.",
      0.8, 4.0, 0.98);
  }
}

// ----------------- Layouts -----------------
module plate_all(){                         // P1S layout (256×256 fits easily)
  translate([-60,  45, 0]) xy_ladder();
  translate([ 60,  45, 0]) hole_gauge();
  translate([   0,   0, 0]) core_readme_tile();
  translate([   0, -20, 0]) dovetail_gauge();
  translate([   0, -80, 0]) snapfit();
  translate([ -85, -80, 0]) ams_readme_tile();
}

module plate_220(){                         // compact layout for 220×220 beds
  // bounding box roughly ~200×200
  translate([-50,  40, 0]) xy_ladder();
  translate([ 50,  40, 0]) hole_gauge();
  translate([   0,   5, 0]) core_readme_tile();
  translate([   0, -25, 0]) dovetail_gauge();
  translate([   0, -85, 0]) snapfit();
  translate([ -75, -85, 0]) ams_readme_tile();
}

// ----------------- part switch -----------------
if (part=="xy_ladder") xy_ladder();
else if (part=="hole_gauge") hole_gauge();
else if (part=="snapfit") snapfit();
else if (part=="dovetail_gauge") dovetail_gauge();
else if (part=="readme") core_readme_tile();
else if (part=="ams_readme") ams_readme_tile();
else if (part=="all_220") plate_220();
else plate_all();
