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
            admin-sql-editor(ref="sqlEditor" @query-results="handleQueryResults")

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
import { ref } from 'vue'
import type { SqlQueryResult } from '~/types'

const editorCollapsed = ref(false)
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
</script>
