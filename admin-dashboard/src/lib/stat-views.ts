import type { LucideIcon } from 'lucide-react'
import {
  AlertTriangle,
  Car,
  Database,
  Flag,
  Gauge,
  LayoutDashboard,
  LocateFixed,
  MapPin,
  ScrollText,
  TrendingUp,
  UserRound,
  UsersRound,
  UserX,
  Wallet,
  Wifi,
} from 'lucide-react'
import type { Locale } from '@/i18n/translations'

/**
 * How a given analytics view should be rendered:
 * - `kpi`   — one row of headline numbers, shown as stat cards.
 * - `bar`   — a labelled category count, shown as a bar chart (+ table).
 * - `table` — arbitrary rows, shown as a generic data table.
 */
export type StatViewKind = 'kpi' | 'bar' | 'table'

export type StatCategory =
  | 'overview'
  | 'rides'
  | 'users'
  | 'financial'
  | 'monitoring'
  | 'location'

type Localized = Record<Locale, string>

export type StatViewConfig = {
  /** Matches the backend whitelist key + the SQL view name. */
  key: string
  category: StatCategory
  icon: LucideIcon
  kind: StatViewKind
  /** For `bar` views: which column is the label and which is the value. */
  bar?: { labelKey: string; valueKey: string }
  label: Localized
  description: Localized
}

/** Category display order + labels for the views menu. */
export const STAT_CATEGORIES: { key: StatCategory; label: Localized }[] = [
  { key: 'overview', label: { en: 'Overview', ar: 'نظرة عامة' } },
  {
    key: 'rides',
    label: { en: 'Rides & reservations', ar: 'الرحلات والحجوزات' },
  },
  { key: 'users', label: { en: 'Users', ar: 'المستخدمون' } },
  { key: 'financial', label: { en: 'Financial', ar: 'المالية' } },
  { key: 'monitoring', label: { en: 'Monitoring', ar: 'المراقبة' } },
  { key: 'location', label: { en: 'Location', ar: 'الموقع' } },
]

export const STAT_VIEWS: StatViewConfig[] = [
  {
    key: 'view_admin_dashboard_summary',
    category: 'overview',
    icon: LayoutDashboard,
    kind: 'kpi',
    label: { en: 'Platform summary', ar: 'ملخص المنصة' },
    description: {
      en: 'Live totals: active users, active rides, open reports, wallet balance, and 30-day revenue.',
      ar: 'إجماليات لحظية: المستخدمون النشطون، الرحلات النشطة، البلاغات المفتوحة، رصيد المحافظ، وإيراد آخر ٣٠ يومًا.',
    },
  },
  {
    key: 'view_active_sessions_count',
    category: 'overview',
    icon: Wifi,
    kind: 'kpi',
    label: { en: 'Active sessions', ar: 'الجلسات النشطة' },
    description: {
      en: 'Number of user sessions currently signed in.',
      ar: 'عدد جلسات المستخدمين المسجّلة حاليًا.',
    },
  },
  {
    key: 'view_driver_trips_count',
    category: 'rides',
    icon: Car,
    kind: 'table',
    label: { en: 'Driver trips', ar: 'رحلات السائقين' },
    description: {
      en: 'Total rides published by each driver.',
      ar: 'إجمالي الرحلات المنشورة لكل سائق.',
    },
  },
  {
    key: 'view_most_active_riders',
    category: 'rides',
    icon: UserRound,
    kind: 'table',
    label: { en: 'Most active riders', ar: 'أنشط الركاب' },
    description: {
      en: 'Riders ranked by total reservations.',
      ar: 'الركاب مرتبين حسب إجمالي الحجوزات.',
    },
  },
  {
    key: 'view_popular_destinations',
    category: 'rides',
    icon: TrendingUp,
    kind: 'bar',
    bar: { labelKey: 'destination_city', valueKey: 'total_trips_to_destination' },
    label: { en: 'Popular destinations', ar: 'الوجهات الأكثر شيوعًا' },
    description: {
      en: 'Most requested destination cities.',
      ar: 'أكثر مدن الوجهة طلبًا.',
    },
  },
  {
    key: 'view_popular_pickup_locations',
    category: 'rides',
    icon: MapPin,
    kind: 'bar',
    bar: { labelKey: 'student_pickup_point', valueKey: 'total_requests' },
    label: { en: 'Popular pickup points', ar: 'نقاط الانطلاق الأكثر شيوعًا' },
    description: {
      en: 'Most requested pickup locations.',
      ar: 'أكثر نقاط الالتقاط طلبًا.',
    },
  },
  {
    key: 'view_ride_occupancy_rate',
    category: 'rides',
    icon: Gauge,
    kind: 'table',
    label: { en: 'Ride occupancy', ar: 'إشغال الرحلات' },
    description: {
      en: 'Accepted reservations vs. capacity per ride.',
      ar: 'الحجوزات المقبولة مقابل السعة لكل رحلة.',
    },
  },
  {
    key: 'view_user_role_summary',
    category: 'users',
    icon: UsersRound,
    kind: 'table',
    label: { en: 'Users by role', ar: 'المستخدمون حسب الدور' },
    description: {
      en: 'Active / inactive user counts per role.',
      ar: 'أعداد المستخدمين النشطين وغير النشطين لكل دور.',
    },
  },
  {
    key: 'view_inactive_users',
    category: 'users',
    icon: UserX,
    kind: 'table',
    label: { en: 'Inactive users', ar: 'المستخدمون الخاملون' },
    description: {
      en: 'Accounts with no login in the last 90 days.',
      ar: 'حسابات لم تسجّل دخولًا خلال آخر ٩٠ يومًا.',
    },
  },
  {
    key: 'view_most_reported_users',
    category: 'users',
    icon: Flag,
    kind: 'table',
    label: { en: 'Most reported users', ar: 'الأكثر تعرضًا للبلاغات' },
    description: {
      en: 'Users ranked by number of reports filed against them.',
      ar: 'المستخدمون مرتبين حسب عدد البلاغات ضدهم.',
    },
  },
  {
    key: 'view_wallet_summary',
    category: 'financial',
    icon: Wallet,
    kind: 'table',
    label: { en: 'Wallet summary', ar: 'ملخص المحافظ' },
    description: {
      en: 'Balance, total deposits, and total spent per wallet.',
      ar: 'الرصيد وإجمالي الإيداعات والمصروفات لكل محفظة.',
    },
  },
  {
    key: 'view_suspicious_deposits',
    category: 'financial',
    icon: AlertTriangle,
    kind: 'table',
    label: { en: 'Suspicious deposits', ar: 'الإيداعات المشبوهة' },
    description: {
      en: 'Users with more than 3 deposit requests within one hour.',
      ar: 'مستخدمون بأكثر من ٣ طلبات إيداع خلال ساعة.',
    },
  },
  {
    key: 'view_audit_activity_by_day',
    category: 'monitoring',
    icon: ScrollText,
    kind: 'table',
    label: { en: 'Audit activity by day', ar: 'نشاط التدقيق يوميًا' },
    description: {
      en: 'Audit-log events per table per day.',
      ar: 'أحداث سجل التدقيق لكل جدول في اليوم.',
    },
  },
  {
    key: 'view_last_known_location',
    category: 'location',
    icon: LocateFixed,
    kind: 'table',
    label: { en: 'Last known locations', ar: 'آخر المواقع المعروفة' },
    description: {
      en: 'Latest recorded coordinates per user.',
      ar: 'أحدث إحداثيات مسجّلة لكل مستخدم.',
    },
  },
  {
    key: 'view_location_data_footprint',
    category: 'location',
    icon: Database,
    kind: 'table',
    label: { en: 'Location data footprint', ar: 'أثر بيانات الموقع' },
    description: {
      en: 'Stored location points and time span per user.',
      ar: 'نقاط الموقع المخزّنة والمدى الزمني لكل مستخدم.',
    },
  },
]

export const STAT_VIEWS_BY_KEY: Record<string, StatViewConfig> =
  Object.fromEntries(STAT_VIEWS.map((v) => [v.key, v]))
