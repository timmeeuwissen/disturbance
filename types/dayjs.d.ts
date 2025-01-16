import { Dayjs } from 'dayjs'

declare module 'dayjs' {
  interface Dayjs {
    toISOString(): string
    startOf(unit: dayjs.UnitType): Dayjs
    endOf(unit: dayjs.UnitType): Dayjs
    isAfter(date: string | Dayjs): boolean
    isBefore(date: string | Dayjs): boolean
    from(date: Dayjs, withoutSuffix?: boolean): string
    format(template?: string): string
  }
}
