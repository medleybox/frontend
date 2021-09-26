<template>
  <div id="app">
    <app-navbar/>
    <router-view/>
  </div>
</template>
<script>
import 'bootstrap/dist/css/bootstrap.css';
import 'bootstrap-vue/dist/bootstrap-vue.css';
import AppNavbar from "./components/AppNavbar.vue"

import { Component, Vue } from 'vue-property-decorator';

@Component({
  components: {
    'app-navbar': AppNavbar 
  },
})
export default class App extends Vue {
}
</script>
<style>
::-webkit-scrollbar {
    color-scheme: dark;
}

body, .close {
  color: white;
}

#app, html {
  background-color: rgb(29, 32, 33);
}

.form-control, .form-control:focus {
  background-color: rgb(29, 32, 33);
  color: white;
}

.card, .modal-content {
  background-color: #111111;
}

.modal-content {
  min-height: 150px;
}

.modal-title {
  color: var(--primary);
}

</style>