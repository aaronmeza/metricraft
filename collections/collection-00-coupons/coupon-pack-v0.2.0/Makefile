# coupon-pack v0.2.0 build helpers
OPENSCAD ?= openscad
SRC := src/coupon_pack.scad

OUT_STL := stls
PARTS := xy_ladder hole_gauge snapfit dovetail_gauge readme

.PHONY: all stls plate-p1s plate-220 clean

all: stls

stls: $(PARTS:%=$(OUT_STL)/%.stl)

$(OUT_STL)/%.stl: $(SRC)
	@mkdir -p $(OUT_STL)
	$(OPENSCAD) -o $@ -D part=\"$*\" $<

plate-p1s: $(SRC)
	@mkdir -p $(OUT_STL)
	$(OPENSCAD) -o $(OUT_STL)/plate-p1s.stl -D part=\"all\" $<

plate-220: $(SRC)
	@mkdir -p $(OUT_STL)
	$(OPENSCAD) -o $(OUT_STL)/plate-220.stl -D part=\"all_220\" $<

clean:
	rm -rf $(OUT_STL)
