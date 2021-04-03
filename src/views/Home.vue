<template>
  <div class="home">
    <h1>MedleyBox</h1>
    <NewMediaFile></NewMediaFile>
    <EditMediaFile></EditMediaFile>
    <MediaPlayer></MediaPlayer>
    <div class="container-fluid">
      <div class="row">
        <MediaFile v-for="(data) in mediaFiles" v-bind:media="data" :key="data.uuid"></MediaFile>
      </div>
    </div>
  </div>
</template>

<script lang="ts">
import { EventBus } from '../components/event-bus.js';
import MediaFile from "../components/MediaFile.vue";
import NewMediaFile from "../components/NewMediaFile.vue"
import EditMediaFile from "../components/EditMediaFile.vue"
import MediaPlayer from "../components/MediaPlayer.vue"
import { Component, Vue } from 'vue-property-decorator';

@Component({
  components: {
    MediaFile,
    NewMediaFile,
    EditMediaFile,
    MediaPlayer
  },
})
export default class Home extends Vue {
  mediaFiles!: object;

  constructor() {
    super();
    EventBus.$on('update-media-list', () => {
      this.updateMediaList();
    });
  }

  private data(): object {
    return {
      mediaFiles: {}
    };
  }

  private doubleRaf (callback) {
    requestAnimationFrame(() => {
      requestAnimationFrame(callback)
    })
  }

  private updateMediaList() {
    console.log('updateMediaList()');
    this.refreshMediaList((files: object) => {

      // If there's a new track we can just update the mediaFiles
      if (Object.keys(files).length !== Object.keys(this.mediaFiles).length) {
        this.mediaFiles = files;
        return true;
      }


      // Otherwise we need to reset the object to avoid issues with vue - https://github.com/vuejs/vue/issues/657
      this.mediaFiles = {};
      Vue.nextTick(() => {
        this.doubleRaf(() => {
          this.mediaFiles = files;
        });
      });
    });
  }

  private refreshMediaList(callback: any): void {
    fetch(process.env.VUE_APP_BASE_URL + '/media-file/list', {
        method: 'GET',
        credentials: 'same-origin',
    }).then((response) => {
        return response.json();
    }).then((json) => {
        callback(json.files);
    });
  }

  created(): void {
    this.updateMediaList();
  }
}

</script>