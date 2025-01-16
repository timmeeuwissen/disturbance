import { dbService } from '~/server/utils/db'

export default defineEventHandler(async (event) => {
  const type = getRouterParam(event, 'type')

  if (!type) {
    throw createError({
      statusCode: 400,
      message: 'Invalid parameters'
    })
  }

  try {
    switch (type) {
      case 'statuses':
        return await dbService.getAllStatuses()
      case 'severities':
        return await dbService.getAllSeverities()
      case 'reference-types':
        return await dbService.getAllReferenceTypes()
      default:
        throw createError({
          statusCode: 400,
          message: 'Invalid list type'
        })
    }
  } catch (error: any) {
    throw createError({
      statusCode: 500,
      message: error.message
    })
  }
})
