import { dbService } from '~/server/utils/db'

export default defineEventHandler(async () => {
  try {
    const issues = dbService.getAllIssues()
    return issues
  } catch (error) {
    console.error('Error fetching issues:', error)
    throw createError({
      statusCode: 500,
      message: 'Failed to fetch issues'
    })
  }
})
