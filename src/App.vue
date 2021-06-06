<template>
  <div id="app">
    <div id="nav">
      <router-link to="/">Home</router-link> |
      <a href="/admin">Admin</a> |
      <a href="/logout">Logout</a> |
    </div>
    <router-view/>
  </div>
</template>
<script>
import 'bootstrap/dist/css/bootstrap.css';
import 'bootstrap-vue/dist/bootstrap-vue.css';

import { Vue } from 'vue-property-decorator';
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