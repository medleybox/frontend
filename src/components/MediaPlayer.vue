<template>
    <div class="file">
      <vue-audio v-bind:is="playing"> :autoPlay="true" :file="playing"></vue-audio>
    </div>
</template>

<script lang="ts">
import { EventBus } from './event-bus.js';
import VueAudio from 'vue-audio';
import { Component, Vue } from 'vue-property-decorator';
@Component({
  components: {
    VueAudio
  },
})
export default class MediaPlayer extends Vue {
  playing!: string;
  show!: boolean;

  @Watch('playing')
  onPropertyChanged(value: string, oldValue: string) {
      console.log('Player playing changed ' + value + ' | ' + oldValue);
  }

  private data(): object {
    return {
      mainProps: {blank: true, blankColor: '#777', width: 640, height: 360, class: 'm1'}
    };
  }

  private streamMediaStart(data: any): void {
    console.log('here', data.stream);
    this.playing = data.stream;
    this.show = true;
  }

  constructor() {
    super();
    this.show = false;
    this.playing = '';
    EventBus.$on('stream-media-start', (data) => {
      this.streamMediaStart(data);
    });
  }
}

</script>
