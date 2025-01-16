import { ref } from 'vue'
import { useStorage } from '@vueuse/core'

export const useAdmin = () => {
  const isAdmin = useStorage('disturbance-admin-mode', false)
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
    isAdmin.value = !isAdmin.value
  }

  return {
    isAdmin,
    adminTheme,
    toggleAdmin
  }
}
