
JAVA=/usr/lib/jvm/java-6-sun/bin/java
LEVEL=SIMPLE_OPTIMIZATIONS
# LEVEL=ADVANCED_OPTIMIZATIONS
# LEVEL=WHITESPACE_ONLY

all: minify

minify: min.bling.js min.bling.js.gz report

compiler-latest.zip:
	@wget http://closure-compiler.googlecode.com/files/compiler-latest.zip

compiler.jar: compiler-latest.zip
	@unzip -o compiler-latest.zip compiler.jar
	@touch compiler.jar

min.bling.js: ../bling.js compiler.jar
	$(JAVA) -jar compiler.jar --js=../bling.js --js_output_file=min.bling.js --warning_level=VERBOSE --compilation_level=$(LEVEL)

min.bling.js.gz: min.bling.js
	@gzip -f9c min.bling.js > min.bling.js.gz

report:
	@wc -c ../bling.js min.bling.js min.bling.js.gz | grep -v total
