<style lang="scss">
</style>
<template>
  <span class="user-avatar">
    <b-avatar :src='src' :size='size' variant="secondary"></b-avatar>
  </span>
</template>
<script lang="ts">
import { EventBus } from './event-bus.js';
import { BAvatar } from 'bootstrap-vue';
import { Component, Prop, Vue } from 'vue-property-decorator';

@Component({
  components: {
    'b-avatar': BAvatar
  },
})
export default class UserAvatar extends Vue {
  src!: string;
  @Prop() readonly size!: string;

  private data(): object {
    return {
      src: null
    }
  }

  private fetchAvatarUrl(): void {
    fetch('/profile/avatar', {
      method: 'GET',
      credentials: 'same-origin',
    }).then((response) => {
      this.src = response.url;
      return response;
    });
  }

  private reloadAvatar(): void  {
    this.fetchAvatarUrl();
  }

  constructor() {
    super();
    EventBus.$on('avatar-reload', (data: object) => {
      Vue.nextTick(() => {
        this.reloadAvatar();
      });
    });

    this.fetchAvatarUrl();
  }
}
</script>