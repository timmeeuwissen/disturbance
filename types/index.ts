export interface BaseEntity {
  id: number
  createdAt: string
  updatedAt: string
}

export interface ListItem extends BaseEntity {
  value: string
  description: string | null
  sortOrder: number
  isActive: boolean
}

export type SeverityValue = 'critical' | 'high' | 'medium' | 'low'
export type StatusValue = 'open' | 'investigating' | 'mitigated' | 'resolved' | 'closed'
export type ReferenceTypeValue = 'jira' | 'slack' | 'system' | 'other'

export interface Severity extends Omit<ListItem, 'value'> {
  value: SeverityValue
}

export interface Status extends Omit<ListItem, 'value'> {
  value: StatusValue
}

export interface ReferenceType extends Omit<ListItem, 'value'> {
  value: ReferenceTypeValue
}

export interface Enumeration extends ListItem {}

export interface Tag extends BaseEntity {
  name: string
  definition: string
  description: string | null
  colorPrimary: string
  colorSecondary: string
}

export interface Issue extends BaseEntity {
  title: string
  description: string | null
  reporter: string
  registrar: string
  severityId: number
  statusId: number
  severity?: Severity
  status?: Status
  topic: string
  startTimestamp: string | null
  reportTimestamp: string | null
  resolutionTimestamp: string | null
  mitigationSteps: string | null
  impactedSystems?: ImpactedSystem[]
  involvedTeams?: InvolvedTeam[]
  references?: Reference[]
}

export interface CommunicationLog extends BaseEntity {
  issueId: number
  link: string | null
  datetime: string
  communicator: string
  system: string | null
  isInternal: boolean
  message: string
}

export interface Reference extends BaseEntity {
  issueId: number
  url: string
  referenceTypeId: number
  referenceType?: ReferenceType
  description: string | null
}

export interface IssueReference extends Reference {}

export interface ImpactedSystem extends BaseEntity {
  issueId: number
  systemName: string
  impactDescription: string | null
}

export interface InvolvedTeam extends BaseEntity {
  issueId: number
  teamName: string
  role: string | null
}

export interface IssueTag {
  issueId: number
  tagId: number
}

export interface SqlQueryResult {
  columns?: string[]
  rows: any[]
  rowCount: number
}

export interface TimeRange {
  startDate?: string
  endDate?: string
}

export interface IssueFilters extends TimeRange {
  status?: StatusValue[]
  severity?: SeverityValue[]
  topic?: string[]
  search?: string
}

export interface ExportOptions {
  format: 'csv' | 'json'
  template: 'full' | 'summary' | 'metrics'
  filters?: IssueFilters
}

// Helper types for creating/updating entities
export type CreateEntity<T> = Omit<T, keyof BaseEntity>

export interface CreateIssueInput {
  title: string
  description: string | null
  reporter: string
  registrar: string
  severity: SeverityValue
  status: StatusValue
  topic: string
  startTimestamp: string | null
  reportTimestamp: string | null
  resolutionTimestamp: string | null
  mitigationSteps: string | null
}

export interface CreateReferenceInput {
  url: string
  referenceType: ReferenceTypeValue
  description?: string | null
}

export interface CreateImpactedSystemInput {
  systemName: string
  impactDescription: string | null
}

export interface CreateInvolvedTeamInput {
  teamName: string
  role: string | null
}

export interface CreateCommunicationLogInput {
  link: string | null
  datetime: string
  communicator: string
  system: string | null
  isInternal: boolean
  message: string
}

// Helper functions for type checking
export const isSeverity = (value: string): value is SeverityValue => {
  return ['critical', 'high', 'medium', 'low'].includes(value)
}

export const isStatus = (value: string): value is StatusValue => {
  return ['open', 'investigating', 'mitigated', 'resolved', 'closed'].includes(value)
}

export const isReferenceType = (value: string): value is ReferenceTypeValue => {
  return ['jira', 'slack', 'system', 'other'].includes(value)
}

// Helper functions for getting values
export const getSeverityValue = (severity?: Severity): SeverityValue | '' => severity?.value ?? ''
export const getStatusValue = (status?: Status): StatusValue | '' => status?.value ?? ''
export const getReferenceTypeValue = (refType?: ReferenceType): ReferenceTypeValue | '' => refType?.value ?? ''

// Helper functions for converting to strings
export const severityToString = (severity?: Severity | SeverityValue): string => {
  if (!severity) return ''
  return typeof severity === 'string' ? severity : severity.value
}

export const statusToString = (status?: Status | StatusValue): string => {
  if (!status) return ''
  return typeof status === 'string' ? status : status.value
}

export const referenceTypeToString = (refType?: ReferenceType | ReferenceTypeValue): string => {
  if (!refType) return ''
  return typeof refType === 'string' ? refType : refType.value
}
