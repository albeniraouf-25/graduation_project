# Backend ↔ Database-Layer Conflicts

Comparison of the Django backend (`back-end/carpolling`) against the DB-layer
changes described in:

- `New Microsoft Word Document (2).pdf` (Arabic summary of the DB objects)
- `data_3_full_expansion_3.sql` (the actual DDL: triggers, views, events, CHECK
  constraints, roles/grants, stored procedure)

The SQL file adds a protection/audit/automation layer **directly in MySQL**.
Some of it duplicates logic the app already does (harmless), but several parts
**conflict** with what the current Python code does or assumes. Conflicts are
grouped by severity.

> **Scope note on the roles (Section 3 of the SQL).** Many conflicts below only
> bite **if the application connects to MySQL as the `app_readwrite` role** the
> file creates. The app currently connects as whatever `DB_USER` env var is set
> to (`carpolling/settings.py:144`). If that user is `root`/`admin_full`, the
> grant-based conflicts (🔴 #1, #2, 🟠 #6) do **not** fire — but then the whole
> point of Section 3's least-privilege hardening is lost. Adopting the intended
> `app_readwrite` role will break the flows listed unless the code is changed
> first. The trigger/constraint/enum conflicts fire **regardless** of DB user.

---

## 🔴 Critical — will break functionality

### 1. Direct wallet-balance `UPDATE`s are forbidden for `app_readwrite`

The SQL revokes direct `UPDATE` on `payments_wallet` — `app_readwrite` gets only
`SELECT` (SQL lines 946–948). The **only** sanctioned way to change a balance is
the stored procedure `sp_adjust_wallet_balance` (lines 970–1004).

But the backend mutates `wallet.balance` directly in **four** places:

| Location | Code |
|----------|------|
| `payments/serializers.py:72-73` | `wallet.balance = F("balance") - reservation.ride.cost; wallet.save()` (pay for ride) |
| `rides/views.py:273-274` | `wallet.balance = F("balance") + reservation.ride.cost; wallet.save()` (refund on reject) |
| `rides/views.py:447-448` | `wallet.balance = F("balance") + total_earnings; wallet.save()` (driver earnings) |
| `dashboard/views.py:248-249` | `wallet.balance += deposit_request.amount; wallet.save()` (approve deposit) |

Under `app_readwrite` every one of these raises a MySQL permission error →
500 / broken payment, refund, earnings payout, and deposit approval.

**Fix options:** route all four through `sp_adjust_wallet_balance` (e.g.
`cursor.callproc('sp_adjust_wallet_balance', [wallet_id, amount, 'credit'|'debit'])`),
**or** grant `UPDATE ON payments_wallet` to `app_readwrite` (defeats the design),
**or** keep connecting as a privileged user (defeats Section 3).

### 2. Deposit approval also does a forbidden `UPDATE` on `payments_depositrequest`

`app_readwrite` is granted only `SELECT, INSERT` on `payments_depositrequest`
and `payments_transaction` (SQL lines 944–945) — no `UPDATE`/`DELETE`.

`dashboard/views.py` `AcceptDepositRequestView` (and the reject view) do
`deposit_request.status = APPROVED; deposit_request.save()` — an `UPDATE`.
Under `app_readwrite` this fails before the wallet step even runs.

**Fix:** grant `UPDATE ON payments_depositrequest TO 'app_readwrite'`, or move
status changes to an admin/privileged connection.

### 3. Reservation status `'expired'` is written by the DB but is not a model choice

Event `expire_pending_reservations` sets `rides_reservation.status = 'expired'`
for pending reservations older than 6h (SQL lines 456–467).

`rides/models.py` `Reservation.ReservationStatus` only defines
`pending / accepted / rejected / cancelled` — **no `expired`**. The DB will
happily store `'expired'` (plain `varchar`), but then:

- Serializers / clients receive a status value outside the declared choices.
- Any app-side filter/branch keyed on the known statuses silently misses these
  rows (e.g. the rider still "has" a reservation that no longer counts).

**Fix:** add `EXPIRED = 'expired'` to `ReservationStatus` and handle it in the
UI/serializers, or drop/rename the event to a status the app understands.

### 4. Report status `'needs_review'` is written by the DB but is not a model choice

Event `escalate_stale_reports` sets `reports_report.status = 'needs_review'`
after 7 days (SQL lines 708–719).

`reports/models.py` `Report.ReportStatus` only defines `pending / reviewed`.
`'needs_review'` is not among them. Same failure mode as #3: escalated reports
carry a status the app can't render/filter, and the admin dashboard report
lists/filters won't recognize them.

**Fix:** add a `NEEDS_REVIEW = 'needs_review'` choice (and surface it in the
dashboard), or change the event to use `'pending'`/`'reviewed'`.

---

## 🟠 High — behavioral mismatch / unhandled errors

### 5. `before_reservation_update` capacity trigger can throw an uncaught 500

On approving a reservation (`pending → accepted`), the trigger re-checks
capacity counting **only `accepted`** rows and `SIGNAL`s SQLSTATE 45000 if full
(SQL lines 238–256). Django surfaces this as `OperationalError`.

The app's own capacity model differs: `Ride.available_seats`
(`rides/models.py`) counts **`pending` + `accepted`** against capacity. So:

- The two layers disagree on when a ride is "full" (app reserves a seat for
  pending requests; the trigger only for accepted ones).
- If the trigger does fire on accept, the accept view does not wrap the `save()`
  in a try/except for the DB error → 500 instead of a clean "ride is full".

**Fix:** align the counting rule, and catch the DB error on accept to return a
proper 400.

### 6. Admin dashboard analytics read objects `app_readwrite` can't access

`dashboard/views.py` (`execute_view_query`, lines ~289–340) selects from DB
views and tables that `app_readwrite` is **not** granted:

- `view_driver_trips_count`, `view_most_active_riders`,
  `view_popular_destinations`, `view_popular_pickup_locations` — the `view_*`
  objects are only reachable via the whole-schema `SELECT` granted to
  `app_readonly`/`admin_full`, **not** the table-by-table `app_readwrite` grants
  (SQL lines 889–946). No grant on the view objects → permission denied.
- `daily_platform_summary` (`DailyPlatformSummaryView`, line ~336) — this table
  gets **no grant at all** for `app_readwrite`.

Under `app_readwrite` these dashboard endpoints fail. (Also, any future feature
that reads `audit_log` / `activity_history` from the app will fail by design —
those are intentionally ungranted, SQL lines 950–955.)

**Fix:** grant `SELECT` on the needed `view_*` objects and
`daily_platform_summary` to `app_readwrite`, or serve analytics from an
admin/read-only connection.

### 7. `before_report_insert_duplicate_check` raises on duplicate reports

Trigger blocks a second **pending** report from the same reporter about the same
user on the same day (SQL lines 681–698). The app (`reports` create flow) has no
matching guard and does not catch the resulting DB error → 500 instead of a
friendly "you already reported this user today".

**Fix:** pre-check in the serializer/view, or catch the `OperationalError`.

### 8. `before_ride_delete` intent vs. Django cascade

Trigger forbids deleting a `rides_ride` that has `pending`/`accepted`
reservations (SQL lines 258–268). Django's `Reservation.ride` is
`on_delete=CASCADE`, so the ORM deletes the child reservations **first**, then
the ride — by which point the trigger sees zero reservations and allows it. Net
effect: the business rule the trigger encodes is **not** enforced through the
ORM (and a raw `DELETE FROM rides_ride` would instead fail). Inconsistent
behavior between code paths. (No ride-delete endpoint exists today, so this is
latent, not active.)

---

## 🟡 Low — worth knowing, currently harmless

- **`code_hash` columns / hashing triggers** (`before_emailverification_hash`,
  `before_passwordreset_hash`, SQL lines 786–825): a new nullable `code_hash`
  column is added to `users_emailverification` and `users_passwordresetcode` and
  filled by SHA2 **on INSERT only**. The Django models don't know about the
  column (fine — Django ignores unknown columns). Note: a "resend code" that
  **updates** an existing row won't refresh `code_hash` (no BEFORE UPDATE
  trigger), so the hash goes stale. Purely informational until anything relies
  on `code_hash`.
- **`before_passwordreset_prevent_reuse`** (UPDATE trigger, lines 828–835):
  blocks setting `is_verified` when it was already 1. The app deletes reset
  codes after use (`users/views.py`) rather than re-updating, so it doesn't hit
  this today.
- **CHECK constraints** `chk_ride_cost`/`chk_ride_capacity` (≥0),
  `chk_transaction_amount_positive`/`chk_deposit_amount_positive` (>0),
  `chk_current_lat_range`/`lng_range`, `chk_point_lat/lng_range`: the models
  don't enforce these. Any code path that could produce `0` or negative
  amount/cost, or an out-of-range lat/lng, will now raise a DB integrity error
  instead of saving. Confirm no zero-amount transactions/deposits are ever
  created (e.g. a zero refund/earning). `rides/views.py:453` already guards
  `if total_earnings > 0` before creating the earning transaction — good.
- **`prevent_transaction_amount_update`** (lines 593–600): forbids changing a
  transaction's `amount`. The app never updates transactions, so no conflict.
- **`before_wallet_update_no_negative`** (lines 583–590): the pay-for-ride flow
  already checks `wallet.balance < cost` first (`payments/serializers.py:59`),
  so it shouldn't drive the balance negative — but this only holds while the
  app, not concurrent events, is the sole writer.

---

## Schema cross-check (no conflict)

All table/column names the SQL references match the Django schema
(`rides_ride`, `rides_reservation`, `users_mainuser`, `users_driver`,
`users_rider`, `payments_wallet/transaction/depositrequest`, `reports_report`,
`locations_currentlocation/locationpoint`, `users_emailverification`,
`users_passwordresetcode` and their columns). The unique constraint the SQL
drops (`unique_user_ride_reservation`, lines 132–147) is redundant with the
Django-generated `unique_together = ['ride','rider']` — safe.

---

## Suggested priority

1. Decide the DB user strategy (adopt `app_readwrite` or not). This determines
   whether #1, #2, #6 are live.
2. If adopting `app_readwrite`: route wallet writes through
   `sp_adjust_wallet_balance`, and grant the missing `SELECT`/`UPDATE`s for the
   dashboard and deposit-request flows.
3. Add the missing enum values (`expired`, `needs_review`) regardless of DB user
   — those conflicts (#3, #4) fire on any connection.
4. Wrap the accept-reservation and create-report paths to catch the trigger
   `SIGNAL` errors (#5, #7) and return clean 4xx responses.
