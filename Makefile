# JAVA=/usr/lib/jvm/java-6-sun/bin/java
DIST=dist
PLUGINS=plugins
COFFEE=node_modules/.bin/coffee
UGLIFY=node_modules/.bin/uglifyjs
JLDOM=node_modules/jldom
MOCHA=node_modules/.bin/mocha
MOCHA_FMT=spec
MOCHA_OPTS=--compilers coffee:coffee-script/register --globals document,window,Bling,$$,_ -R ${MOCHA_FMT} -s 500 --bail

TEST_FILES=$(shell ls test/*.coffee | grep -v setup.coffee | sort -f )
TIME_FILES=$(subst .coffee,.coffee.time,$(shell ls bench/*.coffee | grep -v setup.coffee | sort -f ))


all: dist report

dist: $(DIST)/bling.js $(DIST)/min.bling.js $(DIST)/min.bling.js.gz

test: dist $(TEST_FILES)
	@echo "All tests are passing."

test/bling.coffee: bling.coffee
	@echo Running $@
	@$(MOCHA) $(MOCHA_OPTS) $@ && touch $@

test/%.coffee: plugins/%.coffee bling.coffee
	@echo Running $@
	@$(MOCHA) $(MOCHA_OPTS) $@ && touch $@

bench: dist $(TIME_FILES)
	@echo "All benchmarks are complete."
	@cat bench/*.time

bench/%.coffee.time: bench/%.coffee plugins/%.coffee test/%.coffee bench/setup.coffee bling.coffee Makefile
	@echo Running $<
	@$(COFFEE) $< > $@

site: test
	@git stash save &> /dev/null
	@git checkout site
	@sleep 1
	@cp $(DIST)/*.js js
	@cp $(DIST)/*.js.gz js
	@git show master:$(DIST)/bling.coffee > js/bling.coffee
	@git show master:$(DIST)/bling.js > js/bling.js
	@git show master:$(DIST)/bling.js.map > js/bling.js.map
	@git show master:package.json > js/package.json
	@git commit -am "make site" || true
	@sleep 1
	@git checkout master
	@sleep 1
	@git stash pop || true

$(DIST)/min.%.js: $(DIST)/%.js $(UGLIFY)
	@echo Minifying $< to $@...
	$(UGLIFY) $< -c --source-map $@.map --source-map-url $(subst dist/,,$@).map -m -r '$,Bling,window,document' -o $@

$(DIST)/%.js: $(DIST)/%.coffee $(COFFEE)
	@echo Compiling $< to $@...
	@(cd $(DIST) && ../$(COFFEE) -cm $(subst $(DIST)/,,$<))

$(DIST)/bling.coffee: bling.coffee $(shell ls $(PLUGINS)/*.coffee | sort -f)
	@echo Packing plugins into $@...
	@cat $^ | sed -E 's/^	*#.*$$//g' | grep -v '^ *$$' > $@

%.gz: %
	@echo Compressing $< to $@...
	@gzip -f9c $< > $@

report:
	@cd $(DIST) && wc -c `ls *.coffee *.js *.gz | sort -n` | grep -v total

clean-test:
	rm -f test/pass test/*.pass
	
clean: clean-test
	rm -rf $(DIST)/*
	rm -rf yuicompressor.zip yuicompressor.jar yuicompressor-$(YUI_VERSION)

$(MOCHA):
	npm install mocha

$(COFFEE):
	npm install coffee-script

$(JLDOM):
	npm install jldom

$(UGLIFY):
	npm install uglifyjs

.PHONY: all bling clean dist site test
