const fs = require('fs');
const Builder = require('opal-compiler').Builder;
// Opal object will be available on the global scope

const builder = Builder.create();
builder.appendPaths('lib'); // (1)
const result = builder.build('lib/qha-block-processor/extension.rb'); // (2)
fs.writeFileSync('dtu-enote-asciidoctor-extensions.js', result.toString(), 'utf8');
