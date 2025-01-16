<template lang="pug">
v-card(variant="outlined")
  v-card-title
    span Database Schema
    v-spacer
    v-btn(
      icon="mdi-chevron-up"
      variant="text"
      v-if="!collapsed"
      @click="collapsed = true"
    )
    v-btn(
      icon="mdi-chevron-down"
      variant="text"
      v-else
      @click="collapsed = false"
    )
  v-expand-transition
    v-card-text(v-show="!collapsed")
      div(ref="mermaidContainer")
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import mermaid from 'mermaid'

const collapsed = ref(true)
const mermaidContainer = ref<HTMLElement | null>(null)

// Generate ERD diagram using Mermaid syntax
const generateERD = () => {
  const diagram = `
    erDiagram
      issues {
        int id PK
        string title
        string description
        string reporter
        string registrar
        string severity
        string status
        string topic
        datetime start_timestamp
        datetime report_timestamp
        datetime resolution_timestamp
        string mitigation_steps
        datetime created_at
        datetime updated_at
      }
      
      communication_logs {
        int id PK
        int issue_id FK
        string link
        datetime datetime
        string communicator
        string system
        bool is_internal
        string message
      }
      
      issue_references {
        int id PK
        int issue_id FK
        string url
        string reference_type
        string description
      }
      
      impacted_systems {
        int id PK
        int issue_id FK
        string system_name
        string impact_description
      }
      
      involved_teams {
        int id PK
        int issue_id FK
        string team_name
        string role
      }
      
      tags {
        int id PK
        string name
        string definition
        string description
        string color_primary
        string color_secondary
        datetime created_at
        datetime updated_at
      }
      
      issue_tags {
        int issue_id FK
        int tag_id FK
      }
      
      enumerations {
        int id PK
        string category
        string value
        string description
        int sort_order
        bool is_active
        datetime created_at
        datetime updated_at
      }
      
      issues ||--o{ communication_logs : has
      issues ||--o{ issue_references : has
      issues ||--o{ impacted_systems : has
      issues ||--o{ involved_teams : has
      issues ||--o{ issue_tags : has
      tags ||--o{ issue_tags : has
  `

  // Initialize Mermaid with custom theme
  mermaid.initialize({
    theme: 'default',
    themeVariables: {
      primaryColor: '#FFB74D',
      primaryTextColor: '#000',
      primaryBorderColor: '#FF9800',
      lineColor: '#FF9800',
      secondaryColor: '#FFF3E0',
      tertiaryColor: '#FFF3E0'
    }
  })

  if (mermaidContainer.value) {
    mermaidContainer.value.innerHTML = diagram
    mermaid.contentLoaded()
  }
}

onMounted(() => {
  generateERD()
})
</script>

<style scoped>
.v-card-text {
  overflow-x: auto;
}
</style>
