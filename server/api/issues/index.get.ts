import { dbService } from '~/server/utils/db'

export default defineEventHandler(async () => {
  try {
    const issues = dbService.getAllIssues()
    return issues
  } catch (error: any) {
    throw createError({
      statusCode: 500,
      message: error.message
    })
  }
})
