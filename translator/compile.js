const fs = require('fs');
const util = require('util');
const Builder = require('opal-compiler').Builder;
// Opal object will be available on the global scope

const builder = Builder.create();
builder.appendPaths('lib'); // (1)
// const result = builder.build('lib/qha-block-processor/extension.rb'); // (2)
const result = builder.build('lib/asciidoctor-dtu-enote.rb'); // (2)
util.promisify(fs.writeFile)('dtu-enote-asciidoctor-extensions.js', result.toString(), 'utf8').then(() => console.log('DONE'));

// cp dtu-enote-asciidoctor-extensions.js /Users/iain/Projects/educube/poc-repo/components/educube/components/editor/components/dtu-enote-asciidoctor-extensions.js
