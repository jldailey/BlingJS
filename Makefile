
JAVA=/usr/lib/jvm/java-6-sun/bin/java
LEVEL=SIMPLE_OPTIMIZATIONS
# LEVEL=ADVANCED_OPTIMIZATIONS
# LEVEL=WHITESPACE_ONLY

# location to store built files
BUILD=./build

all: minify

minify: $(BUILD)/min.bling.js content/min.bling.js.gz report

$(BUILD)/compiler-latest.zip:
	@(cd $(BUILD) && wget http://closure-compiler.googlecode.com/files/compiler-latest.zip)

$(BUILD)/compiler.jar: $(BUILD)/compiler-latest.zip
	@(cd $(BUILD) && unzip -o compiler-latest.zip compiler.jar)

$(BUILD)/min.bling.js: bling.js compiler.jar
	(cd $(BUILD) && $(JAVA) -jar compiler.jar --js=../bling.js --js_output_file=min.bling.js --warning_level=VERBOSE --compilation_level=$(LEVEL))

$(BUILD)/min.bling.js.gz: content/min.bling.js
	@(cd $(BUILD) && gzip -f9c min.bling.js > min.bling.js.gz)

report:
	@wc -c bling.js $(BUILD)/min.bling.js $(BUILD)/min.bling.js.gz | grep -v total
