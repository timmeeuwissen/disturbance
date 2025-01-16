<template lang="pug">
v-app(:theme="isAdmin ? adminTheme : undefined")
  v-app-bar(color="primary")
    v-app-bar-title Disturbance Monitor
    v-spacer
    v-switch(
      v-model="isAdmin"
      color="warning"
      hide-details
      inset
      label="Admin Mode"
      @change="handleAdminChange"
    )

  v-navigation-drawer(permanent)
    v-list(nav)
      v-list-item(to="/" prepend-icon="mdi-home" title="Home")
      v-list-item(to="/issues" prepend-icon="mdi-alert" title="Issues")
      v-list-item(to="/analytics" prepend-icon="mdi-chart-bar" title="Analytics")
      template(v-if="isAdmin")
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
const { isAdmin, adminTheme } = useAdmin()

const handleAdminChange = () => {
  // If admin mode is disabled and we're on an admin page, redirect to home
  if (!isAdmin.value && router.currentRoute.value.path.startsWith('/admin')) {
    router.push('/')
  }
}

// Watch for admin mode changes to update theme
watch(isAdmin, (newValue) => {
  // Force theme update by triggering a re-render
  nextTick()
})
</script>
