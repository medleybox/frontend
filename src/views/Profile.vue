<style scoped lang="scss">
.profile {
  padding-top: 10px;
}

.profile--view {
  .profile--avatar {
    width: 80%;
  }
}
</style>
<template>
  <div class="profile">
    <b-container fluid>
      <b-col md="8" offset-md="2">
        <div class="profile--view">
          <b-row>
            <b-col cols="3" sm="3">
              <div class="profile--avatar">
                <user-avatar size="14rem" />
                <b-button v-if="showUpload === false" @click="openUpload" variant="outline-primary" class="no-hover-colour">
                  <b-icon-pencil-square alt="Edit avatar" class="float-left"></b-icon-pencil-square>
                </b-button>
                <vue-dropzone v-if="showUpload" ref="myVueDropzone" id="dropzone" @vdropzone-success="fileUploaded" :options="dropzoneOptions"></vue-dropzone>
              </div>
            </b-col>
            <b-col cols="3" sm="3">
              <h4 class="profile--username">{{this.username}}</h4>
              <h5>Last seen: xxx</h5>
            </b-col>
          </b-row>
        </div>
      </b-col>
    </b-container>
  </div>
</template>

<script lang="ts">
import UserAvatar from '../components/UserAvatar.vue';
import { EventBus } from '../components/event-bus.js';
import { BButton, BIconPencilSquare } from 'bootstrap-vue';
import { Component, Vue } from 'vue-property-decorator';
import vue2Dropzone from 'vue2-dropzone';
import 'vue2-dropzone/dist/vue2Dropzone.min.css';

@Component({
  components: {
    'b-button': BButton,
    'b-icon-pencil-square': BIconPencilSquare,
    'user-avatar': UserAvatar,
    'vue-dropzone': vue2Dropzone,
  },
})
export default class Profile extends Vue {
  username!: string;
  avatar!: string;
  showUpload: boolean;

  constructor() {
    super();
    this.showUpload = false;
    console.log('profile')
  }

  created(): void {
    console.log('profile created()')
    this.loadProfileData((data: any) => {
      this.username = data.username;
    });
  }

  openUpload(): void {
    this.showUpload = true;
  }

  fileUploaded(): void {
    this.showUpload = false;
    this.reloadAvatar();
  }

  private data(): object {
    return {
      username: 'user_name',
      avatar: '/profile/avatar',
      dropzoneOptions: {
          url: '/profile/new-avatar',
          thumbnailWidth: 150,
          maxFilesize: 0.5,
          maxFiles: 1
      }
    };
  }

  private reloadAvatar()
  {
    EventBus.$emit('avatar-reload', {});
  }

  private loadProfileData(callback: (json: Array<string>) => void): void {
    fetch('/profile/data', {
        method: 'GET',
        credentials: 'same-origin',
    }).then((response) => {
        return response.json();
    }).then((json) => {
        callback(json);
    });
  }
}
</script>
