
JAVA=/usr/lib/jvm/java-6-sun/bin/java
LEVEL=SIMPLE_OPTIMIZATIONS
# LEVEL=ADVANCED_OPTIMIZATIONS
# LEVEL=WHITESPACE_ONLY
DIST=../dist

all: dist report

minify: min.bling.js min.bling.js.gz

pack: pack.bling.js.gz

dist: $(DIST)/bling.js $(DIST)/min.bling.js $(DIST)/min.bling.js.gz

$(DIST)/bling.js: ../bling.coffee
	cd .. && coffee -o dist -c bling.coffee

compiler-latest.zip:
	@wget http://closure-compiler.googlecode.com/files/compiler-latest.zip

compiler.jar: compiler-latest.zip
	@unzip -o compiler-latest.zip compiler.jar
	@touch compiler.jar

packer/packer2.perl.zip:
	mkdir -p packer
	cd packer && wget http://deanedwardsoffline.appspot.com/download/packer2.perl.zip && touch packer2.perl.zip

packer/jsPacker.pl: packer/packer2.perl.zip
	cd packer && unzip packer2.perl.zip && touch jsPacker.pl

pack.%.js: %.js packer/jsPacker.pl
	cd packer && perl jsPacker.pl -i ../$< -o ../$@

min.%.js: %.js compiler.jar
	$(JAVA) -jar compiler.jar --js=$< --js_output_file=$@ --compilation_level=$(LEVEL) --externs externs

%.gz: %
	gzip -vf9c $< > $@

report:
	@cd $(DIST) && wc -c `ls *.js *.gz | sort` | grep -v total | grep -v externs.js
