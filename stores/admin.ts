import { defineStore } from 'pinia'

interface AdminState {
  isAdmin: boolean
}

export const useAdminStore = defineStore('admin', {
  state: (): AdminState => ({
    isAdmin: false
  }),
  actions: {
    setAdmin(value: boolean) {
      this.isAdmin = value
    },
    toggleAdmin() {
      this.isAdmin = !this.isAdmin
    }
  },
  persist: true
})
