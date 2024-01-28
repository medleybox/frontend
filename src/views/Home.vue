<style scoped lang="scss">
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

  .b-sidebar {
    background-color: #1f5e61 !important;
    color: white;

    > .b-sidebar-header {
      color: white;
    }

    .header__container {
      width: 98%;
    }
  }
</style>
<template>
  <div class="home">
    <EditMediaFile></EditMediaFile>
    <MediaFileImportLog></MediaFileImportLog>
    <MediaPlayer :showType="vShowType" :settings="settings"></MediaPlayer>
    <b-container fluid>
      <Sidebar />
      <div v-show="showType === 'home'" class="media--home">
        <b-row no-gutters>
          <MediaFile v-for="(data) in mediaFiles['suggested']" v-bind:media="data" :key="data.uuid"></MediaFile>
        </b-row>
        <hr v-show="hasSuggestedMedia()" />
        <b-row no-gutters>
          <MediaFile v-for="(data) in mediaFiles['latest']" v-bind:media="data" :key="data.uuid"></MediaFile>
        </b-row>
      </div>
      <div v-show="showType === 'search'" class="media--search">
        <b-row no-gutters>
          <h3 v-if="null === mediaFiles['search']">No media found</h3>
          <MediaFile v-for="(data) in mediaShowing" v-bind:media="data" :key="data.uuid"></MediaFile>
        </b-row>
      </div>
      <div v-show="showType === 'user'" class="media--browser">
        <b-row no-gutters>
          <MediaFile v-for="(data) in mediaFiles['user']" v-bind:media="data" :key="data.uuid"></MediaFile>
        </b-row>
      </div>
      <div v-show="showType === 'collections'" class="media--collection">
        <MediaCollections></MediaCollections>
      </div>
    </b-container>
  </div>
</template>

<script lang="ts">
import { EventBus } from '../components/event-bus.js';
import Sidebar from '../components/Sidebar.vue';
import MediaCollections from '../components/MediaCollections.vue';
import MediaFile from "../components/MediaFile.vue";
import EditMediaFile from "../components/EditMediaFile.vue";
import MediaPlayer from "../components/MediaPlayer.vue";
import MediaFileImportLog from "../components/MediaFileImportLog.vue";
import { Component, Watch, Vue } from 'vue-property-decorator';

@Component({
  components: {
    Sidebar,
    MediaCollections,
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
  showType = '';
  vShowType!: number;

  constructor() {
    super();
    document.addEventListener('ws', ((event: CustomEvent) => {
      console.log('ws event', event, event.detail);
      if ("refreshMediaList" === event.detail) {
        this.updateMediaList();
      }

      if ("refreshLatestList" === event.detail) {
        this.updateLatestList();
      }

      if ("refreshUserList" === event.detail) {
        this.updateUserList();
      }
      // eslint-disable-next-line
    }) as EventListener, false);
  }

  private data(): object {
    return {
      mediaFiles: {
        search: {},
        suggested: {},
      },
      mediaShowing: {},
      settings: {},
      showType: null,
      vShowType: 0,
    };
  }

  @Watch('showType')
  onShowTypeChanged(value: string, oldValue: string) {
    Vue.nextTick(() => {
      this.doubleRaf(() => {
        this.mediaShowing = this.mediaFiles[value];
      });
    });

    if (['home', 'user', 'collections'].indexOf(value)) {
      sessionStorage.setItem('showType', value);
    }
  }

  hasSuggestedMedia(): boolean {
    console.log('hasSuggestedMedia()');
    if (typeof this.mediaFiles['suggested'] === "undefined" || this.mediaFiles['suggested'].length == 0) {
      return false;
    }
    console.log('is_array:', !Array.isArray(this.mediaFiles['suggested']));
    console.log('suggested_length', this.mediaFiles['suggested'].length);

    return Array.isArray(this.mediaFiles['suggested']);
  }

  private doubleRaf(callback) {
    requestAnimationFrame(() => {
      requestAnimationFrame(callback)
    })
  }

  private showSearch(files: object): void {
    this.mediaFiles['search'] = {};
    Vue.nextTick(() => {
      this.mediaFiles['search'] = files;

      if (Object.keys(files).length === 0) {
        this.mediaFiles['search'] = null;
      }
    });

    this.showType = 'search';
    this.vShowType = -1;
    this.mediaShowing = files;
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
    fetch('/media-file/suggested-list', {
      method: 'GET',
      credentials: 'same-origin',
    }).then((response) => {
      return response.json();
    }).then((json) => {
      callback(json);
    });
  }

  private updateLatestList() {
    this.refreshLatestList((files: object) => {
      this.mediaFiles['latest'] = {};
      Vue.nextTick(() => {
        this.doubleRaf(() => {
          this.mediaFiles['latest'] = files;
        });
      });
    });
  }

  private refreshLatestList(callback: (json: Array<string>) => void): void {
    fetch('/media-file/latest-list', {
      method: 'GET',
      credentials: 'same-origin',
    }).then((response) => {
      return response.json();
    }).then((json) => {
      callback(json);
    });
  }

  private updateUserList() {
    this.refreshUserList((files: object) => {
      this.mediaFiles['user'] = {};
      Vue.nextTick(() => {
        this.doubleRaf(() => {
          this.mediaFiles['user'] = files;
        });
      });
    });
  }

  private refreshUserList(callback: (json: Array<string>) => void): void {
    fetch('/media-file/user-list', {
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
    fetch('/media-file/list', {
      method: 'GET',
      credentials: 'same-origin',
    }).then((response) => {
      return response.json();
    }).then((json) => {
      callback(json.files);
    });
  }

  private fetchSettings(): void {
    fetch('/user/settings', {
      method: 'GET',
      credentials: 'same-origin',
    }).then((response) => {
      return response.json();
    }).then((json) => {
      this.settings = json;
    });
  }

  private setShowTypeFromSession(): void {
    let showType = sessionStorage.getItem('showType');
    if ('search' === showType) {
      showType = 'home';
    }

    if (null === showType) {
      showType = 'home';
    }

    this.showType = showType;
    switch(showType) {
      case "home":
        this.vShowType = 0;
        break;
      case "user":
        this.vShowType = 1;
        break;
      case "collections":
        this.vShowType = 2;
        break;
    } 
  }

  created(): void {
    this.setShowTypeFromSession();
    this.updateMediaList();
    this.fetchSettings();
    this.hasSuggestedMedia();

    EventBus.$on('update-media-list', () => {
      this.updateMediaList();
    });

    EventBus.$on('update-latest-list', () => {
      this.updateLatestList();
    });

    EventBus.$on('update-user-list', () => {
      this.updateUserList();
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

    EventBus.$on('set-search-results', (files: object) => {
      this.showSearch(files);
    });

    EventBus.$on('reset-search', () => {
      this.mediaFiles['search'] = {};
      this.showType = 'home';
    });
  }
}

</script>
