<template lang="pug">
.card
  .card-header
    .sm:flex.sm:items-center
      .sm:flex-auto
        h1.text-xl.font-semibold.text-gray-900 Issues Overview
      .mt-4.sm:mt-0.sm:ml-16.sm:flex-none
        button.btn-primary(@click="exportData") Export Data
  
  .card-body
    // Filters
    .grid.grid-cols-1.gap-4.sm:grid-cols-4.mb-6
      .form-group
        input.form-input(
          type="text"
          placeholder="Search..."
          v-model="filters.search"
        )
      
      .form-group
        select.form-input(v-model="filters.status")
          option(value="") All Statuses
          option(value="open") Open
          option(value="investigating") Investigating
          option(value="mitigated") Mitigated
          option(value="resolved") Resolved
          option(value="closed") Closed
      
      .form-group
        select.form-input(v-model="filters.severity")
          option(value="") All Severities
          option(value="critical") Critical
          option(value="high") High
          option(value="medium") Medium
          option(value="low") Low
      
      .form-group
        select.form-input(v-model="filters.timeRange")
          option(value="all") All Time
          option(value="today") Today
          option(value="week") This Week
          option(value="month") This Month
          option(value="quarter") This Quarter
    
    // Table
    .table-container
      .table-inner
        table.table
          thead.table-header
            tr
              th.table-header-cell ID
              th.table-header-cell Status
              th.table-header-cell Title
              th.table-header-cell Severity
              th.table-header-cell Started
              th.table-header-cell Time to Report
              th.table-header-cell Time to Resolve
              th.table-header-cell Actions
          
          tbody.table-body
            tr.table-row(v-for="issue in paginatedIssues" :key="issue.id")
              td.table-cell {{ issue.id }}
              td.table-cell
                span(:class="getStatusClass(issue.status)") {{ issue.status }}
              td.table-cell {{ issue.title }}
              td.table-cell
                span(:class="getSeverityClass(issue.severity)") {{ issue.severity }}
              td.table-cell {{ formatDate(issue.startTimestamp) }}
              td.table-cell {{ getTimeToReport(issue) }}
              td.table-cell {{ getTimeToResolve(issue) }}
              td.table-cell
                .flex.space-x-2
                  button.btn-secondary(@click="editIssue(issue)") Edit
                  button.btn-secondary(@click="viewDetails(issue)") View
    
    // Pagination
    .mt-6.flex.items-center.justify-between
      .flex-1.flex.justify-between.sm:hidden
        button.btn-secondary(:disabled="currentPage === 1" @click="currentPage--") Previous
        button.btn-secondary(:disabled="currentPage === totalPages" @click="currentPage++") Next
      
      .hidden.sm:flex-1.sm:flex.sm:items-center.sm:justify-between
        .flex.items-center
          p.text-sm.text-gray-700
            | Showing 
            span.font-medium {{ paginationStart + 1 }}
            |  to 
            span.font-medium {{ paginationEnd }}
            |  of 
            span.font-medium {{ totalIssues }}
            |  results
        
        nav.relative.z-0.inline-flex.-space-x-px
          button.btn-secondary.rounded-l-md(:disabled="currentPage === 1" @click="currentPage--") Previous
          button.btn-secondary.rounded-r-md(:disabled="currentPage === totalPages" @click="currentPage++") Next

  // Export Modal
  Teleport(to="body")
    .fixed.inset-0.bg-gray-500.bg-opacity-75.flex.items-center.justify-center(v-if="showExportModal")
      .bg-white.rounded-lg.p-6.max-w-lg.w-full
        h3.text-lg.font-medium.mb-4 Export Issues
        .space-y-4
          .form-group
            label.form-label(for="exportFormat") Format
            select#exportFormat.form-input(v-model="exportFormat")
              option(value="csv") CSV
              option(value="json") JSON
          
          .form-group
            label.form-label(for="exportTemplate") Template
            select#exportTemplate.form-input(v-model="exportTemplate")
              option(value="full") Full Details
              option(value="summary") Summary
              option(value="metrics") Metrics Only
          
          .flex.justify-end.space-x-3.mt-6
            button.btn-secondary(@click="showExportModal = false") Cancel
            button.btn-primary(@click="confirmExport") Export
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import dayjs from 'dayjs'
import relativeTime from 'dayjs/plugin/relativeTime'
import type { Issue, IssueFilters, ExportOptions } from '~/types'

dayjs.extend(relativeTime)

// State
const issues = ref<Issue[]>([])
const currentPage = ref(1)
const itemsPerPage = 10
const showExportModal = ref(false)
const exportFormat = ref('csv')
const exportTemplate = ref('full')

const filters = ref<IssueFilters>({
  search: '',
  status: '',
  severity: '',
  timeRange: 'all'
})

// Computed
const filteredIssues = computed(() => {
  return issues.value.filter(issue => {
    const matchesSearch = !filters.value.search || 
      issue.title.toLowerCase().includes(filters.value.search.toLowerCase()) ||
      issue.description?.toLowerCase().includes(filters.value.search.toLowerCase())
    
    const matchesStatus = !filters.value.status || issue.status === filters.value.status
    const matchesSeverity = !filters.value.severity || issue.severity === filters.value.severity
    
    let matchesTimeRange = true
    const startDate = dayjs(issue.startTimestamp)
    
    switch (filters.value.timeRange) {
      case 'today':
        matchesTimeRange = startDate.isAfter(dayjs().startOf('day'))
        break
      case 'week':
        matchesTimeRange = startDate.isAfter(dayjs().startOf('week'))
        break
      case 'month':
        matchesTimeRange = startDate.isAfter(dayjs().startOf('month'))
        break
      case 'quarter':
        matchesTimeRange = startDate.isAfter(dayjs().startOf('quarter'))
        break
    }
    
    return matchesSearch && matchesStatus && matchesSeverity && matchesTimeRange
  })
})

const totalIssues = computed(() => filteredIssues.value.length)
const totalPages = computed(() => Math.ceil(totalIssues.value / itemsPerPage))

const paginationStart = computed(() => (currentPage.value - 1) * itemsPerPage)
const paginationEnd = computed(() => Math.min(paginationStart.value + itemsPerPage, totalIssues.value))

const paginatedIssues = computed(() => {
  return filteredIssues.value.slice(paginationStart.value, paginationEnd.value)
})

// Methods
const getStatusClass = (status: string) => {
  return `status-${status.toLowerCase()}`
}

const getSeverityClass = (severity: string) => {
  return `severity-${severity.toLowerCase()}`
}

const formatDate = (date: string) => {
  return dayjs(date).format('YYYY-MM-DD HH:mm')
}

const getTimeToReport = (issue: any) => {
  const start = dayjs(issue.startTimestamp)
  const report = dayjs(issue.reportTimestamp)
  return report.from(start, true)
}

const getTimeToResolve = (issue: any) => {
  if (!issue.resolutionTimestamp) return 'Unresolved'
  const start = dayjs(issue.startTimestamp)
  const resolution = dayjs(issue.resolutionTimestamp)
  return resolution.from(start, true)
}

const editIssue = (issue: any) => {
  // Navigate to edit page
  navigateTo(`/issues/${issue.id}/edit`)
}

const viewDetails = (issue: any) => {
  // Navigate to details page
  navigateTo(`/issues/${issue.id}`)
}

const exportData = () => {
  showExportModal.value = true
}

const confirmExport = async () => {
  try {
    const response = await $fetch<string>('/api/issues/export', {
      method: 'POST',
      body: {
        format: exportFormat.value,
        template: exportTemplate.value,
        filters: filters.value
      } as ExportOptions
    })
    
    // Handle the export response (download file)
    const blob = new Blob([response], { type: exportFormat.value === 'csv' ? 'text/csv' : 'application/json' })
    const url = window.URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = url
    a.download = `issues-export-${dayjs().format('YYYY-MM-DD')}.${exportFormat.value}`
    a.click()
    
    showExportModal.value = false
  } catch (error) {
    console.error('Error exporting data:', error)
    alert('Error exporting data. Please try again.')
  }
}

// Fetch issues on component mount
onMounted(async () => {
  try {
    const response = await $fetch<Issue[]>('/api/issues')
    issues.value = response
  } catch (error) {
    console.error('Error fetching issues:', error)
    alert('Error loading issues. Please try again.')
  }
})
</script>
