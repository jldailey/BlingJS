# JAVA=/usr/lib/jvm/java-6-sun/bin/java
JAVA=$(shell which java)
DIST=dist
PLUGINS=plugins
YUI_VERSION=2.4.7
COFFEE=node_modules/.bin/coffee
JLDOM=node_modules/jldom
MOCHA=node_modules/.bin/mocha
MOCHA_FMT=spec
MOCHA_OPTS=--compilers coffee:coffee-script/register --globals document,window,Bling,$$,_ -R ${MOCHA_FMT} -s 500 --bail
WATCH="coffee watch.coffee"

TEST_FILES=$(shell ls test/*.coffee | grep -v setup.coffee | sort )
PASS_FILES=$(subst .coffee,.coffee.pass,$(shell ls test/*.coffee | grep -v setup.coffee | sort ))
TIME_FILES=$(subst .coffee,.coffee.time,$(shell ls bench/*.coffee | grep -v setup.coffee | sort ))


all: dist report

watch: dist
	coffee watch.coffee -v -i -- '.coffee$$' -- make test

dist: $(DIST)/bling.js $(DIST)/min.bling.js $(DIST)/min.bling.js.gz

test: dist $(PASS_FILES)
	@echo "All tests are passing."

test/bling.coffee.pass: test/bling.coffee bling.coffee
	# @echo Running $<
	@$(MOCHA) $(MOCHA_OPTS) $< && touch $@

test/%.coffee.pass: test/%.coffee plugins/%.coffee bling.coffee
	@echo Running $<
	@$(MOCHA) $(MOCHA_OPTS) $< && touch $@

bench: dist $(TIME_FILES)
	@echo "All benchmarks are complete."
	@cat bench/*.time

bench/%.coffee.time: bench/%.coffee plugins/%.coffee test/%.coffee.pass bench/setup.coffee bling.coffee Makefile
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
	@git show master:$(DIST)/bling.map > js/bling.map
	@git show master:package.json > js/package.json
	@git show master:test/html/dialog.html | sed 's@../../dist/bling@/js/bling@' > test/dialog.html
	@git commit -am "make site" || true
	@sleep 1
	@git checkout master
	@sleep 1
	@git stash pop || true

$(DIST)/min.%.js: $(DIST)/%.js yuicompressor.jar
	@echo Minifying $< to $@...
	@$(JAVA) -jar yuicompressor.jar $< -o $@

$(DIST)/%.js: $(DIST)/%.coffee $(COFFEE)
	@echo Compiling $< to $@...
	@(cd $(DIST) && ../$(COFFEE) -cm $(subst $(DIST)/,,$<))

$(DIST)/bling.coffee: bling.coffee $(shell ls $(PLUGINS)/*.coffee | sort)
	@echo Packing plugins into $@...
	@cat $^ | sed -E 's/^	*#.*$$//g' | grep -v '^ *$$' > $@

yuicompressor.jar:
	@echo Downloading $@...
	@curl http://yui.zenfs.com/releases/yuicompressor/yuicompressor-$(YUI_VERSION).zip > yuicompressor.zip
	@unzip yuicompressor.zip
	@rm yuicompressor.zip
	@cp yuicompressor-$(YUI_VERSION)/build/yuicompressor-$(YUI_VERSION).jar ./yuicompressor.jar
	@rm -rf yuicompressor-$(YUI_VERSION)

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


.PHONY: all bling clean dist site test
