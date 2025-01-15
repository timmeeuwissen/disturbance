import { dbService } from '~/server/utils/db'
import type { Issue } from '~/types'
import dayjs from 'dayjs'

interface ExportOptions {
  format: 'csv' | 'json'
  template: 'full' | 'summary' | 'metrics'
  filters?: {
    search?: string
    status?: string
    severity?: string
    timeRange?: string
  }
}

const generateCsv = (issues: Issue[], template: string): string => {
  let headers: string[]
  let rows: string[][]

  switch (template) {
    case 'summary':
      headers = ['ID', 'Title', 'Status', 'Severity', 'Started', 'Resolved', 'Time to Resolve']
      rows = issues.map(issue => [
        issue.id.toString(),
        issue.title,
        issue.status,
        issue.severity,
        dayjs(issue.startTimestamp).format('YYYY-MM-DD HH:mm'),
        issue.resolutionTimestamp ? dayjs(issue.resolutionTimestamp).format('YYYY-MM-DD HH:mm') : 'N/A',
        issue.resolutionTimestamp ? 
          `${dayjs(issue.resolutionTimestamp).diff(dayjs(issue.startTimestamp), 'minute')} minutes` : 
          'N/A'
      ])
      break

    case 'metrics':
      headers = ['ID', 'Time to Report', 'Time to Resolve', 'Impacted Systems Count', 'Teams Involved']
      rows = issues.map(issue => [
        issue.id.toString(),
        `${dayjs(issue.reportTimestamp).diff(dayjs(issue.startTimestamp), 'minute')} minutes`,
        issue.resolutionTimestamp ? 
          `${dayjs(issue.resolutionTimestamp).diff(dayjs(issue.startTimestamp), 'minute')} minutes` : 
          'N/A',
        (issue.impactedSystems || []).length.toString(),
        (issue.involvedTeams || []).length.toString()
      ])
      break

    default: // full
      headers = [
        'ID', 'Title', 'Description', 'Reporter', 'Registrar', 'Severity', 'Status',
        'Topic', 'Started', 'Reported', 'Resolved', 'Mitigation Steps'
      ]
      rows = issues.map(issue => [
        issue.id.toString(),
        issue.title,
        issue.description || '',
        issue.reporter,
        issue.registrar,
        issue.severity,
        issue.status,
        issue.topic,
        dayjs(issue.startTimestamp).format('YYYY-MM-DD HH:mm'),
        dayjs(issue.reportTimestamp).format('YYYY-MM-DD HH:mm'),
        issue.resolutionTimestamp ? dayjs(issue.resolutionTimestamp).format('YYYY-MM-DD HH:mm') : 'N/A',
        issue.mitigationSteps || ''
      ])
  }

  // Escape CSV values and wrap in quotes if needed
  const escapeCsvValue = (value: string): string => {
    if (value.includes(',') || value.includes('"') || value.includes('\n')) {
      return `"${value.replace(/"/g, '""')}"`
    }
    return value
  }

  return [
    headers.join(','),
    ...rows.map(row => row.map(escapeCsvValue).join(','))
  ].join('\n')
}

const filterIssues = (issues: Issue[], filters?: ExportOptions['filters']): Issue[] => {
  if (!filters) return issues

  return issues.filter(issue => {
    const matchesSearch = !filters.search || 
      issue.title.toLowerCase().includes(filters.search.toLowerCase()) ||
      issue.description?.toLowerCase().includes(filters.search.toLowerCase())
    
    const matchesStatus = !filters.status || issue.status === filters.status
    const matchesSeverity = !filters.severity || issue.severity === filters.severity
    
    let matchesTimeRange = true
    if (filters.timeRange && filters.timeRange !== 'all') {
      const startDate = dayjs(issue.startTimestamp)
      const timeRangeParts = filters.timeRange.match(/(\d+)([dwy])/)
      
      if (timeRangeParts) {
        const [, amount, unit] = timeRangeParts
        const unitMap: { [key: string]: 'day' | 'week' | 'month' | 'year' } = { 
          d: 'day', 
          w: 'week', 
          y: 'year' 
        }
        const mappedUnit = unitMap[unit as keyof typeof unitMap]
        if (mappedUnit) {
          matchesTimeRange = startDate.isAfter(
            dayjs().subtract(parseInt(amount), mappedUnit)
          )
        }
      }
    }
    
    return matchesSearch && matchesStatus && matchesSeverity && matchesTimeRange
  })
}

export default defineEventHandler(async (event) => {
  try {
    const body = await readBody<ExportOptions>(event)
    const { format, template, filters } = body

    if (!['csv', 'json'].includes(format)) {
      throw createError({
        statusCode: 400,
        message: 'Invalid export format'
      })
    }

    if (!['full', 'summary', 'metrics'].includes(template)) {
      throw createError({
        statusCode: 400,
        message: 'Invalid export template'
      })
    }

    // Get and filter issues
    const issues = filterIssues(dbService.getAllIssues(), filters)

    // Generate export based on format
    if (format === 'csv') {
      setHeader(event, 'Content-Type', 'text/csv')
      setHeader(event, 'Content-Disposition', `attachment; filename=issues-${dayjs().format('YYYY-MM-DD')}.csv`)
      return generateCsv(issues, template)
    } else {
      setHeader(event, 'Content-Type', 'application/json')
      setHeader(event, 'Content-Disposition', `attachment; filename=issues-${dayjs().format('YYYY-MM-DD')}.json`)
      return JSON.stringify(issues, null, 2)
    }
  } catch (error: any) {
    console.error('Error exporting issues:', error)
    
    if (error?.statusCode) {
      throw error
    }
    
    throw createError({
      statusCode: 500,
      message: 'Failed to export issues'
    })
  }
})
