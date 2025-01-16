import { dbService } from '~/server/utils/db'

export default defineEventHandler(async (event) => {
  const type = getRouterParam(event, 'type')
  const body = await readBody(event)

  if (!type || !body.name) {
    throw createError({
      statusCode: 400,
      message: 'Invalid parameters'
    })
  }

  try {
    switch (type) {
      case 'statuses':
        return await dbService.createStatus(body.name, body.isFinal || false)
      case 'severities':
        return await dbService.createSeverity(body.name)
      case 'reference-types':
        return await dbService.createReferenceType(body.name)
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
