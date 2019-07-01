#!/bin/bash

# Examples
# ./test.sh ../content/01005/pages/EU10S-OPG.md
# ./test.sh ../content/01005/pages/EU12S-DO.md

ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

enote_md_filename=$1

filename=$(basename $enote_md_filename .md)
source_dir=$(dirname $enote_md_filename)
echo "Processing file '$filename'"

ruby $ROOT/preprocess_enote_md.rb ${enote_md_filename} > $filename.pp.md

pandoc -s -f markdown+smart ${filename}.pp.md -t asciidoc -o /tmp/${filename}.adoc

ruby ${ROOT}/adoc_to_enote_adoc.rb /tmp/${filename}.adoc >  ${filename}.adoc

cp ${source_dir}/*.tex .

asciidoctor -r ./lib/asciidoctor-dtu-enote.rb ${filename}.adoc

#rm /tmp/$filename.adoc
