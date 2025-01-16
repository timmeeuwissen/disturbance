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
      v-card(variant="outlined")
        v-card-title
          span Database Schema
          v-spacer
          v-btn(
            icon="mdi-chevron-up"
            variant="text"
            v-if="!schemaCollapsed"
            @click="schemaCollapsed = true"
          )
          v-btn(
            icon="mdi-chevron-down"
            variant="text"
            v-else
            @click="schemaCollapsed = false"
          )
        v-expand-transition
          v-card-text(v-show="!schemaCollapsed")
            ClientOnly
              Suspense
                template(#default)
                  admin-erd-diagram(v-if="!schemaCollapsed")
                template(#fallback)
                  .d-flex.align-center.justify-center.py-8
                    v-progress-circular(indeterminate color="warning")
                    span.ml-2 Loading schema diagram...

  v-row
    v-col(cols="12")
      v-card(variant="outlined")
        v-card-title
          span SQL Query Editor
          v-spacer
          v-btn(
            icon="mdi-chevron-up"
            variant="text"
            v-if="!editorCollapsed"
            @click="editorCollapsed = true"
          )
          v-btn(
            icon="mdi-chevron-down"
            variant="text"
            v-else
            @click="editorCollapsed = false"
          )
        v-expand-transition
          v-card-text(v-show="!editorCollapsed")
            ClientOnly
              Suspense
                template(#default)
                  admin-sql-editor(
                    v-if="!editorCollapsed"
                    ref="sqlEditor"
                    @query-results="handleQueryResults"
                  )
                template(#fallback)
                  .d-flex.align-center.justify-center.py-8
                    v-progress-circular(indeterminate color="warning")
                    span.ml-2 Loading SQL editor...

  v-row(v-if="queryResult")
    v-col(cols="12")
      v-card(variant="outlined")
        v-card-title
          span Query Results
          v-spacer
          v-btn(
            icon="mdi-chevron-up"
            variant="text"
            v-if="!resultsCollapsed"
            @click="resultsCollapsed = true"
          )
          v-btn(
            icon="mdi-chevron-down"
            variant="text"
            v-else
            @click="resultsCollapsed = false"
          )
        v-expand-transition
          v-card-text(v-show="!resultsCollapsed")
            v-data-table(
              :headers="headers"
              :items="queryResult.rows"
              :items-per-page="10"
              class="elevation-1"
            )
              template(#bottom)
                .d-flex.align-center.justify-space-between.pa-4
                  span Total rows: {{ queryResult.rowCount }}
                  v-btn(
                    color="warning"
                    prepend-icon="mdi-download"
                    @click="downloadResults"
                    :disabled="!queryResult.rows.length"
                  ) Export Results
</template>

<script setup lang="ts">
import { ref, defineAsyncComponent, h, inject } from 'vue'
import type { SqlQueryResult } from '~/types'

// Create error component factory
const createErrorComponent = (componentName: string) => ({
  name: 'ErrorComponent',
  emits: ['retry'],
  setup() {
    return () => h('div', { class: 'error-state pa-4 text-center' }, [
      h('v-icon', { icon: 'mdi-alert', color: 'error', size: 'large' }),
      h('p', { class: 'text-error mt-2' }, `Failed to load ${componentName}`),
      h('v-btn', {
        color: 'error',
        variant: 'text',
        onClick: () => {
          const showMessage = inject<(text: string, color?: 'success' | 'error') => void>('showMessage')
          showMessage?.(`Retrying to load ${componentName}...`, 'error')
        }
      }, 'Retry')
    ])
  }
})

// Lazy load components with error handling
const AdminErdDiagram = defineAsyncComponent({
  loader: () => import('~/components/admin/ErdDiagram.vue'),
  loadingComponent: undefined,
  errorComponent: createErrorComponent('schema diagram'),
  timeout: 10000,
  onError(error, retry, fail, attempts) {
    if (attempts <= 3) {
      retry()
    } else {
      const showMessage = inject<(text: string, color?: 'success' | 'error') => void>('showMessage')
      showMessage?.('Failed to load schema diagram after multiple attempts.', 'error')
      fail()
    }
  }
})

const AdminSqlEditor = defineAsyncComponent({
  loader: () => import('~/components/admin/SqlEditor.vue'),
  loadingComponent: undefined,
  errorComponent: createErrorComponent('SQL editor'),
  timeout: 10000,
  onError(error, retry, fail, attempts) {
    if (attempts <= 3) {
      retry()
    } else {
      const showMessage = inject<(text: string, color?: 'success' | 'error') => void>('showMessage')
      showMessage?.('Failed to load SQL editor after multiple attempts.', 'error')
      fail()
    }
  }
})

// State
const schemaCollapsed = ref(true)
const editorCollapsed = ref(true)
const resultsCollapsed = ref(false)
const sqlEditor = ref<any>(null)
const queryResult = ref<SqlQueryResult | null>(null)
const headers = ref<any[]>([])

// Handle query results
const handleQueryResults = (result: SqlQueryResult) => {
  queryResult.value = result
  if (result.columns) {
    headers.value = result.columns.map(col => ({
      title: col,
      key: col,
      sortable: true
    }))
  }
  resultsCollapsed.value = false
}

// Download results as CSV
const downloadResults = () => {
  if (!queryResult.value?.rows.length) return

  const csvContent = [
    headers.value.map(h => h.title).join(','),
    ...queryResult.value.rows.map(row => 
      headers.value.map(h => JSON.stringify(row[h.key])).join(',')
    )
  ].join('\n')

  const blob = new Blob([csvContent], { type: 'text/csv' })
  const url = window.URL.createObjectURL(blob)
  const a = document.createElement('a')
  a.href = url
  a.download = `query-results-${new Date().toISOString()}.csv`
  a.click()
  window.URL.revokeObjectURL(url)
}

// Error handling for async components
onErrorCaptured((error, instance, info) => {
  console.error('Error in SQL admin page:', { error, instance, info })
  const showMessage = inject<(text: string, color?: 'success' | 'error') => void>('showMessage')
  showMessage?.('Error loading component. Please try refreshing the page.', 'error')
  return false
})
</script>

<style scoped>
.v-card-text {
  position: relative;
}

.error-state {
  background-color: var(--v-error-lighten4);
  border-radius: 4px;
}
</style>
