# jekyll-prototype

This is the prototype project for migrating eNote to AsciiDoc.

It consists of 3 major components.
1. In `./translator` you'll find the extensions library code and the eNote-Markdown to eNote-AsciiDoc translator.  This can be used to take eNote 2019 course pages and translate them to AsciiDoc.
2. In `./course-website` you'll find the Jekyll version of the course website.
3. In `./codemirror`  you'll find a prototype of the web editor, using CodeMirror for editing and the eNote-AsciiDoc extensions for rendering a live preview.

The CodeMirror prototype has its own documentation.  For the translator and course website you can find details here.

## Jekyll: Quick Start

### Install dependencies

```
pushd course_website
bundle install
npm install
popd
```

### Optional: Fetch content

You can fetch all the current Markdown files from production or development

```
ssh-add ${HOME}/bin/ssh/enote/ednote_rsa

ssh root@enote-devel3.compute.dtu.dk 'tar -cf - /enote/vol/content | gzip -9'  > ~/enote-vol-content-$(date +"%m-%d-%y").tgz

mkdir content
tar -xzvf ~/enote-vol-content-$(date +"%m-%d-%y").tgz -C content
```

### Transform content

(Assuming the environment variable `$DTU_ENOTE_VOL/content` points to an eNote 2019-style vol content)

This script will transform the 2018 style Markdown files into AsciiDoctor files in the course website's pages folder.

```.env
DTU_ENOTE_VOL=$(pwd) ./translator/translate.sh <course id>
```

### Run the Server

```
cd course_website
npm run start
```

This will start the server at `http://127.0.0.1:4000/`.

The tests can be found [here](https://127.0.0.1:4000/tests/index.html).

The translated files can be found [here](https://127.0.0.1:4000/pages/translated/01005/FU06S-OPG.html) (depending on the course(s) you've translated).

## What's Included in the Prototype

* AsciiDoctor with basic DTU AsciiDoc extensions (question/hint/answer, podcast link, etc...)
* LaTeX rendering for the website (not CodeMirror)

## What's not Included in the Prototype

* Menu or index pages
* Any of the non-static parts of the website (e.g. admin, authentication, etc...)
* Dependency-based rebuild (e.g. rebuilding page if included LaTeX changes, or if link to another page disappears, etc...)




