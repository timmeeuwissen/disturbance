export interface Issue {
  id: number
  title: string
  description: string | null
  reporter: string
  registrar: string
  severity: string
  status: string
  topic: string | null
  startTimestamp: string | null
  reportTimestamp: string
  resolutionTimestamp: string | null
  mitigationSteps: string | null
  createdAt: string
  updatedAt: string
  references?: Reference[]
  impactedSystems?: ImpactedSystem[]
  involvedTeams?: InvolvedTeam[]
}

export interface Reference {
  id: number
  issueId: number
  url: string
  referenceType: string
  description: string | null
}

export interface ImpactedSystem {
  id: number
  issueId: number
  systemName: string
  impactDescription: string | null
}

export interface InvolvedTeam {
  id: number
  issueId: number
  teamName: string
  role: string | null
}

export interface IssueFilters {
  search: string
  status: string[]
  severity: string[]
  topic: string[]
  startDate?: string
  endDate?: string
}

export interface ExportOptions {
  format: 'csv' | 'json'
  template: 'full' | 'summary' | 'metrics'
  filters: IssueFilters
}

export interface ListItem {
  id: number
  name: string
  is_final?: boolean
  is_default?: boolean
}
