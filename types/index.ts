export interface CommunicationLog {
  id: number
  issueId: number
  link?: string
  datetime: string
  communicator: string
  system?: string
  isInternal: boolean
  message: string
}

export interface Reference {
  id: number
  issueId: number
  url: string
  referenceType: 'jira' | 'slack' | 'system' | 'other'
  description?: string
}

export interface ImpactedSystem {
  id: number
  issueId: number
  systemName: string
  impactDescription?: string
}

export interface InvolvedTeam {
  id: number
  issueId: number
  teamName: string
  role?: string
}

export interface IssueFilters {
  search: string
  status: string
  severity: string
  timeRange: 'all' | 'today' | 'week' | 'month' | 'quarter'
}

export interface ExportOptions {
  format: 'csv' | 'json'
  template: 'full' | 'summary' | 'metrics'
  filters: IssueFilters
}

export interface Tag {
  id: number
  name: string
  definition: string
  description?: string
  colorPrimary: string
  colorSecondary: string
  createdAt: string
  updatedAt: string
}

export interface Enumeration {
  id: number
  category: string
  value: string
  description?: string
  sortOrder: number
  isActive: boolean
  createdAt: string
  updatedAt: string
}

export interface AdminState {
  isAdmin: boolean
}

export interface SqlQueryResult {
  columns: string[]
  rows: any[]
  rowCount: number
  error?: string
}

// Update Issue interface to include tags
export interface Issue {
  id: number
  title: string
  description?: string
  reporter: string
  registrar: string
  severity: 'critical' | 'high' | 'medium' | 'low'
  status: 'open' | 'investigating' | 'mitigated' | 'resolved' | 'closed'
  topic: string
  startTimestamp?: string
  reportTimestamp?: string
  resolutionTimestamp?: string
  mitigationSteps?: string
  createdAt: string
  updatedAt: string
  references?: Reference[]
  impactedSystems?: ImpactedSystem[]
  involvedTeams?: InvolvedTeam[]
  communicationLogs?: CommunicationLog[]
  tags?: Tag[]
}
