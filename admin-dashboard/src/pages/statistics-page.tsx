import { useMemo, useState } from 'react'
import { DailySummaryChart } from '@/components/daily-summary-chart'
import { StatViewPanel } from '@/components/stat-view-panel'
import { Skeleton } from '@/components/ui/skeleton'
import {
  Card,
  CardContent,
  CardHeader,
  CardTitle,
} from '@/components/ui/card'
import {
  useDailySummary,
  useStatisticsCatalog,
} from '@/hooks/use-admin-queries'
import { cn } from '@/lib/utils'
import {
  STAT_CATEGORIES,
  STAT_VIEWS,
  STAT_VIEWS_BY_KEY,
} from '@/lib/stat-views'
import { useI18n } from '@/contexts/i18n'

export function StatisticsPage() {
  const { locale, t } = useI18n()
  const dailySummary = useDailySummary()
  const catalog = useStatisticsCatalog()

  // The static config is the source of truth for how each view renders; the
  // catalog (when loaded) narrows it to what the backend actually exposes.
  const views = useMemo(() => {
    const available = catalog.data?.views
    if (!available || available.length === 0) return STAT_VIEWS
    const allowed = new Set(available)
    const filtered = STAT_VIEWS.filter((v) => allowed.has(v.key))
    return filtered.length > 0 ? filtered : STAT_VIEWS
  }, [catalog.data])

  const [selectedKey, setSelectedKey] = useState<string>(STAT_VIEWS[0].key)
  // Guard against a selection that isn't in the available set.
  const activeKey = views.some((v) => v.key === selectedKey)
    ? selectedKey
    : views[0]?.key
  const activeConfig = activeKey ? STAT_VIEWS_BY_KEY[activeKey] : undefined

  // The API returns rows newest-first; a time series needs oldest-first.
  const dailyChart = useMemo(() => {
    const rows = dailySummary.data ?? []
    return [...rows]
      .sort((a, b) => a.summary_date.localeCompare(b.summary_date))
      .map((r) => ({
        date: r.summary_date,
        rides: Number(r.total_rides_created) || 0,
        reservations: Number(r.total_reservations_made) || 0,
      }))
  }, [dailySummary.data])

  return (
    <div className="space-y-6">
      <div>
        <h2 className="text-2xl font-semibold tracking-tight">
          {t('statistics.title')}
        </h2>
        <p className="text-muted-foreground mt-1 text-sm max-w-2xl">
          {t('statistics.description')}
        </p>
      </div>

      {dailySummary.isLoading ? (
        <Skeleton className="h-80 rounded-xl" />
      ) : (
        <DailySummaryChart
          data={dailyChart}
          title={t('statistics.daily.title')}
          description={t('statistics.daily.description')}
        />
      )}

      <div>
        <h3 className="text-lg font-semibold tracking-tight">
          {t('statistics.views.title')}
        </h3>
        <p className="text-muted-foreground mt-1 text-sm max-w-2xl">
          {t('statistics.views.description')}
        </p>
      </div>

      <div className="grid gap-4 lg:grid-cols-[16rem_1fr] lg:items-start">
        {/* Views menu, grouped by category */}
        <Card className="lg:sticky lg:top-4">
          <CardHeader className="pb-2">
            <CardTitle className="text-sm text-muted-foreground font-medium">
              {t('statistics.views.menuTitle')}
            </CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            {STAT_CATEGORIES.map((category) => {
              const items = views.filter((v) => v.category === category.key)
              if (items.length === 0) return null
              return (
                <div key={category.key} className="space-y-1">
                  <p className="text-muted-foreground px-2 text-[0.7rem] font-semibold uppercase tracking-wider">
                    {category.label[locale]}
                  </p>
                  <div className="space-y-0.5">
                    {items.map((view) => {
                      const Icon = view.icon
                      const isActive = view.key === activeKey
                      return (
                        <button
                          key={view.key}
                          type="button"
                          onClick={() => setSelectedKey(view.key)}
                          aria-pressed={isActive}
                          className={cn(
                            'flex w-full items-center gap-2.5 rounded-lg px-2.5 py-2 text-start text-sm transition-colors',
                            'focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring',
                            isActive
                              ? 'bg-primary text-primary-foreground font-medium shadow-sm'
                              : 'text-foreground/80 hover:bg-accent hover:text-accent-foreground',
                          )}
                        >
                          <Icon
                            className={cn(
                              'size-4 shrink-0',
                              isActive
                                ? 'text-primary-foreground'
                                : 'text-muted-foreground',
                            )}
                          />
                          <span className="truncate">{view.label[locale]}</span>
                        </button>
                      )
                    })}
                  </div>
                </div>
              )
            })}
          </CardContent>
        </Card>

        {/* Selected view */}
        <Card className="min-w-0">
          <CardContent className="pt-6">
            {activeConfig ? (
              <StatViewPanel key={activeConfig.key} config={activeConfig} />
            ) : null}
          </CardContent>
        </Card>
      </div>
    </div>
  )
}
