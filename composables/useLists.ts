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

  const loading = ref(false)

  // Convert to simple arrays for backwards compatibility
  const statusValues = computed(() => statuses.value.map(s => s.name))
  const severityValues = computed(() => severities.value.map(s => s.name))
  const referenceTypeValues = computed(() => referenceTypes.value.map(r => r.name))

  const loadLists = async () => {
    loading.value = true
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
    } finally {
      loading.value = false
    }
  }

  onMounted(loadLists)

  return {
    // Lists
    statuses,
    severities,
    referenceTypes,
    
    // Values (for backwards compatibility)
    statusValues,
    severityValues,
    referenceTypeValues,
    
    // Defaults
    defaultStatus,
    defaultSeverity,
    defaultReferenceType,
    
    // State
    loading,
    
    // Actions
    loadLists
  }
}
