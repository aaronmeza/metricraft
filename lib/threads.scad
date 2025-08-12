// lib/threads.scad — Metricraft adapter (minimal) around adrianschlatter/threadlib
// License: BSD-3-Clause (wrapper), threadlib under 3-clause BSD.

include <threadlib/threadlib.scad>  // resolved via OPENSCADPATH

function mc_metric_designator(major, pitch) = str("M", major, "x", pitch);

// External thread generator (threads only)
module mc_external_thread(major=58, pitch=3.0, turns=8, higbee_arc=20, fn=120) {
    thread(str(mc_metric_designator(major, pitch), "-ext"),
           turns=turns, higbee_arc=higbee_arc, fn=fn);
}

// Internal tapped cavity (subtractive)
module mc_internal_tap(major=58, pitch=3.0, turns=8, higbee_arc=20, fn=120) {
    tap(mc_metric_designator(major, pitch),
        turns=turns, higbee_arc=higbee_arc, fn=fn);
}
