<template lang="pug">
div
  div(ref="editorContainer" style="height: 300px; border: 1px solid #ccc")
  v-btn.mt-4(
    color="warning"
    prepend-icon="mdi-play"
    @click="executeQuery"
    :loading="loading"
  ) Execute Query
</template>

<script setup lang="ts">
import { ref, onMounted, onBeforeUnmount } from 'vue'
import loader from '@monaco-editor/loader'
import type { SqlQueryResult } from '~/types'

const editorContainer = ref<HTMLElement | null>(null)
const loading = ref(false)
const editor = ref<any>(null)

const emit = defineEmits<{
  (e: 'query-results', result: SqlQueryResult): void
}>()

// Initialize Monaco editor
onMounted(async () => {
  if (!editorContainer.value) return

  const monaco = await loader.init()
  
  editor.value = monaco.editor.create(editorContainer.value, {
    value: '-- Write your SQL query here\nSELECT * FROM issues LIMIT 10;',
    language: 'sql',
    theme: 'vs',
    minimap: { enabled: false },
    automaticLayout: true,
    quickSuggestions: {
      other: true,
      comments: true,
      strings: true
    },
    suggest: {
      showWords: true,
      showSnippets: true
    }
  })

  // Add SQL keywords for autocomplete
  monaco.languages.registerCompletionItemProvider('sql', {
    provideCompletionItems: (model, position) => {
      const word = model.getWordUntilPosition(position);
      const range = {
        startLineNumber: position.lineNumber,
        endLineNumber: position.lineNumber,
        startColumn: word.startColumn,
        endColumn: word.endColumn
      };

      return {
        suggestions: [
          ...['SELECT', 'FROM', 'WHERE', 'GROUP BY', 'ORDER BY', 'LIMIT', 'JOIN', 'LEFT JOIN', 'INNER JOIN'].map(keyword => ({
            label: keyword,
            kind: monaco.languages.CompletionItemKind.Keyword,
            insertText: keyword,
            range
          })),
          ...['issues', 'communication_logs', 'issue_references', 'impacted_systems', 'involved_teams', 'tags', 'issue_tags', 'enumerations'].map(table => ({
            label: table,
            kind: monaco.languages.CompletionItemKind.Class,
            insertText: table,
            range
          }))
        ]
      };
    }
  });
})

// Clean up editor on component unmount
onBeforeUnmount(() => {
  if (editor.value) {
    editor.value.dispose()
  }
})

const executeQuery = async () => {
  if (!editor.value) return
  
  loading.value = true
  try {
    const query = editor.value.getValue()
    const response = await $fetch<SqlQueryResult>('/api/admin/sql', {
      method: 'POST',
      body: { query }
    })
    
    emit('query-results', response)
  } catch (error: any) {
    const showMessage = inject<(text: string, color?: 'success' | 'error') => void>('showMessage')
    showMessage?.(error.message || 'Error executing query', 'error')
  } finally {
    loading.value = false
  }
}

// Expose method for parent component
defineExpose({
  executeQuery
})
</script>

<style scoped>
:deep(.monaco-editor) {
  border-radius: 4px;
}
</style>
