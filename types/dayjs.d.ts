declare module 'dayjs' {
  interface Dayjs {
    format(template?: string): string
    startOf(unit: 'day' | 'week' | 'month' | 'quarter' | 'year'): Dayjs
    isAfter(date: Dayjs): boolean
    from(date: Dayjs, withoutSuffix?: boolean): string
    diff(date: Dayjs, unit?: 'minute' | 'hour' | 'day' | 'week' | 'month' | 'year'): number
    subtract(amount: number, unit: 'day' | 'week' | 'month' | 'year'): Dayjs
  }

  interface DayjsStatic {
    (date?: string | number | Date | Dayjs): Dayjs
    extend(plugin: any): void
  }

  const dayjs: DayjsStatic
  export = dayjs
}

declare module 'dayjs/plugin/relativeTime' {
  const plugin: any
  export = plugin
}
