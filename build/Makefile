
JAVA=/usr/lib/jvm/java-6-sun/bin/java
LEVEL=SIMPLE_OPTIMIZATIONS
# LEVEL=ADVANCED_OPTIMIZATIONS
# LEVEL=WHITESPACE_ONLY

all: pack minify report

minify: min.bling.js min.bling.js.gz

pack: pack.bling.js.gz

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

bling.js: ../bling.js
	cp ../bling.js bling.js

sizzle.js: ../plugins/sizzle.js
	cp ../plugins/sizzle.js sizzle.js

../bling.js: ../bling.coffee
	cd .. && coffee -c bling.coffee

pack.%.js: %.js packer/jsPacker.pl
	cd packer && perl jsPacker.pl -i ../$< -o ../$@

min.%.js: %.js compiler.jar
	$(JAVA) -jar compiler.jar --js=$< --js_output_file=$@ --warning_level=VERBOSE --compilation_level=$(LEVEL) --externs externs.js

%.js.gz: %.js
	gzip -vf9c $< > $@

report:
	@wc -c `ls *.js *.gz | sort` | grep -v total | grep -v externs.js
