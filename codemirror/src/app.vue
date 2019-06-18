<template>
  <div class="full-width center-content combined-container">
    <div class="editor-container">
      <code-mirror-component />
    </div>
    <div class="previewer-container">
      <ascii-doc-previewer-component :preview-text="previewText" />
    </div>
  </div>
</template>

<script>
import CodeMirrorComponent from './components/CodeMirrorComponent.vue';
import AsciiDocPreviewerComponent from './components/AsciiDocPreviewerComponent.vue';
// import store from './store/store';

export default {
  components: {
    CodeMirrorComponent,
    AsciiDocPreviewerComponent
  },

  props: {
    previewText: { type: String, default: () => 'NOTATHING2' }
  },

  data: function () {
    return {};
  }
};
</script>

<style lang="scss" scoped>
  .combined-container {
    display: flex;
    flex-direction: row;
  }
  .editor-container, .previewer-container {
    width:50%;
    height:100%;
  }
</style>
