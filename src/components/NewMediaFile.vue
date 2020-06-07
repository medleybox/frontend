<template>
    <div class="import">
      <b-button v-b-modal.modal-1>New Import</b-button>

      <b-modal id="modal-1" title="BootstrapVue">
          <b-form @submit="onSubmit">
            <b-form-input v-model="url" placeholder="Enter link to import"></b-form-input>
            <b-button type="submit" variant="primary">Submit</b-button>
          </b-form>
      </b-modal>
    </div>
</template>

<script lang="ts">
import { BModal, BButton, BForm, BFormInput } from 'bootstrap-vue';
import { Component, Prop, Vue } from 'vue-property-decorator';

@Component({
  components: {
    BModal,
    BButton,
    BForm,
    BFormInput
  },
})
export default class NewMediaFile extends Vue {
  @Prop() readonly url!: string;
  onSubmit(evt: any): void {
    evt.preventDefault();

    const formData = new FormData();
    formData.append('url', this.url);

    fetch('/import-form', {
        body: formData,
        method: 'POST',
        credentials: 'same-origin'
    }).then(response =>
        response.json().then(json => {
          return json;
        })
    );
  }
}

</script>
