<style scoped>
  /* Used to hide the undefined message when using cards */
  .card-body {
    display: none;
  }

  .card {
    margin-bottom: 20px;
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

</style>
<template>
  <div class="col-12 col-md-6 col-lg-4 col-xl-3">
    <b-card
        :title="media.title"
        :img-src="media.thumbnail"
        img-alt="Image"
        img-top>
        <template #header>
          <h5 class="mediafile--title">{{media.title}}</h5>
        </template>
        <p>not rendered</p>
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
  </div>
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
  @Prop() readonly media!: any;

  private data(): object {
    return {
      mainProps: {blank: true, blankColor: '#777', width: 640, height: 360, class: 'm1'}
    };
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

  private play(): boolean {
    if (isIOS) {
      window.open(this.steamVlcLink, "_blank");

      return true;
    }
    EventBus.$emit('stream-media-start', {uuid: this.media.uuid, stream: this.media.stream});

    return false;
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
}
</script>