# Rebuild DECISIONS.md whenever a decision file changes
DECISION_FILES := $(shell ls -1 docs/decisions/*.md 2>/dev/null || true)

.PHONY: decisions-index
decisions-index: docs/DECISIONS.md
	@echo "Updated docs/DECISIONS.md"

docs/DECISIONS.md: $(DECISION_FILES) Makefile
	@set -e; \
	outfile=docs/DECISIONS.md.tmp; \
	echo "# DECISIONS Index" > $$outfile; \
	echo "" >> $$outfile; \
	echo "Canonical index of design/engineering decisions. Individual decisions live in \`/docs/decisions/YYYY-MM-DD-<slug>.md\`." >> $$outfile; \
	echo "" >> $$outfile; \
	echo "## Log" >> $$outfile; \
	if ls docs/decisions/*.md >/dev/null 2>&1; then \
		for f in $$(ls -1 docs/decisions/*.md | LC_ALL=C sort); do \
			slug=$$(basename "$$f" .md); \
			date=$$(echo "$$slug" | cut -d- -f1-3); \
			title=$$(grep -m1 '^# ' "$$f" | sed 's/^# *//'); \
			[ -z "$$title" ] && title=$$(echo "$$slug" | sed 's/^[0-9-]*-//; s/-/ /g'); \
			printf -- "- %s — %s — [decisions/%s.md](decisions/%s.md)\n" "$$date" "$$title" "$$slug" "$$slug" >> $$outfile; \
		done; \
	else \
		echo "- (none yet)" >> $$outfile; \
	fi; \
	mv $$outfile docs/DECISIONS.md


.PHONY: docs-templates-check
docs-templates-check:
	@[ -f docs/templates/adr.md ] || (echo "missing: docs/templates/adr.md" && exit 1)
	@[ -f docs/templates/changelog.md ] || (echo "missing: docs/templates/changelog.md" && exit 1)
	@[ -f docs/templates/readme.md ] || (echo "missing: docs/templates/readme.md" && exit 1)
	@[ -f docs/templates/release-checklist.md ] || (echo "missing: docs/templates/release-checklist.md" && exit 1)
	@echo "docs templates: OK"
