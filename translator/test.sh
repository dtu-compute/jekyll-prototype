#!/bin/bash

# Examples
# ./test.sh ../website-raw/01005/EU10S-OPG.md

ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

enote_md_filename=$1

filename=$(basename $enote_md_filename .md)
echo "Processing file '$filename'"

ruby $ROOT/preprocess_enote_md.rb $enote_md_filename > /tmp/$filename.md

pandoc -s -f markdown+smart /tmp/$filename.md -t asciidoc -o /tmp/$filename.adoc

ruby $ROOT/adoc_to_enote_adoc.rb /tmp/$filename.adoc >  $filename.adoc

asciidoctor -r ./lib/asciidoctor-dtu-enote.rb $filename.adoc

#rm /tmp/$filename.adoc
