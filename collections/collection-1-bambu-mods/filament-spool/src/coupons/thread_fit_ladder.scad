// coupons/thread_fit_ladder.scad
include <threads.scad>
clearances = [0.20, 0.25, 0.30];
major = 58; pitch = 3.0; height = 8; ring = 24;
module label_tag(txt="0.20"){
    translate([0,0,height+0.6]) linear_extrude(height=0.6) text(txt, size=4, halign="center", valign="center");
}
module pair(c=0.20, x=0){
    translate([x,0,0]){
        translate([-ring/2,0,0])
            difference(){ cylinder(d=major+4, h=height, $fn=96);
                thread_internal(d=major, pitch=pitch, length=height-1, clearance=c);
                translate([0,0,0.5]) cylinder(d=major-2*c, h=height-1, $fn=96);
            }
        translate([ ring/2,0,0])
            thread_external(d=major-2*c, pitch=pitch, length=height);
            cylinder(d=major-2*c, h=height, $fn=96);
        label_tag(str(c));
    }
}
spacing = 40; for (i=[0:len(clearances)-1]) pair(clearances[i], x=i*spacing);
