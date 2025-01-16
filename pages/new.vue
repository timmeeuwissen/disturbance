<template lang="pug">
v-container(fluid)
  v-row
    v-col(cols="12")
      h1.text-warning.mb-4 New Issue

  v-row
    v-col(cols="12" md="8")
      v-card(variant="outlined")
        v-card-text
          v-form(ref="form" @submit.prevent="submit")
            v-text-field(
              v-model="issue.title"
              label="Title"
              :rules="[v => !!v || 'Title is required']"
            )
            v-textarea(
              v-model="issue.description"
              label="Description"
              :rules="[v => !!v || 'Description is required']"
            )
            v-row
              v-col(cols="12" md="6")
                v-text-field(
                  v-model="issue.reporter"
                  label="Reporter"
                  :rules="[v => !!v || 'Reporter is required']"
                )
              v-col(cols="12" md="6")
                v-text-field(
                  v-model="issue.registrar"
                  label="Registrar"
                  :rules="[v => !!v || 'Registrar is required']"
                )
            v-row
              v-col(cols="12" md="6")
                v-select(
                  v-model="issue.severity"
                  :items="severities"
                  item-title="name"
                  item-value="name"
                  label="Severity"
                  :rules="[v => !!v || 'Severity is required']"
                )
              v-col(cols="12" md="6")
                v-select(
                  v-model="issue.status"
                  :items="statuses"
                  item-title="name"
                  item-value="name"
                  label="Status"
                  :rules="[v => !!v || 'Status is required']"
                )
            v-text-field(
              v-model="issue.topic"
              label="Topic"
            )
            v-row
              v-col(cols="12" md="6")
                v-text-field(
                  v-model="issue.start_timestamp"
                  type="datetime-local"
                  label="Start Time"
                )
              v-col(cols="12" md="6")
                v-text-field(
                  v-model="issue.report_timestamp"
                  type="datetime-local"
                  label="Report Time"
                  :rules="[v => !!v || 'Report time is required']"
                )
            v-textarea(
              v-model="issue.mitigation_steps"
              label="Mitigation Steps"
            )

            v-btn(
              color="warning"
              type="submit"
              :loading="loading"
              class="mt-4"
            ) Create Issue
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter } from '#app'
import { useLists } from '~/composables/useLists'

const router = useRouter()
const form = ref<any>(null)
const loading = ref(false)

// Get lists and defaults
const { 
  statuses, severities, referenceTypes,
  defaultStatus, defaultSeverity, defaultReferenceType
} = useLists()

// Initialize issue with defaults
const issue = ref({
  title: '',
  description: '',
  reporter: '',
  registrar: '',
  severity: '',
  status: '',
  topic: '',
  start_timestamp: '',
  report_timestamp: new Date().toISOString().slice(0, 16),
  mitigation_steps: ''
})

// Set defaults when available
onMounted(() => {
  if (defaultStatus.value) {
    issue.value.status = defaultStatus.value.name
  }
  if (defaultSeverity.value) {
    issue.value.severity = defaultSeverity.value.name
  }
})

const submit = async () => {
  const { valid } = await form.value.validate()
  if (!valid) return

  loading.value = true
  try {
    const response = await $fetch('/api/issues', {
      method: 'POST',
      body: issue.value
    })
    
    router.push(`/issues/${response.id}`)
  } catch (error: any) {
    console.error('Error creating issue:', error)
    const showMessage = inject<(text: string, color?: 'success' | 'error') => void>('showMessage')
    showMessage?.('Error creating issue', 'error')
  } finally {
    loading.value = false
  }
}
</script>
