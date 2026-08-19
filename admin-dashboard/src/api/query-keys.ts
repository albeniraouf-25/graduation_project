export const qk = {
  stats: ['stats'] as const,
  statistics: ['statistics'] as const,
  statisticsCatalog: ['statistics', 'catalog'] as const,
  statisticsView: (view: string) => ['statistics', 'view', view] as const,
  dailySummary: ['dailySummary'] as const,
  users: ['users'] as const,
  userDetail: (id: string) => ['users', 'detail', id] as const,
  rides: ['rides'] as const,
  rideDetail: (id: string) => ['rides', 'detail', id] as const,
  bookings: ['bookings'] as const,
  reports: ['reports'] as const,
  depositRequests: ['depositRequests'] as const,
  depositRequestDetail: (id: string) =>
    ['depositRequests', 'detail', id] as const,
  reportDetail: (id: string) => ['reports', 'detail', id] as const,
}
