# JAVA=/usr/lib/jvm/java-6-sun/bin/java
JAVA=$(shell which java)
DIST=dist
PLUGINS=plugins
YUI_VERSION=2.4.7
COFFEE=node_modules/.bin/coffee
DOCCO=node_modules/.bin/docco
JLDOM=node_modules/jldom
MOCHA=node_modules/.bin/mocha
MOCHA_OPTS=--compilers coffee:coffee-script --globals document,window,Bling,$$,_ -R dot

all: dist report

test: dist test/pass
	@echo "All tests passed last time and nothing has changed."

test/pass: $(MOCHA) $(JLDOM) test/bling.coffee $(DIST)/bling.coffee
	$(MOCHA) $(MOCHA_OPTS) test/bling.coffee && touch test/pass

$(MOCHA):
	npm install mocha

$(COFFEE):
	npm install coffee-script
	sed -i .bak 's/path.exists/fs.exists/' node_modules/coffee-script/lib/coffee-script/command.js
	rm -f node_modules/coffee-script/lib/coffee-script/command.js.bak

$(DOCCO):
	npm install docco

$(JLDOM):
	npm install jldom

dist: $(DIST)/bling.js $(DIST)/min.bling.js $(DIST)/min.bling.js.gz

docs: $(DIST)/docs/bling.html

site: dist docs
	git stash save &> /dev/null \
	&& git checkout site \
	&& sleep 1 \
	&& cp $(DIST)/*.js js \
	&& cp $(DIST)/*.js.gz js \
	&& cp $(DIST)/docs/* docs \
	&& git show master:$(DIST)/bling.coffee > js/bling.coffee \
	&& sleep 1 \
	&& git show master:$(DIST)/bling.js > js/bling.js \
	&& sleep 1 \
	&& git commit -a -m "build files" || true \
	&& sleep 1 \
	&& echo '$$.log("' `git log -1 --format="commit:%h @ %ci"` '")' > js/log-build.js \
	&& sleep 1 \
	&& git commit js/log-build.js --amend -m "build annotation" \
	&& sleep 1 \
	&& git checkout master \
	&& sleep 1 \
	&& git stash pop || true \
	&& sleep 1 \
	&& git status

$(DIST)/min.%.js: $(DIST)/%.js yuicompressor.jar
	$(JAVA) -jar yuicompressor.jar $< -v -o $@

$(DIST)/%.js: $(DIST)/%.coffee $(COFFEE)
	$(COFFEE) -o $(DIST) -c $<

$(DIST)/bling.coffee: bling.coffee $(shell ls $(PLUGINS)/*.coffee)
	cat $^ | sed -E 's/^	*#.*$$//g' | grep -v '^ *$$' > $@

yuicompressor.jar:
	curl http://yui.zenfs.com/releases/yuicompressor/yuicompressor-$(YUI_VERSION).zip > yuicompressor.zip
	unzip yuicompressor.zip
	rm yuicompressor.zip
	cp yuicompressor-$(YUI_VERSION)/build/yuicompressor-$(YUI_VERSION).jar ./yuicompressor.jar
	rm -rf yuicompressor-$(YUI_VERSION)

$(DIST)/docs/%.html: %.coffee $(DOCCO)
	(cd $(DIST) && ../$(DOCCO) ../$<)

%.gz: %
	gzip -vf9c $< > $@

report:
	@cd $(DIST) && wc -c `ls *.coffee *.js *.gz | sort -n` | grep -v total

clean:
	rm -f test/pass
	rm -rf $(DIST)/*
	rm -rf yuicompressor.zip yuicompressor.jar yuicompressor-$(YUI_VERSION)
	rm -rf node_modules/

.PHONY: all bling clean dist site plugins test
