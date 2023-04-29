<style scoped lang="scss">
  .card {
    margin: 4px;
    padding-top: 0%;
  }

  .loading > .card {
    padding-top: 54%;
  }

  .loading .card-img-top {
    height: 162px;
  }

  .card-header {
    padding-bottom: 0;
  }

  .card-title {
    -webkit-line-clamp: 2;
    -webkit-box-orient: vertical;
    height: 58px;
    overflow: hidden;
    text-overflow: ellipsis;
    display: -webkit-box;
    color: white;
    font-size: 16px;
  }

  .card-body {
    flex: 1 1 auto;
    min-height: 1px;
    padding: 10px;
    padding-bottom: 0px;
  }

  .card-footer {
    padding-top: 0;
  }

  .mediafile--button-group .btn.dropdown-toggle {
    padding: 4px;
    min-width: 30px;
  }

  .mediafile--thumbnail_loader {
    padding-top: 18%;
    z-index: 100;
    display: flex;
    position: absolute;
    padding-left: 40%;
  }

  .mediafile--thumbnail_loader > .spinner-border {
    width: 3rem;
    height: 3rem;
  }

  .card-img, .card-img-top {
    max-height: 172px;
    object-fit: contain;
  }

  @media screen and (max-width: 1367px) {
    .card-img, .card-img-top {
      max-height: 121px;
    }
  }

  @media screen and (max-width: 990px) {
    .card {
      margin: 0px;
    }

    .loading .card-img-top {
      max-height: 264px;
    }

    .card-img, .card-img-top {
      max-height: 264px;
    }
  }
</style>
<template>
  <b-col cols="12" md="4" lg="3" xl="2">
    <span :class="wrapperClass">
      <div class="mediafile--thumbnail_loader justify-content-center mb-3">
        <b-spinner v-if="false === this.thumbnailLoaded" variant="primary" />
      </div>
      <b-card
        :title="media.title"
        :img-src="thumbnail"
        img-alt=""
        img-top>
        <template #footer>
          <small class="text-muted">{{showTime}}</small>
          <b-button-group size="sm" class="float-right mediafile--button-group">
            <b-button variant="outline-primary" @click="play">
              <b-icon-play-fill></b-icon-play-fill>
            </b-button>
            <b-dropdown dropleft variant="outline-primary">
              <template #button-content></template>
              <b-dropdown-item @click="play">Play</b-dropdown-item>
              <b-dropdown-item disabled>Play next</b-dropdown-item>
              <b-dropdown-item @click="copyStreamLink">Copy stream link</b-dropdown-item>
              <b-dropdown-item @click="startDownload">Download</b-dropdown-item>
              <b-dropdown-item @click="openEditModal">Edit</b-dropdown-item>
              <b-dropdown-item @click="openDeleteModal">Delete</b-dropdown-item>
            </b-dropdown>
          </b-button-group>
        </template>
      </b-card>
    </span>
  </b-col>
</template>

<script lang="ts">
import { EventBus } from './event-bus.js';
import { BCard, BIconPlayFill, BIconPencilSquare, BDropdown, BButton, BButtonGroup } from 'bootstrap-vue';
import { Component, Prop, Vue } from 'vue-property-decorator';
import JsFileDownloader from 'js-file-downloader';

@Component({
  components: {
    BCard,
    BDropdown,
    BButton,
    BButtonGroup,
    BIconPlayFill,
    BIconPencilSquare
  },
})
export default class MediaFile extends Vue {
  thumbnail: string;
  thumbnailLoaded = false;
  @Prop() readonly media!: any;

  private data(): object {
    return {
      thumbnail: ''
    };
  }

  get wrapperClass(): string
  {
    if ('' === this.thumbnail) {
      return 'loading';
    }

    return '';
  }

  get showTime()
  {
    const time = this.media.seconds;
    if (Number.isNaN(time)) {
      return '--:--';
    }

    const timeAsDateString = new Date(time * 1000).toISOString();
    if (time < 3600) {
      return timeAsDateString.substring(14, 19);
    }

    return timeAsDateString.substring(11, 19);
  }

  private startDownload()
  {
    new JsFileDownloader({
      url: this.media.download
    })
    .then(function () {
      // Called when download ended
    })
    .catch(function (error) {
      // Called when an error occurred
      console.log(error);
    });
  }

  private async copyStreamLink()
  {
    try {
      const link = this.media.stream;
      await navigator.clipboard.writeText(link);
    } catch($e) {
      alert('Cannot copy stream link');
    }
  }

  private async resolveThumbnail()
  {
    const imageUrlToBase64 = async (url: string) => {
      const response = await fetch(url, {
          method: 'GET',
          credentials: 'same-origin',
      }).then((response) => {
          if (200 !== response.status) {
            throw Error('Unable to load thumbnail');
          }
          return response.blob();
      }).then(blob => {
          // eslint-disable-next-line
          const that = this;
          var reader = new FileReader();
          reader.onload = function() {
            that.thumbnail = this.result ? this.result.toString() : '';
            that.thumbnailLoaded = true;
          };
          reader.readAsDataURL(blob);
      });
    };

    return await imageUrlToBase64(this.media.thumbnail);
  }

  private play(): boolean {
    EventBus.$emit('stream-media-start', {uuid: this.media.uuid, stream: this.media.stream});

    return true;
  }

  private openEditModal(): void {
    EventBus.$emit('media-edit', this.media.uuid);
  }

  private openDeleteModal(): void {
    EventBus.$emit('media-delete', this.media.uuid);
  }

  private updateMediaList(): void  {
    EventBus.$emit('update-media-list', {});
  }

  constructor() {
    super();
    this.thumbnail = '';
  }

  mounted(): void {
    this.resolveThumbnail();
  }
}
</script>
