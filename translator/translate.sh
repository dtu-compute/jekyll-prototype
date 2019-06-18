#!/bin/bash

# bulk translate from 2018 Markdown style pages to 2019 asciidoc+enote extensions

ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

find ./course_website/_pages/. -type f -name '*.adoc' -delete
find ./course_website/_pages/. -type f -name '*.tex' -delete

COURSE=${1:-01005}
#COURSE=${1:-00000}

mkdir -p ./course_website/_pages/translated/${COURSE}

cp ${DTU_ENOTE_VOL}/content/${COURSE}/pages/macros.tex ./course_website/_pages/translated/${COURSE}

find ${DTU_ENOTE_VOL}/content/${COURSE}/pages -iname '*.md' -print | while read pathname; do
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

	cat front_matter $filename.adoc+enote > ./course_website/_pages/translated/${COURSE}/$filename.adoc

  rm /tmp/$filename.md
	rm $filename.adoc
	rm $filename.adoc+enote
done

cp -R ${DTU_ENOTE_VOL}/content/${COURSE}/uploads ./course_website/uploads

# copy the test adocs too

mkdir -p course_website/_pages/tests
cp tests/adocs/*.adoc course_website/_pages/tests
cp tests/adocs/*.tex course_website/_pages/tests
