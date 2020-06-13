<template>
  <div class="import">
    <b-button v-b-modal.import>New Import</b-button>

    <b-modal v-model="modalShow" id="import" title="Import new media" hide-footer>
      <b-form @submit="onSubmit">
        <b-container class="import-modal">
          <b-form-row>
            <b-col cols="10">
              <b-form-input v-model="url" placeholder="Enter link to import" autofocus></b-form-input>
            </b-col>
              <b-col cols="1">
                <b-button type="submit" variant="primary">Submit</b-button>
              </b-col>
            </b-form-row>
          </b-container>
      </b-form>
    </b-modal>
  </div>
</template>
<script lang="ts">
import { BModal, BButton, BForm, BFormInput, BContainer, BFormRow, BCol } from 'bootstrap-vue';
import { Component, Prop, Vue } from 'vue-property-decorator';

@Component({
  components: {
    BModal,
    BButton,
    BForm,
    BFormInput,
    BContainer,
    BFormRow,
    BCol
  },
})
export default class NewMediaFile extends Vue {
  @Prop() url!: string;
  modalShow!: boolean;

  // eslint-disable-next-line
  onSubmit(evt: any): void {
    evt.preventDefault();

    const formData = new FormData();
    formData.append('url', this.url);

    this.url = '';
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
        modalShow: false,
    };
  }
}
</script>
<style>
.import-modal {
  margin-top: 20px;
}
</style>
