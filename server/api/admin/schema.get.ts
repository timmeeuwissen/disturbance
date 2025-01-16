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
      if (!trimmedLine || trimmedLine.startsWith('--')) continue

      // Check for foreign key constraint
      if (trimmedLine.includes('FOREIGN KEY')) {
        const fkMatch = trimmedLine.match(/FOREIGN KEY\s*\((\w+)\)\s*REFERENCES\s*(\w+)/)
        if (fkMatch) {
          foreignKeys.push(`${tableName} ||--o{ ${fkMatch[2]} : references`)
        }
        continue
      }

      // Parse regular column
      const parts = trimmedLine.split(/\s+/)
      if (parts[0] === 'PRIMARY' || parts[0] === 'FOREIGN' || parts[0] === 'UNIQUE') continue

      const name = parts[0]
      let type = parts[1]
      let constraints = ''

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

      if (type === 'INTEGER') type = 'integer'
      else if (type === 'TEXT') type = 'string'
      else if (type === 'DATETIME') type = 'datetime'
      else if (type === 'BOOLEAN') type = 'boolean'

      columns.push({ name, type, constraints })
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
      const constraint = col.constraints ? ` ${col.constraints}` : ''
      mermaidCode += `        ${col.type} ${col.name}${constraint}\n`
    })
    mermaidCode += '    }\n\n'
  })

  return { mermaidCode }
})
