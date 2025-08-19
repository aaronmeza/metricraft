// style-map.scad
module flange(style) {
  if (style == "heptachord") heptachord_flange();
  else if (style == "dragoncrest") dragoncrest_flange();
  else assert(false, "unknown style");
}

module core(style) { /* decorations minimal; common geometry */ }
module cover(style) { /* decorations per style if any */ }

module cam_flange2core(style) { cam_base(); }     // cams usually style-agnostic
module cam_cover2flange(style) { cam_base(); }

module heptachord_flange() { /* the vertex-mid pattern */ }
module dragoncrest_flange() { /* geometric dragon pattern */ }
module cam_base() { /* shared cam geometry */ }
