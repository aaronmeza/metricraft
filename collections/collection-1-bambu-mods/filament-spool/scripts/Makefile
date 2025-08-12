
# Makefile — filament-spool
REPO_ROOT := $(shell git rev-parse --show-toplevel)
# Make OpenSCAD find our wrapper and vendor libs no matter the CWD
export OPENSCADPATH := $(REPO_ROOT)/lib:$(REPO_ROOT)/lib/vendor/threadlib:$(REPO_ROOT)/lib/vendor/scad-utils:$(REPO_ROOT)/lib/vendor/list-comprehension-demos:$(REPO_ROOT)/lib/vendor/thread_profile

OPENSCAD ?= openscad
VERSION  ?= v0.1.0
SCAD     := ../src/filament_spool.scad
OUT      := ../stl
PARTS    := flange_left flange_right lid_top lid_bottom coupon_threadfit




all: $(PARTS:%=$(OUT)/filament-spool-%-$(VERSION).stl)

$(OUT)/filament-spool-%-$(VERSION).stl: $(SCAD)
	$(OPENSCAD) --export-format stl -o $@ -D part="$*" $(SCAD)

verify:
	@echo "OPENSCADPATH=$$OPENSCADPATH"
	$(OPENSCAD) --export-format stl -o /tmp/flange_left.stl \
	  -D part="flange_left" ../src/filament_spool.scad
	$(OPENSCAD) --export-format stl -o /tmp/coupon_threadfit.stl \
	  -D part="coupon_threadfit" ../src/filament_spool.scad

clean:
	rm -f $(OUT)/*.stl
.PHONY: all verify clean
