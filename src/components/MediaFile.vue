<style scoped>
  /* Used to hide the undefined message when using cards */
  .card-body {
    display: none;
  }

  .card {
    margin: 0px;
    padding-top: 0%;
  }

  @media screen and (min-width: 990px) {
    .card {
      margin: 4px;
    }
  }

  .loading > .card {
    padding-top: 55%;
  }

  .card-img-top {
    min-height: 24vh;
  }

  .card-header {
    padding-bottom: 0;
  }

  .mediafile--title {
    -webkit-line-clamp: 2;
    -webkit-box-orient: vertical;
    height: 48px;
    overflow: hidden;
    text-overflow: ellipsis;
    display: -webkit-box;
  }

  .mediafile--button-group .btn.dropdown-toggle {
    padding: 4px;
  }

  .mediafile--thumbnail_loader {
    padding-top: 20%;
    z-index: 100;
    display: flex;
    position: absolute;
    padding-left: 45%;
  }

  .mediafile--thumbnail_loader > .spinner-border {
    width: 3rem;
    height: 3rem;
  }
</style>
<template>
    <b-col cols="12" md="6" lg="4" xl="3">
      <span :class="wrapperClass">
        <div v-show="this.thumbnail === ''" class="mediafile--thumbnail_loader justify-content-center mb-3">
          <b-spinner></b-spinner>
        </div>
        <b-card
          :title="media.title"
          :img-src="thumbnail"
          img-alt=""
          img-top>
          <template #header>
            <h5 class="mediafile--title">{{media.title}}</h5>
          </template>
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
                <b-dropdown-item disabled>Download</b-dropdown-item>
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
import { isIOS } from 'mobile-device-detect';
import { EventBus } from './event-bus.js';
import { BCard, BIconPlayFill, BIconPencilSquare, BDropdown, BButton, BButtonGroup } from 'bootstrap-vue';
import { Component, Prop, Vue } from 'vue-property-decorator';

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
  @Prop() readonly media!: any;

  private data(): object {
    return {
      mainProps: {blank: true, blankColor: '#777', width: 640, height: 360, class: 'm1'},
      thumbnail: ''
    };
  }

  get wrapperClass()
  {
    if ('' === this.thumbnail) {
      return 'loading';
    }

    return '';
  }

  get showTime()
  {
    return new Date(this.media.seconds * 1000).toISOString().substr(11, 8);
  }

  get steamVlcLink(): string
  {
    return `vlc-x-callback://x-callback-url/stream?url=${this.media.stream}`;
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
      })
      .then( response => response.blob() )
      .then( blob => {
          // eslint-disable-next-line
          const that = this;
          var reader = new FileReader();
          reader.onload = function(){
            that.thumbnail = this.result ? this.result.toString() : '';
          };
          reader.readAsDataURL(blob);
      });
    };

    return await imageUrlToBase64(this.media.thumbnail);
  }

  private play(): boolean {
    if (isIOS) {
      window.open(this.steamVlcLink, "_blank");

      return true;
    }
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