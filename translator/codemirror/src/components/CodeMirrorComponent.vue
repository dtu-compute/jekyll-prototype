<template>
  <textarea id="editor" />
</template>

<script>
import CodeMirror from 'codemirror';
import 'codemirror/lib/codemirror.css';
import 'codemirror/theme/monokai.css';
import store from '../store/store';

/* eslint-disable-next-line no-unused-vars */
const CodeMirrorAsciiDoc = require('codemirror-asciidoc');

export default {
  data: function () {
    return {
      model: {},
      editor: null
    };
  },

  mounted: function () {
    console.log('mounted');
    const scope = this;
    let previewUpdateTimer = null;

    this.editor = CodeMirror.fromTextArea(this.$el, {
      lineNumbers: true,
      lineWrapping: true,
      mode: 'asciidoc'
    });

    this.editor.on('change', function (cm) {
      scope.model.text = cm.getValue();

      if (previewUpdateTimer) {
        clearTimeout(previewUpdateTimer);
        previewUpdateTimer = null;
      };

      previewUpdateTimer = setTimeout(() => {
        store.updatePreviewText(scope.model.text);
        previewUpdateTimer = null;
      }, 2000);
    });
  }
};
</script>

<style lang="scss" scoped>
    #editor {
        width: 100%;
        height: 100%;
    }
</style>
