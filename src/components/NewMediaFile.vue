<template>
  <div class="import">
    <b-button v-b-modal.import>New Import</b-button>

    <b-modal v-model="modalShow" id="import" title="Import new media" hide-footer>
      <b-form @submit="onSubmit">
        <b-container class="import-modal">
          <b-form-row>
            <b-col cols="12">
              <b-form-input :disabled="this.checking === true" v-model="url" placeholder="Enter link to import" autofocus></b-form-input>
            </b-col>
          </b-form-row>
          <div v-if="uuid !== ''">
            <b-form-row>
              <b-col cols="12">
                <b-img fluid-grow :src="thumbnail"></b-img>
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
        </b-container>
      </b-form>
    </b-modal>
  </div>
</template>
<script lang="ts">
import { BModal, BButton, BForm, BFormInput, BImg, BContainer, BFormRow, BCol } from 'bootstrap-vue';
import { Component, Prop, Watch, Vue } from 'vue-property-decorator';

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
export default class NewMediaFile extends Vue {
  @Prop() url!: string;
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

  check(): boolean {
    if ("" === this.url) {
      return false;
    }

    if (!this.youtube()) {
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
      alert(message);
    };

    const formData = new FormData();
    formData.append('url', this.url);

    fetch(process.env.VUE_APP_BASE_URL + '/check', {
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

    this.url = '';
    this.uuid = '';
    this.title = '';
    this.thumbnail = '';
    this.modalShow = false;

    fetch(process.env.VUE_APP_BASE_URL + '/import-form', {
      body: formData,
      method: 'POST',
      credentials: 'same-origin'
    }).then(response =>
        response.json().then(json => {
          if (false === json.import) {
            alert('Failed to import');
          }
          return json;
        })
    );
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
<style>
.import-modal {
  margin-top: 20px;
}
</style>
