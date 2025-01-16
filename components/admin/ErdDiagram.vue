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
      .mermaid-wrapper(ref="mermaidWrapper")
        .mermaid(
          ref="mermaidContainer"
          @mousedown="startDrag"
          @mousemove="doDrag"
          @mouseup="stopDrag"
          @mouseleave="stopDrag"
        )
        .zoom-controls.pa-2
          v-btn-group
            v-btn(
              icon="mdi-plus"
              variant="text"
              size="small"
              @click="zoom(0.1)"
            )
            v-btn(
              icon="mdi-minus"
              variant="text"
              size="small"
              @click="zoom(-0.1)"
            )
            v-btn(
              icon="mdi-refresh"
              variant="text"
              size="small"
              @click="resetView"
            )
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import mermaid from 'mermaid'

const collapsed = ref(true)
const mermaidWrapper = ref<HTMLElement | null>(null)
const mermaidContainer = ref<HTMLElement | null>(null)
const scale = ref(1)
const position = ref({ x: 0, y: 0 })
let isDragging = false
let startPosition = { x: 0, y: 0 }

// Pan functionality
const startDrag = (e: MouseEvent) => {
  if (!mermaidContainer.value) return
  isDragging = true
  startPosition = {
    x: e.clientX - position.value.x,
    y: e.clientY - position.value.y
  }
  mermaidContainer.value.style.cursor = 'grabbing'
}

const doDrag = (e: MouseEvent) => {
  if (!isDragging || !mermaidContainer.value) return
  position.value = {
    x: e.clientX - startPosition.x,
    y: e.clientY - startPosition.y
  }
  updateTransform()
}

const stopDrag = () => {
  if (!mermaidContainer.value) return
  isDragging = false
  mermaidContainer.value.style.cursor = 'grab'
}

// Zoom functionality
const zoom = (delta: number) => {
  scale.value = Math.min(Math.max(0.5, scale.value + delta), 2)
  updateTransform()
}

const resetView = () => {
  scale.value = 1
  position.value = { x: 0, y: 0 }
  updateTransform()
}

const updateTransform = () => {
  if (!mermaidContainer.value) return
  mermaidContainer.value.style.transform = 
    `translate(${position.value.x}px, ${position.value.y}px) scale(${scale.value})`
}

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
      resetView()
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
  position: relative;
  overflow: hidden;
  height: 600px;
}

.mermaid-wrapper {
  position: relative;
  width: 100%;
  height: 100%;
}

.mermaid {
  position: absolute;
  background-color: white;
  padding: 1rem;
  border-radius: 4px;
  cursor: grab;
  transform-origin: center;
  transition: transform 0.1s;
}

.zoom-controls {
  position: absolute;
  top: 0;
  right: 0;
  z-index: 1;
  background-color: rgba(255, 255, 255, 0.9);
  border-radius: 4px;
}

:deep(#erd-diagram) {
  width: 100%;
  height: auto;
}
</style>
