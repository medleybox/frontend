<style scoped>
  .mediaplayer-row {
    margin: -18px;
  }
  .container-fluid {
    padding-right: 0px;
    padding-left: 0px;
  }
  @media screen and (min-width: 990px) {
    .container-fluid {
      padding-right: 10px;
      padding-left: 10px;
    }
  }
</style>
<template>
  <div class="home">
    <EditMediaFile></EditMediaFile>
    <MediaFileImportLog></MediaFileImportLog>
    <MediaPlayer :settings="settings"></MediaPlayer>
    <b-container fluid>
      <div v-show="showType === 'home'" class="media--home">
        <b-row no-gutters>
          <MediaFile v-for="(data) in mediaFiles['suggested']" v-bind:media="data" :key="data.uuid"></MediaFile>
        </b-row>
        <hr />
        <b-row no-gutters>
          <MediaFile v-for="(data) in mediaFiles['latest']" v-bind:media="data" :key="data.uuid"></MediaFile>
        </b-row>
      </div>
      <div v-show="showType === 'user'" class="media--browser">
        <b-row no-gutters>
          <MediaFile v-for="(data) in mediaFiles['user']" v-bind:media="data" :key="data.uuid"></MediaFile>
        </b-row>
      </div>
    </b-container>
  </div>
</template>

<script lang="ts">
import { EventBus } from '../components/event-bus.js';
import MediaFile from "../components/MediaFile.vue";
import EditMediaFile from "../components/EditMediaFile.vue";
import MediaPlayer from "../components/MediaPlayer.vue";
import MediaFileImportLog from "../components/MediaFileImportLog.vue";
import { Component, Watch, Vue } from 'vue-property-decorator';

@Component({
  components: {
    MediaFile,
    EditMediaFile,
    MediaPlayer,
    MediaFileImportLog
  },
})
export default class Home extends Vue {
  mediaFiles!: object;
  mediaShowing!: object;
  settings!: any;
  showType = 'home';

  constructor() {
    super();
    document.addEventListener('ws', ((event: CustomEvent) => {
        console.log('ws event', event, event.detail);
        if ("refreshMediaList" === event.detail) {
          this.updateMediaList();
        }
        // eslint-disable-next-line
    }) as EventListener, false);
  }

  private data(): object {
    return {
      mediaFiles: {},
      mediaShowing: {},
      settings: {},
      showType: 'home',
    };
  }

  @Watch('showType')
  onShowTypeChanged(value: string, oldValue: string) {
    Vue.nextTick(() => {
      this.doubleRaf(() => {
        this.mediaShowing = this.mediaFiles[value];
      });
    });
  }

  private doubleRaf (callback) {
    requestAnimationFrame(() => {
      requestAnimationFrame(callback)
    })
  }

  private updateSuggestedList() {
    this.refreshSuggestedList((files: object) => {
      this.mediaFiles['suggested'] = {};
      Vue.nextTick(() => {
        this.doubleRaf(() => {
          this.mediaFiles['suggested'] = files;
        });
      });
    });
  }

  private refreshSuggestedList(callback: (json: Array<string>) => void): void {
    fetch(process.env.VUE_APP_BASE_URL + '/media-file/suggested-list', {
        method: 'GET',
        credentials: 'same-origin',
    }).then((response) => {
        return response.json();
    }).then((json) => {
        callback(json);
    });
  }

  private updateMediaList() {
    this.refreshMediaList((files: object) => {
      this.mediaFiles = {};
      Vue.nextTick(() => {
        this.doubleRaf(() => {
          this.mediaFiles = files;
          this.mediaShowing = this.mediaFiles[this.showType];
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

  private fetchSettings(): void {
    fetch(process.env.VUE_APP_BASE_URL + '/user/settings', {
        method: 'GET',
        credentials: 'same-origin',
    }).then((response) => {
        return response.json();
    }).then((json) => {
        this.settings = json;
    });
  }

  created(): void {
    this.updateMediaList();
    this.fetchSettings();

    EventBus.$on('update-media-list', () => {
      this.updateMediaList();
    });

    EventBus.$on('update-suggested-list', () => {
      this.updateSuggestedList();
    });

    EventBus.$on('update-show-type', (type: string) => {
      if (type === this.showType) {
        return;
      }

      if ('home' === this.showType) {
        this.updateSuggestedList();
      }
      this.showType = type;
    });

    EventBus.$on('settings-updated', () => {
      this.fetchSettings();
    });
  }
}

</script>