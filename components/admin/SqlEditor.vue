<template lang="pug">
div
  div(ref="editorContainer" style="height: 300px; border: 1px solid #ccc")
    .editor-loading(v-if="!editorLoaded")
      v-progress-circular(indeterminate color="warning")
      span.ml-2 Loading editor...
  v-btn.mt-4(
    color="warning"
    prepend-icon="mdi-play"
    @click="executeQuery"
    :loading="loading"
    :disabled="!editorLoaded"
  ) Execute Query
</template>

<script setup lang="ts">
import { ref, onMounted, onBeforeUnmount } from 'vue'
import loader from '@monaco-editor/loader'
import type { SqlQueryResult } from '~/types'

const editorContainer = ref<HTMLElement | null>(null)
const loading = ref(false)
const editorLoaded = ref(false)
const editor = ref<any>(null)
let monacoInstance: any = null

const emit = defineEmits<{
  (e: 'query-results', result: SqlQueryResult): void
}>()

// Initialize Monaco editor
onMounted(async () => {
  if (!editorContainer.value) return

  try {
    // Configure Monaco loader
    loader.config({
      paths: {
        vs: 'https://cdnjs.cloudflare.com/ajax/libs/monaco-editor/0.44.0/min/vs'
      }
    })

    // Load Monaco
    monacoInstance = await loader.init()
    
    // Create editor instance
    editor.value = monacoInstance.editor.create(editorContainer.value, {
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
      },
      fontSize: 14,
      lineNumbers: 'on',
      scrollBeyondLastLine: false,
      wordWrap: 'on'
    })

    // Add SQL keywords for autocomplete
    monacoInstance.languages.registerCompletionItemProvider('sql', {
      provideCompletionItems: (model: any, position: any) => {
        const word = model.getWordUntilPosition(position);
        const range = {
          startLineNumber: position.lineNumber,
          endLineNumber: position.lineNumber,
          startColumn: word.startColumn,
          endColumn: word.endColumn
        };

        const keywords = [
          'SELECT', 'FROM', 'WHERE', 'GROUP BY', 'ORDER BY', 'LIMIT',
          'JOIN', 'LEFT JOIN', 'INNER JOIN', 'AND', 'OR', 'NOT',
          'INSERT INTO', 'UPDATE', 'DELETE FROM', 'VALUES',
          'COUNT', 'SUM', 'AVG', 'MIN', 'MAX',
          'HAVING', 'DISTINCT', 'AS', 'ON', 'IN', 'LIKE'
        ]

        const tables = [
          'issues', 'communication_logs', 'issue_references',
          'impacted_systems', 'involved_teams', 'tags', 'issue_tags',
          'severities', 'statuses', 'reference_types'
        ]

        return {
          suggestions: [
            ...keywords.map(keyword => ({
              label: keyword,
              kind: monacoInstance.languages.CompletionItemKind.Keyword,
              insertText: keyword,
              range,
              detail: 'SQL Keyword'
            })),
            ...tables.map(table => ({
              label: table,
              kind: monacoInstance.languages.CompletionItemKind.Class,
              insertText: table,
              range,
              detail: 'Table'
            }))
          ]
        };
      }
    });

    editorLoaded.value = true
  } catch (error) {
    console.error('Error initializing Monaco editor:', error)
    const showMessage = inject<(text: string, color?: 'success' | 'error') => void>('showMessage')
    showMessage?.('Error loading SQL editor. Please try refreshing the page.', 'error')
  }
})

// Clean up editor on component unmount
onBeforeUnmount(() => {
  if (editor.value) {
    editor.value.dispose()
    editor.value = null
  }
  if (monacoInstance?.editor) {
    monacoInstance.editor.getModels().forEach((model: any) => model.dispose())
  }
  editorLoaded.value = false
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
.editor-loading {
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #f5f5f5;
  border-radius: 4px;
}

:deep(.monaco-editor) {
  border-radius: 4px;
  padding: 8px 0;
}
</style>
