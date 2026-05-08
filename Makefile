.PHONY: dev-deps diagrams check help

D2_FILES := $(wildcard docs/diagrams/*.d2)
SVG_FILES := $(D2_FILES:.d2=.svg)

help:
	@echo "Targets:"
	@echo "  dev-deps   Install developer dependencies (d2 via Homebrew)"
	@echo "  diagrams   Re-render every docs/diagrams/*.d2 to .svg"
	@echo "  check      Verify d2 is on PATH"

dev-deps:
	@command -v d2 >/dev/null 2>&1 || brew install d2
	@command -v d2 >/dev/null 2>&1 && echo "d2 ready: $$(d2 --version 2>/dev/null || echo installed)"

check:
	@command -v d2 >/dev/null 2>&1 || { echo "d2 not on PATH — run 'make dev-deps'"; exit 1; }
	@echo "d2 ready"

diagrams: check
	@for f in $(D2_FILES); do \
	  echo "  rendering $$f"; \
	  d2 "$$f" "$${f%.d2}.svg"; \
	done
	@echo "diagrams up to date"

%.svg: %.d2
	d2 $< $@
