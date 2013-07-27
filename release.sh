#!/bin/sh

echo Making new release: $2 from current release: $1...

sed -i .bak -e "s/$1/$2/" package.json && \
	rm package.json.bak && \
	git commit package.json -m "v$2" && \
	make site && \
	git push && \
	git push github && \
	npm publish
