import '../assets/app.scss';
import '../assets/exercises.scss';

import Vue from 'vue';
import App from './App.vue';
import store from './store/store';

/* eslint-disable-next-line no-new */
new Vue({
  el: '#app',
  data: store.state,
  render: function (h) {
    console.log('render');
    return h(App, { props: { previewText: this.previewText } });
  }
});
