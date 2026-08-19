export type ApiPaginatedResponse<T> = {
  next: string | null
  previous: string | null
  results: T[]
  count?: number
}

export type ApiUserRow = {
  id: number
  name: string | null
  user_type: 'driver' | 'rider' | 'admin' | null
  created_at: string
  /** Present on some deployments only */
  email?: string
  is_active?: boolean
  /** Number of reports filed against this user (from view_users/) */
  reports_count?: number
  /** Wallet balance (from view_users/ and the user profile) */
  balance?: string | number | null
}

export type ApiReportRow = {
  id: number
  reporter: number | null
  reported_user: number | null
  ride: number | null
  type: string
  reason: string
  status: string
  /** Admin's note on the report (from view_report_details/ and send_note/) */
  admin_note?: string | null
  created_at: string
  updated_at?: string
}

export type ApiDepositRequestRow = {
  id: number
  user_name: string | null
  payment_method: string
  amount: string | number
  status: string
  created_at: string
}

export type ApiDepositRequestDetail = ApiDepositRequestRow & {
  transaction_reference?: string
}

export type ApiRideRow = {
  id: number
  location: string
  destination: string
  /** Top-level on list endpoints; nested under driver_info on detail endpoints */
  driver_name?: string
  driver_info?: {
    driver_name?: string
    car_image?: string | null
  }
  departure_time: string | null
  departure_date?: string | null
  expected_duration?: string | null
  capacity: number
  available_seats: number
  cost: string | number
  status: string
}

export type ApiReservationRow = {
  id: number
  rider_name: string
  /** Absent on the user-detail reservation shape (ReservationDetailSerializer) */
  ride?: number
  status: string
  created_at: string
  payment?: string
}

export type ApiRideDetail = ApiRideRow & {
  available_seats: number
  reservations: ApiReservationRow[]
}

export type ApiUserDetailReservationRow = ApiReservationRow & {
  ride_location?: string
  ride_destination?: string
}

export type ApiTransaction = {
  id: number
  amount: string | number
  transaction_type: string
  created_at: string
}

/** Nested profile block returned by view_user_details/ (UserProfileSerializer). */
export type ApiUserProfile = {
  id: number
  user_type: 'driver' | 'rider' | 'admin' | null
  status?: string
  created_at?: string
  balance?: string | number | null
  transactions?: ApiTransaction[]
}

export type ApiUserDetail = {
  profile?: ApiUserProfile
  rides?: ApiRideRow[]
  reservations?: ApiUserDetailReservationRow[]
}

/** Row from view_driver_trips_count (statistics/). */
export type ApiDriverTripCount = {
  driver_id: number
  driver_email: string
  total_rides: number
}

/** Row from view_most_active_riders (statistics/). */
export type ApiActiveRider = {
  rider_id: number
  rider_email: string
  total_reservations: number
}

/** Row from view_popular_destinations (statistics/). */
export type ApiPopularDestination = {
  destination_city: string
  total_trips_to_destination: number
}

/** Row from view_popular_pickup_locations (statistics/). */
export type ApiPopularPickupLocation = {
  student_pickup_point: string
  total_requests: number
}

/** Response shape of GET /api/dashboard/statistics/. */
export type ApiDashboardStatistics = {
  driver_trips: ApiDriverTripCount[]
  active_riders: ApiActiveRider[]
  popular_destinations: ApiPopularDestination[]
  popular_pickup_locations: ApiPopularPickupLocation[]
}

/** Catalog of available analytics views, from GET /api/dashboard/statistics/. */
export type ApiStatisticsCatalog = {
  views: string[]
}

/**
 * A single analytics view's data, from GET /api/dashboard/statistics/?view=<key>.
 * `columns` preserves the DB column order; each row is a column→value map.
 */
export type ApiStatisticsView = {
  view: string
  columns: string[]
  rows: Array<Record<string, string | number | boolean | null>>
}

/**
 * Row from the daily_platform_summary table (daily_summary/), populated once a
 * day by the `daily_summary_job` MySQL event. `total_revenue` exists in the
 * table but is not exposed by the endpoint.
 */
export type ApiDailySummaryRow = {
  summary_date: string
  total_rides_created: number
  total_reservations_made: number
}

export type LoginResponse = {
  access_token: string
  token_type?: string
  expires_in?: number
  refresh_token?: string
  scope?: string
  user?: {
    email: string
    name: string | null
    user_type: string
  }
}
