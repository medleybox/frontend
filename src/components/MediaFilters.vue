<style scoped>
.media-filters > .container-fluid {
  padding-left: 0px;
}

.media-filters_searchWrapper {
  width: 134%;
}
@media screen and (min-width: 500px) {
  .media-filters_searchWrapper {
    width: 100%;
  }
}
.media-filters_search{
  width: 75%;
}
.media-filters_search > .btn-group {
  width: 75;
}
.media-filters_search input.form-control {
  border-color: var(--primary);
}

.media-filters_type {
  width: 260%;
}
@media screen and (min-width: 340px) {
  .media-filters_type {
    width: 250%;
  }
}
@media screen and (min-width: 360px) {
  .media-filters_type {
    width: 222%;
  }
}
@media screen and (min-width: 385px) {
  .media-filters_type {
    width: 200%;
  }
}
@media screen and (min-width: 422px) {
  .media-filters_type {
    width: 168%;
  }
}
@media screen and (min-width: 520px) {
  .media-filters_type {
    width: 140%;
  }
}
@media screen and (min-width: 769px) {
  .media-filters_type {
    width: 128%;
  }
}
@media screen and (min-width: 850px) {
  .media-filters_type {
    width: 118%;
  }
}
@media screen and (min-width: 990px) {
  .media-filters_type {
    width: 100%;
  }
}
</style>
<template>
<div class="media-filters">
  <b-container fluid>
    <b-row no-gutters>
      <b-col cols="12" lg="4" no-gutters>
        <div class="media-filters_searchWrapper">
          <b-form>
            <div class="media-filters_search">
              <b-button-group>
                <b-form-input v-model="search" disabled placeholder="Type to search" ref="searchInput" autocomplete="off"></b-form-input>
                <b-button variant="outline-primary"><b-icon-search></b-icon-search></b-button>
              </b-button-group>
            </div>
          </b-form>
        </div>
      </b-col>
      <b-col cols=12 lg=8 no-gutters>
        <div class="media-filters_type d-flex justify-content-center">
          <b-tabs pills>
            <b-tab @click="changeShowType('home')" title="Home" active></b-tab>
            <b-tab @click="changeShowType('user')" title="Media"></b-tab>
            <b-tab title="Collections" disabled></b-tab>
            <b-tab title="Podcasts" disabled></b-tab>
          </b-tabs>
        </div>
      </b-col>
    </b-row>
  </b-container>
</div>
</template>

<script lang="ts">
import { EventBus } from './event-bus.js';
import { BButton, BCol, BButtonGroup, BIconSearch } from 'bootstrap-vue';
import { Component, Vue } from 'vue-property-decorator';

@Component({
  components: {
    BButton,
    BButtonGroup,
    BCol,
    BIconSearch,
  },
})
export default class MediaFilters extends Vue {
  type!: string;
  search!: string;

  public changeShowType(type: string) {
    EventBus.$emit('update-show-type', type);
  }

  constructor() {
    super();
    this.type = '';
    this.search = '';
  }
}
</script>