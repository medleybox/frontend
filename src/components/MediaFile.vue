<template>
  <div class="col-3">
    <div class="card">
      <b-card
        :title="media.title"
        :img-src="media.thumbnail"
        img-alt="Image"
        img-top
        style=""
        class=""
      >
        <b-card-text>
          <h5 style="height: 50px">{{media.title}}</h5>
          {{media.seconds}} - <b-button variant="primary" @click="play">Play</b-button> <b-button variant="danger" @click="remove">remove</b-button>
        </b-card-text>
      </b-card>
    </div>
  </div>
</template>

<script lang="ts">
import { EventBus } from './event-bus.js';
import { BCard, BImgLazy, BButton, ModalPlugin } from 'bootstrap-vue';
import { Component, Prop, Vue } from 'vue-property-decorator';

Vue.use(ModalPlugin);

@Component({
  components: {
    BCard,
    BImgLazy,
    BButton
  },
})
export default class MediaFile extends Vue {
  @Prop() readonly media!: any;
  private data(): object {
    return {
        mainProps: {blank: true, blankColor: '#777', width: 640, height: 360, class: 'm1'}
    };
  }

  private play() {
    EventBus.$emit('stream-media-start', {uuid: this.media.uuid, stream: this.media.stream});
  }

  private remove() {
    this.$bvModal.msgBoxConfirm(`Please confirm that you want to delete "${this.media.title}"`, {
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
            fetch(process.env.VUE_APP_BASE_URL + this.media.delete, {
                method: 'GET',
                credentials: 'same-origin',
            }).then((response) => {
                return response.json();
            }).then((json) => {
                if (true !== json.delete) {
                    alert('Unable to remove media');
                    return false;
                }
                this.updateMediaList();
                return true;
            });
        }
    }).catch(err => {
      // An error occurred
    });

  }

  private updateMediaList()  {
      EventBus.$emit('update-media-list', {});
  }

  mounted(): void {
      console.log('mounted');
  }
}
</script>