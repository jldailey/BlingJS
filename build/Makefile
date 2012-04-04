# JAVA=/usr/lib/jvm/java-6-sun/bin/java
JAVA=$(shell which java)
LEVEL=SIMPLE_OPTIMIZATIONS
# LEVEL=ADVANCED_OPTIMIZATIONS
# LEVEL=WHITESPACE_ONLY
DIST=../dist
PLUGINS=../plugins
DIST_PLUGINS=$(DIST)/plugins
# TEMP:=$(shell mktemp /tmp/blingjs.XXXXXX)

all: dist report

minify: $(DIST)/min.bling.js $(DIST)/min.bling.js.gz

clean:
	rm -f $(DIST)/*.js
	rm -f $(DIST_PLUGINS)/*.js

dist: $(DIST)/bling.js minify plugin

site: dist
	cd .. \
	&& git stash save &> /dev/null \
	&& git checkout site \
	&& cp dist/*.js js \
	&& cp dist/*.js.gz js \
	&& cp -r dist/plugins js \
	&& git show master:bling.coffee > js/bling.coffee \
	&& git commit js -m "build files" &> /dev/null || true \
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

plugin: plugin_compile plugin_minify

plugin_minify: $(DIST_PLUGINS)/min.lazy.js $(DIST_PLUGINS)/min.pprint.js $(DIST_PLUGINS)/min.template.js $(DIST_PLUGINS)/min.tnet.js $(DIST_PLUGINS)/min.ui.js $(DIST_PLUGINS)/min.all.js

$(DIST_PLUGINS)/min.%.js: $(DIST_PLUGINS)/%.js compiler.jar
	$(JAVA) -jar compiler.jar --js=$< --js_output_file=$@ --compilation_level=$(LEVEL) --externs externs
	
plugin_compile:
	coffee -o $(DIST_PLUGINS) -c $(PLUGINS)/*.coffee
	cat $(DIST_PLUGINS)/*.js > $(DIST_PLUGINS)/all.js

$(DIST)/bling.js: ../bling.coffee
	cd .. && coffee -o dist -c bling.coffee

compiler-latest.zip:
	@curl http://closure-compiler.googlecode.com/files/compiler-latest.zip > compiler-latest.zip

compiler.jar: compiler-latest.zip
	@unzip -o compiler-latest.zip compiler.jar
	@touch compiler.jar

$(DIST)/min.%.js: $(DIST)/%.js compiler.jar
	$(JAVA) -jar compiler.jar --js=$< --js_output_file=$@ --compilation_level=$(LEVEL) --externs externs


%.gz: %
	gzip -vf9c $< > $@

report:
	@cd $(DIST) && wc -c `ls *.js *.gz | sort` | grep -v total | grep -v externs.js

.PHONY: all minify clean dist site publish plugin
