import Database from 'better-sqlite3'
import { resolve } from 'path'
import type { Issue, Reference, ImpactedSystem, InvolvedTeam } from '~/types'

const db = new Database(resolve(process.cwd(), 'db/disturbance.db'))

// Prepare statements for better performance
const statements = {
  // Issues
  getAllIssues: db.prepare(`
    SELECT * FROM issues ORDER BY created_at DESC
  `),
  
  getIssueById: db.prepare(`
    SELECT * FROM issues WHERE id = ?
  `),
  
  createIssue: db.prepare(`
    INSERT INTO issues (
      title, description, reporter, registrar, severity, status,
      topic, start_timestamp, report_timestamp, resolution_timestamp,
      mitigation_steps
    ) VALUES (
      @title, @description, @reporter, @registrar, @severity, @status,
      @topic, @startTimestamp, @reportTimestamp, @resolutionTimestamp,
      @mitigationSteps
    )
  `),
  
  updateIssue: db.prepare(`
    UPDATE issues SET
      title = @title,
      description = @description,
      reporter = @reporter,
      registrar = @registrar,
      severity = @severity,
      status = @status,
      topic = @topic,
      start_timestamp = @startTimestamp,
      report_timestamp = @reportTimestamp,
      resolution_timestamp = @resolutionTimestamp,
      mitigation_steps = @mitigationSteps,
      updated_at = CURRENT_TIMESTAMP
    WHERE id = @id
  `),
  
  // References
  getIssueReferences: db.prepare(`
    SELECT * FROM issue_references WHERE issue_id = ?
  `),
  
  createReference: db.prepare(`
    INSERT INTO issue_references (
      issue_id, url, reference_type, description
    ) VALUES (
      @issueId, @url, @referenceType, @description
    )
  `),
  
  deleteIssueReferences: db.prepare(`
    DELETE FROM issue_references WHERE issue_id = ?
  `),
  
  // Impacted Systems
  getIssueImpactedSystems: db.prepare(`
    SELECT * FROM impacted_systems WHERE issue_id = ?
  `),
  
  createImpactedSystem: db.prepare(`
    INSERT INTO impacted_systems (
      issue_id, system_name, impact_description
    ) VALUES (
      @issueId, @systemName, @impactDescription
    )
  `),
  
  deleteIssueImpactedSystems: db.prepare(`
    DELETE FROM impacted_systems WHERE issue_id = ?
  `),
  
  // Involved Teams
  getIssueInvolvedTeams: db.prepare(`
    SELECT * FROM involved_teams WHERE issue_id = ?
  `),
  
  createInvolvedTeam: db.prepare(`
    INSERT INTO involved_teams (
      issue_id, team_name, role
    ) VALUES (
      @issueId, @teamName, @role
    )
  `),
  
  deleteIssueInvolvedTeams: db.prepare(`
    DELETE FROM involved_teams WHERE issue_id = ?
  `)
}

export const dbService = {
  // Execute raw SQL query (admin only)
  executeQuery(query: string): any[] {
    return db.prepare(query).all()
  },

  getAllIssues(): Issue[] {
    return statements.getAllIssues.all() as Issue[]
  },
  
  getIssueById(id: number): Issue | undefined {
    const issue = statements.getIssueById.get(id) as Issue | undefined
    if (!issue) return undefined
    
    // Get related data
    const references = statements.getIssueReferences.all(id) as Reference[]
    const impactedSystems = statements.getIssueImpactedSystems.all(id) as ImpactedSystem[]
    const involvedTeams = statements.getIssueInvolvedTeams.all(id) as InvolvedTeam[]
    
    return {
      ...issue,
      references,
      impactedSystems,
      involvedTeams
    }
  },
  
  createIssue(issue: Omit<Issue, 'id' | 'createdAt' | 'updatedAt'>, 
    references: Omit<Reference, 'id' | 'issueId'>[],
    impactedSystems: Omit<ImpactedSystem, 'id' | 'issueId'>[],
    involvedTeams: Omit<InvolvedTeam, 'id' | 'issueId'>[]
  ): Issue {
    const result = db.transaction(() => {
      // Create issue
      const { lastInsertRowid } = statements.createIssue.run(issue)
      const issueId = Number(lastInsertRowid)
      
      // Create references
      for (const ref of references) {
        statements.createReference.run({ ...ref, issueId })
      }
      
      // Create impacted systems
      for (const system of impactedSystems) {
        statements.createImpactedSystem.run({ ...system, issueId })
      }
      
      // Create involved teams
      for (const team of involvedTeams) {
        statements.createInvolvedTeam.run({ ...team, issueId })
      }
      
      return this.getIssueById(issueId)
    })()
    
    return result!
  },
  
  updateIssue(
    id: number,
    issue: Omit<Issue, 'id' | 'createdAt' | 'updatedAt'>,
    references: Omit<Reference, 'id' | 'issueId'>[],
    impactedSystems: Omit<ImpactedSystem, 'id' | 'issueId'>[],
    involvedTeams: Omit<InvolvedTeam, 'id' | 'issueId'>[]
  ): Issue | undefined {
    const result = db.transaction(() => {
      // Update issue
      const { changes } = statements.updateIssue.run({ ...issue, id })
      if (changes === 0) return undefined
      
      // Update references
      statements.deleteIssueReferences.run(id)
      for (const ref of references) {
        statements.createReference.run({ ...ref, issueId: id })
      }
      
      // Update impacted systems
      statements.deleteIssueImpactedSystems.run(id)
      for (const system of impactedSystems) {
        statements.createImpactedSystem.run({ ...system, issueId: id })
      }
      
      // Update involved teams
      statements.deleteIssueInvolvedTeams.run(id)
      for (const team of involvedTeams) {
        statements.createInvolvedTeam.run({ ...team, issueId: id })
      }
      
      return this.getIssueById(id)
    })()
    
    return result
  }
}
