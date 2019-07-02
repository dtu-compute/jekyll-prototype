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
      return this.asciidoctor.convert(this.previewText, { 'extension_registry': this.registry });
    }
  },

  created: function () {
    this.asciidoctor = Asciidoctor();
    this.registry = this.asciidoctor.Extensions.create();
    /* eslint-disable-next-line no-unused-vars */
    const dtuExtension = require('./dtu-enote-asciidoctor-extensions.js');
    // dtuExtension(this.registry);
    // require('./lorem.js')(this.registry);
  },

  mounted: function () {
  },

  updated: function () {
    Exercise.replaceHints();
  }
};
</script>

<style lang="scss" scoped>
    #preview {
        width: 100%;
        height: 100%;
    }
</style>
