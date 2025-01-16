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
      .mermaid(ref="mermaidContainer")
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import mermaid from 'mermaid'

const collapsed = ref(true)
const mermaidContainer = ref<HTMLElement | null>(null)

// Generate ERD diagram using Mermaid syntax
const generateERD = async () => {
  const diagram = `erDiagram
    ISSUES ||--o{ COMMUNICATION_LOGS : has
    ISSUES ||--o{ ISSUE_REFERENCES : has
    ISSUES ||--o{ IMPACTED_SYSTEMS : has
    ISSUES ||--o{ INVOLVED_TEAMS : has
    ISSUES ||--o{ ISSUE_TAGS : has
    TAGS ||--o{ ISSUE_TAGS : has

    ISSUES {
        integer id PK
        string title
        string description
        string reporter
        string registrar
        string severity FK "enumerations.value"
        string status FK "enumerations.value"
        string topic
        datetime start_timestamp
        datetime report_timestamp
        datetime resolution_timestamp
        string mitigation_steps
        datetime created_at
        datetime updated_at
    }

    COMMUNICATION_LOGS {
        integer id PK
        integer issue_id FK
        string link
        datetime datetime
        string communicator
        string system
        boolean is_internal
        string message
    }

    ISSUE_REFERENCES {
        integer id PK
        integer issue_id FK
        string url
        string reference_type FK "enumerations.value"
        string description
    }

    IMPACTED_SYSTEMS {
        integer id PK
        integer issue_id FK
        string system_name
        string impact_description
    }

    INVOLVED_TEAMS {
        integer id PK
        integer issue_id FK
        string team_name
        string role
    }

    TAGS {
        integer id PK
        string name UK
        string definition
        string description
        string color_primary
        string color_secondary
        datetime created_at
        datetime updated_at
    }

    ISSUE_TAGS {
        integer issue_id FK
        integer tag_id FK
        primary_key(issue_id, tag_id)
    }

    ENUMERATIONS {
        integer id PK
        string category
        string value
        string description
        integer sort_order
        boolean is_active
        datetime created_at
        datetime updated_at
        unique_key(category, value)
    }`

  // Initialize Mermaid with custom theme
  await mermaid.initialize({
    startOnLoad: false,
    theme: 'default',
    er: {
      useMaxWidth: false,
      diagramPadding: 20,
      entityPadding: 15,
      fontSize: 12
    },
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
    const { svg } = await mermaid.render('erd-diagram', diagram)
    mermaidContainer.value.innerHTML = svg
  }
}

onMounted(async () => {
  await generateERD()
})
</script>

<style scoped>
.v-card-text {
  overflow-x: auto;
}

.mermaid {
  background-color: white;
  padding: 1rem;
  border-radius: 4px;
}

:deep(#erd-diagram) {
  width: 100%;
  height: auto;
}
</style>
