#!/bin/bash

ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

find ./website-raw/01005 -iname '*.md' -print | while read line; do
	filename=$(basename $line .md)
	echo "Processing file '$filename'"

	cat << EOF >front_matter
---
layout: post
title:  "${filename}"
date:  $(date '+%Y-%m-%d %H:%M:%S %z')
---
EOF

	prefix=$(date '+%Y-%m-%d-')

	pandoc -s -f markdown+smart $line -t asciidoc -o $filename.adoc

	ruby $ROOT/adoc_to_enote_adoc.rb $filename.adoc >  $filename.adoc+enote

#	cat front_matter $filename.adoc > ./course_website/_pages/$prefix$filename.adoc
	cat front_matter $filename.adoc+enote > ./course_website/_pages/$filename.adoc

	rm $filename.adoc
	rm $filename.adoc+enote
done