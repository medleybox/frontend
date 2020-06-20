<template>
    <div class="file">
      <vue-audio :autoPlay="true" :file="playing"></vue-audio>
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

  // @Watch('playing')
  // onPropertyChanged(value: string, oldValue: string) {
  //     console.log('Player playing changed ' + value + ' | ' + oldValue);
  // }

  private data(): object {
    return {
      mainProps: {blank: true, blankColor: '#777', width: 640, height: 360, class: 'm1'}
    };
  }

  private streamMediaStart(data: any): void {
    console.log('here', data.stream);
    this.playing = data.stream;
  }

  constructor() {
    super();
    this.playing = '';
    EventBus.$on('stream-media-start', (data) => {
      this.streamMediaStart(data);
    });
  }
}

</script>
