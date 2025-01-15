import { dbService } from '~/server/utils/db'
import type { Issue, Reference, ImpactedSystem, InvolvedTeam } from '~/types'

export default defineEventHandler(async (event) => {
  try {
    const id = parseInt(event.context.params?.id || '')
    
    if (isNaN(id)) {
      throw createError({
        statusCode: 400,
        message: 'Invalid issue ID'
      })
    }

    const body = await readBody(event)
    
    // Extract the main issue data and related entities
    const {
      references = [],
      impactedSystems = [],
      involvedTeams = [],
      ...issueData
    } = body

    // Validate required fields
    const requiredFields = [
      'title',
      'reporter',
      'registrar',
      'severity',
      'status',
      'topic',
      'startTimestamp',
      'reportTimestamp'
    ]

    for (const field of requiredFields) {
      if (!issueData[field]) {
        throw createError({
          statusCode: 400,
          message: `Missing required field: ${field}`
        })
      }
    }

    // Validate severity
    if (!['critical', 'high', 'medium', 'low'].includes(issueData.severity)) {
      throw createError({
        statusCode: 400,
        message: 'Invalid severity level'
      })
    }

    // Validate status
    if (!['open', 'investigating', 'mitigated', 'resolved', 'closed'].includes(issueData.status)) {
      throw createError({
        statusCode: 400,
        message: 'Invalid status'
      })
    }

    // Update the issue with related data
    const updatedIssue = dbService.updateIssue(
      id,
      issueData as Omit<Issue, 'id' | 'createdAt' | 'updatedAt'>,
      references as Omit<Reference, 'id' | 'issueId'>[],
      impactedSystems as Omit<ImpactedSystem, 'id' | 'issueId'>[],
      involvedTeams as Omit<InvolvedTeam, 'id' | 'issueId'>[]
    )

    if (!updatedIssue) {
      throw createError({
        statusCode: 404,
        message: 'Issue not found'
      })
    }

    return updatedIssue
  } catch (error: any) {
    console.error('Error updating issue:', error)
    
    if (error?.statusCode) {
      throw error
    }
    
    throw createError({
      statusCode: 500,
      message: 'Failed to update issue'
    })
  }
})
