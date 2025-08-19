SHELL := /bin/zsh
.SHELLFLAGS := -lc

SCAD := collections/collection-00-coupons/moisture-check/src/moisture-check-v1.0.0.scad
OUT  := collections/collection-00-coupons/moisture-check
STL1 := $(OUT)/stl/01-string-bridge-mast.stl
STL2 := $(OUT)/stl/02-thinwall-tube.stl
PRJ  := $(OUT)/bambu/moisture-check-v1.0.0.3mf

# Detect CLI unless user overrides
BAMBU_CLI ?= $(shell ./scripts/find_bambu_cli.zsh 2>/dev/null || true)

.PHONY: plate-export
plate-export: $(STL1) $(STL2)
ifeq ($(strip $(BAMBU_CLI))),)
	@echo "WARN: Bambu Studio CLI not found. Manually export 3MF to: $(PRJ)"
	@/usr/bin/open -b com.bambulab.BambuStudio --args --export-3mf "$(PRJ)" "$(STL1)" "$(STL2)" || true
else
	@"$(BAMBU_CLI)" --arrange 1 --slice 0 --export-3mf "$(PRJ)" "$(STL1)" "$(STL2)"
endif

$(STL1):
	@openscad -o "$@" -D "string_bridge_mast();" "$(SCAD)"

$(STL2):
	@openscad -o "$@" -D "thinwall_tube();" "$(SCAD)"
