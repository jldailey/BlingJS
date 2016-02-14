COFFEE=node_modules/.bin/coffee
UGLIFY=node_modules/.bin/uglifyjs
UGLIFY_OPTS?=--screw-ie8
JLDOM=node_modules/jldom
MOCHA=node_modules/.bin/mocha
MOCHA_FMT?=dot
MOCHA_OPTS=--compilers coffee:coffee-script/register --globals document,window,Bling,$$,_ -R ${MOCHA_FMT} -s 500 --bail
GPP=gpp
GPP_OPTS=-U '' '' '(' ',' ')' '(' ')' '\#' '' \
	-M '\#' '\n' ' ' ' ' '\n' '(' ')' \
	+c '\# ' '\n' \
	+c '\#\#\#' '\#\#\#' \
	+s '"' '"' "\\" \
	+s "'" "'" "\\" -n

TEST_FILES=$(shell ls test/*.coffee | grep -v setup.coffee | sort -f )
TIME_FILES=$(subst .coffee,.coffee.time,$(shell ls bench/*.coffee | grep -v setup.coffee | sort -f ))

all: release

release: dist/bling.js

test: $(JLDOM) $(MOCHA) dist/bling.js $(TEST_FILES)
	@echo "All tests are passing."

test/bling.coffee: bling.coffee
	# Testing $<
	@$(MOCHA) $(MOCHA_OPTS) $@ && touch $@

test/%.coffee: plugins/%.coffee bling.coffee
	# Testing $<
	@$(MOCHA) $(MOCHA_OPTS) $@ && touch $@

bench: release $(TIME_FILES)
	@echo "All benchmarks are complete."
	@cat bench/*.time

bench/%.coffee.time: bench/%.coffee plugins/%.coffee bench/setup.coffee bling.coffee Makefile
	@echo Running $<
	@$(COFFEE) $< > $@

site: dist/bling.js test $(UGLIFY)
	@git stash save &> /dev/null
	@git checkout site
	@sleep 1
	@cp dist/bling* js/
	@git show master:package.json > js/package.json
	@(cd js \
		&& ../$(UGLIFY) bling.js -c --source-map bling.min.js.map --in-source-map bling.js.map  -m -r '$,Bling,window,document' --screw-ie8 -o bling.min.js \
		&& (gzip -f9c bling.min.js > bling.min.js.gz))
	@git add -f js/bling* js/package.json
	@git commit -am "make site" || true
	@sleep 1
	@echo git checkout master
	@sleep 1
	@echo git stash pop || true

dist/bling.js: dist/bling.coffee $(COFFEE)
	@echo Compiling $< to $@...
	@(cd dist && ../node_modules/.bin/coffee -cm bling.coffee)

dist/bling.coffee: bling.coffee $(shell ls plugins/*.coffee | sort -f)
	@echo Packing plugins into $@...
	@mkdir -p dist
	@cat $^ | sed -E 's/^	*# .*$$//g' | grep -v '^ *$$' | $(GPP) $(GPP_OPTS) > $@

clean:
	rm -rf dist/*

$(MOCHA):
	npm install mocha

$(COFFEE):
	npm install coffee-script

$(JLDOM):
	npm install jldom

$(UGLIFY):
	npm install uglify-js

.PHONY: all bling clean release site test
