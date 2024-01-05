<template>
  <div>
    <h3>{{ message }}</h3>
    <button @click="count++">Click me</button>
    <p>Button clicks: {{ count }}</p>
  </div>
</template>

<script>
export default {
  data() {
    return {
      message: 'Hello Vue!',
      count: 0
    };
  }
};
</script>

<style scoped>
h3 {
  color: blue;
}
</style>
