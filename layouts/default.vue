<template lang="pug">
  v-app
    v-app-bar(color="primary")
      v-app-bar-title Disturbance Monitor
      v-spacer
      v-tabs(v-model="activeTab" color="white")
        v-tab(to="/") New Issue
        v-tab(to="/issues") Issues Overview
        v-tab(to="/analytics") Analytics

    v-main
      v-container(fluid)
        v-row(justify="center")
          v-col(cols="12" lg="10")
            slot

    v-snackbar(
      v-model="snackbar.show"
      :color="snackbar.color"
      :timeout="3000"
      location="top"
    )
      | {{ snackbar.text }}
      template(#actions)
        v-btn(color="white" variant="text" @click="snackbar.show = false") Close
</template>

<script setup lang="ts">
import { ref, reactive, watch, provide } from 'vue'
import { useRoute } from '#app'

const activeTab = ref(0)

// Global snackbar state
export const snackbar = reactive({
  show: false,
  text: '',
  color: 'success'
})

// Show snackbar message
export const showMessage = (text: string, color: 'success' | 'error' = 'success') => {
  snackbar.text = text
  snackbar.color = color
  snackbar.show = true
}

// Update active tab based on current route
watch(() => useRoute().path, (newPath) => {
  switch (newPath) {
    case '/':
      activeTab.value = 0
      break
    case '/issues':
      activeTab.value = 1
      break
    case '/analytics':
      activeTab.value = 2
      break
  }
}, { immediate: true })

// Provide snackbar functionality to child components
provide('showMessage', showMessage)
</script>

<style lang="sass">
// Layout styles
</style>
