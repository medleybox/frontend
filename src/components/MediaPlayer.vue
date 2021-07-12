<style scoped>
  .mediaplayer {
    margin: 0px;
  }
</style>
<template>
  <div class="mediaplayer">
    <div class="player-controls float-right" v-show="'' != this.playing">
      <b-button-group size="sm" class="float-left">
        <b-button variant="outline-primary" @click="playPause">
          <b-icon-play-fill v-show="false === isPlaying"></b-icon-play-fill>
          <b-icon-pause-fill v-show="true === isPlaying"></b-icon-pause-fill>
        </b-button>
        <b-button variant="outline-primary" @click="settings">
          <b-icon-gear-fill></b-icon-gear-fill>
        </b-button>
      </b-button-group>
    </div>
    <h3>{{currentPlayingTitle}}</h3>
    <div id="waveform" ref="wave"></div>
  </div>
</template>

<script lang="ts">
import { EventBus } from './event-bus.js';
import WaveSurfer from "wavesurfer.js";
import { BIconPlayFill, BIconPauseFill, BIconGearFill, BButton, BButtonGroup } from 'bootstrap-vue';
import { Component, Watch, Vue } from 'vue-property-decorator';

declare global {
    interface Window {
        startPlayEvent: Function;
    }
}

@Component({
  components: {
    BButton,
    BButtonGroup,
    BIconPlayFill,
    BIconPauseFill,
    BIconGearFill
  },
})
export default class MediaPlayer extends Vue {
  playing!: string;
  isPlaying: boolean;
  uuid!: string | null;
  metadata: any;
  waveSurfer: any;
  options: object;

  get currentPlayingTitle(): string {
    if ('' === this.playing) {
        return '';
    }
    
    return this.metadata.title;
  }

  @Watch('playing')
  onPropertyChanged(value: string, oldValue: string) {
    console.log('Player playing changed ' + value + ' | ' + oldValue);
  }

  @Watch('metadata')
  onPropertyChangedOne(value: any, oldValue: object) {
    document.title = value.title;
  }

  public playPause() {
    if (null !== this.waveSurfer) {
      this.waveSurfer.playPause();
    }
  }

  public settings()
  {
    alert('Soon!');
  }

  private streamMediaStart(data: any): void {
    this.playing = data.stream.replace(/^http:\/\//i, 'https://');
    this.uuid = data.uuid;

    this.waveSurfer.load(this.playing);
    window.startPlayEvent();
    this.loadTrack();
  }

  private loadTrack(): void {
    fetch(process.env.VUE_APP_BASE_URL + '/media-file/metadata/' + this.uuid, {
        method: 'GET',
        credentials: 'same-origin',
    }).then((response) => {
        return response.json();
    }).then((json) => {
        this.metadata = json;
    });
  }

  mounted() {
    const waveSurfer = WaveSurfer.create({
      container: document.getElementById('waveform'),
      scrollParent: false,
      height: 128
    });

    waveSurfer.on('ready', () => {
      console.log('waveSurfer ready');
      waveSurfer.play();
    });

    waveSurfer.on('play', () => {
      this.isPlaying = true;
    });

    waveSurfer.on('pause', () => {
      this.isPlaying = false;
    });

    this.waveSurfer = waveSurfer;
    Vue.nextTick(() => {
      this.waveSurfer.empty();
    });
  }

  beforeDestroy() {
    this.waveSurfer.destroy();
  }

  constructor() {
    super();
    this.playing = '';
    this.isPlaying = false;
    this.uuid = null;
    this.metadata = {};
    this.options = {};

    EventBus.$on('stream-media-start', (data) => {
      this.streamMediaStart(data);

      Vue.nextTick(() => {
        //
      });
    });
  }
}

</script>
