import { useAdmin } from '~/composables/useAdmin'

export default defineNuxtRouteMiddleware((to) => {
  const { store } = useAdmin()

  if (to.path.startsWith('/admin') && !store.isAdmin) {
    return navigateTo('/')
  }
})
