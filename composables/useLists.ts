import type { Severity, Status, ReferenceType, SqlQueryResult } from '~/types'

export const useLists = () => {
  const severities = ref<Severity[]>([])
  const statuses = ref<Status[]>([])
  const referenceTypes = ref<ReferenceType[]>([])
  const loading = ref(false)

  const fetchSeverities = async () => {
    try {
      const response = await $fetch<SqlQueryResult>('/api/admin/sql', {
        method: 'POST',
        body: {
          query: 'SELECT * FROM severities WHERE is_active = 1 ORDER BY sort_order'
        }
      })
      severities.value = response.rows.map(row => ({
        id: row.id,
        value: row.value,
        description: row.description,
        sortOrder: row.sort_order,
        isActive: row.is_active === 1,
        createdAt: row.created_at,
        updatedAt: row.updated_at
      }))
    } catch (error) {
      console.error('Error fetching severities:', error)
      const showMessage = inject<(text: string, color?: 'success' | 'error') => void>('showMessage')
      showMessage?.('Error loading severities', 'error')
    }
  }

  const fetchStatuses = async () => {
    try {
      const response = await $fetch<SqlQueryResult>('/api/admin/sql', {
        method: 'POST',
        body: {
          query: 'SELECT * FROM statuses WHERE is_active = 1 ORDER BY sort_order'
        }
      })
      statuses.value = response.rows.map(row => ({
        id: row.id,
        value: row.value,
        description: row.description,
        sortOrder: row.sort_order,
        isActive: row.is_active === 1,
        isFinal: row.is_final === 1,
        createdAt: row.created_at,
        updatedAt: row.updated_at
      }))
    } catch (error) {
      console.error('Error fetching statuses:', error)
      const showMessage = inject<(text: string, color?: 'success' | 'error') => void>('showMessage')
      showMessage?.('Error loading statuses', 'error')
    }
  }

  const fetchReferenceTypes = async () => {
    try {
      const response = await $fetch<SqlQueryResult>('/api/admin/sql', {
        method: 'POST',
        body: {
          query: 'SELECT * FROM reference_types WHERE is_active = 1 ORDER BY sort_order'
        }
      })
      referenceTypes.value = response.rows.map(row => ({
        id: row.id,
        value: row.value,
        description: row.description,
        sortOrder: row.sort_order,
        isActive: row.is_active === 1,
        createdAt: row.created_at,
        updatedAt: row.updated_at
      }))
    } catch (error) {
      console.error('Error fetching reference types:', error)
      const showMessage = inject<(text: string, color?: 'success' | 'error') => void>('showMessage')
      showMessage?.('Error loading reference types', 'error')
    }
  }

  const fetchAll = async () => {
    loading.value = true
    try {
      await Promise.all([
        fetchSeverities(),
        fetchStatuses(),
        fetchReferenceTypes()
      ])
    } finally {
      loading.value = false
    }
  }

  // Computed properties for values only
  const severityValues = computed(() => severities.value.map(s => s.value))
  const statusValues = computed(() => statuses.value.map(s => s.value))
  const referenceTypeValues = computed(() => referenceTypes.value.map(r => r.value))

  // Helper functions
  const findStatus = (value: string) => statuses.value.find(s => s.value === value)
  const findSeverity = (value: string) => severities.value.find(s => s.value === value)
  const findReferenceType = (value: string) => referenceTypes.value.find(r => r.value === value)

  return {
    // Raw data
    severities,
    statuses,
    referenceTypes,
    loading,

    // Values only
    severityValues,
    statusValues,
    referenceTypeValues,

    // Fetch functions
    fetchAll,
    fetchSeverities,
    fetchStatuses,
    fetchReferenceTypes,

    // Helper functions
    findStatus,
    findSeverity,
    findReferenceType
  }
}
