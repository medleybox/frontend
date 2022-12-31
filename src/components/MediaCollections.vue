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

  & > svg.b-icon {
    color: red;
    font-size: 70px;
  }
}
</style>
<template>
  <div>
    <h1>My Collections</h1>
    <b-row no-gutters>
      <b-col cols="12" md="3" lg="2">
        <b-card>
          <div class="mediacollection--container">
            <div class="mediacollection--artwork">
              <b-icon :icon="icon" animation="throb"></b-icon>
            </div>
          </div>
          <template #footer>
            <h4 class="mediacollection--title">Favorites</h4>
          </template>
        </b-card>
      </b-col>
    </b-row>
  </div>
</template>

<script lang="ts">
import { BCard, BIcon, IconsPlugin} from 'bootstrap-vue';
import { Component, Vue } from 'vue-property-decorator';

Vue.use(IconsPlugin)

@Component({
  components: {
    BCard,
    BIcon
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

  mounted(): void {
    //this.resolveThumbnail();
    console.log('MediaCollections mounted');
  }
}
</script>
