
// filament_spool.scad — v0.1.0 scaffold
// AMS‑safe 199 × 67 × 55 (OD × width × bore), split‑hub official-style
include <threads.scad>

/*************** Parameters ***************/
spool_od        = 199;
spool_width     = 67;
hub_bore_id     = 55;
thread_major    = 58;   // AMS variant thread major
thread_pitch    = 3.0;
lid_depth       = 18;
lid_wall        = 1.6;
bead_size       = 2.0;
baffle_count    = 8;
baffle_thk      = 1.2;
baffle_height   = 10;
clip_count      = 4;
clip_slot_w     = 3.0;
clip_gap        = 0.6;
label_deboss    = 0.6;
logo_badge_r    = 12;

// Part selector
part = is_undef(part) ? "flange_left" : part;
// Options: "flange_left","flange_right","lid_top","lid_bottom","coupon_threadfit"

$fa = 2; $fs = 0.4;

module round_cylinder(d=10,h=10){ cylinder(d=d,h=h,$fn=96); }
module interlock_keys(key_w=6,key_d=3,key_h=2, count=6, r=34){
    for(i=[0:count-1]) rotate([0,0, i*360/count])
        translate([r,0,0]) cube([key_w,key_d,key_h],center=true);
}
module filament_clip_slot(slot_w=clip_slot_w, gap=clip_gap, thickness=2.0){
    cube([slot_w,gap,thickness],center=true);
}
module baffles_annulus(ri=hub_bore_id/2+2, ro=thread_major/2+lid_depth, thk=baffle_thk, h=baffle_height, n=baffle_count){
    for(i=[0:n-1]) rotate([0,0,i*360/n]) translate([ri, -thk/2, 0]) cube([ro-ri, thk, h]);
}

// Flange + half-hub with interlock
module spool_flange(side="left"){
    flange_thk = 2.4;
    difference(){
        linear_extrude(height=flange_thk)
            difference(){ circle(d=spool_od); circle(d=hub_bore_id); }
        for(i=[0:clip_count-1]) rotate([0,0, i*360/clip_count])
            translate([spool_od/2 - 5,0,flange_thk/2])
                filament_clip_slot(thickness=flange_thk+0.2);
    }
    hub_len = spool_width/2 - 2;
    translate([0,0,flange_thk])
        difference(){
            // solid hub sleeve (OD slightly larger than thread crest)
            cylinder(d=thread_major + 2*lid_wall + 2, h=hub_len, $fn=120);

            // threaded cavity we subtract
            // start a little above Z=0 to avoid razor-thin bases
            translate([0,0,1]){
                turns = floor((hub_len - 2) / thread_pitch);
                mc_internal_tap(major=thread_major, pitch=thread_pitch, turns=turns);
            }

            // keep your interlock features as subtractive or additive as needed
            if (side=="left"){
                // subtract female pockets (leave as you have it)
                translate([0,0,hub_len-3]) interlock_keys(count=6, r=(hub_bore_id+8)/2);
            } else {
                // subtract relief for male keys (if you’re modeling them as positive on the right half)
                // or add the keys in a union() before the difference if you prefer.
                // (keep your existing key logic here)
            }
        }
}

// Desiccant lid (external thread stub)
module desiccant_lid_top(){
    h  = lid_depth;                               // total lid height
    od = thread_major + 2*lid_wall;               // outer diameter of the cap body
    turns = floor((h - 2) / thread_pitch);        // thread turns that fit within h

    union(){
        // Hollow cap shell
        difference(){
            cylinder(d=od, h=h, $fn=120);
            translate([0,0,1]) cylinder(d=od - 2*lid_wall, h=h, $fn=120);
        }
        // External thread wrapped around the cap
        // (adds thread ribs at ~thread_major diameter)
        mc_external_thread(major=thread_major, pitch=thread_pitch, turns=turns);
    }
}

module desiccant_lid_bottom(){ desiccant_lid_top(); } // symmetric for scaffold


// Switch
if (part=="flange_left")       spool_flange("left");
else if (part=="flange_right") spool_flange("right");
else if (part=="lid_top")      desiccant_lid_top();
else if (part=="lid_bottom")   desiccant_lid_bottom();
else if (part=="coupon_threadfit") include <coupons/thread_fit_ladder.scad>;
