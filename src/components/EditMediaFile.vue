<template>
  <div class="edit">
    <b-modal ref="editModal" v-model="modalShow" id="edit" title="Edit media" hide-footer>
      <b-form @submit="onSubmit">
        <b-container fluid class="edit-modal">
          <div v-if="fetching !== true && metadata.loaded === true">
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

            <b-button type="submit" variant="primary">Save</b-button>
            <b-button type="button" variant="danger" @click="remove">Delete</b-button>
          </div>
        </b-container>
      </b-form>
    </b-modal>
  </div>
</template>
<script lang="ts">
import { EventBus } from './event-bus.js';
import { BModal, BButton, BForm, BFormGroup, BFormInput, BImg, BContainer, BFormRow, BCol } from 'bootstrap-vue';
import { Component, Vue } from 'vue-property-decorator';
import prettyBytes from 'pretty-bytes';

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
    BCol
  },
})
export default class NewMediaFile extends Vue {
  modalShow!: boolean;
  fetching!: boolean;
  uuid!: string;
  metadata!: EntryMetadata;

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
<style scoped>
.import-modal {
  margin-top: 20px;
}
</style>