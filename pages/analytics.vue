<template lang="pug">
div
  // Summary Cards
  v-row
    v-col(cols="12" sm="6" lg="3")
      v-card
        v-card-text
          .text-subtitle-2 Open Issues
          .text-h4.mt-2 {{ stats.openIssues }}
    
    v-col(cols="12" sm="6" lg="3")
      v-card
        v-card-text
          .text-subtitle-2 Mean Time to Report
          .text-h4.mt-2 {{ formatDuration(stats.meanTimeToReport) }}
    
    v-col(cols="12" sm="6" lg="3")
      v-card
        v-card-text
          .text-subtitle-2 Mean Time to Resolve
          .text-h4.mt-2 {{ formatDuration(stats.meanTimeToResolve) }}
    
    v-col(cols="12" sm="6" lg="3")
      v-card
        v-card-text
          .text-subtitle-2 Resolution Rate
          .text-h4.mt-2 {{ stats.resolutionRate }}%

  // Filters
  v-card.mt-6
    v-card-text
      v-row
        v-col(cols="12" sm="4")
          v-select(
            v-model="filters.period"
            label="Time Period"
            :items="[
              { value: '7d', title: 'Last 7 Days' },
              { value: '30d', title: 'Last 30 Days' },
              { value: '90d', title: 'Last 90 Days' },
              { value: '1y', title: 'Last Year' },
              { value: 'all', title: 'All Time' }
            ]"
            item-title="title"
            item-value="value"
          )
        
        v-col(cols="12" sm="4")
          v-select(
            v-model="filters.topic"
            label="Topic"
            :items="['', ...topics]"
            :item-title="item => item || 'All Topics'"
          )
        
        v-col(cols="12" sm="4")
          v-select(
            v-model="filters.severity"
            label="Severity"
            :items="['', 'critical', 'high', 'medium', 'low']"
            :item-title="item => item || 'All Severities'"
          )

  // Charts Section
  v-row.mt-6
    v-col(cols="12" lg="6")
      v-card
        v-card-title Issues Over Time
        v-card-text
          canvas(ref="issuesTimelineChart")
    
    v-col(cols="12" lg="6")
      v-card
        v-card-title Issues by Status
        v-card-text
          canvas(ref="statusDistributionChart")
    
    v-col(cols="12" lg="6")
      v-card
        v-card-title Issues by Severity
        v-card-text
          canvas(ref="severityDistributionChart")
    
    v-col(cols="12" lg="6")
      v-card
        v-card-title Resolution Time Distribution
        v-card-text
          canvas(ref="resolutionTimeChart")

  // Detailed Metrics Table
  v-card.mt-6
    v-card-title Detailed Metrics
    v-card-text
      v-table
        thead
          tr
            th.text-left Metric
            th.text-left Value
        tbody
          tr
            td Total Issues
            td {{ stats.totalIssues }}
          tr
            td Critical Issues
            td {{ stats.criticalIssues }}
          tr
            td Average Resolution Time (Critical)
            td {{ formatDuration(stats.avgResolutionTimeCritical) }}
          tr
            td Resolution Rate (Critical)
            td {{ stats.resolutionRateCritical }}%
          tr
            td Most Common Topic
            td {{ stats.mostCommonTopic }}
          tr
            td Longest Resolution Time
            td {{ formatDuration(stats.longestResolutionTime) }}
</template>

<script setup lang="ts">
import { ref, onMounted, watch, inject, onUnmounted } from 'vue'
import dayjs from 'dayjs'
import relativeTime from 'dayjs/plugin/relativeTime'

dayjs.extend(relativeTime)
import Chart from 'chart.js/auto'
import type { Issue } from '~/types'

// Chart references
const issuesTimelineChart = ref<HTMLCanvasElement | null>(null)
const statusDistributionChart = ref<HTMLCanvasElement | null>(null)
const severityDistributionChart = ref<HTMLCanvasElement | null>(null)
const resolutionTimeChart = ref<HTMLCanvasElement | null>(null)

// State
const filters = ref({
  period: '30d',
  topic: '',
  severity: ''
})

const stats = ref({
  openIssues: 0,
  meanTimeToReport: 0,
  meanTimeToResolve: 0,
  resolutionRate: 0,
  totalIssues: 0,
  criticalIssues: 0,
  avgResolutionTimeCritical: 0,
  resolutionRateCritical: 0,
  mostCommonTopic: '',
  longestResolutionTime: 0
})

const topics = ref<string[]>([])
const chartInstances = ref<{ [key: string]: Chart }>({})

// Methods
const formatDuration = (minutes: number): string => {
  if (minutes < 60) return `${Math.round(minutes)}m`
  if (minutes < 1440) return `${Math.round(minutes / 60)}h`
  return `${Math.round(minutes / 1440)}d`
}

const calculateStats = (issues: Issue[]) => {
  const filteredIssues = filterIssues(issues)
  
  // Calculate basic stats
  stats.value.totalIssues = filteredIssues.length
  stats.value.openIssues = filteredIssues.filter(i => i.status === 'open').length
  
  // Calculate time-based metrics
  const reportTimes = filteredIssues.map(i => 
    dayjs(i.reportTimestamp).diff(dayjs(i.startTimestamp), 'minute'))
  
  const resolutionTimes = filteredIssues
    .filter(i => i.resolutionTimestamp)
    .map(i => dayjs(i.resolutionTimestamp!).diff(dayjs(i.startTimestamp), 'minute'))
  
  stats.value.meanTimeToReport = reportTimes.length ? 
    reportTimes.reduce((a, b) => a + b, 0) / reportTimes.length : 0
  
  stats.value.meanTimeToResolve = resolutionTimes.length ?
    resolutionTimes.reduce((a, b) => a + b, 0) / resolutionTimes.length : 0
  
  // Calculate resolution rate
  const resolvedIssues = filteredIssues.filter(i => 
    i.status === 'resolved' || i.status === 'closed').length
  stats.value.resolutionRate = Math.round((resolvedIssues / filteredIssues.length) * 100)
  
  // Critical issues metrics
  const criticalIssues = filteredIssues.filter(i => i.severity === 'critical')
  stats.value.criticalIssues = criticalIssues.length
  
  const criticalResolutionTimes = criticalIssues
    .filter(i => i.resolutionTimestamp)
    .map(i => dayjs(i.resolutionTimestamp!).diff(dayjs(i.startTimestamp), 'minute'))
  
  stats.value.avgResolutionTimeCritical = criticalResolutionTimes.length ?
    criticalResolutionTimes.reduce((a, b) => a + b, 0) / criticalResolutionTimes.length : 0
  
  const resolvedCritical = criticalIssues.filter(i => 
    i.status === 'resolved' || i.status === 'closed').length
  stats.value.resolutionRateCritical = criticalIssues.length ?
    Math.round((resolvedCritical / criticalIssues.length) * 100) : 0
  
  // Find most common topic
  const topicCounts = filteredIssues.reduce((acc, issue) => {
    acc[issue.topic] = (acc[issue.topic] || 0) + 1
    return acc
  }, {} as { [key: string]: number })
  
  stats.value.mostCommonTopic = Object.entries(topicCounts)
    .sort(([,a], [,b]) => b - a)[0]?.[0] || ''
  
  // Find longest resolution time
  stats.value.longestResolutionTime = Math.max(...resolutionTimes, 0)
}

const filterIssues = (issues: Issue[]): Issue[] => {
  return issues.filter(issue => {
    const matchesTopic = !filters.value.topic || issue.topic === filters.value.topic
    const matchesSeverity = !filters.value.severity || issue.severity === filters.value.severity
    
    let matchesPeriod = true
    if (filters.value.period !== 'all') {
      const startDate = dayjs(issue.startTimestamp)
      const timeRangeParts = filters.value.period.match(/(\d+)([dwy])/)
      
      if (timeRangeParts) {
        const [, amount, unit] = timeRangeParts
        const unitMap: { [key: string]: 'day' | 'week' | 'month' | 'year' } = { 
          d: 'day', 
          w: 'week', 
          y: 'year' 
        }
        const mappedUnit = unitMap[unit as keyof typeof unitMap]
        if (mappedUnit) {
          matchesPeriod = startDate.isAfter(
            dayjs().subtract(parseInt(amount), mappedUnit)
          )
        }
      }
    }
    
    return matchesTopic && matchesSeverity && matchesPeriod
  })
}

const updateCharts = (issues: Issue[]) => {
  const filteredIssues = filterIssues(issues)
  
  // Issues Timeline Chart
  if (issuesTimelineChart.value) {
    const timelineData = generateTimelineData(filteredIssues)
    updateOrCreateChart('timeline', issuesTimelineChart.value, {
      type: 'line',
      data: timelineData,
      options: {
        responsive: true,
        maintainAspectRatio: false
      }
    })
  }
  
  // Status Distribution Chart
  if (statusDistributionChart.value) {
    const statusData = generateStatusData(filteredIssues)
    updateOrCreateChart('status', statusDistributionChart.value, {
      type: 'doughnut',
      data: statusData,
      options: {
        responsive: true,
        maintainAspectRatio: false
      }
    })
  }
  
  // Severity Distribution Chart
  if (severityDistributionChart.value) {
    const severityData = generateSeverityData(filteredIssues)
    updateOrCreateChart('severity', severityDistributionChart.value, {
      type: 'pie',
      data: severityData,
      options: {
        responsive: true,
        maintainAspectRatio: false
      }
    })
  }
  
  // Resolution Time Distribution Chart
  if (resolutionTimeChart.value) {
    const resolutionData = generateResolutionTimeData(filteredIssues)
    updateOrCreateChart('resolution', resolutionTimeChart.value, {
      type: 'bar',
      data: resolutionData,
      options: {
        responsive: true,
        maintainAspectRatio: false
      }
    })
  }
}

const updateOrCreateChart = (id: string, canvas: HTMLCanvasElement, config: any) => {
  if (chartInstances.value[id]) {
    chartInstances.value[id].destroy()
  }
  chartInstances.value[id] = new Chart(canvas, config)
}

const generateTimelineData = (issues: Issue[]) => {
  // Group issues by date
  const dateGroups = issues.reduce((acc, issue) => {
    const date = dayjs(issue.startTimestamp).format('YYYY-MM-DD')
    acc[date] = (acc[date] || 0) + 1
    return acc
  }, {} as { [key: string]: number })
  
  const dates = Object.keys(dateGroups).sort()
  
  return {
    labels: dates,
    datasets: [{
      label: 'New Issues',
      data: dates.map(date => dateGroups[date]),
      borderColor: 'rgb(75, 192, 192)',
      tension: 0.1
    }]
  }
}

const generateStatusData = (issues: Issue[]) => {
  const statusCounts = issues.reduce((acc, issue) => {
    acc[issue.status] = (acc[issue.status] || 0) + 1
    return acc
  }, {} as { [key: string]: number })
  
  return {
    labels: Object.keys(statusCounts),
    datasets: [{
      data: Object.values(statusCounts),
      backgroundColor: [
        'rgb(255, 99, 132)',
        'rgb(54, 162, 235)',
        'rgb(255, 206, 86)',
        'rgb(75, 192, 192)',
        'rgb(153, 102, 255)'
      ]
    }]
  }
}

const generateSeverityData = (issues: Issue[]) => {
  const severityCounts = issues.reduce((acc, issue) => {
    acc[issue.severity] = (acc[issue.severity] || 0) + 1
    return acc
  }, {} as { [key: string]: number })
  
  return {
    labels: Object.keys(severityCounts),
    datasets: [{
      data: Object.values(severityCounts),
      backgroundColor: [
        'rgb(255, 99, 132)',
        'rgb(255, 159, 64)',
        'rgb(255, 205, 86)',
        'rgb(75, 192, 192)'
      ]
    }]
  }
}

const generateResolutionTimeData = (issues: Issue[]) => {
  const resolutionTimes = issues
    .filter(i => i.resolutionTimestamp)
    .map(i => dayjs(i.resolutionTimestamp!).diff(dayjs(i.startTimestamp), 'hour'))
  
  // Create time buckets
  const buckets = {
    '<1h': 0,
    '1-4h': 0,
    '4-12h': 0,
    '12-24h': 0,
    '1-3d': 0,
    '>3d': 0
  }
  
  resolutionTimes.forEach(hours => {
    if (hours < 1) buckets['<1h']++
    else if (hours < 4) buckets['1-4h']++
    else if (hours < 12) buckets['4-12h']++
    else if (hours < 24) buckets['12-24h']++
    else if (hours < 72) buckets['1-3d']++
    else buckets['>3d']++
  })
  
  return {
    labels: Object.keys(buckets),
    datasets: [{
      label: 'Number of Issues',
      data: Object.values(buckets),
      backgroundColor: 'rgb(75, 192, 192)'
    }]
  }
}

// Fetch data and initialize
onMounted(async () => {
  try {
    const response = await $fetch<Issue[]>('/api/issues')
    const issues = response
    
    // Extract unique topics
    topics.value = [...new Set(issues.map(i => i.topic))]
    
    // Initial calculations
    calculateStats(issues)
    updateCharts(issues)
    
    // Watch for filter changes
    watch(filters, () => {
      calculateStats(issues)
      updateCharts(issues)
    })
  } catch (error) {
    console.error('Error fetching analytics data:', error)
    const showMessage = inject<(text: string, color?: 'success' | 'error') => void>('showMessage')
    showMessage?.('Error loading analytics data. Please try again.', 'error')
  }
})

// Cleanup charts on component unmount
onUnmounted(() => {
  Object.values(chartInstances.value).forEach(chart => chart.destroy())
})
</script>
