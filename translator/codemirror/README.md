# Codemirror with DTU AsciiDoctor preview

## Setup

First step is to compile the DTU asciidoctor extensions using Opal.

```
pushd ..
npm install
npm run compile
cp dtu-enote-asciidoctor-extensions.js codemirror/src/components
popd
```

## Run

```
npm install
npm run serve
```

This will start the server under `http://localhost:8080`. 

It creates a very bare-bones editor/preview page.  The preview updates automatically after a few seconds of no input.

## Prototype

* The prototype *supports* the full AsciiDoctor syntax
* The prototype *supports* the basic question/hint/answer AsciiDoctor extension syntax for DTU, e.g.
```asciidoc
[question]
.....

Opstil det karakteriske polynomium for latexmath:[\mA\,,] og find ved
hjælp af dette egenværdierne for latexmath:[\mA\,.]
.....

[answer]
.....
Egenværdierne er latexmath:[\,3+i\,] og latexmath:[\,3-i\,.]
.....
```  
* The prototype *does not yet support* LaTeX (it's easy to add)

### Notes

Core setup is from:

https://itnext.io/vue-js-and-webpack-4-from-scratch-part-3-3f68d2a3c127
