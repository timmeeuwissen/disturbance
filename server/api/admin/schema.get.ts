import { readFileSync } from 'fs'
import { resolve } from 'path'

export default defineEventHandler(async () => {
  const schemaPath = resolve(process.cwd(), 'db/schema.sql')
  const schema = readFileSync(schemaPath, 'utf-8')

  // Parse CREATE TABLE statements
  const tableRegex = /CREATE TABLE IF NOT EXISTS (\w+)\s*\(([\s\S]*?)\);/g
  const tables: { [key: string]: any } = {}
  let match

  while ((match = tableRegex.exec(schema)) !== null) {
    const tableName = match[1]
    const columnsStr = match[2]
    const columns: any[] = []
    const foreignKeys: string[] = []

    // Parse columns
    const columnLines = columnsStr.split('\n')
    for (const line of columnLines) {
      const trimmedLine = line.trim()
      if (!trimmedLine || trimmedLine.startsWith('--') || trimmedLine.startsWith('CHECK')) continue

      // Check for foreign key constraint
      if (trimmedLine.startsWith('FOREIGN KEY')) {
        const fkMatch = trimmedLine.match(/FOREIGN KEY\s*\((\w+)\)\s*REFERENCES\s*(\w+)/)
        if (fkMatch) {
          foreignKeys.push(`${tableName} }|--|| ${fkMatch[2]} : has`)
        }
        continue
      }

      // Skip other constraints
      if (trimmedLine.startsWith('PRIMARY') || trimmedLine.startsWith('UNIQUE')) continue

      // Parse column definition
      const columnMatch = trimmedLine.match(/^(\w+)\s+(\w+)/)
      if (!columnMatch) continue

      const [, name, type] = columnMatch
      let constraints = ''

      // Check for constraints in the column definition
      if (trimmedLine.includes('PRIMARY KEY')) {
        constraints = 'PK'
      } else if (trimmedLine.includes('UNIQUE')) {
        constraints = 'UK'
      } else if (trimmedLine.includes('REFERENCES')) {
        const refMatch = trimmedLine.match(/REFERENCES\s+(\w+)/)
        if (refMatch) {
          constraints = `FK "${refMatch[1]}"`
        }
      }

      // Convert SQL types to Mermaid types
      let mermaidType = type.toLowerCase()
      if (type === 'INTEGER') mermaidType = 'int'
      else if (type === 'TEXT') mermaidType = 'string'
      else if (type === 'DATETIME') mermaidType = 'datetime'
      else if (type === 'BOOLEAN') mermaidType = 'bool'

      // Convert snake_case to camelCase for Mermaid compatibility
      const camelName = name.replace(/_([a-z])/g, (g) => g[1].toUpperCase())
      columns.push({ name: camelName, type: mermaidType, constraints })
    }

    tables[tableName] = { columns, foreignKeys }
  }

  // Generate Mermaid ERD diagram
  let mermaidCode = 'erDiagram\n'

  // Add relationships
  const relationships = new Set<string>()
  Object.values(tables).forEach(table => {
    table.foreignKeys.forEach((fk: string) => {
      relationships.add(fk)
    })
  })
  relationships.forEach(rel => {
    mermaidCode += `    ${rel}\n`
  })
  mermaidCode += '\n'

  // Add entities with attributes
  Object.entries(tables).forEach(([tableName, table]) => {
    mermaidCode += `    ${tableName} {\n`
    table.columns.forEach((col: any) => {
      const constraint = col.constraints ? ` "${col.constraints}"` : ''
      mermaidCode += `        ${col.type} ${col.name}${constraint}\n`
    })
    mermaidCode += '    }\n\n'
  })

  return { mermaidCode }
})
