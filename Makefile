# JAVA=/usr/lib/jvm/java-6-sun/bin/java
JAVA=$(shell which java)
DIST=dist
PLUGINS=plugins
YUI_VERSION=2.4.7
COFFEE=node_modules/.bin/coffee
JLDOM=node_modules/jldom
MOCHA=node_modules/.bin/mocha
MOCHA_OPTS=--compilers coffee:coffee-script --globals document,window,Bling,$$,_ -R dot
TEST_FILES=$(shell ls test/*.coffee | grep -v setup.coffee )

all: dist report

test: dist test/pass
	@echo "All tests are passing."

test/pass: $(MOCHA) $(JLDOM) $(TEST_FILES) test/setup.coffee $(DIST)/bling.coffee
	$(MOCHA) $(MOCHA_OPTS) $(TEST_FILES) && touch test/pass

$(MOCHA):
	npm install mocha

$(COFFEE):
	npm install coffee-script
	sed -ibak -e 's/path.exists/fs.exists/' node_modules/coffee-script/lib/coffee-script/command.js
	rm -f node_modules/coffee-script/lib/coffee-script/command.js.bak

$(JLDOM):
	npm install jldom

dist: $(DIST)/bling.js $(DIST)/min.bling.js $(DIST)/min.bling.js.gz

site: dist
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
	$(JAVA) -jar yuicompressor.jar $< -v -o $@

$(DIST)/%.js: $(DIST)/%.coffee $(COFFEE)
	(cd $(DIST) && ../$(COFFEE) -cm $(subst $(DIST)/,,$<))

$(DIST)/bling.coffee: bling.coffee $(shell ls $(PLUGINS)/*.coffee)
	cat $^ | sed -E 's/^	*#.*$$//g' | grep -v '^ *$$' > $@

yuicompressor.jar:
	curl http://yui.zenfs.com/releases/yuicompressor/yuicompressor-$(YUI_VERSION).zip > yuicompressor.zip
	unzip yuicompressor.zip
	rm yuicompressor.zip
	cp yuicompressor-$(YUI_VERSION)/build/yuicompressor-$(YUI_VERSION).jar ./yuicompressor.jar
	rm -rf yuicompressor-$(YUI_VERSION)

%.gz: %
	gzip -vf9c $< > $@

report:
	@cd $(DIST) && wc -c `ls *.coffee *.js *.gz | sort -n` | grep -v total

clean:
	rm -f test/pass
	rm -rf $(DIST)/*
	rm -rf yuicompressor.zip yuicompressor.jar yuicompressor-$(YUI_VERSION)
	rm -rf node_modules/

.PHONY: all bling clean dist site test
