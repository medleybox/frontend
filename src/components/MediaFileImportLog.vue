<template>
  <div class="import-log">
    <b-modal v-model="modalShow" size="lg" id="import-log" title="Importing media output" hide-footer>
       <b-container fluid class="edit-modal">
          <b-progress :value="progress" class="mb-3"></b-progress>
          <div class="" v-show="!this.showOutputModal">
            <h3>Import queued <b-spinner variant="primary" /></h3>
            <p>Waiting for job to start processing ...</p>
          </div>
          <div class="" v-show="this.showOutputModal">
            <div class="output--container output--log">
              <pre id='pre_log'>{{this.logToString}}</pre>
            </div>
            <h3>yt-dlp output</h3>
            <div class="output--container output--output">
              <pre id='pre_output'>{{this.outputToString}}</pre>
            </div>
          </div>
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

  get showOutputModal(): boolean {
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
      str += i + '\n';
    });
    return str;
  }

  step = (step: number): number => {
    return 100 / 7 * step;
  };

  public resetOutputState() {
    console.log('[MediaFileImportLog] resetOutputState()');
    this.output = [];
    this.log = [];
    this.progress = 0;
    this.status = 'queue';
  }

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

    console.log('[MediaFileImportLog] status: ' + value, this.progress);
    if ('start' === value) {
      this.output = [];
      this.log = [];
      this.progress = 0;
      console.log('[MediaFileImportLog] reset state');
    }
    if ('checkForDownload' === value) {
      // Smooth scroll to the bottom once finished
      const elem: HTMLInputElement = document.getElementById('pre_output') as HTMLInputElement;
      elem.scrollTo({
        top: 200000,
        behavior: 'smooth'
      });
    }
    if ('finish' === value) {
      setTimeout(() => {
        this.modalShow = false;
        this.resetOutputState();
      }, 5500);
    }
  }

  @Watch('output')
  onOutputChanged() {
    const elem: HTMLInputElement = document.getElementById('pre_output') as HTMLInputElement;
    if (null === elem) {
      return null;
    }
    elem.scrollTo(0, 200000);
  }

  @Watch('log')
  onLogChanged(value: Array<string>, oldValue: Array<string>) {
    if (value === oldValue) {
      return null;
    }
  }

  check(): boolean {
    console.log('[MediaFileImportLog] check()');
    return true;
  }

  private data(): object {
    return {
        modalShow: false,
        uuid: '',
        title: 'title',
        output: []
    };
  }

  constructor() {
    super();

    EventBus.$on('media-import-log-start', (uuid: string) => {
      this.uuid = uuid;
      Vue.nextTick(() => {
        this.resetOutputState();
        this.$bvModal.show('import-log');
      });
    });
  }

  mounted(): void {
    console.log('[MediaFileImportLog] importLogOutput mounted()');
    document.addEventListener('importLogOutput', ((event: CustomEvent) => {
        this.log.push(event.detail.data.data);
        this.status = event.detail.data.stage;
        // eslint-disable-next-line
    }) as EventListener, false);

    document.addEventListener('importOutput', ((event: CustomEvent) => {
        this.output.push(event.detail.data.lines);
        // eslint-disable-next-line
    }) as EventListener, false);
  }
}
</script>
<style lang="scss" scoped>
.output--container {
  white-space: pre-wrap;
  word-wrap: break-word;
}

pre {
  margin-bottom: 0px;
  overflow-x: hidden;

  &#pre_log {
    color: #fff;
    height: 165px;
  }

  &#pre_output {
    color: #fff;
    height: 274px;
  }
}
</style>
