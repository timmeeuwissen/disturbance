<template lang="pug">
v-container(fluid)
  v-row
    v-col(cols="12")
      h1.text-warning.mb-4 List Management

  v-row
    v-col(cols="12" md="6" lg="4")
      v-card(variant="outlined")
        v-card-title
          span Statuses
          v-spacer
          v-btn(
            color="warning"
            prepend-icon="mdi-plus"
            size="small"
            @click="addStatus"
          ) Add
        v-card-text
          v-list
            v-list-item(
              v-for="status in statuses"
              :key="status.id"
              :title="status.name"
            )
              template(#append)
                v-switch(
                  v-model="status.is_final"
                  color="warning"
                  hide-details
                  density="compact"
                  label="Final"
                  @change="updateStatus(status)"
                )
                v-switch(
                  v-model="status.is_default"
                  color="warning"
                  hide-details
                  density="compact"
                  label="Default"
                  @change="updateStatus(status)"
                )
                v-btn(
                  icon="mdi-pencil"
                  variant="text"
                  size="small"
                  class="ml-2"
                  @click="editStatus(status)"
                )
                v-btn(
                  icon="mdi-delete"
                  variant="text"
                  size="small"
                  color="error"
                  @click="deleteStatus(status)"
                )

    v-col(cols="12" md="6" lg="4")
      v-card(variant="outlined")
        v-card-title
          span Severities
          v-spacer
          v-btn(
            color="warning"
            prepend-icon="mdi-plus"
            size="small"
            @click="addSeverity"
          ) Add
        v-card-text
          v-list
            v-list-item(
              v-for="severity in severities"
              :key="severity.id"
              :title="severity.name"
            )
              template(#append)
                v-switch(
                  v-model="severity.is_default"
                  color="warning"
                  hide-details
                  density="compact"
                  label="Default"
                  @change="updateSeverity(severity)"
                )
                v-btn(
                  icon="mdi-pencil"
                  variant="text"
                  size="small"
                  @click="editSeverity(severity)"
                )
                v-btn(
                  icon="mdi-delete"
                  variant="text"
                  size="small"
                  color="error"
                  @click="deleteSeverity(severity)"
                )

    v-col(cols="12" md="6" lg="4")
      v-card(variant="outlined")
        v-card-title
          span Reference Types
          v-spacer
          v-btn(
            color="warning"
            prepend-icon="mdi-plus"
            size="small"
            @click="addReferenceType"
          ) Add
        v-card-text
          v-list
            v-list-item(
              v-for="type in referenceTypes"
              :key="type.id"
              :title="type.name"
            )
              template(#append)
                v-switch(
                  v-model="type.is_default"
                  color="warning"
                  hide-details
                  density="compact"
                  label="Default"
                  @change="updateReferenceType(type)"
                )
                v-btn(
                  icon="mdi-pencil"
                  variant="text"
                  size="small"
                  @click="editReferenceType(type)"
                )
                v-btn(
                  icon="mdi-delete"
                  variant="text"
                  size="small"
                  color="error"
                  @click="deleteReferenceType(type)"
                )

  // Edit Dialog
  v-dialog(v-model="dialog.show" max-width="500")
    v-card
      v-card-title {{ dialog.title }}
      v-card-text
        v-text-field(
          v-model="dialog.item.name"
          label="Name"
          :rules="[v => !!v || 'Name is required']"
        )
        v-switch(
          v-if="dialog.type === 'status'"
          v-model="dialog.item.is_final"
          color="warning"
          hide-details
          label="Final Status"
        )
        v-switch(
          v-model="dialog.item.is_default"
          color="warning"
          hide-details
          label="Default Value"
        )
      v-card-actions
        v-spacer
        v-btn(
          color="error"
          variant="text"
          @click="dialog.show = false"
        ) Cancel
        v-btn(
          color="warning"
          @click="saveItem"
        ) Save
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'

interface ListItem {
  id: number
  name: string
  is_final?: boolean
  is_default?: boolean
}

// State
const statuses = ref<ListItem[]>([])
const severities = ref<ListItem[]>([])
const referenceTypes = ref<ListItem[]>([])

// Dialog state
const dialog = reactive({
  show: false,
  title: '',
  type: '' as 'status' | 'severity' | 'reference',
  item: {} as ListItem,
  isNew: false
})

// Load data
const loadData = async () => {
  try {
    const [statusesData, severitiesData, referenceTypesData] = await Promise.all([
      $fetch('/api/admin/lists/statuses'),
      $fetch('/api/admin/lists/severities'),
      $fetch('/api/admin/lists/reference-types')
    ])
    statuses.value = statusesData
    severities.value = severitiesData
    referenceTypes.value = referenceTypesData
  } catch (error: any) {
    console.error('Error loading lists:', error)
    const showMessage = inject<(text: string, color?: 'success' | 'error') => void>('showMessage')
    showMessage?.('Error loading lists', 'error')
  }
}

onMounted(loadData)

// Status actions
const addStatus = () => {
  dialog.show = true
  dialog.title = 'Add Status'
  dialog.type = 'status'
  dialog.item = { id: 0, name: '', is_final: false, is_default: false }
  dialog.isNew = true
}

const editStatus = (status: ListItem) => {
  dialog.show = true
  dialog.title = 'Edit Status'
  dialog.type = 'status'
  dialog.item = { ...status }
  dialog.isNew = false
}

const updateStatus = async (status: ListItem) => {
  try {
    await $fetch(`/api/admin/lists/statuses/${status.id}`, {
      method: 'PUT',
      body: status
    })
    await loadData()
  } catch (error: any) {
    console.error('Error updating status:', error)
    const showMessage = inject<(text: string, color?: 'success' | 'error') => void>('showMessage')
    showMessage?.('Error updating status', 'error')
  }
}

const deleteStatus = async (status: ListItem) => {
  if (confirm(`Are you sure you want to delete "${status.name}"?`)) {
    try {
      await $fetch(`/api/admin/lists/statuses/${status.id}`, {
        method: 'DELETE'
      })
      await loadData()
    } catch (error: any) {
      console.error('Error deleting status:', error)
      const showMessage = inject<(text: string, color?: 'success' | 'error') => void>('showMessage')
      showMessage?.('Error deleting status', 'error')
    }
  }
}

// Severity actions
const addSeverity = () => {
  dialog.show = true
  dialog.title = 'Add Severity'
  dialog.type = 'severity'
  dialog.item = { id: 0, name: '', is_default: false }
  dialog.isNew = true
}

const editSeverity = (severity: ListItem) => {
  dialog.show = true
  dialog.title = 'Edit Severity'
  dialog.type = 'severity'
  dialog.item = { ...severity }
  dialog.isNew = false
}

const updateSeverity = async (severity: ListItem) => {
  try {
    await $fetch(`/api/admin/lists/severities/${severity.id}`, {
      method: 'PUT',
      body: severity
    })
    await loadData()
  } catch (error: any) {
    console.error('Error updating severity:', error)
    const showMessage = inject<(text: string, color?: 'success' | 'error') => void>('showMessage')
    showMessage?.('Error updating severity', 'error')
  }
}

const deleteSeverity = async (severity: ListItem) => {
  if (confirm(`Are you sure you want to delete "${severity.name}"?`)) {
    try {
      await $fetch(`/api/admin/lists/severities/${severity.id}`, {
        method: 'DELETE'
      })
      await loadData()
    } catch (error: any) {
      console.error('Error deleting severity:', error)
      const showMessage = inject<(text: string, color?: 'success' | 'error') => void>('showMessage')
      showMessage?.('Error deleting severity', 'error')
    }
  }
}

// Reference Type actions
const addReferenceType = () => {
  dialog.show = true
  dialog.title = 'Add Reference Type'
  dialog.type = 'reference'
  dialog.item = { id: 0, name: '', is_default: false }
  dialog.isNew = true
}

const editReferenceType = (type: ListItem) => {
  dialog.show = true
  dialog.title = 'Edit Reference Type'
  dialog.type = 'reference'
  dialog.item = { ...type }
  dialog.isNew = false
}

const updateReferenceType = async (type: ListItem) => {
  try {
    await $fetch(`/api/admin/lists/reference-types/${type.id}`, {
      method: 'PUT',
      body: type
    })
    await loadData()
  } catch (error: any) {
    console.error('Error updating reference type:', error)
    const showMessage = inject<(text: string, color?: 'success' | 'error') => void>('showMessage')
    showMessage?.('Error updating reference type', 'error')
  }
}

const deleteReferenceType = async (type: ListItem) => {
  if (confirm(`Are you sure you want to delete "${type.name}"?`)) {
    try {
      await $fetch(`/api/admin/lists/reference-types/${type.id}`, {
        method: 'DELETE'
      })
      await loadData()
    } catch (error: any) {
      console.error('Error deleting reference type:', error)
      const showMessage = inject<(text: string, color?: 'success' | 'error') => void>('showMessage')
      showMessage?.('Error deleting reference type', 'error')
    }
  }
}

// Save dialog item
const saveItem = async () => {
  if (!dialog.item.name) return

  try {
    const endpoint = dialog.type === 'status' ? 'statuses' :
      dialog.type === 'severity' ? 'severities' :
      'reference-types'

    if (dialog.isNew) {
      await $fetch(`/api/admin/lists/${endpoint}`, {
        method: 'POST',
        body: dialog.item
      })
    } else {
      await $fetch(`/api/admin/lists/${endpoint}/${dialog.item.id}`, {
        method: 'PUT',
        body: dialog.item
      })
    }

    dialog.show = false
    await loadData()
  } catch (error: any) {
    console.error('Error saving item:', error)
    const showMessage = inject<(text: string, color?: 'success' | 'error') => void>('showMessage')
    showMessage?.('Error saving item', 'error')
  }
}

definePageMeta({
  middleware: ['admin']
})
</script>
