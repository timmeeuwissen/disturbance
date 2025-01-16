<template lang="pug">
v-container(fluid)
  v-row
    v-col(cols="12")
      h1.text-h4.mb-4 New Issue
      v-form(ref="form" @submit.prevent="submitForm")
        v-card
          v-card-text
            v-row
              v-col(cols="12")
                v-text-field(
                  v-model="issue.title"
                  label="Title"
                  required
                  :rules="[v => !!v || 'Title is required']"
                )
              
              v-col(cols="12")
                v-textarea(
                  v-model="issue.description"
                  label="Description"
                  rows="3"
                )
              
              v-col(cols="12" sm="6")
                v-text-field(
                  v-model="issue.reporter"
                  label="Reporter"
                  required
                  :rules="[v => !!v || 'Reporter is required']"
                )
              
              v-col(cols="12" sm="6")
                v-text-field(
                  v-model="issue.registrar"
                  label="Registrar"
                  required
                  :rules="[v => !!v || 'Registrar is required']"
                )
              
              v-col(cols="12" sm="6")
                v-select(
                  v-model="issue.severity"
                  label="Severity"
                  :items="severityValues"
                  required
                  :rules="[v => !!v || 'Severity is required']"
                  :loading="listsLoading"
                )
              
              v-col(cols="12" sm="6")
                v-select(
                  v-model="issue.status"
                  label="Status"
                  :items="statusValues"
                  required
                  :rules="[v => !!v || 'Status is required']"
                  :loading="listsLoading"
                )
              
              v-col(cols="12")
                v-text-field(
                  v-model="issue.topic"
                  label="Topic"
                  required
                  :rules="[v => !!v || 'Topic is required']"
                )
              
              v-col(cols="12" sm="4")
                v-text-field(
                  v-model="issue.startTimestamp"
                  label="Start Time"
                  type="datetime-local"
                  :rules="timestampRules"
                )
              
              v-col(cols="12" sm="4")
                v-text-field(
                  v-model="issue.reportTimestamp"
                  label="Report Time"
                  type="datetime-local"
                )
              
              v-col(cols="12" sm="4")
                v-text-field(
                  v-model="issue.resolutionTimestamp"
                  label="Resolution Time"
                  type="datetime-local"
                  :rules="timestampRules"
                )
              
              v-col(cols="12")
                v-textarea(
                  v-model="issue.mitigationSteps"
                  label="Mitigation Steps"
                  rows="3"
                )

          v-divider

          v-card-text
            h2.text-h6.mb-4 Communication Log
            v-row(v-for="(log, index) in communicationLogs" :key="index")
              v-col(cols="12" sm="3")
                v-text-field(
                  v-model="log.datetime"
                  label="Date & Time"
                  type="datetime-local"
                  required
                  :rules="[v => !!v || 'Date & time is required']"
                )
              
              v-col(cols="12" sm="3")
                v-text-field(
                  v-model="log.communicator"
                  label="Communicator"
                  required
                  :rules="[v => !!v || 'Communicator is required']"
                )
              
              v-col(cols="12" sm="3")
                v-text-field(
                  v-model="log.system"
                  label="System"
                )
              
              v-col(cols="12" sm="3")
                v-switch(
                  v-model="log.isInternal"
                  label="Internal"
                  color="primary"
                )
              
              v-col(cols="12")
                v-text-field(
                  v-model="log.link"
                  label="Link"
                )
              
              v-col(cols="12")
                v-textarea(
                  v-model="log.message"
                  label="Message"
                  rows="2"
                  required
                  :rules="[v => !!v || 'Message is required']"
                )
            
            v-btn(
              color="primary"
              prepend-icon="mdi-plus"
              @click="addCommunicationLog"
            ) Add Communication Log

          v-divider

          v-card-text
            h2.text-h6.mb-4 References
            v-row(v-for="(ref, index) in references" :key="index")
              v-col(cols="12" sm="4")
                v-text-field(
                  v-model="ref.url"
                  label="URL"
                  required
                  :rules="[v => !!v || 'URL is required']"
                )
              
              v-col(cols="12" sm="4")
                v-select(
                  v-model="ref.referenceType"
                  label="Type"
                  :items="referenceTypeValues"
                  required
                  :rules="[v => !!v || 'Type is required']"
                  :loading="listsLoading"
                )
              
              v-col(cols="12" sm="4")
                v-text-field(
                  v-model="ref.description"
                  label="Description"
                )
            
            v-btn(
              color="primary"
              prepend-icon="mdi-plus"
              @click="addReference"
            ) Add Reference

          v-divider

          v-card-text
            h2.text-h6.mb-4 Impacted Systems
            v-row(v-for="(system, index) in impactedSystems" :key="index")
              v-col(cols="12" sm="6")
                v-text-field(
                  v-model="system.systemName"
                  label="System Name"
                  required
                  :rules="[v => !!v || 'System name is required']"
                )
              
              v-col(cols="12" sm="6")
                v-text-field(
                  v-model="system.impactDescription"
                  label="Impact Description"
                )
            
            v-btn(
              color="primary"
              prepend-icon="mdi-plus"
              @click="addImpactedSystem"
            ) Add Impacted System

          v-divider

          v-card-text
            h2.text-h6.mb-4 Involved Teams
            v-row(v-for="(team, index) in involvedTeams" :key="index")
              v-col(cols="12" sm="6")
                v-text-field(
                  v-model="team.teamName"
                  label="Team Name"
                  required
                  :rules="[v => !!v || 'Team name is required']"
                )
              
              v-col(cols="12" sm="6")
                v-text-field(
                  v-model="team.role"
                  label="Role"
                )
            
            v-btn(
              color="primary"
              prepend-icon="mdi-plus"
              @click="addInvolvedTeam"
            ) Add Involved Team

          v-card-actions
            v-spacer
            v-btn(
              color="primary"
              type="submit"
              :loading="loading"
            ) Create Issue
</template>

<script setup lang="ts">
import { ref, computed, watch } from 'vue'
import type { 
  CreateIssueInput, 
  CreateCommunicationLogInput, 
  CreateReferenceInput, 
  CreateImpactedSystemInput, 
  CreateInvolvedTeamInput
} from '~/types'

const form = ref<any>(null)
const loading = ref(false)

// Lists
const { 
  severityValues,
  statusValues,
  referenceTypeValues,
  findStatus,
  loading: listsLoading,
  fetchAll: fetchLists
} = useLists()

// Form data
const issue = ref<CreateIssueInput>({
  title: '',
  description: '',
  reporter: '',
  registrar: '',
  severity: 'medium',
  status: 'open',
  topic: '',
  startTimestamp: null,
  reportTimestamp: null,
  resolutionTimestamp: null,
  mitigationSteps: null
})

const communicationLogs = ref<CreateCommunicationLogInput[]>([])
const references = ref<CreateReferenceInput[]>([])
const impactedSystems = ref<CreateImpactedSystemInput[]>([])
const involvedTeams = ref<CreateInvolvedTeamInput[]>([])

// Watch for status changes to handle required timestamps
watch(() => issue.value.status, (newStatus) => {
  const status = findStatus(newStatus)
  if (status?.isFinal) {
    form.value?.validate()
  }
})

// Validation rules
const timestampRules = computed(() => {
  const status = findStatus(issue.value.status)
  if (status?.isFinal) {
    return [(v: string | null) => !!v || 'Required for final status']
  }
  return []
})

// Methods
const addCommunicationLog = () => {
  communicationLogs.value.push({
    link: null,
    datetime: '',
    communicator: '',
    system: null,
    isInternal: false,
    message: ''
  })
}

const addReference = () => {
  references.value.push({
    url: '',
    referenceType: 'other',
    description: null
  })
}

const addImpactedSystem = () => {
  impactedSystems.value.push({
    systemName: '',
    impactDescription: null
  })
}

const addInvolvedTeam = () => {
  involvedTeams.value.push({
    teamName: '',
    role: null
  })
}

const submitForm = async () => {
  const { valid } = await form.value?.validate()
  if (!valid) return

  loading.value = true
  try {
    const response = await $fetch('/api/issues', {
      method: 'POST',
      body: {
        ...issue.value,
        communicationLogs: communicationLogs.value,
        references: references.value,
        impactedSystems: impactedSystems.value,
        involvedTeams: involvedTeams.value
      }
    })

    navigateTo(`/issues/${response.id}`)
  } catch (error) {
    console.error('Error creating issue:', error)
    const showMessage = inject<(text: string, color?: 'success' | 'error') => void>('showMessage')
    showMessage?.('Failed to create issue. Please try again.', 'error')
  } finally {
    loading.value = false
  }
}

// Fetch lists on mount
onMounted(() => {
  fetchLists()
})
</script>
