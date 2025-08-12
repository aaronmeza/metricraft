
// lib/threads.scad — Metricraft adapter around adrianschlatter/threadlib
// License: BSD-3-Clause (wrapper by Metricraft) + see threadlib LICENSE for the library itself.
//
// Usage (from a product .scad):
//   use <../lib/threads.scad>;
//
//   // External thread on a support cylinder (bolt/cap):
//   mc_external_thread(major=58, pitch=3.0, turns=8);
//
//   // Internal threaded cavity to subtract from a part:
//   difference() {
//     my_part();
//     mc_internal_tap(major=58, pitch=3.0, turns=8);
//   }
//
// Notes:
// - Requires vendor libs checked into repo (see README): threadlib + deps.
// - We compute designators like "M58x3" for metric threads. Adjust if using other families.

// Include vendor threadlib
include <vendor/threadlib/threadlib.scad>
// Helper: construct metric designator (e.g., M58x3)
function mc_metric_designator(major, pitch) = str("M", major, "x", pitch);

// External thread (with optional support cylinder)
module mc_external_thread(major=58, pitch=3.0, turns=8, higbee_arc=30, support=true, support_od=0) {
    des = mc_metric_designator(major, pitch);
    if (support) {
        specs = thread_specs(str(des, "-ext"));
        P = specs[0];
        Dsupport = specs[2];
        H = (turns + 1) * P;
        // Support body
        translate([0,0,-P/2])
            cylinder(h=H, d=(support_od>0? support_od : Dsupport), $fn=120);
        // Actual thread
        thread(str(des, "-ext"), turns=turns, higbee_arc=higbee_arc);
    } else {
        thread(str(des, "-ext"), turns=turns, higbee_arc=higbee_arc);
    }
}

// Internal tapped cavity (subtractive mask)
module mc_internal_tap(major=58, pitch=3.0, turns=8, higbee_arc=30) {
    des = mc_metric_designator(major, pitch);
    tap(des, turns=turns, higbee_arc=higbee_arc);
}
