// lib/threads.scad — Metricraft adapter (compat override)
use <threadlib/threadlib.scad>    // resolved via OPENSCADPATH

// ---- COMPAT OVERRIDE for 2025 OpenSCAD ----
// Replace threadlib's named-arg `search()` with positional args.
// Same behavior, but avoids the parser quirk.
function thread_specs(designator, tbl=THREAD_TABLE) =
    let (
        idx   = search([designator], tbl, 1, 0)[0],
        specs = tbl[idx][1]
    )
    assert(!is_undef(specs), str("Designator: '", designator, "' not found")) specs;

// ---- Our thin adapters ----
function mc_metric_designator(major, pitch) = str("M", major, "x", pitch);

module mc_external_thread(major=58, pitch=3.0, turns=8, higbee_arc=20, fn=120) {
    thread(str(mc_metric_designator(major, pitch), "-ext"),
           turns=turns, higbee_arc=higbee_arc, fn=fn);
}

module mc_internal_tap(major=58, pitch=3.0, turns=8, higbee_arc=20, fn=120) {
    tap(mc_metric_designator(major, pitch),
        turns=turns, higbee_arc=higbee_arc, fn=fn);
}
