<template>
  <b-navbar toggleable="lg" type="dark" variant="primary">
      <b-navbar-brand>MedleyBox</b-navbar-brand>
      <b-navbar-toggle target="nav-collapse"></b-navbar-toggle>
      <b-collapse id="nav-collapse" is-nav>
        <b-navbar-nav>
          <b-nav-item to="/" exact exact-active-class="active">Home</b-nav-item>
          <b-nav-item href="/admin">Admin</b-nav-item>
          <b-nav-item href="/logout">Logout</b-nav-item>
        </b-navbar-nav>
        <!-- Right aligned nav items>
        <b-navbar-nav class="ml-auto">
          <b-nav-item-dropdown right>
            <template #button-content>
              <em>User</em>
            </template>
            <b-dropdown-item href="#">Profile</b-dropdown-item>
            <b-dropdown-item href="#">Sign Out</b-dropdown-item>
          </b-nav-item-dropdown>
        </b-navbar-nav -->
      </b-collapse>
    </b-navbar>
</template>

<script lang="ts">
import { Vue } from 'vue-property-decorator';

export default class AppNavbar extends Vue {
  constructor() {
    super();
  }
}
</script>
