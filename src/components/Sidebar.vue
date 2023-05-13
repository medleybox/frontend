<template>
  <span>
    <MediaCollection />
    <UserPlayHistory />
  </span>
</template>

<script lang="ts">
import { Component, Vue } from 'vue-property-decorator';
import MediaCollection from './Sidebar/MediaCollection.vue';
import UserPlayHistory from './Sidebar/UserPlayHistory.vue';
@Component({
  components: {
    MediaCollection,
    UserPlayHistory
  },
})
export default class Sidebar extends Vue {
  constructor() {
    super();
  }
}
</script>
