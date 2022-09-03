<template>
  <div id="app">
    <app-navbar/>
    <router-view/>
  </div>
</template>
<script>
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
<style lang="scss">
$theme-colors: (
  "primary": rgb(0, 150, 147),
  "danger": #ff4136
);

// Import Bootstrap and BootstrapVue source SCSS files
@import '~bootstrap/scss/bootstrap.scss';
@import '~bootstrap-vue/src/index.scss';

::-webkit-scrollbar {
  color-scheme: dark;
}

body, .close {
  color: var(--light);
}

#app, html {
  background-color: rgb(29, 32, 33);
}

.form-control, .form-control:focus {
  background-color: rgb(29, 32, 33);
  color: var(--light);
}

.form-control:disabled {
  background-color: #4a5255;
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

.sticky-top {
  z-index: 999 !important;
}

.navbar {
  padding: 0 10px;
}

</style>