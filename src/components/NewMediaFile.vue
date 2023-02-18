<style scoped>
.modal-body {
  padding-top: 0px y!important;
}
.import-modal {
  margin-top: 10px;
}
@media screen and (min-width: 576px) {
  .import-thumbnail {
    height: 245px;
  }
}

.loader-svg {
  width: 100%;
  height: 185px;
  padding: 70px;
  color: var(--info);
}

.NewMediaFile {
  padding: 0;
}
.NewMediaFile .btn.btn-outline-primary {
  padding: 0;
}
</style>
<template>
<span class="NewMediaFile">
<b-button variant="outline-primary" v-b-modal.import>
  <b-icon-plus font-scale="2"></b-icon-plus>
</b-button>
<b-modal v-model="modalShow" id="import" title="Import new media" hide-footer static>
    <b-form @submit="onSubmit">
      <b-container class="import-modal">
        <b-form-row>
          <b-col cols="12">
            <b-form-input :disabled="this.checking === true" v-model="url" placeholder="Enter link to import" ref="urlInput" autocomplete="off"></b-form-input>
          </b-col>
        </b-form-row>
        <div v-if="uuid !== ''">
          <b-form-row>
            <b-col cols="12">
              <b-img class="import-thumbnail" fluid-grow :src="thumbnail"></b-img>
            </b-col>
          </b-form-row>
          <b-form-row>
            <b-col cols="10">
              <b-form-input v-model="title"></b-form-input>
            </b-col>
            <b-col cols="1">
              <b-button type="submit" variant="primary">Import</b-button>
            </b-col>
          </b-form-row>
        </div>
        <div v-if="this.checking === true">
          <b-row>
            <b-col cols="6" offset="3">
              <b-icon-circle-fill class="loader-svg" animation="throb" font-scale="4"></b-icon-circle-fill>
            </b-col>
          </b-row>
        </div>
      </b-container>
    </b-form>
  </b-modal>
</span>
</template>
<script lang="ts">
import { EventBus } from './event-bus.js';
import { BModal, BButton, BIconPlus, BIconCircleFill, BForm, BFormInput, BImg, BContainer, BFormRow, BCol } from 'bootstrap-vue';
import { Component, Watch, Vue } from 'vue-property-decorator';

@Component({
  components: {
    BModal,
    BButton,
    BIconPlus,
    BIconCircleFill,
    BForm,
    BFormInput,
    BImg,
    BContainer,
    BFormRow,
    BCol
  },
})
export default class NewMediaFile extends Vue {
  url = '';
  modalShow!: boolean;
  checking!: boolean;
  uuid!: string;
  title!: string;
  thumbnail!: string;

  @Watch('url')
  onPropertyChanged(value: string, oldValue: string) {
    if (value === oldValue) {
      return null;
    }

    this.check();
  }

  @Watch('modalShow')
  onModalShowChanged(value: boolean) {
    // Reset the modal when opening
    if (true === value) {
      this.url = '';
      this.checking = false;
    }

    this.$nextTick(() => {
      const urlInput = this.$refs.urlInput;

      (urlInput as HTMLElement).focus();
    });
  }

  check(): boolean {
    if ("" === this.url) {
      return false;
    }

    if (!this.youtube() && !this.soundcloud()) {
      return false;
    }

    this.checking = true
    this.uuid = '';
    this.title = '';
    this.thumbnail = '';
    const callback = (json) => {
      this.checking = false;
      this.uuid = json.metadata.uuid;
      this.title = json.metadata.title;
      this.thumbnail = json.metadata.thumbnail;
    };

    const errorCallback = (message) => {
      this.checking = false;
      this.uuid = '';
      this.title = '';
      this.thumbnail = '';
      this.modalShow = false;
      alert(message);
    };

    const formData = new FormData();
    formData.append('url', this.url);

    fetch('/check', {
      body: formData,
      method: 'POST',
      credentials: 'same-origin'
    }).then(response =>
        response.json().then(json => {
          if (false === json.check) {
            errorCallback(json.message);
            return false;
          }
          callback(json);

          return true;
        })
    );
    return true;
  }

  youtube(): boolean {
    //Check if youtube link - https://stackoverflow.com/a/31726735
    const regex = /((http(s)?:\/\/)?)(www\.)?((youtube\.com\/)|(youtu.be\/))[\S]+/gi;
    const matches = regex.exec(this.url);
    console.log(this.url, matches, regex);

    if (null !== matches) {
      return true;
    }

    return false;
  }

  soundcloud(): boolean {
    const regex = /((http(s)?:\/\/)?)(www\.)?((soundcloud\.com\/))[\S]+/gi;
    const matches = regex.exec(this.url);
    console.log(this.url, matches, regex);

    if (null !== matches) {
      return true;
    }

    return false;
  }

  // eslint-disable-next-line
  onSubmit(evt: any): void {
    evt.preventDefault();

    const formData = new FormData();
    formData.append('uuid', this.uuid);
    formData.append('title', this.title);
    formData.append('url', this.url);

    this.openImportLog();
    
    this.url = '';
    this.uuid = '';
    this.title = '';
    this.thumbnail = '';
    this.modalShow = false;

    fetch('/import-form', {
      body: formData,
      method: 'POST',
      credentials: 'same-origin'
    }).then(response =>
        response.json().then(json => {
          if (false === json.import) {
            if (true === json.attempt) {
              console.log('Failed to import but attempted!');
              return false;
            }

            alert('Failed to import. Please try again'); 
            return false;
          }

          return json;
        })
    );
  }

  private updateMediaList()  {
    EventBus.$emit('update-media-list', {});
  }

  private openImportLog()  {
    EventBus.$emit('media-import-log-start', this.uuid);
  }

  private data(): object {
    return {
      checking: false,
      modalShow: false,
      uuid: '',
      title: '',
      thumbnail: '',
    };
  }
}
</script>