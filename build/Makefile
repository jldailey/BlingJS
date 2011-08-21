# JAVA=/usr/lib/jvm/java-6-sun/bin/java
JAVA=$(shell which java)
LEVEL=SIMPLE_OPTIMIZATIONS
# LEVEL=ADVANCED_OPTIMIZATIONS
# LEVEL=WHITESPACE_ONLY
DIST=../dist
PLUGINS=../plugins
DIST_PLUGINS=$(DIST)/plugins
TEMP:=$(shell mktemp /tmp/blingjs.XXXXXX)

all: dist report

minify: min.bling.js min.bling.js.gz

clean:
	rm -f $(DIST)/*.js

dist: $(DIST)/bling.js $(DIST)/min.bling.js $(DIST)/min.bling.js.gz

site:
	cd .. \
	&& git stash save &> /dev/null \
	&& git checkout site \
	&& cp dist/*.js js \
	&& git show master:bling.coffee > $(TEMP) \
	&& cp $(TEMP) js/bling.coffee \
	&& rm $(TEMP) \
	&& git commit js -m "build" &> /dev/null || true \
	&& git checkout master \
	&& git stash pop &> /dev/null
	git status

publish:
	git stash save \
	&& git checkout site \
	&& git push origin site \
	&& git checkout master \
	&& git stash pop || true

plugins: $(subst $(PLUGINS),$(DIST_PLUGINS),$(shell ls ../plugins/*))

dist_plugins: plugins
	cp $(PLUGINS)/*.js $(DIST_PLUGINS)

$(DIST_PLUGINS)/%.coffee: $(PLUGINS)/%.coffee
	cp $< $@

$(DIST_PLUGINS)/%.js: $(DIST_PLUGINS)/%.coffee
	(cd $(DIST_PLUGINS) && coffee -c $<)

$(DIST)/bling.js: ../bling.coffee
	cd .. && coffee -o dist -c bling.coffee

compiler-latest.zip:
	@wget http://closure-compiler.googlecode.com/files/compiler-latest.zip

compiler.jar: compiler-latest.zip
	@unzip -o compiler-latest.zip compiler.jar
	@touch compiler.jar

$(DIST)/min.%.js: $(DIST)/%.js compiler.jar
	$(JAVA) -jar compiler.jar --js=$< --js_output_file=$@ --compilation_level=$(LEVEL) --externs externs

%.gz: %
	gzip -vf9c $< > $@

report:
	@cd $(DIST) && wc -c `ls *.js *.gz | sort` | grep -v total | grep -v externs.js
