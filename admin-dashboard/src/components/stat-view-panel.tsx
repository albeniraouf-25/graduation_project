import { useMemo } from 'react'
import { DashboardOverviewChart } from '@/components/dashboard-overview-chart'
import { ListEmptyState } from '@/components/empty-state'
import { Skeleton } from '@/components/ui/skeleton'
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table'
import { Database } from 'lucide-react'
import { useStatisticsView } from '@/hooks/use-admin-queries'
import { formatDate, formatNumber } from '@/lib/format'
import { useI18n } from '@/contexts/i18n'
import type { StatViewConfig } from '@/lib/stat-views'

/** Top-N rows to plot / list, keeping dense views readable. */
const TOP_N = 12
const MAX_TABLE_ROWS = 50

type CellValue = string | number | boolean | null

/** Turn a raw DB column name into a human header, e.g. `total_rides` → "Total rides". */
function humanizeColumn(column: string): string {
  const cleaned = column.replace(/_/g, ' ').trim()
  return cleaned.charAt(0).toUpperCase() + cleaned.slice(1)
}

function looksLikeDate(column: string): boolean {
  return /(_at|_date|date|last_login|earliest|latest|updated|recorded)/.test(
    column,
  )
}

function asNumber(value: CellValue): number | null {
  if (typeof value === 'number') return value
  if (typeof value === 'string' && value.trim() !== '' && !isNaN(Number(value))) {
    return Number(value)
  }
  return null
}

/** Best-effort formatting for a generic cell, driven by column-name hints. */
function formatCell(column: string, value: CellValue, locale: string): string {
  if (value === null || value === undefined || value === '') return '—'
  if (typeof value === 'boolean') return value ? '✓' : '—'

  if (looksLikeDate(column) && typeof value === 'string') {
    return formatDate(value, locale)
  }

  const num = asNumber(value)
  if (num !== null) {
    // IDs read better without thousands separators.
    if (column === 'id' || /_id$/.test(column)) return String(num)
    if (/percent|percentage|rate/.test(column)) return `${formatNumber(num)}%`
    return formatNumber(num)
  }

  return String(value)
}

/** Numeric columns are right-aligned with tabular figures for tidy columns. */
function isNumericColumn(rows: Array<Record<string, CellValue>>, column: string) {
  if (looksLikeDate(column)) return false
  for (const row of rows) {
    const v = row[column]
    if (v === null || v === undefined || v === '') continue
    return asNumber(v) !== null
  }
  return false
}

export function StatViewPanel({ config }: { config: StatViewConfig }) {
  const { locale, t } = useI18n()
  const query = useStatisticsView(config.key)

  const rows = useMemo(
    () => (query.data?.rows ?? []) as Array<Record<string, CellValue>>,
    [query.data],
  )
  const columns = query.data?.columns ?? []

  const barData = useMemo(() => {
    if (config.kind !== 'bar' || !config.bar) return []
    const { labelKey, valueKey } = config.bar
    return [...rows]
      .map((r) => ({
        name: String(r[labelKey] ?? '—') || '—',
        value: asNumber(r[valueKey]) ?? 0,
      }))
      .sort((a, b) => b.value - a.value)
      .slice(0, TOP_N)
  }, [rows, config])

  if (query.isLoading) {
    return (
      <div className="space-y-4">
        <Skeleton className="h-8 w-56 rounded-md" />
        <Skeleton className="h-64 rounded-xl" />
      </div>
    )
  }

  if (query.isError) {
    return (
      <div className="rounded-xl border border-destructive/30 bg-destructive/5 p-6 text-sm text-destructive">
        {t('statistics.views.error')}
      </div>
    )
  }

  const header = (
    <div className="flex items-start justify-between gap-4">
      <div>
        <h3 className="text-lg font-semibold tracking-tight">
          {config.label[locale]}
        </h3>
        <p className="text-muted-foreground mt-0.5 text-sm max-w-xl">
          {config.description[locale]}
        </p>
      </div>
      <span className="shrink-0 rounded-full bg-secondary px-3 py-1 text-xs font-medium text-secondary-foreground tabular-nums">
        {t('statistics.views.rowCount', { count: formatNumber(rows.length) })}
      </span>
    </div>
  )

  if (rows.length === 0) {
    return (
      <div className="space-y-4">
        {header}
        <ListEmptyState
          icon={Database}
          title={t('statistics.views.emptyTitle')}
          description={t('statistics.views.emptyDescription')}
        />
      </div>
    )
  }

  // KPI: render the single summary row as a grid of headline stat cards.
  if (config.kind === 'kpi') {
    const row = rows[0]
    return (
      <div className="space-y-4">
        {header}
        <div className="grid gap-3 sm:grid-cols-2 xl:grid-cols-3">
          {columns.map((col) => (
            <div
              key={col}
              className="rounded-xl border bg-card p-5 shadow-sm transition-shadow hover:shadow-md"
            >
              <p className="text-muted-foreground text-xs font-medium uppercase tracking-wide">
                {humanizeColumn(col)}
              </p>
              <p className="text-primary mt-2 text-3xl font-semibold tabular-nums">
                {formatCell(col, row[col], locale)}
              </p>
            </div>
          ))}
        </div>
      </div>
    )
  }

  // Bar: a labelled category count, plus a compact ranked table underneath.
  if (config.kind === 'bar' && config.bar) {
    const { labelKey, valueKey } = config.bar
    return (
      <div className="space-y-4">
        {header}
        <DashboardOverviewChart
          data={barData}
          title={config.label[locale]}
          description={config.description[locale]}
        />
        <div className="overflow-x-auto rounded-xl border">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>{humanizeColumn(labelKey)}</TableHead>
                <TableHead className="text-end">
                  {humanizeColumn(valueKey)}
                </TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {barData.map((r) => (
                <TableRow key={r.name}>
                  <TableCell className="font-medium">{r.name}</TableCell>
                  <TableCell className="text-end tabular-nums">
                    {formatNumber(r.value)}
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </div>
      </div>
    )
  }

  // Table: generic rows rendered straight from columns/rows.
  const numericByColumn = new Map(
    columns.map((c) => [c, isNumericColumn(rows, c)]),
  )
  const visibleRows = rows.slice(0, MAX_TABLE_ROWS)

  return (
    <div className="space-y-4">
      {header}
      <div className="overflow-x-auto rounded-xl border">
        <Table>
          <TableHeader>
            <TableRow>
              {columns.map((col) => (
                <TableHead
                  key={col}
                  className={numericByColumn.get(col) ? 'text-end' : undefined}
                >
                  {humanizeColumn(col)}
                </TableHead>
              ))}
            </TableRow>
          </TableHeader>
          <TableBody>
            {visibleRows.map((row, i) => (
              <TableRow key={i}>
                {columns.map((col) => (
                  <TableCell
                    key={col}
                    className={
                      numericByColumn.get(col)
                        ? 'text-end tabular-nums'
                        : undefined
                    }
                  >
                    {formatCell(col, row[col], locale)}
                  </TableCell>
                ))}
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </div>
      {rows.length > MAX_TABLE_ROWS ? (
        <p className="text-muted-foreground text-xs">
          {t('statistics.views.truncated', {
            shown: formatNumber(MAX_TABLE_ROWS),
            total: formatNumber(rows.length),
          })}
        </p>
      ) : null}
    </div>
  )
}
