import { dbService } from '~/server/utils/db'

export default defineEventHandler(async (event) => {
  try {
    const id = parseInt(event.context.params?.id || '')
    
    if (isNaN(id)) {
      throw createError({
        statusCode: 400,
        message: 'Invalid issue ID'
      })
    }

    const issue = dbService.getIssueById(id)
    
    if (!issue) {
      throw createError({
        statusCode: 404,
        message: 'Issue not found'
      })
    }

    return issue
  } catch (error: any) {
    console.error('Error fetching issue:', error)
    
    if (error?.statusCode) {
      throw error
    }
    
    throw createError({
      statusCode: 500,
      message: 'Failed to fetch issue'
    })
  }
})
