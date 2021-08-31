<style scoped>
  .mediaplayer {
    margin: 0px;
    min-height: 160px;
  }
</style>
<template>
  <div class="mediaplayer">
    <div class="player-controls float-right" v-show="'' != this.playing">
      <b-button-group size="sm" class="float-left">
        <b-button variant="outline-primary" @click="playPause">
          {{showTrackSeconds}} / {{showTrackTotal}}
        </b-button>
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
  trackSeconds = 0;
  trackTotal = 0;
  metadata: any;
  waveSurfer: any;
  options: object;

  get currentPlayingTitle(): string {
    if ('' === this.playing) {
        return '';
    }
    
    return this.metadata.title;
  }

  get showTrackSeconds()
  {
    return new Date(this.trackSeconds * 1000).toISOString().substr(11, 8)
  }

  get showTrackTotal()
  {
    return new Date(this.trackTotal * 1000).toISOString().substr(11, 8)
  }

  @Watch('playing')
  onPropertyChanged(value: string, oldValue: string) {
    console.log('Player playing changed ' + value + ' | ' + oldValue);
  }

  @Watch('metadata')
  onPropertyChangedOne(value: any) {
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
        if (null !== this.metadata.metadata.wavedata && null !== this.metadata.metadata.wavedata.data) {
          this.waveSurfer.empty();
          this.waveSurfer.load(this.playing, this.metadata.metadata.wavedata.data);
          window.startPlayEvent();
          this.waveSurfer.play();
        } else {
          alert('Unable to play media!');
        }
    });
  }

  mounted() {
    const waveSurfer = WaveSurfer.create({
      container: document.getElementById('waveform'),
      scrollParent: false,
      height: 128
    });

    document.onkeypress = function(e) {
      e = e || window.event;
      const charCode = e.keyCode || e.which;
      if (charCode === 32) {
        e.preventDefault();
        waveSurfer.playPause();
        return false;
      }
    }

    waveSurfer.on('ready', () => {
      console.log('waveSurfer ready');
      this.trackTotal = waveSurfer.getDuration().toFixed(1);
      waveSurfer.play();
    });

    waveSurfer.on('play', () => {
      this.isPlaying = true;
    });

    waveSurfer.on('pause', () => {
      this.isPlaying = false;
    });

    waveSurfer.on('audioprocess', () => {
      if(waveSurfer.isPlaying()) {
          const currentTime = waveSurfer.getCurrentTime();

          this.trackSeconds = currentTime.toFixed(1);
      }
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
