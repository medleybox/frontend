<style lang="scss">
.vjs-tree {
  .vjs-tree-node.is-highlight,
  .vjs-tree-node:hover {
    background-color: #00969345 !important;
  }

  .vjs-key,
  .vjs-node-index {
    color: var(--light) !important;
  }

  .vjs-carets > svg {
    filter: invert(1);
  }

  .vjs-tree-node .vjs-indent-unit.has-line {
    border-left: 1px dashed #009693;
  }

  .vjs-tree-brackets {
    color: #009693;
  }
}
</style>
<template>
  <div class="edit">
    <b-modal ref="editModal" v-model="modalShow" id="edit" title="Edit media" hide-footer>
      <b-container fluid class="edit-modal">
        <div v-if="fetching !== true && metadata.loaded === true">
          <b-col cols=12 no-gutters>
            <div class="d-flex justify-content-center">
              <b-tabs pills>
                <b-tab @click="tab = 'data'" title="Data" active></b-tab>
                <b-tab @click="tab = 'metadata'" title="Metadata"></b-tab>
                <b-tab title="Thubmnail" disabled></b-tab>
              </b-tabs>
            </div>
          </b-col>
          <b-col cols=12 no-gutters>
            <div v-if="tab == 'data'" class="tab--data">
              <b-form @submit="onSubmit">
                <b-form-group id="input-group-title" label="Title" label-for="input-title">
                  <b-form-input id="input-title" v-model="metadata.title"></b-form-input>
                </b-form-group>

                <b-form-group id="input-group-provider" label="Provider Class" label-for="input-provider">
                  <b-form-input disabled id="input-provider" v-model="metadata.metadata.provider"></b-form-input>
                </b-form-group>

                <b-form-group id="input-group-size" label="Size" label-for="input-size">
                  <b-form-input disabled id="input-size" v-model="mediaSize"></b-form-input>
                </b-form-group>

                <b-form-group id="input-group-imported" label="Date Imported" label-for="input-imported">
                  <b-form-input disabled id="input-imported" v-model="metadata.metadata.imported"></b-form-input>
                </b-form-group>

                <b-form-group id="input-group-importuser" label="User Imported" label-for="input-importuser">
                  <b-form-input disabled id="input-importuser" v-model="metadata.importuser"></b-form-input>
                </b-form-group>

                <div class="float-right">
                  <b-button-group>
                    <b-button type="submit" variant="primary">Save</b-button>
                    <b-button type="button" variant="danger" @click="remove">Delete</b-button>
                  </b-button-group>
                </div>
              </b-form>
            </div>
            <div v-if="tab == 'metadata'" class="tab--data">
              <vue-json-pretty :show-icon=true :show-line=true :show-line-number=true :collapsed-on-click-brackets=true :data="metadata" />
            </div>
          </b-col>
        </div>
      </b-container>
    </b-modal>
  </div>
</template>
<script lang="ts">
import { EventBus } from './event-bus.js';
import { BModal, BButton, BForm, BFormGroup, BFormInput, BImg, BContainer, BFormRow, BCol } from 'bootstrap-vue';
import { Component, Vue } from 'vue-property-decorator';
import prettyBytes from 'pretty-bytes';
import VueJsonPretty from 'vue-json-pretty';
import 'vue-json-pretty/lib/styles.css';

interface Metadata {
  [key: string]: any;
}

interface EntryMetadata {
    loaded: boolean;
    title: string;
    metadata: Metadata;
    delete: string;
}

type MetadataCallback = () => void;

@Component({
  components: {
    BModal,
    BButton,
    BForm,
    BFormGroup,
    BFormInput,
    BImg,
    BContainer,
    BFormRow,
    BCol,
    VueJsonPretty
  },
})
export default class NewMediaFile extends Vue {
  modalShow!: boolean;
  fetching!: boolean;
  uuid!: string;
  metadata!: EntryMetadata;
  tab = 'data';

  private loadMedadata(uuid: string, callback: MetadataCallback|undefined|null): void {
    this.uuid = uuid;
    this.fetching = true;
    fetch(process.env.VUE_APP_BASE_URL + '/media-file/metadata/' + this.uuid, {
        method: 'GET',
        credentials: 'same-origin',
    }).then((response) => {
        return response.json();
    }).then((json) => {
        this.fetching = false;
        this.metadata = json;

        if (undefined !== callback && null !== callback) {
          callback();
        }
    });
  }

  // eslint-disable-next-line
  onSubmit(evt: any): void {
    evt.preventDefault();

    const formData = new FormData();
    formData.append('uuid', this.uuid);
    formData.append('title', this.metadata.title);

    this.resetModal();

    fetch(process.env.VUE_APP_BASE_URL + '/media-file/update', {
      body: formData,
      method: 'POST',
      credentials: 'same-origin'
    }).then(response =>
        response.json().then(json => {
          if (false === json.import) {
            alert('Failed to update MediaFile');
          }

          return json;
        })
    );
  }

  private resetModal()  {
    //EventBus.$emit('update-media-list', {});
    this.$bvModal.hide('edit');
    this.uuid = '';
    this.metadata = {loaded: false, title: '', metadata: {}, delete: ''};
    this.fetching = false;
  }

  private get mediaSize() {
    if (null === this.metadata.metadata.size) {
      return '0';
    }

    return prettyBytes(this.metadata.metadata.size);
  }

  private remove() {
    this.$bvModal.msgBoxConfirm(`Please confirm that you want to delete "${this.metadata.title}"`, {
        title: 'Please Confirm',
        size: 'sm',
        buttonSize: 'sm',
        okVariant: 'danger',
        okTitle: 'YES',
        cancelTitle: 'NO',
        footerClass: 'p-2',
        hideHeaderClose: false,
        centered: true
    }).then(value => {
        if (true === value) {
            console.log('edit hide');
            this.$bvModal.hide('edit');
            fetch(process.env.VUE_APP_BASE_URL + this.metadata.delete, {
                method: 'GET',
                credentials: 'same-origin',
            }).then((response) => {
                return response.json();
            }).then((json) => {
                if (true !== json.delete) {
                    alert('Unable to remove media');
                    return false;
                }
                this.resetModal();

                return true;
            });
        }
    }).catch(err => {
      // An error occurred
      console.log(err);
    });
  }

  private data(): object {
    return {
      modalShow: false,
      metadata: {
        loaded: false,
        title: '',  
        metadata: {},
        delete: ''
      }
    };
  }

  constructor() {
    super();
    this.uuid = '';
    this.fetching = false;

    EventBus.$on('media-edit', (uuid: string) => {
      this.loadMedadata(uuid, null);
      Vue.nextTick(() => {
        this.$bvModal.show('edit');
      });
    });
    EventBus.$on('media-delete', (uuid: string) => {
      this.loadMedadata(uuid, () => {this.remove()});
    });
  }
}
</script>