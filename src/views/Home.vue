<style scoped>
  .mediaplayer-row {
    margin: -18px;
  }
</style>
<template>
  <div class="home">
    <EditMediaFile></EditMediaFile>
    <MediaFileImportLog></MediaFileImportLog>
    <MediaPlayer></MediaPlayer>
    <b-container fluid>
      <b-row>
        <NewMediaFile></NewMediaFile>
        <MediaFile v-for="(data) in mediaFiles" v-bind:media="data" :key="data.uuid"></MediaFile>
      </b-row>
    </b-container>
  </div>
</template>

<script lang="ts">
import { EventBus } from '../components/event-bus.js';
import MediaFile from "../components/MediaFile.vue";
import NewMediaFile from "../components/NewMediaFile.vue"
import EditMediaFile from "../components/EditMediaFile.vue"
import MediaPlayer from "../components/MediaPlayer.vue"
import MediaFileImportLog from "../components/MediaFileImportLog.vue"
import { Component, Vue } from 'vue-property-decorator';

@Component({
  components: {
    MediaFile,
    NewMediaFile,
    EditMediaFile,
    MediaPlayer,
    MediaFileImportLog
  },
})
export default class Home extends Vue {
  mediaFiles!: object;

  constructor() {
    super();
    EventBus.$on('update-media-list', () => {
      this.updateMediaList();
    });

    document.addEventListener('ws', ((event: CustomEvent) => {
        console.log('ws event', event, event.detail);
        if ("refreshMediaList" === event.detail) {
          this.updateMediaList();
        }
    }) as EventListener, false);

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
    this.refreshMediaList((files: object) => {
      console.log('refreshMediaList()');

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

  private refreshMediaList(callback: (json: Array<string>) => void): void {
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