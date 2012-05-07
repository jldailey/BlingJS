all:

test: all
	for i in tests/bling.coffee; do coffee $$i; done

docs: docs/bling.html

docs/bling.html: bling.coffee
	docco bling.coffee

%:
	make -C build $@

.PHONY: docs
