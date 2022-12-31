<style scoped lang="scss">
.b-sidebar {
  background-color: #1f5e61 !important;
  color: white;

  > .b-sidebar-header {
    color: white;
  }

  .header__container {
    width: 98%;
  }
}

td {
  color: white;
}

</style>
<template>
  <div>
    <b-button v-b-toggle.collection-sidebar>Toggle Sidebar</b-button>
    <b-sidebar :title="title" bg-variant="dark" text-variant="light" shadow backdrop id="collection-sidebar">
      <template #header>
        <div class="header__container"><p class="float-right"><a>edit</a></p> <h4>{{title}}</h4></div>
      </template>
      <div class="px-3 py-2">
        <b-table-simple hover small caption-top responsive>
          <b-thead head-variant="dark">
            <b-tr>
              <b-th>Time</b-th>
              <b-th>Title</b-th>
            </b-tr>
          </b-thead>
          <b-tbody>
            <b-tr>
              <b-td>2:34</b-td>
              <b-td>title long here dasd</b-td>
            </b-tr>
            <b-tr>
              <b-td>4:23</b-td>
              <b-td>15</b-td>
            </b-tr>
            <b-tr>
              <b-td>2:53</b-td>
              <b-td>51</b-td>
            </b-tr>
            <b-tr>
              <b-td>6:32</b-td>
              <b-td>38</b-td>
            </b-tr>
            <b-tr>
              <b-td>3:14</b-td>
              <b-td>19</b-td>
            </b-tr>
          </b-tbody>
          <b-tfoot>
            <b-tr>
              <b-td colspan="2" class="text-left">
                Total Rows: <b>5</b>
              </b-td>
            </b-tr>
          </b-tfoot>
        </b-table-simple>
      </div>
    </b-sidebar>
  </div>
</template>

<script lang="ts">
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
export default class Sidebar extends Vue {
  title: string;

  constructor() {
    super();
    this.title = 'set in mounted';
  }

  mounted(): void {
    console.log('Collection Sidebar mounted');
  }
}
</script>
