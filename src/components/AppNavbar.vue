<template>
  <div>
    <b-navbar toggleable="lg" type="dark" variant="primary">
      <b-navbar-brand>MedleyBox</b-navbar-brand>
      <b-navbar-toggle target="nav-collapse"></b-navbar-toggle>
      <b-collapse id="nav-collapse" is-nav>
        <b-navbar-nav>
          <b-nav-item to="/" exact exact-active-class="active">Home</b-nav-item>
          <b-nav-item href="/admin">Admin</b-nav-item>
        </b-navbar-nav>
        <!-- Right aligned nav items -->
        <b-navbar-nav class="ml-auto">
          <b-nav-item-dropdown right>
            <template #button-content>
              <user-avatar />
            </template>
            <b-dropdown-item to="/profile">Profile</b-dropdown-item>
            <b-dropdown-item @click="showHistory">History</b-dropdown-item>
            <b-dropdown-item v-b-modal.passwordModal href="#">Update password</b-dropdown-item>
            <b-dropdown-item href="/logout">Sign Out</b-dropdown-item>
          </b-nav-item-dropdown>
        </b-navbar-nav>
      </b-collapse>
    </b-navbar>
    <user-change-password />
  </div>
</template>

<script lang="ts">
import { EventBus } from './event-bus.js';
import { Component, Vue } from 'vue-property-decorator';
import UserAvatar from './UserAvatar.vue';
import UserChangePassword from './UserChangePassword.vue';
@Component({
  components: {
    'user-avatar': UserAvatar,
    'user-change-password': UserChangePassword
  },
})
export default class AppNavbar extends Vue {
  constructor() {
    super();
  }

  private showHistory() {
    EventBus.$emit('sidebar-userplayhistory-open');
  }
}
</script>
