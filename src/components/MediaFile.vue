<style lang="scss">
  /* Used to hide the undefined message when using cards */
  .card-body {
    display: none;
  }

  .card {
    margin: 4px;
    padding-top: 0%;
  }

  .loading > .card {
    padding-top: 49%;
  }

  .loading .card-img-top {
    height: 162px;
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

  @media screen and (max-width: 990px) {
    .card {
      margin: 0px;
    }

    .loading .card-img-top {
      max-height: 121px;
    }

    .card-img-top {
      max-height: 121px;
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
  thumbnailLoaded = false;
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
