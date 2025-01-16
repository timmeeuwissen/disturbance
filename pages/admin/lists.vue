<script lang="ts">
definePageMeta({
  middleware: ['admin']
})
</script>

<template lang="pug">
v-container(fluid)
  v-row
    v-col(cols="12")
      h1.text-warning.mb-4 Lists Management

  v-row
    v-col(cols="12" md="6")
      v-card
        v-card-title Enumerations
        v-card-text
          v-select(
            v-model="selectedCategory"
            label="Category"
            :items="['severity', 'status', 'reference_type']"
            @update:model-value="loadEnumerations"
          )
          v-data-table(
            v-if="selectedCategory"
            :headers="enumHeaders"
            :items="enumerations"
            :items-per-page="10"
          )
            template(#item.is_active="{ item }")
              v-switch(
                v-model="item.raw.is_active"
                color="warning"
                hide-details
                @change="updateEnumeration(item.raw)"
              )
            template(#item.actions="{ item }")
              v-btn(
                icon="mdi-pencil"
                variant="text"
                size="small"
                color="warning"
                @click="editEnumeration(item.raw)"
              )
          v-btn.mt-4(
            color="warning"
            prepend-icon="mdi-plus"
            @click="showEnumDialog = true"
          ) Add Value

    v-col(cols="12" md="6")
      v-card
        v-card-title Tags
        v-card-text
          v-data-table(
            :headers="tagHeaders"
            :items="tags"
            :items-per-page="10"
          )
            template(#item.colors="{ item }")
              v-chip(
                :color="item.raw.color_primary"
                :text-color="getContrastColor(item.raw.color_primary)"
              ) Primary
              v-chip.ml-2(
                :color="item.raw.color_secondary"
                :text-color="getContrastColor(item.raw.color_secondary)"
              ) Secondary
            template(#item.actions="{ item }")
              v-btn(
                icon="mdi-pencil"
                variant="text"
                size="small"
                color="warning"
                @click="editTag(item.raw)"
              )
          v-btn.mt-4(
            color="warning"
            prepend-icon="mdi-plus"
            @click="showTagDialog = true"
          ) Add Tag

  // Enumeration Dialog
  v-dialog(v-model="showEnumDialog" max-width="500px")
    v-card
      v-card-title {{ editingEnum ? 'Edit' : 'Add' }} Enumeration Value
      v-card-text
        v-form(ref="enumForm")
          v-text-field(
            v-model="enumFormData.value"
            label="Value"
            required
            :rules="[v => !!v || 'Value is required']"
          )
          v-text-field(
            v-model="enumFormData.description"
            label="Description"
          )
          v-text-field(
            v-model.number="enumFormData.sortOrder"
            label="Sort Order"
            type="number"
            required
            :rules="[v => !!v || 'Sort order is required']"
          )
          v-switch(
            v-model="enumFormData.isActive"
            label="Active"
            color="warning"
          )
      v-card-actions
        v-spacer
        v-btn(
          color="secondary"
          variant="text"
          @click="showEnumDialog = false"
        ) Cancel
        v-btn(
          color="warning"
          @click="saveEnumeration"
        ) Save

  // Tag Dialog
  v-dialog(v-model="showTagDialog" max-width="500px")
    v-card
      v-card-title {{ editingTag ? 'Edit' : 'Add' }} Tag
      v-card-text
        v-form(ref="tagForm")
          v-text-field(
            v-model="tagFormData.name"
            label="Name"
            required
            :rules="[v => !!v || 'Name is required']"
          )
          v-text-field(
            v-model="tagFormData.definition"
            label="Definition"
            required
            :rules="[v => !!v || 'Definition is required']"
          )
          v-textarea(
            v-model="tagFormData.description"
            label="Description"
            rows="3"
          )
          v-color-picker(
            v-model="tagFormData.colorPrimary"
            label="Primary Color"
            mode="hex"
            hide-inputs
            show-swatches
            swatches-max-height="200"
          )
          v-color-picker(
            v-model="tagFormData.colorSecondary"
            label="Secondary Color"
            mode="hex"
            hide-inputs
            show-swatches
            swatches-max-height="200"
          )
      v-card-actions
        v-spacer
        v-btn(
          color="secondary"
          variant="text"
          @click="showTagDialog = false"
        ) Cancel
        v-btn(
          color="warning"
          @click="saveTag"
        ) Save
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import type { Enumeration, Tag, SqlQueryResult } from '~/types'

interface FormRef {
  validate: () => Promise<{ valid: boolean }>
}

// State
const selectedCategory = ref('')
const enumerations = ref<Enumeration[]>([])
const tags = ref<Tag[]>([])
const showEnumDialog = ref(false)
const showTagDialog = ref(false)
const editingEnum = ref<Enumeration | null>(null)
const editingTag = ref<Tag | null>(null)
const enumFormData = ref<Partial<Enumeration>>({
  value: '',
  description: '',
  sortOrder: 0,
  isActive: true
})
const tagFormData = ref<Partial<Tag>>({
  name: '',
  definition: '',
  description: '',
  colorPrimary: '#FF9800',
  colorSecondary: '#FFB74D'
})
const enumForm = ref<FormRef | null>(null)
const tagForm = ref<FormRef | null>(null)

// Table headers
const enumHeaders = [
  { title: 'Value', key: 'value' },
  { title: 'Description', key: 'description' },
  { title: 'Sort Order', key: 'sort_order' },
  { title: 'Active', key: 'is_active' },
  { title: 'Actions', key: 'actions', sortable: false }
]

const tagHeaders = [
  { title: 'Name', key: 'name' },
  { title: 'Definition', key: 'definition' },
  { title: 'Colors', key: 'colors', sortable: false },
  { title: 'Actions', key: 'actions', sortable: false }
]

// Methods
const loadEnumerations = async () => {
  if (!selectedCategory.value) return
  try {
    const response = await $fetch<SqlQueryResult>('/api/admin/sql', {
      method: 'POST',
      body: {
        query: `SELECT * FROM enumerations WHERE category = '${selectedCategory.value}' ORDER BY sort_order`
      }
    })
    enumerations.value = response.rows
  } catch (error) {
    console.error('Error loading enumerations:', error)
  }
}

const loadTags = async () => {
  try {
    const response = await $fetch<SqlQueryResult>('/api/admin/sql', {
      method: 'POST',
      body: {
        query: 'SELECT * FROM tags ORDER BY name'
      }
    })
    tags.value = response.rows
  } catch (error) {
    console.error('Error loading tags:', error)
  }
}

const editEnumeration = (enumeration: Enumeration) => {
  editingEnum.value = enumeration
  enumFormData.value = {
    value: enumeration.value,
    description: enumeration.description,
    sortOrder: enumeration.sortOrder,
    isActive: enumeration.isActive
  }
  showEnumDialog.value = true
}

const editTag = (tag: Tag) => {
  editingTag.value = tag
  tagFormData.value = {
    name: tag.name,
    definition: tag.definition,
    description: tag.description,
    colorPrimary: tag.colorPrimary,
    colorSecondary: tag.colorSecondary
  }
  showTagDialog.value = true
}

const saveEnumeration = async () => {
  const result = await enumForm.value?.validate()
  if (!result?.valid) return

  try {
    const query = editingEnum.value
      ? `UPDATE enumerations SET 
          value = '${enumFormData.value.value}',
          description = '${enumFormData.value.description || ''}',
          sort_order = ${enumFormData.value.sortOrder},
          is_active = ${enumFormData.value.isActive ? 1 : 0}
        WHERE id = ${editingEnum.value.id}`
      : `INSERT INTO enumerations (category, value, description, sort_order, is_active)
        VALUES (
          '${selectedCategory.value}',
          '${enumFormData.value.value}',
          '${enumFormData.value.description || ''}',
          ${enumFormData.value.sortOrder},
          ${enumFormData.value.isActive ? 1 : 0}
        )`

    await $fetch('/api/admin/sql', {
      method: 'POST',
      body: { query }
    })

    showEnumDialog.value = false
    loadEnumerations()
  } catch (error) {
    console.error('Error saving enumeration:', error)
  }
}

const saveTag = async () => {
  const result = await tagForm.value?.validate()
  if (!result?.valid) return

  try {
    const query = editingTag.value
      ? `UPDATE tags SET 
          name = '${tagFormData.value.name}',
          definition = '${tagFormData.value.definition}',
          description = '${tagFormData.value.description || ''}',
          color_primary = '${tagFormData.value.colorPrimary}',
          color_secondary = '${tagFormData.value.colorSecondary}'
        WHERE id = ${editingTag.value.id}`
      : `INSERT INTO tags (name, definition, description, color_primary, color_secondary)
        VALUES (
          '${tagFormData.value.name}',
          '${tagFormData.value.definition}',
          '${tagFormData.value.description || ''}',
          '${tagFormData.value.colorPrimary}',
          '${tagFormData.value.colorSecondary}'
        )`

    await $fetch('/api/admin/sql', {
      method: 'POST',
      body: { query }
    })

    showTagDialog.value = false
    loadTags()
  } catch (error) {
    console.error('Error saving tag:', error)
  }
}

const updateEnumeration = async (enumeration: Enumeration) => {
  try {
    await $fetch('/api/admin/sql', {
      method: 'POST',
      body: {
        query: `UPDATE enumerations SET is_active = ${enumeration.isActive ? 1 : 0} WHERE id = ${enumeration.id}`
      }
    })
  } catch (error) {
    console.error('Error updating enumeration:', error)
  }
}

const getContrastColor = (hexColor: string) => {
  // Convert hex to RGB
  const r = parseInt(hexColor.slice(1, 3), 16)
  const g = parseInt(hexColor.slice(3, 5), 16)
  const b = parseInt(hexColor.slice(5, 7), 16)
  
  // Calculate relative luminance
  const luminance = (0.299 * r + 0.587 * g + 0.114 * b) / 255
  
  return luminance > 0.5 ? '#000000' : '#FFFFFF'
}

// Load initial data
onMounted(() => {
  loadTags()
})
</script>
