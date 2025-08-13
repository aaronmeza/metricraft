// metricraft coupon-pack v0.1.0
// P1S + AMS | Bambu Studio 2.2.0.85 | basement 50–60°F ~60% RH
// Tokens: mc-rail-12, mc-dovetail-8
// Usage: openscad -o out.stl -D part="all" coupon_pack.scad
// Valid parts: "all","xy_ladder","hole_gauge","snapfit","dovetail_gauge","readme"

part = "all";
$fn = 64;

// ----------------- helpers -----------------
module tag(name){ /* for readability in tree */ children(); }
module rrect(x,y,r,h){ linear_extrude(h) offset(r=r) square([x-2*r,y-2*r], center=true); }
module text3d(t, h=0.8, s=6){ linear_extrude(h) text(t, size=s, halign="center", valign="center"); }
module label(t, w=28, h=8, th=1.2){ difference(){ rrect(w,h,1.2,th); translate([0,0,th]) text3d(t, h=0.4, s=4.2); } }

plate_gap = 2; plate_th = 2;

// ----------------- 1) XY clearance ladder -----------------
module xy_ladder(bar_w=10, bar_l=36, bar_h=8, start=0.10, step=0.10, n=5){
  // prints a male bar and n female slots with increasing clearance
  spacing = 18;
  // title
  translate([0, 20 + n*spacing/2, 0]) label("xy ladder 0.10–0.50", 60,10);

  // male bar (target)
  translate([-30,0,0]) tag("xy_male_bar")
    rrect(bar_w, bar_l, 1, bar_h);

  // slots ladder
  for(i=[0:n-1]){
    clr = start + i*step;
    // slot is (bar_w + 2*clr)
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
  // base
  translate([0,0,0]) tag("hole_block") rrect(82, 38, 2, th);
  // holes
  for(i=[0:len(steps)-1]){
    d = steps[i];
    c = i % cols;
    r = floor(i/cols);
    translate([-34 + c*10.5, -10 + r*10.5, 0])
      tag(str("hole_",d))
        cylinder(h=th+0.2, d=d, $fn=64);
  }
  // 5.00mm pin
  translate([34,0,0]) tag("pin_5_00")
    rrect(12, 20, 1.2, th)
    translate([0,0,th]) cylinder(h=12, d=5.00);
}

// ----------------- 3) Snap-fit cantilever -----------------
module snapfit(){
  translate([0,-35,0]) label("snap W6/8/10×T1.6/2.0/2.4 L16",72,10);
  widths=[6,8,10]; ths=[1.6,2.0,2.4]; L=16; base=2.2;
  for(wi=[0:len(widths)-1]){
    for(ti=[0:len(ths)-1]){
      w=widths[wi]; t=ths[ti];
      translate([-40 + wi*40, -60 - ti*12, 0])
        tag(str("snap_w",w,"_t",t)){
          // base
          rrect(w+10, 8, 0.8, base);
          // fixed root
          translate([-(w/2)+0.5,0,base]) cube([1,w, t], center=false);
          // arm
          translate([-(w/2)+1.5,0,base]) cube([L, w, t], center=false);
          // chamfer nose
          translate([L-(w/2), w/2, base+t-0.01]) rotate([0,90,0]) cylinder(h=3, r1=0.0, r2=1.0);
        }
    }
  }
}

// ----------------- 4) Dovetail / rail gauge -----------------
module mc_rail_12(len=36, h=8, w=12, alpha=55, nose=1){
  // simple symmetric rail body
  union(){
    cube([len,w,h], center=true);
    // nose relief to catch seams
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
    // sockets row
    translate([-50 + i*16, 10, 0]) tag(str("socket_",o)) mc_socket_12(offset=o);
    // matching rails row
    translate([-50 + i*16, -10, 0]) tag(str("rail_",o)) mc_rail_12();
  }
}

// ----------------- 5) README tile -----------------
module readme_tile(){
  translate([0,0,0]) difference(){
    rrect(90, 60, 2, 1.8);
    translate([0,0,0.2]) linear_extrude(0.8)
      text("metricraft coupon-pack v0.1.0\nPLA: 0.20–0.25 XY\nPETG: 0.30–0.35 XY\nRun after filament change or drying.\nAccept: 5.00 pin press, snap no whitening (PETG 100 cycles).",
           size=4.2, halign="center", valign="center", spacing=1.00);
  }
}

// ----------------- layout -----------------
module plate_all(){
  translate([-60,  45, 0]) xy_ladder();
  translate([ 60,  45, 0]) hole_gauge();
  translate([   0,   0, 0]) readme_tile();
  translate([   0, -20, 0]) dovetail_gauge();
  translate([   0, -80, 0]) snapfit();
}

if (part=="xy_ladder") xy_ladder();
else if (part=="hole_gauge") hole_gauge();
else if (part=="snapfit") snapfit();
else if (part=="dovetail_gauge") dovetail_gauge();
else if (part=="readme") readme_tile();
else plate_all();
