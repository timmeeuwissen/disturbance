<template lang="pug">
v-app(:theme="admin.store.isAdmin ? admin.adminTheme : undefined")
  v-app-bar(color="primary")
    v-app-bar-title Disturbance Monitor
    v-spacer
    v-switch(
      :model-value="admin.store.isAdmin"
      color="warning"
      hide-details
      inset
      label="Admin Mode"
      @update:model-value="admin.toggleAdmin"
    )

  v-navigation-drawer(permanent)
    v-list(nav)
      v-list-item(to="/" prepend-icon="mdi-home" title="Home")
      v-list-item(to="/new" prepend-icon="mdi-new-box" title="New")
      v-list-item(to="/issues" prepend-icon="mdi-alert" title="Issues")
      v-list-item(to="/analytics" prepend-icon="mdi-chart-bar" title="Analytics")
      template(v-if="admin.store.isAdmin")
        v-divider
        v-list-subheader Admin
        v-list-item(
          to="/admin/sql"
          prepend-icon="mdi-database"
          title="SQL Admin"
          color="warning"
        )
        v-list-item(
          to="/admin/lists"
          prepend-icon="mdi-format-list-bulleted"
          title="Lists"
          color="warning"
        )

  v-main
    v-container(fluid)
      slot
</template>

<script setup lang="ts">
import { watch } from 'vue'
import { useAdmin } from '~/composables/useAdmin'
import { useRouter } from '#app'

const router = useRouter()
const admin = useAdmin()

// Watch for admin mode changes to handle navigation
watch(() => admin.store.isAdmin, (newValue) => {
  // If admin mode is disabled and we're on an admin page, redirect to home
  if (!newValue && router.currentRoute.value.path.startsWith('/admin')) {
    router.push('/')
  }
})
</script>
