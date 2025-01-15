<template lang="pug">
v-card
  v-card-title New Issue
  
  v-card-text
    v-form(@submit.prevent="submitIssue" ref="form")
      v-container
        // Basic Information
        v-row
          v-col(cols="12")
            v-text-field(
              v-model="issue.title"
              label="Title"
              required
              placeholder="Brief description of the issue"
              :rules="[v => !!v || 'Title is required']"
            )

        v-row
          v-col(cols="12" sm="6")
            v-text-field(
              v-model="issue.reporter"
              label="Reporter"
              required
              placeholder="Who reported the issue"
              :rules="[v => !!v || 'Reporter is required']"
            )
          
          v-col(cols="12" sm="6")
            v-text-field(
              v-model="issue.registrar"
              label="Registrar"
              required
              placeholder="Who is registering the issue"
              :rules="[v => !!v || 'Registrar is required']"
            )

        v-row
          v-col(cols="12" sm="4")
            v-select(
              v-model="issue.severity"
              label="Severity"
              required
              :items="['critical', 'high', 'medium', 'low']"
              :rules="[v => !!v || 'Severity is required']"
            )

          v-col(cols="12" sm="4")
            v-select(
              v-model="issue.status"
              label="Status"
              required
              :items="['open', 'investigating', 'mitigated', 'resolved', 'closed']"
              :rules="[v => !!v || 'Status is required']"
            )

          v-col(cols="12" sm="4")
            v-text-field(
              v-model="issue.topic"
              label="Topic"
              required
              placeholder="Issue category/topic"
              :rules="[v => !!v || 'Topic is required']"
            )

        v-row
          v-col(cols="12" sm="4")
            v-text-field(
              v-model="issue.startTimestamp"
              label="Start Time"
              type="datetime-local"
              required
              :rules="[v => !!v || 'Start time is required']"
            )

          v-col(cols="12" sm="4")
            v-text-field(
              v-model="issue.reportTimestamp"
              label="Report Time"
              type="datetime-local"
              required
              :rules="[v => !!v || 'Report time is required']"
            )

          v-col(cols="12" sm="4")
            v-text-field(
              v-model="issue.resolutionTimestamp"
              label="Resolution Time"
              type="datetime-local"
            )

        v-row
          v-col(cols="12")
            v-textarea(
              v-model="issue.description"
              label="Description"
              placeholder="Detailed description of the issue"
              rows="3"
            )

          v-col(cols="12")
            v-textarea(
              v-model="issue.mitigationSteps"
              label="Mitigation Steps"
              placeholder="Steps taken to mitigate the issue"
              rows="3"
            )

        // References Section
        v-row
          v-col(cols="12")
            v-card(variant="outlined")
              v-card-title References (Jira, Slack, etc.)
              v-card-text
                v-row(v-for="(ref, index) in references" :key="index")
                  v-col(cols="12" sm="6")
                    v-text-field(
                      v-model="ref.url"
                      label="URL"
                      type="url"
                      placeholder="URL"
                    )
                  v-col(cols="12" sm="4")
                    v-select(
                      v-model="ref.referenceType"
                      label="Type"
                      :items="['jira', 'slack', 'system', 'other']"
                    )
                  v-col(cols="12" sm="2")
                    v-btn(
                      color="error"
                      variant="outlined"
                      @click="removeReference(index)"
                      block
                    ) Remove
                v-btn(
                  color="primary"
                  variant="outlined"
                  @click="addReference"
                  class="mt-2"
                  block
                ) Add Reference

        // Impacted Systems Section
        v-row
          v-col(cols="12")
            v-card(variant="outlined")
              v-card-title Impacted Systems
              v-card-text
                v-row(v-for="(system, index) in impactedSystems" :key="index")
                  v-col(cols="12" sm="5")
                    v-text-field(
                      v-model="system.systemName"
                      label="System Name"
                      placeholder="System name"
                    )
                  v-col(cols="12" sm="5")
                    v-text-field(
                      v-model="system.impactDescription"
                      label="Impact Description"
                      placeholder="Impact description"
                    )
                  v-col(cols="12" sm="2")
                    v-btn(
                      color="error"
                      variant="outlined"
                      @click="removeSystem(index)"
                      block
                    ) Remove
                v-btn(
                  color="primary"
                  variant="outlined"
                  @click="addSystem"
                  class="mt-2"
                  block
                ) Add System

        // Involved Teams Section
        v-row
          v-col(cols="12")
            v-card(variant="outlined")
              v-card-title Involved Teams
              v-card-text
                v-row(v-for="(team, index) in involvedTeams" :key="index")
                  v-col(cols="12" sm="5")
                    v-text-field(
                      v-model="team.teamName"
                      label="Team Name"
                      placeholder="Team name"
                    )
                  v-col(cols="12" sm="5")
                    v-text-field(
                      v-model="team.role"
                      label="Role"
                      placeholder="Team's role"
                    )
                  v-col(cols="12" sm="2")
                    v-btn(
                      color="error"
                      variant="outlined"
                      @click="removeTeam(index)"
                      block
                    ) Remove
                v-btn(
                  color="primary"
                  variant="outlined"
                  @click="addTeam"
                  class="mt-2"
                  block
                ) Add Team

  v-card-actions
    v-spacer
    v-btn(
      color="secondary"
      variant="outlined"
      @click="resetForm"
    ) Reset
    v-btn(
      color="primary"
      @click="submitIssue"
    ) Create Issue
</template>

<script setup lang="ts">
import type { Issue, Reference, ImpactedSystem, InvolvedTeam } from '~/types'

const form = ref<any>(null)

const issue = ref<Omit<Issue, 'id' | 'createdAt' | 'updatedAt'>>({
  title: '',
  description: '',
  reporter: '',
  registrar: '',
  severity: null as unknown as 'critical' | 'high' | 'medium' | 'low',
  status: null as unknown as 'open' | 'investigating' | 'mitigated' | 'resolved' | 'closed',
  topic: '',
  startTimestamp: '',
  reportTimestamp: '',
  resolutionTimestamp: '',
  mitigationSteps: ''
})

const references = ref<Omit<Reference, 'id' | 'issueId'>[]>([])
const impactedSystems = ref<Omit<ImpactedSystem, 'id' | 'issueId'>[]>([])
const involvedTeams = ref<Omit<InvolvedTeam, 'id' | 'issueId'>[]>([])

const addReference = () => {
  references.value.push({ url: '', referenceType: 'jira' })
}

const removeReference = (index: number) => {
  references.value.splice(index, 1)
}

const addSystem = () => {
  impactedSystems.value.push({ systemName: '', impactDescription: '' })
}

const removeSystem = (index: number) => {
  impactedSystems.value.splice(index, 1)
}

const addTeam = () => {
  involvedTeams.value.push({ teamName: '', role: '' })
}

const removeTeam = (index: number) => {
  involvedTeams.value.splice(index, 1)
}

const resetForm = () => {
  form.value?.reset()
  references.value = []
  impactedSystems.value = []
  involvedTeams.value = []
}

const submitIssue = async () => {
  const { valid } = await form.value?.validate()
  
  if (!valid) {
    return
  }

  try {
    const response = await $fetch('/api/issues', {
      method: 'POST',
      body: {
        ...issue.value,
        references: references.value,
        impactedSystems: impactedSystems.value,
        involvedTeams: involvedTeams.value
      }
    })
    
    const showMessage = inject<(text: string, color?: 'success' | 'error') => void>('showMessage')
    showMessage?.('Issue created successfully')
    resetForm()
  } catch (error) {
    console.error('Error creating issue:', error)
    const showMessage = inject<(text: string, color?: 'success' | 'error') => void>('showMessage')
    showMessage?.('Failed to create issue. Please try again.', 'error')
  }
}
</script>
