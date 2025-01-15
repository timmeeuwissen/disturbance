<template lang="pug">
.space-y-6
  // Summary Cards
  .grid.grid-cols-1.gap-6.sm:grid-cols-2.lg:grid-cols-4
    .stat-card
      .stat-title Open Issues
      .stat-value {{ stats.openIssues }}
    
    .stat-card
      .stat-title Mean Time to Report
      .stat-value {{ formatDuration(stats.meanTimeToReport) }}
    
    .stat-card
      .stat-title Mean Time to Resolve
      .stat-value {{ formatDuration(stats.meanTimeToResolve) }}
    
    .stat-card
      .stat-title Resolution Rate
      .stat-value {{ stats.resolutionRate }}%

  // Filters
  .card
    .card-body
      .grid.grid-cols-1.gap-4.sm:grid-cols-3
        .form-group
          label.form-label(for="period") Time Period
          select#period.form-input(v-model="filters.period")
            option(value="7d") Last 7 Days
            option(value="30d") Last 30 Days
            option(value="90d") Last 90 Days
            option(value="1y") Last Year
            option(value="all") All Time
        
        .form-group
          label.form-label(for="topic") Topic
          select#topic.form-input(v-model="filters.topic")
            option(value="") All Topics
            option(v-for="topic in topics" :key="topic" :value="topic") {{ topic }}
        
        .form-group
          label.form-label(for="severity") Severity
          select#severity.form-input(v-model="filters.severity")
            option(value="") All Severities
            option(value="critical") Critical
            option(value="high") High
            option(value="medium") Medium
            option(value="low") Low

  // Charts Section
  .grid.grid-cols-1.gap-6.lg:grid-cols-2
    // Issues Over Time
    .card
      .card-header
        h3.text-lg.font-medium Issues Over Time
      .card-body
        .chart-container
          canvas(ref="issuesTimelineChart")
    
    // Issues by Status
    .card
      .card-header
        h3.text-lg.font-medium Issues by Status
      .card-body
        .chart-container
          canvas(ref="statusDistributionChart")
    
    // Issues by Severity
    .card
      .card-header
        h3.text-lg.font-medium Issues by Severity
      .card-body
        .chart-container
          canvas(ref="severityDistributionChart")
    
    // Resolution Time Distribution
    .card
      .card-header
        h3.text-lg.font-medium Resolution Time Distribution
      .card-body
        .chart-container
          canvas(ref="resolutionTimeChart")

  // Detailed Metrics Table
  .card
    .card-header
      h3.text-lg.font-medium Detailed Metrics
    .card-body
      table.table
        thead.table-header
          tr
            th.table-header-cell Metric
            th.table-header-cell Value
        tbody.table-body
          tr.table-row
            td.table-cell Total Issues
            td.table-cell {{ stats.totalIssues }}
          tr.table-row
            td.table-cell Critical Issues
            td.table-cell {{ stats.criticalIssues }}
          tr.table-row
            td.table-cell Average Resolution Time (Critical)
            td.table-cell {{ formatDuration(stats.avgResolutionTimeCritical) }}
          tr.table-row
            td.table-cell Resolution Rate (Critical)
            td.table-cell {{ stats.resolutionRateCritical }}%
          tr.table-row
            td.table-cell Most Common Topic
            td.table-cell {{ stats.mostCommonTopic }}
          tr.table-row
            td.table-cell Longest Resolution Time
            td.table-cell {{ formatDuration(stats.longestResolutionTime) }}
</template>

<script setup lang="ts">
import { ref, onMounted, watch } from 'vue'
import dayjs from 'dayjs'
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
    const matchesPeriod = filters.value.period === 'all' ? true :
      dayjs(issue.startTimestamp).isAfter(
        dayjs().subtract(
          parseInt(filters.value.period),
          filters.value.period.endsWith('d') ? 'day' : 'year'
        )
      )
    
    const matchesTopic = !filters.value.topic || issue.topic === filters.value.topic
    const matchesSeverity = !filters.value.severity || issue.severity === filters.value.severity
    
    return matchesPeriod && matchesTopic && matchesSeverity
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
    alert('Error loading analytics data. Please try again.')
  }
})

// Cleanup charts on component unmount
onUnmounted(() => {
  Object.values(chartInstances.value).forEach(chart => chart.destroy())
})
</script>
