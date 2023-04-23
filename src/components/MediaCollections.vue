<style scoped lang="scss">
.mediacollection--container {
  height: 150px;
}

.mediacollection--artwork {
  padding-top: 10%;
  z-index: 100;
  display: flex;
  position: absolute;
  padding-left: 29%;

  &:hover {
    cursor: pointer;
  }

  & > svg.b-icon {
    color: red;
    font-size: 70px;
  }
}
</style>
<template>
  <div>
    <h1>My Collections <b-button disabled size="sm" variant="outline-primary"><b-icon-plus font-scale="2"></b-icon-plus></b-button></h1>
    <b-row no-gutters>
      <b-col cols="12" md="3" lg="2">
        <b-card>
          <div class="mediacollection--container">
            <div class="mediacollection--artwork" @click="openFavorites">
              <b-icon :icon="icon" animation="throb"></b-icon>
            </div>
          </div>
          <template #footer>
            <h4 class="mediacollection--title">My Favorites</h4>
          </template>
        </b-card>
      </b-col>
    </b-row>
  </div>
</template>

<script lang="ts">
import { EventBus } from './event-bus.js';
import { BCard, BIcon, BIconPlus, IconsPlugin} from 'bootstrap-vue';
import { Component, Vue } from 'vue-property-decorator';

Vue.use(IconsPlugin)

@Component({
  components: {
    BCard,
    BIcon,
    BIconPlus
  },
})
export default class MediaCollections extends Vue {
  private data(): object {
    return {
      icon: 'suit-heart-fill'
    };
  }

  constructor() {
    super();
  }

  openFavorites() {
    EventBus.$emit('sidebar-mediacollection-load');
  }

  mounted(): void {
    console.log('MediaCollections mounted');
  }
}
</script>
