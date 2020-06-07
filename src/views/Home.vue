<template>
  <div class="home">
    <h1>MedleyBox</h1>
    <NewMediaFile></NewMediaFile>
  </div>
</template>

<script lang="ts">

import NewMediaFile from "../components/NewMediaFile.vue"
import { Component, Vue } from 'vue-property-decorator';

@Component({
  components: {
    NewMediaFile,
  },
})
export default class Home extends Vue {

}

</script>