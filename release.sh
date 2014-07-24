#!/bin/sh

if [ -z "$2" ]; then
	exit 0
fi

echo Making new release: $2 from current release: $1... && \
	echo Patching package.json && \
	sed -i.bak -e "s/$1/$2/" package.json && \
	rm package.json.bak && \
	echo Committing package.json && \
	git commit package.json -m "v$2" &> /dev/null && \
	echo Publishing to npm && \
	npm publish
