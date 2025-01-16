import { useAdmin } from '~/composables/useAdmin'

export default defineNuxtRouteMiddleware((to) => {
  const { isAdmin } = useAdmin()

  if (to.path.startsWith('/admin') && !isAdmin.value) {
    return navigateTo('/')
  }
})
