all:

test:
	for i in `ls tests/*.coffee`; do coffee $$i; done

%:
	make -C build $@
