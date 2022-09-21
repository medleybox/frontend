<template>
  <div class="edit">
    <b-modal ref="userChangePassword" v-model="modalShow" id="passwordModal" title="Change password" hide-footer>
      <b-form @submit.stop.prevent @submit="onSubmit">
        <b-container fluid class="update-password-modal">
            <b-form-group id="input-group-importuser" label="New password:" label-for="input-importuser">
              <b-form-input type="password" autofocus="autofocus" autocomplete="new-password" v-model="password" :state="validation" id="feedback-user"></b-form-input>
              <b-form-invalid-feedback :v-show="this.password !== ''" :state="validation">
                Your password must be 6 characters long.
              </b-form-invalid-feedback>
              <b-form-valid-feedback :v-show="this.password !== ''" :state="validation">
                Looks Good.
              </b-form-valid-feedback>
            </b-form-group>
            <b-button type="submit" :disabled="false === this.validation" variant="primary float-right">Save</b-button>
        </b-container>
      </b-form>
    </b-modal>
  </div>
</template>
<script lang="ts">
import { BModal, BButton, BForm, BFormGroup, BFormInput, BContainer, BFormRow } from 'bootstrap-vue';
import { Component, Watch, Vue } from 'vue-property-decorator';

@Component({
  components: {
    BModal,
    BButton,
    BForm,
    BFormGroup,
    BFormInput,
    BContainer,
    BFormRow,
  },
})
export default class UserChangePassword extends Vue {
  modalShow!: boolean;
  fetching!: boolean;
  password!: string;

  private data(): object {
    return {
      modalShow: false
    };
  }

  constructor() {
    super();
    this.password = '';
    this.fetching = false;
  }

  get validation() {
    return this.password.length > 6
  }

  onSubmit(): void {
    const formData = new FormData();
    formData.append('password', this.password);
    fetch(process.env.VUE_APP_BASE_URL + '/user/update-password', {
      body: formData,
      method: 'POST',
      credentials: 'same-origin'
    }).then(response => {
      response.json().then(json => {
        this.resetModal();
        if (false === json.updated) {
          alert('Unable to update password. Please try again');
          return false;
        }

        this.$bvToast.toast('Toast body content', {
          title: `Your password has been updated`,
          variant: 'success',
          solid: true
        })

        return json;
      })
    }).catch(error => {
        this.resetModal();
        alert('Unable to update password. Please try again');
    });
  }

  private resetModal()  {
    this.$bvModal.hide('passwordModal');
    this.password = '';
    this.fetching = false;
  }
}
</script>
