<template lang="pug">
.card
  .card-header
    h1.text-xl.font-semibold.text-gray-900 New Issue
  
  form.card-body(@submit.prevent="submitIssue")
    // Basic Information
    .form-group
      label.form-label(for="title") Title
      input#title.form-input(
        type="text"
        v-model="issue.title"
        required
        placeholder="Brief description of the issue"
      )

    .grid.grid-cols-1.gap-4.sm:grid-cols-2
      .form-group
        label.form-label(for="reporter") Reporter
        input#reporter.form-input(
          type="text"
          v-model="issue.reporter"
          required
          placeholder="Who reported the issue"
        )
      
      .form-group
        label.form-label(for="registrar") Registrar
        input#registrar.form-input(
          type="text"
          v-model="issue.registrar"
          required
          placeholder="Who is registering the issue"
        )

    .grid.grid-cols-1.gap-4.sm:grid-cols-3
      .form-group
        label.form-label(for="severity") Severity
        select#severity.form-input(v-model="issue.severity" required)
          option(value="") Select severity
          option(value="critical") Critical
          option(value="high") High
          option(value="medium") Medium
          option(value="low") Low

      .form-group
        label.form-label(for="status") Status
        select#status.form-input(v-model="issue.status" required)
          option(value="") Select status
          option(value="open") Open
          option(value="investigating") Investigating
          option(value="mitigated") Mitigated
          option(value="resolved") Resolved
          option(value="closed") Closed

      .form-group
        label.form-label(for="topic") Topic
        input#topic.form-input(
          type="text"
          v-model="issue.topic"
          required
          placeholder="Issue category/topic"
        )

    .grid.grid-cols-1.gap-4.sm:grid-cols-3
      .form-group
        label.form-label(for="startTime") Start Time
        input#startTime.form-input(
          type="datetime-local"
          v-model="issue.startTimestamp"
          required
        )

      .form-group
        label.form-label(for="reportTime") Report Time
        input#reportTime.form-input(
          type="datetime-local"
          v-model="issue.reportTimestamp"
          required
        )

      .form-group
        label.form-label(for="resolutionTime") Resolution Time
        input#resolutionTime.form-input(
          type="datetime-local"
          v-model="issue.resolutionTimestamp"
        )

    .form-group
      label.form-label(for="description") Description
      textarea#description.form-input(
        rows="3"
        v-model="issue.description"
        placeholder="Detailed description of the issue"
      )

    .form-group
      label.form-label(for="mitigation") Mitigation Steps
      textarea#mitigation.form-input(
        rows="3"
        v-model="issue.mitigationSteps"
        placeholder="Steps taken to mitigate the issue"
      )

    // References Section
    .form-group
      label.form-label References (Jira, Slack, etc.)
      .space-y-2
        .flex.items-center.space-x-2(v-for="(ref, index) in references" :key="index")
          input.form-input.flex-1(
            type="url"
            v-model="ref.url"
            placeholder="URL"
          )
          select.form-input.w-32(v-model="ref.referenceType")
            option(value="jira") Jira
            option(value="slack") Slack
            option(value="system") System
            option(value="other") Other
          button.btn-danger(
            type="button"
            @click="removeReference(index)"
          ) Remove
        button.btn-secondary(
          type="button"
          @click="addReference"
        ) Add Reference

    // Impacted Systems Section
    .form-group
      label.form-label Impacted Systems
      .space-y-2
        .flex.items-center.space-x-2(v-for="(system, index) in impactedSystems" :key="index")
          input.form-input.flex-1(
            type="text"
            v-model="system.systemName"
            placeholder="System name"
          )
          input.form-input.flex-1(
            type="text"
            v-model="system.impactDescription"
            placeholder="Impact description"
          )
          button.btn-danger(
            type="button"
            @click="removeSystem(index)"
          ) Remove
        button.btn-secondary(
          type="button"
          @click="addSystem"
        ) Add System

    // Involved Teams Section
    .form-group
      label.form-label Involved Teams
      .space-y-2
        .flex.items-center.space-x-2(v-for="(team, index) in involvedTeams" :key="index")
          input.form-input.flex-1(
            type="text"
            v-model="team.teamName"
            placeholder="Team name"
          )
          input.form-input.flex-1(
            type="text"
            v-model="team.role"
            placeholder="Team's role"
          )
          button.btn-danger(
            type="button"
            @click="removeTeam(index)"
          ) Remove
        button.btn-secondary(
          type="button"
          @click="addTeam"
        ) Add Team

    .flex.justify-end.space-x-3
      button.btn-secondary(
        type="button"
        @click="resetForm"
      ) Reset
      button.btn-primary(
        type="submit"
      ) Create Issue
</template>

<script setup lang="ts">
interface Issue {
  title: string
  description: string
  reporter: string
  registrar: string
  severity: string
  status: string
  topic: string
  startTimestamp: string
  reportTimestamp: string
  resolutionTimestamp: string
  mitigationSteps: string
}

interface Reference {
  url: string
  referenceType: string
}

interface System {
  systemName: string
  impactDescription: string
}

interface Team {
  teamName: string
  role: string
}

const issue = ref<Issue>({
  title: '',
  description: '',
  reporter: '',
  registrar: '',
  severity: '',
  status: '',
  topic: '',
  startTimestamp: '',
  reportTimestamp: '',
  resolutionTimestamp: '',
  mitigationSteps: ''
})

const references = ref<Reference[]>([])
const impactedSystems = ref<System[]>([])
const involvedTeams = ref<Team[]>([])

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
  issue.value = {
    title: '',
    description: '',
    reporter: '',
    registrar: '',
    severity: '',
    status: '',
    topic: '',
    startTimestamp: '',
    reportTimestamp: '',
    resolutionTimestamp: '',
    mitigationSteps: ''
  }
  references.value = []
  impactedSystems.value = []
  involvedTeams.value = []
}

const submitIssue = async () => {
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
    
    // Show success message
    alert('Issue created successfully')
    resetForm()
  } catch (error) {
    console.error('Error creating issue:', error)
    alert('Error creating issue. Please try again.')
  }
}
</script>
