<script lang="ts">
definePageMeta({
  middleware: ['admin']
})
</script>

<template lang="pug">
v-container(fluid)
  v-row
    v-col(cols="12")
      h1.text-warning.mb-4 SQL Administration

  v-row
    v-col(cols="12")
      admin-erd-diagram

  v-row
    v-col(cols="12")
      admin-sql-editor
</template>

<script setup lang="ts">
// Components are auto-imported by Nuxt
</script>
