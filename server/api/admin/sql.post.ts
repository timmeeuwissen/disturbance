import type { SqlQueryResult } from '~/types'
import { dbService } from '~/server/utils/db'

export default defineEventHandler(async (event) => {
  // Admin check will be handled by middleware
  const { query } = await readBody(event)
  if (!query) {
    throw createError({
      statusCode: 400,
      message: 'Query is required'
    })
  }

  // Prevent destructive queries
  const lowerQuery = query.toLowerCase()
  if (lowerQuery.includes('drop') || lowerQuery.includes('delete') || lowerQuery.includes('truncate')) {
    throw createError({
      statusCode: 400,
      message: 'Destructive queries are not allowed'
    })
  }

  try {
    const rows = dbService.executeQuery(query)
    const result: SqlQueryResult = {
      columns: rows.length > 0 ? Object.keys(rows[0]) : [],
      rows,
      rowCount: rows.length
    }
    return result
  } catch (error: any) {
    throw createError({
      statusCode: 400,
      message: error.message
    })
  }
})
