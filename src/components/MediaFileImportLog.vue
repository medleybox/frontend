<template>
  <div class="import-log">
    <b-modal v-model="modalShow" size="lg" id="import-log" title="Importing media output" hide-footer>
       <b-container fluid class="edit-modal">
          <b-progress :value="progress" class="mb-3"></b-progress>
          <div class="" v-show="!this.showOutputMoal">
            <h3>Import queued</h3>
            <p>Waiting for import job</p>
          </div>
          <div class="" v-show="this.showOutputMoal">
            <h3>Import log</h3>
            <div class="output--container output--log">
              <pre id='pre_log'>{{this.logToString}}</pre>
            </div>
            <h3>youtube-dl output</h3>
            <div class="output--container output--output">
              <pre id='pre_output'>{{this.outputToString}}</pre>
            </div>
          </div>
          <!-- b-button variant="primary">Save</b-button -->
        </b-container>
    </b-modal>
  </div>
</template>
<script lang="ts">
import { EventBus } from './event-bus.js';
import { BModal, BButton, BForm, BFormInput, BImg, BContainer, BFormRow, BCol } from 'bootstrap-vue';
import { Component, Watch, Vue } from 'vue-property-decorator';

@Component({
  components: {
    BModal,
    BButton,
    BForm,
    BFormInput,
    BImg,
    BContainer,
    BFormRow,
    BCol
  },
})

export default class MediaFileImportLog extends Vue {
  modalShow!: boolean;
  uuid!: string;
  status = 'queue';
  progress = 0;
  output: Array<string> = [];
  outputString = ' ';
  log: Array<string> = [];
  logString = ' ';

  get showOutputMoal(): boolean {
    return this.status !== 'queue';
  }

  get logToString(): string {
    let str = '';
    this.log.forEach((i, index) => {
      str += i;
      if (index != (this.log.length - 1)) {
        str += '\n';
      }
    });
    return str;
  }

  get outputToString(): string {
    let str = '';
    this.output.forEach((i) => {
      str += i;
    });
    return str;
  }

  step = (step: number): number => {
    return 100 / 7 * step;
  };

  @Watch('status')
  onStatusChanged(value: string, oldValue: string) {
    if (value === oldValue) {
      return null;
    }

    switch (value) {
      case 'start':
        this.progress = this.step(1);
        break;

      case 'attemptDownload':
        this.progress = this.step(2);
        break;

      case 'checkForDownload':
        this.progress = this.step(3);
        break;

      case 'process':
        this.progress = this.step(4);
        break;

      case 'upload':
        this.progress = this.step(5);
        break;

      case 'import':
        this.progress = this.step(6);
        break;

      case 'finish':
        this.progress = 100;
        break;
    }

    /**
      status: start
      status: attemptDownload
      status: checkForDownload
      status: process
      status: upload
      status: import
      status: finish
    */

    console.log('status: ' + value, this.progress);
    if ('start' === value) {
      this.output = [];
      this.log = [];
      this.progress = 0;

      console.log('reset state');
    }
    if ('finish' === value) {
      setTimeout(() => {this.modalShow = false}, 5500);
    }
  }

  @Watch('output')
  onOutputChanged() {
    // value: Array<string>, oldValue: Array<string>
    const elem: HTMLInputElement = document.getElementById('pre_output') as HTMLInputElement;
    if (null === elem) {
      return null;
    }
    elem.scrollTo(1000, 200000);
  }

  @Watch('log')
  onLogChanged(value: Array<string>, oldValue: Array<string>) {
    if (value === oldValue) {
      return null;
    }
  }

  check(): boolean {
    console.log('check()');
    return true;
  }

  private data(): object {
    return {
        modalShow: false,
        uuid: '',
        output: []
    };
  }

  constructor() {
    super();

    EventBus.$on('media-import-log-start', (uuid: string) => {
      this.uuid = uuid;
      Vue.nextTick(() => {
        this.output = [];
        this.log = [];
        this.progress = 0;
        this.status = 'queue';
        this.$bvModal.show('import-log');
      });
    });
  }

  mounted(): void {
    console.log('importLogOutput mounted()');
    document.addEventListener('importLogOutput', ((event: CustomEvent) => {
        this.log.push(event.detail.data);
        this.status = event.detail.stage;

        //console.log('[importLogOutput] ' + event.detail.data, this.output);
    }) as EventListener, false);

    document.addEventListener('importOutput', ((event: CustomEvent) => {
        this.output.push(event.detail.data);
        //console.log('[importOutput] ' + event.detail.data, this.output);
    }) as EventListener, false);
  }
}
</script>
<style>
.output--container {
  white-space: pre-wrap;
  word-wrap: break-word;
}

pre#pre_log {
  height: 140px;
}

pre#pre_output {
  height: 260px;
}
</style>
