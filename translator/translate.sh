#!/bin/bash
# bulk translate from 2018 Markdown style pages to 2019 asciidoc+enote extensions

ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

find ./website-raw/01005 -iname '*.md' -print | while read pathname; do
	filename=$(basename $pathname .md)
	echo "Processing file '$filename'"

	cat << EOF >front_matter
---
layout: page
title:  "${filename}"
date:  $(stat -f '%Sc' -t '%Y-%m-%d %H:%M:%S %z' ${pathname})
---
EOF

    ruby $ROOT/preprocess_enote_md.rb $pathname > /tmp/$filename.md

	pandoc -s -f markdown+smart /tmp/$filename.md -t asciidoc -o $filename.adoc

	ruby $ROOT/adoc_to_enote_adoc.rb $filename.adoc >  $filename.adoc+enote

#	prefix=$(date '+%Y-%m-%d-')
#	cat front_matter $filename.adoc > ./course_website/_pages/$prefix$filename.adoc

	cat front_matter $filename.adoc+enote > ./course_website/_pages/$filename.adoc

    rm /tmp/$filename.md
	rm $filename.adoc
	rm $filename.adoc+enote
done
