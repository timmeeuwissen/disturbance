import { computed } from 'vue'
import { useAdminStore } from '~/stores/admin'

export const useAdmin = () => {
  const store = useAdminStore()

  const adminTheme = {
    dark: false,
    colors: {
      primary: '#FF9800',
      secondary: '#FFB74D',
      accent: '#FFA726',
      error: '#FF5252',
      info: '#2196F3',
      success: '#4CAF50',
      warning: '#FB8C00'
    }
  }

  const toggleAdmin = () => {
    store.toggleAdmin()
  }

  return {
    store,
    adminTheme,
    toggleAdmin
  }
}
