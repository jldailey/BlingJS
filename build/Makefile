# JAVA=/usr/lib/jvm/java-6-sun/bin/java
JAVA=$(shell which java)
DIST=../dist
PLUGINS=../plugins
YUI_VERSION=2.4.7

all: dist docs report

bling: $(DIST)/min.bling.js $(DIST)/min.bling.js.gz $(DIST)/bling.coffee

dist: $(DIST)/bling.js bling plugins

docs: $(DIST)/docs/bling.html

site: dist
	cd .. \
	&& git stash save &> /dev/null \
	&& git checkout site \
	&& cp dist/*.js js \
	&& cp dist/*.js.gz js \
	&& git show master:dist/bling.coffee > js/bling.coffee \
	&& git show master:dist/bling.js > js/bling.js \
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

yuicompressor.jar:
	curl http://yui.zenfs.com/releases/yuicompressor/yuicompressor-$(YUI_VERSION).zip > yuicompressor.zip
	unzip yuicompressor.zip
	cp yuicompressor-$(YUI_VERSION)/build/yuicompressor-$(YUI_VERSION).jar ./yuicompressor.jar
	rm -r yuicompressor-$(YUI_VERSION)

$(DIST)/bling.js: $(DIST)/bling.coffee
	coffee -o $(DIST) -c $<

$(DIST)/bling.coffee: ../bling.coffee $(shell ls ../plugins/*.coffee)
	cat $^ | sed -E 's/^	*#.*$$//g' | grep -v '^ *$$' > $@

$(DIST)/min.%.js: $(DIST)/%.js yuicompressor.jar
	$(JAVA) -jar yuicompressor.jar $< -v -o $@

$(DIST)/docs/%.html: ../%.coffee
	(cd $(DIST) && docco $<)

%.gz: %
	gzip -vf9c $< > $@

report:
	@cd $(DIST) && wc -c `ls *.coffee *.js *.gz | sort` | grep -v total

clean:
	rm -rf $(DIST)/*.coffee $(DIST)/*.js $(DIST)/*.gz $(DIST)/docs

.PHONY: all bling clean dist site publish plugins
