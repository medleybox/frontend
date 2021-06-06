<style scoped>
  /* Used to hide the undefined message when using cards */
  .card-body {
    display: none;
  }
</style>
<template>
  <div class="col-12 col-md-6 col-lg-4 col-xl-2">
    <div class="card">
      <b-card
        :title="media.title"
        :img-src="media.thumbnail"
        img-alt="Image"
        img-top>
        <template #header>
          <h5 style="min-height: 40px">{{media.title}}</h5>
        </template>
        <p>not rendered</p>
        <template #footer>
          <small class="text-muted">{{showTime}}</small>
          <b-button-group size="sm" class="float-right">
            <b-button variant="outline-primary" @click="play">
              <b-icon-play-fill></b-icon-play-fill>
            </b-button>
            <b-button variant="outline-secondary" @click="openModal">
              <b-icon-pencil-square></b-icon-pencil-square>
            </b-button>
          </b-button-group>
        </template>
      </b-card>
    </div>
  </div>
</template>

<script lang="ts">
import { isIOS } from 'mobile-device-detect';
import { EventBus } from './event-bus.js';
import { BCard, BIconPlayFill, BIconPencilSquare, BButton, BButtonGroup } from 'bootstrap-vue';
import { Component, Prop, Vue } from 'vue-property-decorator';

@Component({
  components: {
    BCard,
    BButton,
    BButtonGroup,
    BIconPlayFill,
    BIconPencilSquare
  },
})
export default class MediaFile extends Vue {
  @Prop() readonly media!: any;

  get showTime()
  {
    return new Date(this.media.seconds * 1000).toISOString().substr(11, 8)
  }

  get steamVlcLink()
  {
    return 'vlc-x-callback://x-callback-url/stream?url=' + this.media.stream;
  }

  private data(): object {
    return {
      mainProps: {blank: true, blankColor: '#777', width: 640, height: 360, class: 'm1'}
    };
  }

  private play(): boolean {
    if (isIOS) {
      window.open(this.steamVlcLink, "_blank");

      return true;
    }
    EventBus.$emit('stream-media-start', {uuid: this.media.uuid, stream: this.media.stream});

    return false;
  }

  private openModal() {
    EventBus.$emit('media-edit', this.media.uuid);
  }

  private updateMediaList()  {
    EventBus.$emit('update-media-list', {});
  }

  mounted(): void {
    //
  }
}
</script>