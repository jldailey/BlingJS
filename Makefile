# JAVA=/usr/lib/jvm/java-6-sun/bin/java
JAVA=$(shell which java)
COFFEE=./node_modules/coffee-script/bin/coffee
DOCCO=./node_modules/docco/bin/docco
DIST=dist
PLUGINS=plugins
YUI_VERSION=2.4.7

all: dist docs report

test: dist test/passing

test/passing: test/bling.coffee
	$(COFFEE) test/bling.coffee && touch test/passing

dist: $(DIST)/bling.js $(DIST)/min.bling.js $(DIST)/min.bling.js.gz

docs: $(DIST)/docs/bling.html

site: dist
	git stash save &> /dev/null \
	&& git checkout site \
	&& cp $(DIST)/*.js js \
	&& cp $(DIST)/*.js.gz js \
	&& git show master:$(DIST)/bling.coffee > js/bling.coffee \
	&& git show master:$(DIST)/bling.js > js/bling.js \
	&& git commit js -m "build files" || true \
	&& echo '$$.log("' `git log -1 --format="commit:%h @ %ci"` '")' > js/log-build.js \
	&& git commit js/log-build.js --amend -m "build annotation" \
	&& git checkout master \
	&& git stash pop || true \
	git status

publish:
	git stash save \
	&& git checkout site \
	&& git push origin site \
	&& git checkout master \
	&& git stash pop || true

$(DIST)/min.%.js: $(DIST)/%.js yuicompressor.jar
	$(JAVA) -jar yuicompressor.jar $< -v -o $@

$(DIST)/%.js: $(DIST)/%.coffee $(COFFEE)
	$(COFFEE) -o $(DIST) -c $<

$(DIST)/bling.coffee: bling.coffee $(shell ls $(PLUGINS)/*.coffee)
	rm -f test/passing
	cat $^ | sed -E 's/^	*#.*$$//g' | grep -v '^ *$$' > $@

yuicompressor.jar:
	curl http://yui.zenfs.com/releases/yuicompressor/yuicompressor-$(YUI_VERSION).zip > yuicompressor.zip
	unzip yuicompressor.zip
	rm yuicompressor.zip
	cp yuicompressor-$(YUI_VERSION)/build/yuicompressor-$(YUI_VERSION).jar ./yuicompressor.jar
	rm -rf yuicompressor-$(YUI_VERSION)

$(DIST)/docs/%.html: %.coffee $(DOCCO)
	(cd $(DIST) && ../$(DOCCO) $<)

%.gz: %
	gzip -vf9c $< > $@

report:
	@cd $(DIST) && wc -c `ls *.coffee *.js *.gz | sort` | grep -v total

clean:
	rm -rf $(DIST)/*
	rm -rf yuicompressor.zip yuicompressor.jar yuicompressor-$(YUI_VERSION)

.PHONY: all bling clean dist site publish plugins test
