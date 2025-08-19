# Rebuild DECISIONS.md whenever a decision file changes
DECISION_FILES := $(shell ls -1 docs/decisions/*.md 2>/dev/null || true)


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

.PHONY: decisions-index
decisions-index: docs/DECISIONS.md
	@echo "Updated docs/DECISIONS.md"

.PHONY: docs-templates-check
docs-templates-check:
	@[ -f docs/templates/adr.md ] || (echo "missing: docs/templates/adr.md" && exit 1)
	@[ -f docs/templates/changelog.md ] || (echo "missing: docs/templates/changelog.md" && exit 1)
	@[ -f docs/templates/readme.md ] || (echo "missing: docs/templates/readme.md" && exit 1)
	@[ -f docs/templates/release-checklist.md ] || (echo "missing: docs/templates/release-checklist.md" && exit 1)
	@echo "✓ docs templates: OK"


.PHONY: glossary-check
glossary-check:
	@bash scripts/glossary-check.sh


.PHONY: docs-checks
docs-checks: glossary-check docs-templates-check

# Verify DECISIONS.md is up to date (for CI and local)
.PHONY: check-decisions-index
check-decisions-index:
	@$(MAKE) -s decisions-index
	@# Fail if the index changed during regeneration
	@git diff --quiet -- docs/DECISIONS.md || ( \
	  echo "docs/DECISIONS.md is out of date. Run 'make decisions-index' and commit." >&2; \
	  git --no-pager diff -- docs/DECISIONS.md; \
	  exit 1 )

# Create a new decision file with today's date and a slug: make new-decision SLUG=materials-policy
.PHONY: new-decision
new-decision:
	@[ -n "$(SLUG)" ] || (echo "Usage: make new-decision SLUG=my-decision-slug" >&2; exit 2)
	@d=$$(date +%F); \
	f="docs/decisions/$$d-$(SLUG).md"; \
	test -e "$$f" && { echo "$$f already exists" >&2; exit 3; } || true; \
	echo "# $(SLUG)"                                  > "$$f"; \
	echo ""                                           >> "$$f"; \
	echo "- **Date:** $$d"                            >> "$$f"; \
	echo "- **Status:** Proposed | Accepted | Superseded" >> "$$f"; \
	echo "- **Context:** <why this came up>"          >> "$$f"; \
	echo "- **Decision:** <one clear sentence>"       >> "$$f"; \
	echo "- **Rationale:** <tradeoffs>"               >> "$$f"; \
	echo "- **Links:** </docs/specs/... or PRs>"      >> "$$f"; \
	echo ""                                           >> "$$f"; \
	echo "## Details"                                 >> "$$f"; \
	echo ""                                           >> "$$f"; \
	$(MAKE) -s decisions-index; \
	echo "Created $$f and refreshed DECISIONS.md"

models:
	./scripts/models/export.zsh

web-build:
	( cd web/apps/www && true ) && ( cd web/apps/docs && true )
