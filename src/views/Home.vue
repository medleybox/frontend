<template>
  <div class="home">
    <h1>MedleyBox</h1>
    <NewMediaFile></NewMediaFile>
    <MediaFile v-for="(data) in mediaFiles" v-bind:media="data" :key="data.uuid"></MediaFile>
  </div>
</template>

<script lang="ts">
import MediaFile from "../components/MediaFile.vue";
import NewMediaFile from "../components/NewMediaFile.vue"
import { Component, Vue } from 'vue-property-decorator';

@Component({
  components: {
    MediaFile,
    NewMediaFile,
  },
})
export default class Home extends Vue {
  mediaFiles!: object;

  private data(): object {
    return {
        mediaFiles: {},
    };
  }

  private refreshMediaList(callback: any): void {
    fetch('https://localhost/media-file/list', {
        method: 'GET',
        credentials: 'same-origin',
    }).then((response) => {
        return response.json();
    }).then((json) => {
        callback(json.files);
    });
  }

  created(): void {
    this.refreshMediaList((files: object) => {
        this.mediaFiles = files;
    });
  }
}

</script>