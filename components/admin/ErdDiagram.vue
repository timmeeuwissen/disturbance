<template lang="pug">
v-card(variant="outlined")
  v-card-title
    span Database Schema
    v-spacer
    v-btn(
      icon="mdi-chevron-up"
      variant="text"
      v-if="!collapsed"
      @click="collapsed = true"
    )
    v-btn(
      icon="mdi-chevron-down"
      variant="text"
      v-else
      @click="collapsed = false"
    )
  v-expand-transition
    v-card-text(v-show="!collapsed")
      .mermaid(ref="mermaidContainer")
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import mermaid from 'mermaid'

const collapsed = ref(true)
const mermaidContainer = ref<HTMLElement | null>(null)

// Fetch and render ERD diagram
const generateERD = async () => {
  try {
    const { mermaidCode } = await $fetch<{ mermaidCode: string }>('/api/admin/schema')

    // Initialize Mermaid with custom theme
    await mermaid.initialize({
      startOnLoad: false,
      theme: 'default',
      er: {
        useMaxWidth: false,
        diagramPadding: 20,
        entityPadding: 15,
        fontSize: 12
      },
      themeVariables: {
        primaryColor: '#FFB74D',
        primaryTextColor: '#000',
        primaryBorderColor: '#FF9800',
        lineColor: '#FF9800',
        secondaryColor: '#FFF3E0',
        tertiaryColor: '#FFF3E0'
      }
    })

    if (mermaidContainer.value) {
      const { svg } = await mermaid.render('erd-diagram', mermaidCode)
      mermaidContainer.value.innerHTML = svg
    }
  } catch (error) {
    console.error('Error generating ERD:', error)
  }
}

onMounted(async () => {
  await generateERD()
})
</script>

<style scoped>
.v-card-text {
  overflow-x: auto;
}

.mermaid {
  background-color: white;
  padding: 1rem;
  border-radius: 4px;
}

:deep(#erd-diagram) {
  width: 100%;
  height: auto;
}
</style>
