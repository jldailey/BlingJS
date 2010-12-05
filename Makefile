
JAVA=/usr/lib/jvm/java-6-sun/bin/java
LEVEL=SIMPLE_OPTIMIZATIONS
# LEVEL=ADVANCED_OPTIMIZATIONS
# LEVEL=WHITESPACE_ONLY

all: minify

minify: content/min.bling.js content/min.bling.js.gz report

compiler-latest.zip:
	@wget http://closure-compiler.googlecode.com/files/compiler-latest.zip

compiler.jar: compiler-latest.zip
	@unzip -o compiler-latest.zip compiler.jar

content/min.bling.js: bling.js compiler.jar
	$(JAVA) -jar compiler.jar --js=bling.js --js_output_file=content/min.bling.js --warning_level=VERBOSE --compilation_level=$(LEVEL)

content/min.bling.js.gz: content/min.bling.js
	@gzip -f9c content/min.bling.js > content/min.bling.js.gz

report:
	@wc -c bling.js content/min.bling.js content/min.bling.js.gz | grep -v total
