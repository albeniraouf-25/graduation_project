import {
  keepPreviousData,
  useMutation,
  useQuery,
  useQueryClient,
} from '@tanstack/react-query'
import {
  acceptDepositRequest,
  banUser,
  fetchDailySummary,
  fetchDashboardDepositRequestDetail,
  fetchDashboardDepositRequests,
  fetchDashboardDepositRequestsPage,
  fetchDashboardReportDetail,
  fetchDashboardReports,
  fetchDashboardReportsPage,
  fetchDashboardReservations,
  fetchDashboardReservationsPage,
  fetchStatisticsCatalog,
  fetchStatisticsView,
  fetchDashboardRideDetail,
  fetchDashboardRides,
  fetchDashboardRidesPage,
  fetchDashboardUserDetail,
  fetchDashboardUsers,
  fetchDashboardUsersPage,
  rejectDepositRequest,
  sendReportNote,
  unbanUser,
} from '@/api/dashboard-api'
import { ApiError } from '@/api/http'
import { qk } from '@/api/query-keys'
import {
  mapApiDepositRequest,
  mapApiReport,
  mapApiReservation,
  mapApiRide,
  mapApiTransaction,
  mapApiUser,
} from '@/lib/map-dashboard'
import type { ApiPaginatedResponse } from '@/api/types-api'
import type { DashboardStats } from '@/types/domain'

async function loadStats(): Promise<DashboardStats> {
  const [users, rides, reservations, reports, depositRequests] =
    await Promise.all([
      fetchDashboardUsers(),
      fetchDashboardRides(),
      fetchDashboardReservations(),
      fetchDashboardReports(),
      fetchDashboardDepositRequests(),
    ])

  const totalUsers = users.length
  const activeUsers = users.filter((u) => u.is_active !== false).length
  const bannedUsers = users.filter((u) => u.is_active === false).length
  const driverAccounts = users.filter((u) => u.user_type === 'driver').length
  const passengerAccounts = users.filter((u) => u.user_type === 'rider').length
  const totalRides = rides.length
  const activeRides = rides.filter((r) => r.status === 'active').length
  const totalBookings = reservations.length
  const pendingBookings = reservations.filter((b) => b.status === 'pending')
    .length
  const openReports = reports.filter((r) => r.status === 'pending').length
  const pendingDepositRequests = depositRequests.filter(
    (d) => d.status === 'pending',
  ).length

  return {
    totalUsers,
    activeUsers,
    bannedUsers,
    totalRides,
    activeRides,
    totalBookings,
    pendingBookings,
    driverAccounts,
    passengerAccounts,
    openReports,
    pendingDepositRequests,
  }
}

export function useDashboardStats() {
  return useQuery({ queryKey: qk.stats, queryFn: loadStats })
}

// Server-side analytics (statistics/ + daily_summary/). These are backed by DB
// views and a once-a-day summary job, so they change slowly — cache generously.
const STATISTICS_STALE_TIME = 5 * 60 * 1000

/** The catalog of available analytics views (used to build the views menu). */
export function useStatisticsCatalog() {
  return useQuery({
    queryKey: qk.statisticsCatalog,
    queryFn: fetchStatisticsCatalog,
    staleTime: STATISTICS_STALE_TIME,
  })
}

/**
 * A single analytics view's data. Only fetches once a view is selected, so the
 * endpoint returns one view at a time instead of all of them at once.
 */
export function useStatisticsView(view: string | null) {
  return useQuery({
    queryKey: qk.statisticsView(view ?? ''),
    queryFn: () => fetchStatisticsView(view as string),
    enabled: Boolean(view),
    staleTime: STATISTICS_STALE_TIME,
  })
}

export function useDailySummary() {
  return useQuery({
    queryKey: qk.dailySummary,
    queryFn: fetchDailySummary,
    staleTime: STATISTICS_STALE_TIME,
  })
}

// Full-list lookups used to enrich paginated tables with names/labels.
// Cached for the session so they load once, in the background.
const LOOKUP_STALE_TIME = 5 * 60 * 1000

export function useUsers() {
  return useQuery({
    queryKey: qk.users,
    queryFn: async () => {
      const rows = await fetchDashboardUsers()
      return rows.map(mapApiUser)
    },
    staleTime: LOOKUP_STALE_TIME,
  })
}

export function useUsersPage(page: number, pageSize = 10) {
  return useQuery<ApiPaginatedResponse<ReturnType<typeof mapApiUser>>>({
    queryKey: [...qk.users, 'page', page, pageSize],
    queryFn: async () => {
      const res = await fetchDashboardUsersPage((page - 1) * pageSize, pageSize)
      return {
        ...res,
        results: res.results.map(mapApiUser),
      }
    },
    placeholderData: keepPreviousData,
  })
}

export function useRides() {
  return useQuery({
    queryKey: qk.rides,
    queryFn: async () => {
      const rows = await fetchDashboardRides()
      return rows.map(mapApiRide)
    },
    staleTime: LOOKUP_STALE_TIME,
  })
}

export function useRidesPage(page: number, pageSize = 10) {
  return useQuery<ApiPaginatedResponse<ReturnType<typeof mapApiRide>>>({
    queryKey: [...qk.rides, 'page', page, pageSize],
    queryFn: async () => {
      const res = await fetchDashboardRidesPage((page - 1) * pageSize, pageSize)
      return {
        ...res,
        results: res.results.map(mapApiRide),
      }
    },
    placeholderData: keepPreviousData,
  })
}

export function useRideDetail(rideId: string | undefined) {
  const idOk = Boolean(rideId && /^\d+$/.test(rideId))
  return useQuery({
    queryKey: rideId ? qk.rideDetail(rideId) : ['rides', 'detail', ''],
    queryFn: async () => {
      if (!rideId) throw new ApiError(404, 'Ride not found')
      return fetchDashboardRideDetail(rideId)
    },
    enabled: idOk,
  })
}

export function useBookings() {
  return useQuery({
    queryKey: qk.bookings,
    queryFn: async () => {
      const rows = await fetchDashboardReservations()
      return rows.map(mapApiReservation)
    },
  })
}

export function useBookingsPage(page: number, pageSize = 10) {
  return useQuery<ApiPaginatedResponse<ReturnType<typeof mapApiReservation>>>({
    queryKey: [...qk.bookings, 'page', page, pageSize],
    queryFn: async () => {
      const res = await fetchDashboardReservationsPage(
        (page - 1) * pageSize,
        pageSize,
      )
      return {
        ...res,
        results: res.results.map(mapApiReservation),
      }
    },
    placeholderData: keepPreviousData,
  })
}

export function useUserDetail(userId: string | undefined) {
  const qc = useQueryClient()
  const idOk = Boolean(userId && /^\d+$/.test(userId))
  return useQuery({
    queryKey: userId ? qk.userDetail(userId) : ['users', 'detail', ''],
    queryFn: async () => {
      if (!userId) throw new ApiError(404, 'User not found')
      const detail = await fetchDashboardUserDetail(userId)
      const profile = detail.profile

      // The detail endpoint returns { profile, rides|reservations }. The profile
      // block carries user_type, status, balance and transactions; the remaining
      // base fields (name, email, joined) live in the users list, so resolve
      // them from there (cached when possible).
      let usersList = qc.getQueryData<ReturnType<typeof mapApiUser>[]>(qk.users)
      if (!usersList) {
        const rows = await fetchDashboardUsers()
        usersList = rows.map(mapApiUser)
        qc.setQueryData(qk.users, usersList)
      }

      const roleMap: Record<string, ReturnType<typeof mapApiUser>['role']> = {
        rider: 'passenger',
        driver: 'driver',
        admin: 'admin',
      }
      const baseUser = usersList.find((u) => u.id === userId)
      const user: ReturnType<typeof mapApiUser> = baseUser ?? {
        id: userId,
        email: '',
        fullName: `#${userId}`,
        role: (profile?.user_type && roleMap[profile.user_type]) || 'admin',
        status: profile?.status === 'Blocked' ? 'banned' : 'active',
        createdAt: profile?.created_at ?? '',
        reportsCount: 0,
      }

      // Prefer the authoritative balance from the profile block when present.
      const balance =
        profile?.balance == null
          ? user.balance
          : typeof profile.balance === 'string'
            ? parseFloat(profile.balance)
            : profile.balance
      const userWithBalance = { ...user, balance }

      const transactions = profile?.transactions?.map(mapApiTransaction) ?? []
      const ridesAsDriver = detail.rides?.map(mapApiRide) ?? []
      const bookingsAsRider = detail.reservations
        ? detail.reservations.map(mapApiReservation)
        : []

      const rideRows =
        qc.getQueryData(qk.rides) as
          | Array<{ id: string; origin: string; destination: string }>
          | undefined

      return {
        user: userWithBalance,
        transactions,
        ridesAsDriver,
        bookingsAsRider,
        rideRows: rideRows ?? [],
      }
    },
    enabled: idOk,
  })
}

export function useBanUser() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: async ({
      userId,
      banned,
    }: {
      userId: string
      banned: boolean
    }) => {
      const id = Number(userId)
      if (banned) await banUser(id)
      else await unbanUser(id)
    },
    onSuccess: () => {
      void qc.invalidateQueries({ queryKey: qk.users })
      void qc.invalidateQueries({ queryKey: qk.stats })
      void qc.invalidateQueries({ queryKey: ['users', 'detail'] })
    },
  })
}

export function useReports() {
  return useQuery({
    queryKey: qk.reports,
    queryFn: async () => {
      const rows = await fetchDashboardReports()
      return rows.map(mapApiReport)
    },
  })
}

export function useReportsPage(page: number, pageSize = 10) {
  return useQuery<ApiPaginatedResponse<ReturnType<typeof mapApiReport>>>({
    queryKey: [...qk.reports, 'page', page, pageSize],
    queryFn: async () => {
      const res = await fetchDashboardReportsPage((page - 1) * pageSize, pageSize)
      return {
        ...res,
        results: res.results.map(mapApiReport),
      }
    },
    placeholderData: keepPreviousData,
  })
}

export function useReportDetail(reportId: string | undefined) {
  const idOk = Boolean(reportId && /^\d+$/.test(reportId))
  return useQuery({
    queryKey: reportId ? qk.reportDetail(reportId) : ['reports', 'detail', ''],
    queryFn: async () => {
      if (!reportId) throw new ApiError(404, 'Report not found')
      const detail = await fetchDashboardReportDetail(reportId)
      return mapApiReport(detail)
    },
    enabled: idOk,
  })
}

export function useSendReportNote() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: ({ reportId, note }: { reportId: string; note: string }) =>
      sendReportNote(Number(reportId), note),
    onSuccess: (_data, variables) => {
      void qc.invalidateQueries({ queryKey: qk.reports })
      void qc.invalidateQueries({
        queryKey: qk.reportDetail(variables.reportId),
      })
    },
  })
}

export function useDepositRequestsPage(page: number, pageSize = 10) {
  return useQuery<ApiPaginatedResponse<ReturnType<typeof mapApiDepositRequest>>>({
    queryKey: [...qk.depositRequests, 'page', page, pageSize],
    queryFn: async () => {
      const res = await fetchDashboardDepositRequestsPage(
        (page - 1) * pageSize,
        pageSize,
      )
      return {
        ...res,
        results: res.results.map(mapApiDepositRequest),
      }
    },
    placeholderData: keepPreviousData,
  })
}

export function useDepositRequestDetail(depositRequestId: string | undefined) {
  const idOk = Boolean(depositRequestId && /^\d+$/.test(depositRequestId))
  return useQuery({
    queryKey: depositRequestId
      ? qk.depositRequestDetail(depositRequestId)
      : ['depositRequests', 'detail', ''],
    queryFn: async () => {
      if (!depositRequestId) throw new ApiError(404, 'Deposit request not found')
      const detail = await fetchDashboardDepositRequestDetail(depositRequestId)
      return mapApiDepositRequest(detail)
    },
    enabled: idOk,
  })
}

export function useAcceptDepositRequest() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: (depositRequestId: string) =>
      acceptDepositRequest(Number(depositRequestId)),
    onSuccess: () => {
      void qc.invalidateQueries({ queryKey: qk.depositRequests })
      void qc.invalidateQueries({ queryKey: qk.stats })
    },
  })
}

export function useRejectDepositRequest() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: (depositRequestId: string) =>
      rejectDepositRequest(Number(depositRequestId)),
    onSuccess: () => {
      void qc.invalidateQueries({ queryKey: qk.depositRequests })
      void qc.invalidateQueries({ queryKey: qk.stats })
    },
  })
}
