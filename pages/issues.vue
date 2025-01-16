<template lang="pug">
v-card
  v-card-title.d-flex.align-center
    span Issues Overview
    v-spacer
    v-btn(
      color="primary"
      prepend-icon="mdi-download"
      @click="showExportDialog = true"
    ) Export Data
  
  v-card-text
    // Filters
    v-row
      v-col(cols="12" sm="3")
        v-text-field(
          v-model="filters.search"
          label="Search"
          prepend-inner-icon="mdi-magnify"
          hide-details
          density="compact"
        )
      
      v-col(cols="12" sm="3")
        v-select(
          v-model="filters.status"
          label="Status"
          :items="[[], ...statusOptions]"
          :item-title="item => item.length ? item[0] : 'All Statuses'"
          hide-details
          density="compact"
          :loading="loading"
        )
      
      v-col(cols="12" sm="3")
        v-select(
          v-model="filters.severity"
          label="Severity"
          :items="[[], ...severityOptions]"
          :item-title="item => item.length ? item[0] : 'All Severities'"
          hide-details
          density="compact"
          :loading="loading"
        )
      
      v-col(cols="12" sm="3")
        v-select(
          v-model="selectedTimeRange"
          label="Time Range"
          :items="timeRangeOptions"
          item-title="title"
          item-value="value"
          hide-details
          density="compact"
          @update:model-value="updateTimeRange"
        )
    
    // Table
    v-data-table(
      :headers="headers"
      :items="filteredIssues"
      :items-per-page="itemsPerPage"
      :page="currentPage"
      @update:page="currentPage = $event"
      @update:items-per-page="itemsPerPage = $event"
    )
      template(#item.status="{ item }")
        span(:class="getStatusClass(item.raw.status)") {{ item.raw.status }}
      
      template(#item.severity="{ item }")
        span(:class="getSeverityClass(item.raw.severity)") {{ item.raw.severity }}
      
      template(#item.startTimestamp="{ item }")
        | {{ formatDate(item.raw.startTimestamp) }}
      
      template(#item.timeToReport="{ item }")
        | {{ getTimeToReport(item.raw) }}
      
      template(#item.timeToResolve="{ item }")
        | {{ getTimeToResolve(item.raw) }}
      
      template(#item.actions="{ item }")
        v-btn(
          icon="mdi-pencil"
          variant="text"
          size="small"
          color="primary"
          @click="editIssue(item.raw)"
        )
        v-btn(
          icon="mdi-eye"
          variant="text"
          size="small"
          color="primary"
          @click="viewDetails(item.raw)"
        )

  // Export Dialog
  v-dialog(v-model="showExportDialog" max-width="500px")
    v-card
      v-card-title Export Issues
      v-card-text
        v-form(ref="exportForm")
          v-select(
            v-model="exportFormat"
            label="Format"
            :items="[{ value: 'csv', title: 'CSV' }, { value: 'json', title: 'JSON' }]"
            item-title="title"
            item-value="value"
            required
          )
          v-select(
            v-model="exportTemplate"
            label="Template"
            :items="[{ value: 'full', title: 'Full Details' }, { value: 'summary', title: 'Summary' }, { value: 'metrics', title: 'Metrics Only' }]"
            item-title="title"
            item-value="value"
            required
          )
      v-card-actions
        v-spacer
        v-btn(
          color="secondary"
          variant="text"
          @click="showExportDialog = false"
        ) Cancel
        v-btn(
          color="primary"
          @click="confirmExport"
        ) Export
</template>

<script setup lang="ts">
import { ref, computed, onMounted, inject } from 'vue'
import dayjs from 'dayjs'
import type { Issue, IssueFilters, ExportOptions } from '~/types'
import { useLists } from '~/composables/useLists'

// Lists
const { 
  statusValues,
  severityValues,
  loading,
  loadLists
} = useLists()

// Convert values to options format
const statusOptions = computed(() => statusValues.value.map(v => [v]))
const severityOptions = computed(() => severityValues.value.map(v => [v]))

// Table headers
const headers = [
  { title: 'ID', key: 'id', sortable: true },
  { title: 'Status', key: 'status', sortable: true },
  { title: 'Title', key: 'title', sortable: true },
  { title: 'Severity', key: 'severity', sortable: true },
  { title: 'Started', key: 'startTimestamp', sortable: true },
  { title: 'Time to Report', key: 'timeToReport' },
  { title: 'Time to Resolve', key: 'timeToResolve' },
  { title: 'Actions', key: 'actions', sortable: false }
]

// State
const issues = ref<Issue[]>([])
const currentPage = ref(1)
const itemsPerPage = ref(10)
const showExportDialog = ref(false)
const exportFormat = ref<'csv' | 'json'>('csv')
const exportTemplate = ref<'full' | 'summary' | 'metrics'>('full')
const exportForm = ref<any>(null)
const selectedTimeRange = ref('all')

const filters = ref<IssueFilters>({
  search: '',
  status: [],
  severity: [],
  topic: []
})

// Time range options
const timeRangeOptions = [
  { value: 'all', title: 'All Time' },
  { value: 'today', title: 'Today' },
  { value: 'week', title: 'This Week' },
  { value: 'month', title: 'This Month' },
  { value: 'quarter', title: 'This Quarter' }
]

// Methods
const updateTimeRange = (value: string) => {
  const now = dayjs()
  switch (value) {
    case 'today':
      filters.value.startDate = now.startOf('day').toISOString()
      filters.value.endDate = now.endOf('day').toISOString()
      break
    case 'week':
      filters.value.startDate = now.startOf('week').toISOString()
      filters.value.endDate = now.endOf('week').toISOString()
      break
    case 'month':
      filters.value.startDate = now.startOf('month').toISOString()
      filters.value.endDate = now.endOf('month').toISOString()
      break
    case 'quarter':
      filters.value.startDate = now.startOf('quarter').toISOString()
      filters.value.endDate = now.endOf('quarter').toISOString()
      break
    default:
      filters.value.startDate = undefined
      filters.value.endDate = undefined
  }
}

// Computed
const filteredIssues = computed(() => {
  return issues.value.filter(issue => {
    const matchesSearch = !filters.value.search || 
      issue.title.toLowerCase().includes(filters.value.search.toLowerCase()) ||
      issue.description?.toLowerCase().includes(filters.value.search.toLowerCase())
    
    const matchesStatus = !filters.value.status?.length || 
      filters.value.status.includes(issue.status)
    
    const matchesSeverity = !filters.value.severity?.length || 
      filters.value.severity.includes(issue.severity)
    
    let matchesTimeRange = true
    if (filters.value.startDate && issue.startTimestamp) {
      matchesTimeRange = dayjs(issue.startTimestamp).isAfter(filters.value.startDate)
    }
    if (filters.value.endDate && issue.startTimestamp) {
      matchesTimeRange = matchesTimeRange && dayjs(issue.startTimestamp).isBefore(filters.value.endDate)
    }
    
    return matchesSearch && matchesStatus && matchesSeverity && matchesTimeRange
  })
})

const getStatusClass = (status?: string) => {
  return status ? `status-${status.toLowerCase()}` : ''
}

const getSeverityClass = (severity?: string) => {
  return severity ? `severity-${severity.toLowerCase()}` : ''
}

const formatDate = (date: string | null) => {
  return date ? dayjs(date).format('YYYY-MM-DD HH:mm') : ''
}

const getTimeToReport = (issue: Issue) => {
  if (!issue.startTimestamp || !issue.reportTimestamp) return ''
  const start = dayjs(issue.startTimestamp)
  const report = dayjs(issue.reportTimestamp)
  return report.from(start, true)
}

const getTimeToResolve = (issue: Issue) => {
  if (!issue.startTimestamp || !issue.resolutionTimestamp) return 'Unresolved'
  const start = dayjs(issue.startTimestamp)
  const resolution = dayjs(issue.resolutionTimestamp)
  return resolution.from(start, true)
}

const editIssue = (issue: Issue) => {
  navigateTo(`/issues/${issue.id}/edit`)
}

const viewDetails = (issue: Issue) => {
  navigateTo(`/issues/${issue.id}`)
}

const confirmExport = async () => {
  const { valid } = await exportForm.value?.validate()
  if (!valid) return

  try {
    const response = await $fetch<string>('/api/issues/export', {
      method: 'POST',
      body: {
        format: exportFormat.value,
        template: exportTemplate.value,
        filters: filters.value
      } as ExportOptions
    })
    
    const blob = new Blob([response], { 
      type: exportFormat.value === 'csv' ? 'text/csv' : 'application/json' 
    })
    const url = window.URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = url
    a.download = `issues-export-${dayjs().format('YYYY-MM-DD')}.${exportFormat.value}`
    a.click()
    window.URL.revokeObjectURL(url)
    
    showExportDialog.value = false
  } catch (error) {
    console.error('Error exporting data:', error)
    const showMessage = inject<(text: string, color?: 'success' | 'error') => void>('showMessage')
    showMessage?.('Failed to export data. Please try again.', 'error')
  }
}

// Fetch data on mount
onMounted(async () => {
  await loadLists()
  try {
    const response = await $fetch<Issue[]>('/api/issues')
    issues.value = response
  } catch (error) {
    console.error('Error fetching issues:', error)
    const showMessage = inject<(text: string, color?: 'success' | 'error') => void>('showMessage')
    showMessage?.('Error loading issues. Please try again.', 'error')
  }
})
</script>

<style scoped>
.status-open { color: var(--v-warning-base); }
.status-investigating { color: var(--v-info-base); }
.status-mitigated { color: var(--v-success-lighten1); }
.status-resolved { color: var(--v-success-base); }
.status-closed { color: var(--v-grey-base); }

.severity-critical { color: var(--v-error-darken1); }
.severity-high { color: var(--v-error-base); }
.severity-medium { color: var(--v-warning-base); }
.severity-low { color: var(--v-success-base); }
</style>
