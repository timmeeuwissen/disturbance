import { dbService } from '~/server/utils/db'

export default defineEventHandler(async (event) => {
  const type = getRouterParam(event, 'type')
  const id = parseInt(getRouterParam(event, 'id') || '0')
  const body = await readBody(event)

  if (!type || !id || !body.name) {
    throw createError({
      statusCode: 400,
      message: 'Invalid parameters'
    })
  }

  try {
    switch (type) {
      case 'statuses':
        return await dbService.updateStatus(id, body.name, body.isFinal || false)
      case 'severities':
        return await dbService.updateSeverity(id, body.name)
      case 'reference-types':
        return await dbService.updateReferenceType(id, body.name)
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
