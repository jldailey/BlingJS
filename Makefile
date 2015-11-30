# JAVA=/usr/lib/jvm/java-6-sun/bin/java
DIST=dist
PLUGINS=plugins
COFFEE=node_modules/.bin/coffee
UGLIFY=node_modules/.bin/uglifyjs
UGLIFY_OPTS?=--screw-ie8
JLDOM=node_modules/jldom
MOCHA=node_modules/.bin/mocha
MOCHA_FMT?=dot
MOCHA_OPTS=--compilers coffee:coffee-script/register --globals document,window,Bling,$$,_ -R ${MOCHA_FMT} -s 500 --bail

TEST_FILES=$(shell ls test/*.coffee | grep -v setup.coffee | sort -f )
TIME_FILES=$(subst .coffee,.coffee.time,$(shell ls bench/*.coffee | grep -v setup.coffee | sort -f ))

all: release report

release: $(DIST)/bling.js $(DIST)/min.bling.js $(DIST)/min.bling.js.gz

test: $(JLDOM) $(MOCHA) $(DIST)/bling.js $(TEST_FILES)
	@echo "All tests are passing."

test/bling.coffee: bling.coffee
	# Testing $<
	@$(MOCHA) $(MOCHA_OPTS) $@ && touch $@

test/%.coffee: plugins/%.coffee bling.coffee
	# Testing $<
	@$(MOCHA) $(MOCHA_OPTS) $@ && touch $@

bench: dist $(TIME_FILES)
	@echo "All benchmarks are complete."
	@cat bench/*.time

bench/%.coffee.time: bench/%.coffee plugins/%.coffee bench/setup.coffee bling.coffee Makefile
	@echo Running $<
	@$(COFFEE) $< > $@

site: dist/bling.js test
	@git stash save &> /dev/null
	@git checkout site
	@sleep 1
	@git show master:dist/bling.coffee > js/bling.coffee
	@git show master:dist/bling.js > js/bling.coffee
	@git show master:dist/bling.js.map > js/bling.coffee
	@(cd js && ../node_modules/.bin/uglifyjs bling.js -c --source-map bling.min.js.map --in-source-map bling.js.map  -m -r '$,Bling,window,document' --screw-ie8 -o bling.min.js)
	@(cd js && gzip -f9c bling.min.js > bling.min.js.gz)
	@git add -f js/bling* js/package.json
	@git commit -am "make site" || true
	@sleep 1
	@echo git checkout master
	@sleep 1
	@echo git stash pop || true

$(DIST)/min.%.js: $(DIST)/%.js $(UGLIFY)
	@echo Minifying $< to $@...
	$(UGLIFY) $< -c --source-map $@.map --source-map-url $(subst dist/,,$@).map -m -r '$,Bling,window,document' $(UGLIFY_OPTS) -o $@

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

clean:
	rm -rf $(DIST)/*

$(MOCHA):
	npm install mocha

$(COFFEE):
	npm install coffee-script

$(JLDOM):
	npm install jldom

$(UGLIFY):
	npm install uglifyjs

.PHONY: all bling clean release site test
