all:
	@echo "Targets:"
	@echo " - doc ... convert markdown files to html"

MD = markdown_py
doc:
	@mkdir -p html/
	@for f in *.md; do \
	  $(MD) $$f > html/$$(basename $$f).html ; \
	done
