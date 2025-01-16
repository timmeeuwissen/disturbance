import { ref, onMounted, inject } from 'vue'

export interface ListItem {
  id: number
  name: string
  is_final?: boolean
  is_default?: boolean
}

export const useLists = () => {
  const statuses = ref<ListItem[]>([])
  const severities = ref<ListItem[]>([])
  const referenceTypes = ref<ListItem[]>([])

  const defaultStatus = ref<ListItem | null>(null)
  const defaultSeverity = ref<ListItem | null>(null)
  const defaultReferenceType = ref<ListItem | null>(null)

  const loadLists = async () => {
    try {
      const [statusesData, severitiesData, referenceTypesData] = await Promise.all([
        $fetch<ListItem[]>('/api/admin/lists/statuses'),
        $fetch<ListItem[]>('/api/admin/lists/severities'),
        $fetch<ListItem[]>('/api/admin/lists/reference-types')
      ])

      statuses.value = statusesData
      severities.value = severitiesData
      referenceTypes.value = referenceTypesData

      // Set defaults
      defaultStatus.value = statusesData.find(s => s.is_default) || null
      defaultSeverity.value = severitiesData.find(s => s.is_default) || null
      defaultReferenceType.value = referenceTypesData.find(t => t.is_default) || null
    } catch (error: any) {
      console.error('Error loading lists:', error)
      const showMessage = inject<(text: string, color?: 'success' | 'error') => void>('showMessage')
      showMessage?.('Error loading lists', 'error')
    }
  }

  onMounted(loadLists)

  return {
    // Lists
    statuses,
    severities,
    referenceTypes,
    
    // Defaults
    defaultStatus,
    defaultSeverity,
    defaultReferenceType,
    
    // Actions
    loadLists
  }
}
