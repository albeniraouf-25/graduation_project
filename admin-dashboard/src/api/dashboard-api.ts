import { apiFetch } from '@/api/http'
import type {
  ApiDailySummaryRow,
  ApiStatisticsCatalog,
  ApiStatisticsView,
  ApiDepositRequestDetail,
  ApiDepositRequestRow,
  ApiPaginatedResponse,
  ApiReportRow,
  ApiReservationRow,
  ApiRideDetail,
  ApiRideRow,
  ApiUserDetail,
  ApiUserRow,
} from '@/api/types-api'

function buildQuery(path: string, params: Record<string, string | number | null>) {
  if (path.startsWith('http://') || path.startsWith('https://')) {
    const url = new URL(path)
    Object.entries(params).forEach(([key, value]) => {
      if (value == null) url.searchParams.delete(key)
      else url.searchParams.set(key, String(value))
    })
    return url.toString()
  }

  const url = new URL(path, 'http://dummy')
  Object.entries(params).forEach(([key, value]) => {
    if (value == null) url.searchParams.delete(key)
    else url.searchParams.set(key, String(value))
  })
  return `${url.pathname}${url.search}`
}

function normalizePaginatedResponse<T>(data: unknown): ApiPaginatedResponse<T> {
  if (Array.isArray(data)) {
    return { next: null, previous: null, results: data }
  }
  if (data && typeof data === 'object') {
    const page = data as ApiPaginatedResponse<T>
    if (Array.isArray(page.results)) {
      return {
        next: page.next ?? null,
        previous: page.previous ?? null,
        results: page.results,
        count: page.count,
      }
    }
  }
  throw new Error('Unexpected paginated response from API')
}

function canonicalizePageUrl(urlString: string) {
  try {
    const url = urlString.startsWith('http://') || urlString.startsWith('https://')
      ? new URL(urlString)
      : new URL(urlString, 'http://dummy')
    const sortedParams = [...url.searchParams.entries()].sort(([a], [b]) =>
      a.localeCompare(b),
    )
    url.search = ''
    sortedParams.forEach(([key, value]) => url.searchParams.append(key, value))
    return `${url.pathname}${url.search}`
  } catch {
    return urlString
  }
}

/**
 * The dashboard API paginates with LimitOffsetPagination (params `limit` +
 * `offset`, `max_limit=50`), returning `count`/`total_pages`/`next`/`previous`.
 */
const MAX_LIMIT = 50

async function fetchPaginated<T>(path: string, offset = 0, limit = 10) {
  const queryPath = buildQuery(path, { limit, offset })
  const response = await apiFetch<unknown>(queryPath)
  return normalizePaginatedResponse<T>(response)
}

function fetchPage<T>(path: string, offset = 0, limit = 10) {
  return fetchPaginated<T>(path, offset, limit)
}

/** Walk every page (using the max page size to minimise round-trips). */
async function fetchAllPages<T>(path: string) {
  const data: T[] = []
  const seen = new Set<string>()
  const maxPages = 100
  let pageCount = 0

  let page = await fetchPaginated<T>(path, 0, MAX_LIMIT)
  data.push(...page.results)

  while (page.next && pageCount < maxPages) {
    pageCount += 1
    const normalizedNext = canonicalizePageUrl(page.next)
    if (seen.has(normalizedNext)) {
      break
    }
    seen.add(normalizedNext)
    const nextPage = normalizePaginatedResponse<T>(
      await apiFetch<unknown>(page.next),
    )
    if (nextPage.results.length === 0 || nextPage.next === page.next) {
      break
    }
    page = nextPage
    data.push(...page.results)
  }

  return data
}

export function fetchDashboardUsersPage(offset = 0, limit = 10) {
  return fetchPage<ApiUserRow>('/api/dashboard/view_users/', offset, limit)
}

export function fetchDashboardRidesPage(offset = 0, limit = 10) {
  return fetchPage<ApiRideRow>('/api/dashboard/view_rides/', offset, limit)
}

export function fetchDashboardReservationsPage(offset = 0, limit = 10) {
  return fetchPage<ApiReservationRow>(
    '/api/dashboard/view_reservations/',
    offset,
    limit,
  )
}

export async function fetchDashboardUsers() {
  return fetchAllPages<ApiUserRow>('/api/dashboard/view_users/')
}

export async function fetchDashboardRides() {
  return fetchAllPages<ApiRideRow>('/api/dashboard/view_rides/')
}

export async function fetchDashboardReservations() {
  return fetchAllPages<ApiReservationRow>('/api/dashboard/view_reservations/')
}

export function fetchDashboardReportsPage(offset = 0, limit = 10) {
  return fetchPage<ApiReportRow>('/api/dashboard/view_reports/', offset, limit)
}

export async function fetchDashboardReports() {
  return fetchAllPages<ApiReportRow>('/api/dashboard/view_reports/')
}

export function fetchDashboardReportDetail(reportId: string) {
  return apiFetch<ApiReportRow>(`/api/dashboard/view_report_details/${reportId}/`)
}

export function sendReportNote(reportId: number, note: string) {
  return apiFetch<ApiReportRow>(`/api/dashboard/send_note/${reportId}/`, {
    method: 'PATCH',
    body: JSON.stringify({ admin_note: note }),
  })
}

export function fetchDashboardDepositRequestsPage(offset = 0, limit = 10) {
  return fetchPage<ApiDepositRequestRow>(
    '/api/dashboard/view_deposit_requests/',
    offset,
    limit,
  )
}

export async function fetchDashboardDepositRequests() {
  return fetchAllPages<ApiDepositRequestRow>('/api/dashboard/view_deposit_requests/')
}

export function fetchDashboardDepositRequestDetail(depositRequestId: string) {
  return apiFetch<ApiDepositRequestDetail>(
    `/api/dashboard/view_deposit_requests/${depositRequestId}/`,
  )
}

export function acceptDepositRequest(depositRequestId: number) {
  return apiFetch<{ message?: string }>(
    `/api/dashboard/accept/${depositRequestId}/`,
    {
      method: 'POST',
      body: JSON.stringify({}),
    },
  )
}

export function rejectDepositRequest(depositRequestId: number) {
  return apiFetch<{ message?: string }>(
    `/api/dashboard/reject/${depositRequestId}/`,
    {
      method: 'POST',
      body: JSON.stringify({}),
    },
  )
}

/** Catalog of available analytics views (no `view` param returns the menu). */
export function fetchStatisticsCatalog() {
  return apiFetch<ApiStatisticsCatalog>('/api/dashboard/statistics/')
}

/** Data for a single analytics view — the endpoint returns only this one view. */
export function fetchStatisticsView(view: string) {
  return apiFetch<ApiStatisticsView>(
    `/api/dashboard/statistics/?view=${encodeURIComponent(view)}`,
  )
}

/** Per-day platform totals, newest first (as returned by the API). */
export function fetchDailySummary() {
  return apiFetch<ApiDailySummaryRow[]>('/api/dashboard/daily_summary/')
}

export function fetchDashboardRideDetail(rideId: string) {
  return apiFetch<ApiRideDetail>(`/api/dashboard/view_ride_details/${rideId}/`)
}

export function fetchDashboardUserDetail(userId: string) {
  return apiFetch<ApiUserDetail>(`/api/dashboard/view_user_details/${userId}/`)
}

export function banUser(userId: number) {
  return apiFetch<{ message?: string }>(`/api/dashboard/ban/${userId}/`, {
    method: 'POST',
    body: JSON.stringify({}),
  })
}

export function unbanUser(userId: number) {
  return apiFetch<{ message?: string }>(`/api/dashboard/unban/${userId}/`, {
    method: 'POST',
    body: JSON.stringify({}),
  })
}
