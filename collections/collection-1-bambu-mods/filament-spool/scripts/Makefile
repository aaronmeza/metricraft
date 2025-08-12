
# Makefile — filament-spool
VERSION ?= v0.1.0
SCAD    := ../src/filament_spool.scad
OUT     := ../stl
OPENSCAD ?= openscad
PARTS := flange_left flange_right lid_top lid_bottom coupon_threadfit
all: $(PARTS:%=$(OUT)/filament-spool-%-$(VERSION).stl)
$(OUT)/filament-spool-%-$(VERSION).stl: $(SCAD)
	$(OPENSCAD) -o $@ -D part="$*" $(SCAD)
clean:
	rm -f $(OUT)/*.stl
coupon:
	$(OPENSCAD) -o ../stl/filament-spool-coupon-threadfit-$(VERSION).stl \
		-D part="coupon_threadfit" ../src/filament_spool.scad


.PHONY: all clean coupon
