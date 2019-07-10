<template>
  <div>
    <!-- eslint-disable vue/no-v-html -->
    <div
      id="preview"
      readonly
      v-html="previewHtml"
    />
  </div>
</template>

<script>
import Asciidoctor from 'asciidoctor';
import Exercise from '../exercise';
import '@asciidoctor/core/dist/css/asciidoctor.css';

export default {
  props: {
    previewText: { type: String, default: () => 'NOTATHING' }
  },

  data: function () {
    return {
      preview: this.previewText,
      asciidoctor: null
    };
  },

  computed: {
    previewHtml: function () {
      const html = this.asciidoctor.convert(this.previewText, { 'extension_registry': this.registry });
      return html;
    }
  },

  created: function () {
    this.asciidoctor = Asciidoctor();
    this.registry = this.asciidoctor.Extensions.create();
    this.dtuExtensionExtension = require('./dtu-enote-asciidoctor-extensions.js');
    // this.asciiDoctorLatexExtension = require('asciidoctor-latex.js');
    // dtuExtension(this.registry);
    // require('./lorem.js')(this.registry);
  },

  mounted: function () {
  },

  updated: function () {
    this.$nextTick(function () {
      Exercise.replaceHints();
      console.log('queing typeset');
      window.MathJax.Hub.Queue(['Typeset', window.MathJax.Hub]);
    });
  }
};
</script>

<style lang="scss" scoped>
    #preview {
      width: 100%;
      height: 100%;
      max-height: 100vh;
      overflow-y: scroll;
    }
</style>
