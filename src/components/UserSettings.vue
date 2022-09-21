<template>
  <div class="user_settings">
    <b-modal ref="userSettings" v-model="modalShow" id="settingsModal" title="Settings" hide-footer>
      <b-form @submit.stop.prevent @submit="onSubmit">
        <b-container fluid class="user-settings-modal">
          <b-form-group id="mobile-settings" label="Player settings:">
            <b-form-checkbox v-model="autoPlay" name="autoPlay" switch>
              Auto play
            </b-form-checkbox>
            <b-form-checkbox v-model="random" name="random" switch>
              Random
            </b-form-checkbox>
          </b-form-group>
          <b-form-group id="mobile-settings" label="Mobile:">
            <b-form-checkbox v-model="openVlc" name="openVlc" switch>
              Play via VLC
            </b-form-checkbox>
          </b-form-group>
          <b-button type="submit" variant="primary float-right">Save</b-button>
        </b-container>
      </b-form>
    </b-modal>
  </div>
</template>
<script lang="ts">
import { EventBus } from './event-bus.js';
import { BModal, BButton, BForm, BFormGroup, BFormInput, BContainer, BFormRow } from 'bootstrap-vue';
import { Component, Watch, Prop, Vue } from 'vue-property-decorator';

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
export default class UserSettings extends Vue {
  @Prop() readonly settings!: any;
  modalShow!: boolean;
  autoPlay: boolean;
  random: boolean;
  openVlc: boolean;

  private data(): object {
    return {
      modalShow: false
    };
  }

  @Watch('modalShow')
  onPropertyChangedModalShow(value: any): void {
    this.autoPlay = this.settings.autoPlay;
    this.random = this.settings.random;
    this.openVlc = this.settings.openVlc;
  }

  constructor() {
    super();
    this.autoPlay = false;
    this.random = false;
    this.openVlc = false;
  }

  onSubmit(): void {
    const formData = new FormData();
    formData.append('autoPlay', this.autoPlay ? '1' : '0');
    formData.append('random', this.random ? '1' : '0');
    formData.append('openVlc', this.openVlc ? '1' : '0');
    fetch(process.env.VUE_APP_BASE_URL + '/user/update-settings', {
      body: formData,
      method: 'POST',
      credentials: 'same-origin'
    }).then(response => {
      response.json().then(json => {
        this.resetModal();
        if (false === json.updated) {
          alert('Unable to save settings. Please try again');
          return false;
        }

        this.$bvToast.toast('Your settings have been saved', {
          title: `Settings updated!`,
          variant: 'success',
          solid: true
        });

        EventBus.$emit('settings-updated');

        return json;
      })
    }).catch(error => {
        this.resetModal();
        alert('Unable to save settings. Please try again');
    });
  }

  private resetModal()  {
    this.$bvModal.hide('settingsModal');
  }
}
</script>
