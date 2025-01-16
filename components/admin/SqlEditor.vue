<template lang="pug">
v-card
  v-card-title SQL Query Editor
  v-card-text
    div(ref="editorContainer" style="height: 300px; border: 1px solid #ccc")
    v-btn.mt-4(
      color="warning"
      prepend-icon="mdi-play"
      @click="executeQuery"
      :loading="loading"
    ) Execute Query

  v-card-text(v-if="result")
    v-data-table(
      :headers="headers"
      :items="result.rows"
      :items-per-page="10"
      class="elevation-1"
    )
      template(#bottom)
        .d-flex.align-center.justify-space-between.pa-4
          span Total rows: {{ result.rowCount }}
          v-btn(
            color="warning"
            prepend-icon="mdi-download"
            @click="downloadResults"
            :disabled="!result.rows.length"
          ) Export Results
</template>

<script setup lang="ts">
import { ref, onMounted, onBeforeUnmount } from 'vue'
import loader from '@monaco-editor/loader'
import type { SqlQueryResult } from '~/types'

const editorContainer = ref<HTMLElement | null>(null)
const loading = ref(false)
const result = ref<SqlQueryResult | null>(null)
const editor = ref<any>(null)
const headers = ref<any[]>([])

// Initialize Monaco editor
onMounted(async () => {
  if (!editorContainer.value) return

  const monaco = await loader.init()
  
  editor.value = monaco.editor.create(editorContainer.value, {
    value: '-- Write your SQL query here\nSELECT * FROM issues LIMIT 10;',
    language: 'sql',
    theme: 'vs',
    minimap: { enabled: false },
    automaticLayout: true
  })
})

// Clean up editor on component unmount
onBeforeUnmount(() => {
  if (editor.value) {
    editor.value.dispose()
  }
})

const executeQuery = async () => {
  if (!editor.value) return
  
  loading.value = true
  try {
    const query = editor.value.getValue()
    const response = await $fetch<SqlQueryResult>('/api/admin/sql', {
      method: 'POST',
      body: { query }
    })
    
    result.value = response
    if (response.columns) {
      headers.value = response.columns.map(col => ({
        title: col,
        key: col,
        sortable: true
      }))
    }
  } catch (error: any) {
    const showMessage = inject<(text: string, color?: 'success' | 'error') => void>('showMessage')
    showMessage?.(error.message || 'Error executing query', 'error')
  } finally {
    loading.value = false
  }
}

const downloadResults = () => {
  if (!result.value?.rows.length) return

  // Create CSV content
  const csvContent = [
    headers.value.map(h => h.title).join(','),
    ...result.value.rows.map(row => 
      headers.value.map(h => JSON.stringify(row[h.key])).join(',')
    )
  ].join('\n')

  // Create and trigger download
  const blob = new Blob([csvContent], { type: 'text/csv' })
  const url = window.URL.createObjectURL(blob)
  const a = document.createElement('a')
  a.href = url
  a.download = `query-results-${new Date().toISOString()}.csv`
  a.click()
  window.URL.revokeObjectURL(url)
}
</script>
