<style scoped lang="scss">
td {
  color: white;
}
</style>
<template>
  <div>
    <b-sidebar
      shadow
      backdrop
      width="40%"
      v-model="show"
      bg-variant="dark"
      text-variant="light"
      id="collection-sidebar">
      <template #header>
        <div class="header__container">
          <p class="float-right">
            <b-icon-pencil-square alt="Edit"></b-icon-pencil-square>
          </p>
          <h4>User Play History</h4>
        </div>
      </template>
      <div class="px-3 py-2">
        <b-table-simple :items="tracks" hover small caption-top responsive>
          <b-thead head-variant="dark">
            <b-tr>
              <b-th>Time</b-th>
              <b-th>Title</b-th>
            </b-tr>
          </b-thead>
          <b-tbody>
            <b-tr
              :key="track.uuid"
              v-for="track in this.tracks">
              <b-td>{{track.media.seconds}}</b-td>
              <b-td>{{track.media.title}}</b-td>
            </b-tr>
          </b-tbody>
          <b-tfoot>
            <b-tr>
              <b-td colspan="2" class="text-left">
                Total Tracks: <b>{{this.tracks.length}}</b>&nbsp;&nbsp;Total Time: <b>5</b>
              </b-td>
            </b-tr>
          </b-tfoot>
        </b-table-simple>
      </div>
    </b-sidebar>
  </div>
</template>

<script lang="ts">
import { EventBus } from '../event-bus.js';
import { BButton, BSidebar, BTableSimple, IconsPlugin} from 'bootstrap-vue';
import { Component, Vue } from 'vue-property-decorator';

Vue.use(IconsPlugin)

@Component({
  components: {
    BButton,
    BSidebar,
    BTableSimple,
  },
})
export default class UserPlayHistory extends Vue {
  tracks: object;
  show: boolean;

  constructor() {
    super();
    this.tracks = {};
    this.show = false;

    EventBus.$on('sidebar-userplayhistory-open', () => {
      this.showSidebar();
      Vue.nextTick(() => {
        this.loadHistory();
      });
    });
  }

  showSidebar(): void {
    this.show = true;
  }

  loadHistory(): void {
    fetch('/history/list', {
      method: 'GET',
      credentials: 'same-origin'
    }).then(response =>
        response.json().then(json => {
          console.log(json);
          this.tracks = json;

          return true;
        })
    );
  }

  mounted(): void {
    console.log('Collection Sidebar mounted');
  }
}
</script>
