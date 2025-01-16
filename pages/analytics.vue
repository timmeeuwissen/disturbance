<template lang="pug">
v-container(fluid)
  v-row
    v-col(cols="12")
      h1.text-h4.mb-4 Analytics

  v-row
    v-col(cols="12" md="6")
      v-card
        v-card-title Status Distribution
        v-card-text
          v-chart(:option="statusChartOption")

    v-col(cols="12" md="6")
      v-card
        v-card-title Severity Distribution
        v-card-text
          v-chart(:option="severityChartOption")

  v-row
    v-col(cols="12" md="6")
      v-card
        v-card-title Resolution Time by Status
        v-card-text
          v-chart(:option="resolutionTimeChartOption")

    v-col(cols="12" md="6")
      v-card
        v-card-title Resolution Time by Severity
        v-card-text
          v-chart(:option="severityTimeChartOption")

  v-row
    v-col(cols="12")
      v-card
        v-card-title Issue Timeline
        v-card-text
          v-chart(:option="timelineChartOption")
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import dayjs from 'dayjs'
import type { Issue, StatusValue, SeverityValue } from '~/types'
import { getStatusValue, getSeverityValue } from '~/types'

// State
const issues = ref<Issue[]>([])

// Chart options
const statusChartOption = computed(() => {
  const statusCounts = new Map<StatusValue, number>()
  issues.value.forEach(issue => {
    const status = getStatusValue(issue.status)
    if (status) {
      statusCounts.set(status, (statusCounts.get(status) || 0) + 1)
    }
  })

  return {
    tooltip: {
      trigger: 'item',
      formatter: '{b}: {c} ({d}%)'
    },
    series: [{
      type: 'pie',
      radius: '70%',
      data: Array.from(statusCounts.entries()).map(([status, count]) => ({
        name: status,
        value: count
      }))
    }]
  }
})

const severityChartOption = computed(() => {
  const severityCounts = new Map<SeverityValue, number>()
  issues.value.forEach(issue => {
    const severity = getSeverityValue(issue.severity)
    if (severity) {
      severityCounts.set(severity, (severityCounts.get(severity) || 0) + 1)
    }
  })

  return {
    tooltip: {
      trigger: 'item',
      formatter: '{b}: {c} ({d}%)'
    },
    series: [{
      type: 'pie',
      radius: '70%',
      data: Array.from(severityCounts.entries()).map(([severity, count]) => ({
        name: severity,
        value: count
      }))
    }]
  }
})

const resolutionTimeChartOption = computed(() => {
  const resolutionTimes = new Map<StatusValue, number[]>()
  
  issues.value.forEach(issue => {
    if (!issue.startTimestamp || !issue.resolutionTimestamp) return
    
    const status = getStatusValue(issue.status)
    if (status) {
      const time = dayjs(issue.resolutionTimestamp).diff(issue.startTimestamp, 'hour')
      const times = resolutionTimes.get(status) || []
      times.push(time)
      resolutionTimes.set(status, times)
    }
  })

  return {
    tooltip: {
      trigger: 'axis',
      axisPointer: { type: 'shadow' }
    },
    xAxis: {
      type: 'category',
      data: Array.from(resolutionTimes.keys())
    },
    yAxis: {
      type: 'value',
      name: 'Hours'
    },
    series: [{
      type: 'bar',
      data: Array.from(resolutionTimes.entries()).map(([status, times]) => ({
        name: status,
        value: times.length ? Math.round(times.reduce((a, b) => a + b) / times.length) : 0
      }))
    }]
  }
})

const severityTimeChartOption = computed(() => {
  const resolutionTimes = new Map<SeverityValue, number[]>()
  
  issues.value.forEach(issue => {
    if (!issue.startTimestamp || !issue.resolutionTimestamp) return
    
    const severity = getSeverityValue(issue.severity)
    if (severity) {
      const time = dayjs(issue.resolutionTimestamp).diff(issue.startTimestamp, 'hour')
      const times = resolutionTimes.get(severity) || []
      times.push(time)
      resolutionTimes.set(severity, times)
    }
  })

  return {
    tooltip: {
      trigger: 'axis',
      axisPointer: { type: 'shadow' }
    },
    xAxis: {
      type: 'category',
      data: Array.from(resolutionTimes.keys())
    },
    yAxis: {
      type: 'value',
      name: 'Hours'
    },
    series: [{
      type: 'bar',
      data: Array.from(resolutionTimes.entries()).map(([severity, times]) => ({
        name: severity,
        value: times.length ? Math.round(times.reduce((a, b) => a + b) / times.length) : 0
      }))
    }]
  }
})

const timelineChartOption = computed(() => {
  const timelineData = issues.value
    .filter(issue => issue.startTimestamp)
    .map(issue => {
      const status = getStatusValue(issue.status)
      const severity = getSeverityValue(issue.severity)
      if (!status || !severity) return null
      return {
        name: issue.title,
        value: [
          dayjs(issue.startTimestamp).toDate(),
          dayjs(issue.resolutionTimestamp || new Date()).toDate(),
          status,
          severity
        ]
      }
    })
    .filter((item): item is NonNullable<typeof item> => item !== null)
    .sort((a, b) => (a.value[0] as Date).getTime() - (b.value[0] as Date).getTime())

  return {
    tooltip: {
      formatter: (params: any) => {
        const data = params.data
        return `${data.name}<br/>
                Status: ${data.value[2]}<br/>
                Severity: ${data.value[3]}<br/>
                Start: ${dayjs(data.value[0]).format('YYYY-MM-DD HH:mm')}<br/>
                ${data.value[1] ? 'End: ' + dayjs(data.value[1]).format('YYYY-MM-DD HH:mm') : 'Ongoing'}`
      }
    },
    xAxis: {
      type: 'time',
      axisLabel: {
        formatter: (value: string) => dayjs(value).format('MM-DD HH:mm')
      }
    },
    yAxis: {
      type: 'category',
      data: timelineData.map(item => item.name)
    },
    series: [{
      type: 'custom',
      renderItem: (params: any, api: any) => {
        const start = api.coord([api.value(0), api.value(4)])
        const end = api.coord([api.value(1), api.value(4)])
        const height = api.size([0, 1])[1] * 0.6
        
        return {
          type: 'rect',
          shape: {
            x: start[0],
            y: start[1] - height / 2,
            width: Math.max(end[0] - start[0], 5),
            height: height
          },
          style: {
            fill: api.value(2) === 'resolved' ? '#4CAF50' : '#FF9800'
          }
        }
      },
      encode: {
        x: [0, 1],
        y: 4
      },
      data: timelineData
    }]
  }
})

// Fetch issues on component mount
onMounted(async () => {
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
.v-card-text {
  height: 400px;
}
</style>
