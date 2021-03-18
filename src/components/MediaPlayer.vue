<template>
    <div class="file">
      <vue-audio :autoPlay="true" :file="playing"></vue-audio>
    </div>
</template>

<script lang="ts">
import { EventBus } from './event-bus.js';
import VueAudio from 'vue-audio';
import { Component, Watch, Vue } from 'vue-property-decorator';
@Component({
  components: {
    VueAudio
  },
})
export default class MediaPlayer extends Vue {
  playing!: string;
  uuid!: string | null;
  metadata: object;

  @Watch('playing')
  onPropertyChanged(value: string, oldValue: string) {
      console.log('Player playing changed ' + value + ' | ' + oldValue);
  }

  @Watch('metadata')
  onPropertyChangedOne(value: any, oldValue: object) {
      document.title = value.title;
  }

  private data(): object {
    return {
      mainProps: {blank: true, blankColor: '#777', width: 640, height: 360, class: 'm1'}
    };
  }

  private streamMediaStart(data: any): void {
    console.log(data);
    this.playing = data.stream;
    this.uuid = data.uuid;
    this.loadTrack();
  }

  private loadTrack(): void {
    console.log(this.uuid);
    fetch(process.env.VUE_APP_BASE_URL + '/media-file/metadata/' + this.uuid, {
        method: 'GET',
        credentials: 'same-origin',
    }).then((response) => {
        return response.json();
    }).then((json) => {
        this.metadata = json;
    });
  }

  constructor() {
    super();
    this.playing = '';
    this.uuid = null;
    this.metadata = {};

    EventBus.$on('stream-media-start', (data) => {
      this.streamMediaStart(data);

      Vue.nextTick(() => {
        const audio = document.querySelector('audio');
        if (null !== audio) {
          audio.play();
        }
      });
    });
  }
}

</script>
