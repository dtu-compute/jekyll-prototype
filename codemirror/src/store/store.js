
class Store {
  constructor () {
    this.state = {
      editorText: 'this is the editor text',
      previewText: 'this is the preview text'
    };
  }

  updatePreviewText (newText) {
    this.state.previewText = newText;
  }
}

const store = new Store();

export default store;
