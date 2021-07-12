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
.modal-content {
  min-height: 150px;
}
::-webkit-scrollbar {
    color-scheme: dark;
}
</style>