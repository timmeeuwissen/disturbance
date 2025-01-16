import { dbService } from '~/server/utils/db'

export default defineEventHandler(async (event) => {
  const type = getRouterParam(event, 'type')
  const id = parseInt(getRouterParam(event, 'id') || '0')

  if (!type || !id) {
    throw createError({
      statusCode: 400,
      message: 'Invalid parameters'
    })
  }

  try {
    switch (type) {
      case 'statuses':
        await dbService.deleteStatus(id)
        break
      case 'severities':
        await dbService.deleteSeverity(id)
        break
      case 'reference-types':
        await dbService.deleteReferenceType(id)
        break
      default:
        throw createError({
          statusCode: 400,
          message: 'Invalid list type'
        })
    }
    return { success: true }
  } catch (error: any) {
    throw createError({
      statusCode: 500,
      message: error.message
    })
  }
})
