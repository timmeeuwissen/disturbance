import { dbService } from '~/server/utils/db'

interface OrderItem {
  id: number
  sort_order: number
}

export default defineEventHandler(async (event) => {
  const type = getRouterParam(event, 'type')
  const items = await readBody<OrderItem[]>(event)

  if (!type || !items?.length) {
    throw createError({
      statusCode: 400,
      message: 'Invalid parameters'
    })
  }

  try {
    const db = dbService.getDb()
    await db.transaction(() => {
      let table: string
      switch (type) {
        case 'statuses':
          table = 'statuses'
          break
        case 'severities':
          table = 'severities'
          break
        case 'reference-types':
          table = 'reference_types'
          break
        default:
          throw createError({
            statusCode: 400,
            message: 'Invalid list type'
          })
      }

      const stmt = db.prepare(`UPDATE ${table} SET sort_order = ? WHERE id = ?`)
      for (const item of items) {
        stmt.run(item.sort_order, item.id)
      }
    })()

    return { success: true }
  } catch (error: any) {
    throw createError({
      statusCode: 500,
      message: error.message
    })
  }
})
