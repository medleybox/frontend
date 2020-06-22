<template>
  <div class="col-3">
    <div class="card">
      <b-card
        :title="media.title"
        :img-src="media.thumbnail"
        img-alt="Image"
        img-top
        style=""
        class=""
      >
        <b-card-text>
          <h5 style="height: 50px">{{media.title}}</h5>
          {{media.seconds}} - <b-button variant="primary" @click="play">Play</b-button>
        </b-card-text>
      </b-card>
    </div>
  </div>
</template>

<script lang="ts">
import { EventBus } from './event-bus.js';
import { BCard, BImgLazy, BButton } from 'bootstrap-vue';
import { Component, Prop, Vue } from 'vue-property-decorator';

@Component({
  components: {
    BCard,
    BImgLazy,
    BButton
  },
})
export default class MediaFile extends Vue {
  @Prop() readonly media!: any;
  private data(): object {
    return {
        mainProps: {blank: true, blankColor: '#777', width: 640, height: 360, class: 'm1'}
    };
  }

  private play() {
    EventBus.$emit('stream-media-start', {uuid: this.media.uuid, stream: this.media.stream});
  }

  mounted(): void {
      console.log('mounted');
  }
}
</script>