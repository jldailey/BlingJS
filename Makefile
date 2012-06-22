all:

test: all
	for i in tests/bling.coffee; do coffee $$i; done

%:
	@make -C build $@

