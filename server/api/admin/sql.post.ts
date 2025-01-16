import { Database } from 'sqlite3'
import { promisify } from 'util'
import type { SqlQueryResult } from '~/types'

export default defineEventHandler(async (event) => {
  const { isAdmin } = useAdmin()
  if (!isAdmin.value) {
    throw createError({
      statusCode: 403,
      message: 'Unauthorized: Admin access required'
    })
  }

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

  const db = new Database('db/disturbance.db')
  const runAsync = promisify(db.all).bind(db)

  try {
    const rows = await runAsync(query)
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
  } finally {
    db.close()
  }
})
