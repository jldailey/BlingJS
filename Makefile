all: minify

minify: content/min.bling.js content/min.bling.js.gz report

content/min.bling.js: bling.js
	./jsc_compile.py bling.js content/min.bling.js

content/min.bling.js.gz: content/min.bling.js
	gzip -f9c content/min.bling.js > content/min.bling.js.gz

report:
	wc bling.js content/min.bling.js content/min.bling.js.gz
