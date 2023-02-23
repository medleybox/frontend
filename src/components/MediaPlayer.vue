<style scoped>
  .mediaplayer {
    margin: 0px;
    min-height: 42px;
    background-color: #1d2021;
  }

  .no-hover-colour:hover {
    background-color: #1d2021;
  }

  .player--volume--button .btn {
    max-width: 45px;
    max-height: 38px;
    z-index: 100;
    position: relative;
  }

  .player--volume--button #volume-range {
    transform: rotate(270deg);
    width: 130px;
    height: 0px;
    margin-left: -54px;
    margin-top: 65px;
  }

  .player--timer {
    color: #007bff;
  }

  .player--title {
    margin-bottom: 0px;
    padding-top: 6px;
  }
</style>
<template>
  <div class="mediaplayer sticky-top">
    <div class="player-controls float-right">
      <b-button-group size="sm">
        <span class="player--volume--button">
          <b-button v-show="'' != this.playing" variant="outline-primary" @mouseover="overVolume" @mouseleave="hideVolume">
            <b-icon-volume-off-fill></b-icon-volume-off-fill>
            <b-form-input v-show="showVolume" id="volume-range" v-model="volume" type="range" min="0" max="100"></b-form-input>
          </b-button>
        </span>
      </b-button-group>
      <b-button-group size="sm">
        <b-button variant="outline-primary" class="no-hover-colour player--timer">
          {{showTrackSeconds}} / {{showTrackTotal}}
        </b-button>
        <b-button v-show="'' != this.playing" variant="outline-primary" @click="playPause">
          <b-icon-play-fill v-show="false === isPlaying"></b-icon-play-fill>
          <b-icon-pause-fill v-show="true === isPlaying"></b-icon-pause-fill>
        </b-button>
        <NewMediaFile></NewMediaFile>
        <b-button variant="outline-primary" @click="settingsModal">
          <b-icon-gear-fill></b-icon-gear-fill>
        </b-button>
      </b-button-group>
    </div>
    <h3 class="player--title" v-show="'' != this.playing">{{currentPlayingTitle}}</h3>
    <div v-show="'' != this.playing" id="waveform" ref="wave"></div>
    <MediaFilters :showType="showType" />
    <user-settings v-bind:settings="settings"/>
  </div>
</template>

<script lang="ts">
import { isIOS } from 'mobile-device-detect';
import { EventBus } from './event-bus.js';
import WaveSurfer from "wavesurfer.js";
import MediaFilters from "../components/MediaFilters.vue";
import NewMediaFile from "../components/NewMediaFile.vue";
import UserSettings from './UserSettings.vue';
import { BIconPlayFill, BIconPauseFill, BIconVolumeOffFill, BIconGearFill, BIconVinyl, BIconVinylFill, BIconSearch, BButton, BButtonGroup } from 'bootstrap-vue';
import { Component, Prop, Watch, Vue } from 'vue-property-decorator';

declare global {
    interface Window {
        // eslint-disable-next-line
        startPlayEvent: Function;
    }
}
@Component({
  components: {
    'user-settings': UserSettings,
    MediaFilters,
    NewMediaFile,
    BButton,
    BButtonGroup,
    BIconPlayFill,
    BIconPauseFill,
    BIconVolumeOffFill,
    BIconGearFill,
    BIconVinyl,
    BIconVinylFill,
    BIconSearch
  },
})
export default class MediaPlayer extends Vue {
  playing!: string;
  isPlaying: boolean;
  uuid!: string | null;
  trackSeconds = 0;
  trackTotal = 0;
  volume = 100;
  showVolume = false;
  metadata: any;
  waveSurfer: any;
  options: object;
  show: boolean;
  search: string;
  @Prop() readonly settings!: any;
  @Prop() readonly showType!: any;

  get currentPlayingTitle(): string {
    if ('' === this.playing) {
        return '';
    }
    
    return this.metadata.title;
  }

  get showTrackSeconds()
  {
    if (Number.isNaN(this.trackSeconds)) {
      return '--:--:--';
    }

    return new Date(this.trackSeconds * 1000).toISOString().substr(11, 8)
  }

  get showTrackTotal()
  {
    if (Number.isNaN(this.trackTotal)) {
      return '--:--:--';
    }

    return new Date(this.trackTotal * 1000).toISOString().substr(11, 8)
  }

  @Watch('playing')
  onPropertyChanged(value: string, oldValue: string) {
    console.log('Player playing changed ' + value + ' | ' + oldValue);
  }

  @Watch('metadata')
  onPropertyChangedOne(value: any) {
    const endTitle = '- MedleyBox';
    let title = `${value.title} ${endTitle}`;
    if ('undefined' === typeof value.title) {
      title = `Home ${endTitle}`;
    }
    document.title = title;
  }

  @Watch('volume')
  onPropertyChangedVolume(value: any): void {
    this.waveSurfer.setVolume(value/100);
  }

  public playPause(): void {
    if (null !== this.waveSurfer) {
      this.waveSurfer.playPause();
    }
  }

  public overVolume(): void {
    this.showVolume = true;
  }

  public hideVolume(): void {
    setTimeout(() => {
      this.showVolume = false;
    }, 1200);
  }

  public settingsModal()
  {
    this.$bvModal.show('settingsModal');
  }

  public changeShowType(type: string): void {
    EventBus.$emit('update-show-type', type);
  }

  private streamMediaStart(data: any): boolean {
    this.uuid = data.uuid;
    this.trackPlay();

    if (isIOS && true === this.settings.openVlc) {
      window.open(`vlc-x-callback://x-callback-url/stream?url=${data.stream}`, "_blank");

      return true;
    }

    this.playing = data.stream.replace(/^http:\/\//i, 'https://');
    this.initWaveSurfer();
    this.loadTrack();

    return true;
  }

  private resetPlayer(): void {
    this.show = false;
    this.playing = '';
    this.uuid = null;
    this.metadata = {};
    this.trackSeconds = 0;
    this.trackTotal = 0;
  }

  private loadTrack(): void {
    console.log('Loading track metadata');
    fetch('/media-file/metadata/' + this.uuid, {
        method: 'GET',
        credentials: 'same-origin',
    }).then((response) => {
        return response.json();
    }).then((json) => {
        this.metadata = json;
        this.trackSeconds = 0;
        this.trackTotal = this.metadata.seconds;
        this.loadTrackWavedata();
        Vue.nextTick(() => {
          this.waveSurfer.empty();
        });
    });
  }

  private trackPlay(): void {
    console.log('Loading track metadata');
    fetch('/media-file/play/' + this.uuid, {
        method: 'HEAD',
        credentials: 'same-origin',
    }).then((response) => {
        return response.json();
    }).then((json) => {
        console.log(json);
    });
  }

  private loadTrackWavedata(): void {
    console.log('Loading track wavedata');
    fetch('/media-file/wavedata/' + this.uuid, {
        method: 'GET',
        credentials: 'same-origin',
    }).then((response) => {
        return response.json();
    }).then((json) => {
        if (null !== json && null !== json.data) {
          this.waveSurfer.load(this.playing, json.data, 'metadata');
        } else {
          alert('Unable to play media!');
        }
    });
  }

  private initWaveSurfer(): void {
    if (null !== this.waveSurfer) {
      console.log('[waveSurfer] Run init but already loaded')
      return;
    }
    console.log('[waveSurfer] backend: "WebAudio"');
    const waveSurfer = WaveSurfer.create({
      container: document.getElementById('waveform'),
      backend: 'WebAudio',
      scrollParent: false,
      height: 128,
      progressColor: 'rgb(99, 255, 252)',
      partialRender: false
    });

    waveSurfer.on('ready', () => {
      console.log('[waveSurfer] ready');
      waveSurfer.play();
    });

    waveSurfer.on('play', () => {
      this.isPlaying = true;
    });

    waveSurfer.on('pause', () => {
      this.isPlaying = false;
    });

    waveSurfer.on('finish', () => {
      console.log('[waveSurfer] finish');
      this.isPlaying = false;
      setTimeout(() => {
        this.resetPlayer();
      }, 1200);
    });

    waveSurfer.setVolume(this.volume/100);

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

  mounted() {
    console.log('[MediaPlayer] mounted()');
  }

  beforeDestroy() {
    if (this.waveSurfer) {
      this.waveSurfer.destroy();
    }
  }

  constructor() {
    super();
    this.playing = '';
    this.isPlaying = false;
    this.uuid = null;
    this.metadata = {};
    this.options = {};
    this.show = false;
    this.search = '';

    EventBus.$on('stream-media-start', (data: any) => {
      // Stop any running player while loading next track
      if (this.waveSurfer) {
        this.waveSurfer.pause();
      }

      Vue.nextTick(() => {
        this.streamMediaStart(data);
      });
    });
  }
}

</script>
