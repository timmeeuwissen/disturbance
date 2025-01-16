<template lang="pug">
v-container(fluid)
  v-row
    v-col(cols="12")
      h1.text-warning.mb-4 Disturbance Management

  v-row
    v-col(cols="12" md="6" lg="4")
      v-card(variant="outlined" :to="'/issues'" class="mb-4")
        v-card-title Issues
        v-card-text
          p View and manage all disturbance issues. Track their status, severity, and progress.

    v-col(cols="12" md="6" lg="4")
      v-card(variant="outlined" :to="'/analytics'" class="mb-4")
        v-card-title Analytics
        v-card-text
          p Analyze disturbance data with interactive charts and reports.

  v-row(v-if="admin.store.isAdmin")
    v-col(cols="12")
      h2.text-warning.mb-4 Administration

    v-col(cols="12" md="6" lg="4")
      v-card(variant="outlined" :to="'/admin/lists'" class="mb-4")
        v-card-title List Management
        v-card-text
          p Manage system enumerations like statuses, severities, and reference types.

    v-col(cols="12" md="6" lg="4")
      v-card(variant="outlined" :to="'/admin/sql'" class="mb-4")
        v-card-title SQL Administration
        v-card-text
          p Direct database access with SQL editor and schema visualization.
</template>

<script setup lang="ts">
const admin = useAdmin()
</script>

<style scoped lang="sass">
.v-card
  height: 100%
  transition: transform 0.2s, box-shadow 0.2s
  cursor: pointer

  &:hover
    transform: translateY(-2px)
    box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1)

  .v-card-title
    color: var(--v-warning-base)
    font-size: 1.25rem

  .v-card-text
    color: var(--v-grey-darken1)
    p
      margin: 0
      line-height: 1.5
</style>
