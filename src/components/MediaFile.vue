<template>
    <div class="file">
      <b-img-lazy v-bind="mainProps" rounded :src="media.thumbnail" />
      <p>{{media.uuid}} - {{media.title}}</p>
    </div>
</template>

<script lang="ts">
import { BImgLazy, BButton } from 'bootstrap-vue';
import { Component, Prop, Vue } from 'vue-property-decorator';

@Component({
  components: {
    BImgLazy,
    BButton
  },
})
export default class MediaFile extends Vue {
  @Prop() readonly media!: object;
  private data(): object {
    return {
        mainProps: {blank: true, blankColor: '#777', width: 640, height: 360, class: 'm1'}
    };
  }

  mounted(): void {
      console.log('mounted');
  }
}

</script>
