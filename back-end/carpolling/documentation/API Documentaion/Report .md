## 1. جدول حقول البيانات والمعاني (Fields Dictionary)

| الحقل           | نوع البيانات         | إجباري؟                                                                                                                                                                                                              | الوصف والشروط                                                                                                 |
| --------------- | -------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------- |
| `id`            | Integer              | تلقائي                                                                                                                                                                                                               | المعرّف الفريد للبلاغ، يتم إنشاؤه تلقائيًا.                                                                   |
| `reporter`      | User / ForeignKey    | تلقائي                                                                                                                                                                                                               | المستخدم الذي قام بإنشاء البلاغ، ويتم تحديده من `request.user`.                                               |
| `reported_user` | User / ForeignKey    | تلقائي                                                                                                                                                                                                               | المستخدم الذي تم الإبلاغ عنه، ويتم تحديده من `user_id` الموجود في الـ URL.                                    |
| `ride`          | Integer / ForeignKey | اختياري                                                                                                                                                                                                              | الرحلة التي بسببها تم تقديم البلاغ. يجب أن تكون رحلة مشتركة بين المبلّغ والمستخدم المُبلّغ عنه.               |
| `type`          | String (Enum)        | **نعم**                                                                                                                                                                                                              | نوع البلاغ.                                                                                                   |
| `reason`        | String / Text        | **نعم**                                                                                                                                                                                                              | السبب أو التفاصيل التي يكتبها المستخدم حول البلاغ.                                                            |
| `status`        | String (Enum)        | تلقائي                                                                                                                                                                                                               | حالة البلاغ، وتبدأ افتراضيًا بـ `pending`.                                                                    |
| `admin_note`    | String / Text        | اختياري\|   \|<br>\|---\|<br>\|`/my_reports/`\|<br><br>\|   \|<br>\|---\|<br>\|`GET`\|<br><br>\|   \|<br>\|---\|<br>\|**نعم**\|<br><br>\|   \|<br>\|---\|<br>\|عرض جميع البلاغات التي قام المستخدم الحالي بإرسالها\| | ملاحظة يضيفها الـ Adminملاحظة يضيفها الـ Admin أثناء معالجة البلاغ. تكون `null` إلى أن يضيف الـ Admin ملاحظة. |
| `created_at`    | DateTime             | تلقائي                                                                                                                                                                                                               | تاريخ ووقت إنشاء البلاغ.                                                                                      |
| `updated_at`    | DateTime             | تلقائي                                                                                                                                                                                                               | تاريخ ووقت آخر تعديل على البلاغ.                                                                              |
### ملاحظة حول `ride`

حقل `ride` **اختياري**.

يعني المستخدم يستطيع الإبلاغ عن مستخدم آخر بدون تحديد رحلة معينة.

أما إذا اختار رحلة، فالـ Backend يتحقق أن الرحلة فعلًا **مشتركة بين المستخدمين** قبل إنشاء البلاغ.

# 2. القيم الثابتة والتعدادات (Enums & Fixed Values)

## `ReportCategory` — نوع البلاغ

القيم المدعومة في النظام:

|القيمة|المعنى|
|---|---|
|`spam`|محتوى أو سلوك مزعج / Spam|
|`harassment`|مضايقة أو تحرش|
|`fake`|معلومات أو حساب مزيف|
|`dangerous`|سلوك خطير|
|`other`|سبب آخر|

---

## `ReportStatus` — حالة البلاغ

|القيمة|المعنى|
|---|---|
|`pending`|البلاغ بانتظار مراجعة الـ Admin|
|`reviewed`|تمت مراجعة البلاغ من قبل الـ Admin|

### الحالة الافتراضية

عند إنشاء البلاغ:

```
status = pending
```

ولا يحتاج المستخدم إلى إرسال `status`.

---

# 3. منطق الإبلاغ عن المستخدم

عملية الإبلاغ تبدأ من **Profile المستخدم الآخر**.

مثلاً:

```
User Profile
     │
     ▼
Report User
     │
     ▼
Select Report Type
     │
     ▼
Write Reason
     │
     ▼
Optional: Select Shared Ride
     │
     ▼
Submit Report
```

الـ Frontend يرسل `user_id` الخاص بالمستخدم الذي يريد الإبلاغ عنه ضمن الـ URL.

---
# 4. جدول مسارات الـ API

Base URL:

```
http://127.0.0.1:8000/api/reports
```

| Endpoint                   | Method | يتطلب Token؟ | الوصف                                               |
| -------------------------- | ------ | ------------ | --------------------------------------------------- |
| `/report/user/<user_id>/`  | `POST` | **نعم**      | إنشاء بلاغ ضد مستخدم                                |
| `/shared_rides/<user_id>/` | `GET`  | **نعم**      | جلب الرحلات المشتركة مع المستخدم                    |
| /my_reports/               | GET    | نعم          | عرض جميع البلاغات التي قام المستخدم الحالي بإرسالها |

مثال:

```
POST /api/reports/report/user/15/
```

يعني:

> المستخدم الحالي يريد الإبلاغ عن المستخدم الذي `id = 15`.

---

# 5. جلب الرحلات المشتركة

## `GET /shared_rides/<user_id>/`

هذا الـ endpoint يستخدم قبل إنشاء البلاغ عندما يريد المستخدم اختيار الرحلة التي بسببها يقدم البلاغ.

مثال:

```
GET /api/reports/shared_rides/15/
```

حيث:

```
15 = ID المستخدم المراد الإبلاغ عنه
```

### Headers

```
Authorization: Bearer <access_token>
```

---

# 6. Response — Shared Rides

**200 OK**

مثال:

```
[
    {
        "id": 12,
        "location": "Latakia",
        "destination": "Tartous",
        "departure_date": "2026-08-10",
        "departure_time": "09:00:00",
        "cost": "50000.00",
        "available_seats": 2,
        "status": "active"
    },
    {
        "id": 8,
        "location": "Latakia",
        "destination": "Jableh",
        "departure_date": "2026-08-09",
        "departure_time": "14:00:00",
        "cost": "30000.00",
        "available_seats": 1,
        "status": "active"
    }
]
```

يتم ترتيب الرحلات حسب:

```
departure_date DESC
departure_time DESC
```

أي الرحلات الأحدث تظهر أولًا.

---

# 7. إنشاء بلاغ

## `POST /report/user/<user_id>/`

### Headers

```
Authorization: Bearer <access_token>
Content-Type: application/json
```

### Request

إذا لم يحدد المستخدم رحلة:

```
{
    "type": "harassment",
    "reason": "The user behaved inappropriately."
}
```

إذا أراد تحديد رحلة:

```
{
    "ride": 12,
    "type": "dangerous",
    "reason": "The driver was driving dangerously."
}
```

---

# 8. عرض بلاغات المستخدم

## `GET /my_reports/`

يستخدم هذا الـ endpoint لعرض جميع البلاغات التي قام المستخدم الحالي بإرسالها.

### Headers

```
Authorization: Bearer <access_token>
```

### Response — Success

**200 OK**

مثال:

```
[
    {
        "id": 5,
        "reported_user": 12,
        "ride": 12,
        "type": "dangerous",
        "reason": "The driver was driving dangerously.",
        "status": "pending",
        "admin_note": null,
        "created_at": "2026-08-09T10:30:00Z",
        "updated_at": "2026-08-09T10:30:00Z"
    },
    {
        "id": 3,
        "reported_user": 8,
        "ride": null,
        "type": "harassment",
        "reason": "The user behaved inappropriately.",
        "status": "reviewed",
        "admin_note": "The report was reviewed and appropriate action was taken.",
        "created_at": "2026-08-08T15:20:00Z",
        "updated_at": "2026-08-09T12:00:00Z"
    }
]
```

### حالة `admin_note`

عند إنشاء البلاغ:

```
"admin_note": null
```

لأن الـ Admin لم يضف ملاحظة بعد.

بعد أن يقوم الـ Admin بإضافة ملاحظة:

```
"admin_note": "The report was reviewed and appropriate action was taken."
```
# 9. البيانات التي يدخلها المستخدم

من ناحية **واجهة المستخدم**:

### إجباري:

```
Report Type
Reason
```

### اختياري:

```
Shared Ride
```

أي:

```
Report User
     │
     ├── Report Type *
     │
     ├── Reason *
     │
     └── Select Ride (Optional)
```

---

# 10. البيانات التي يحددها النظام تلقائيًا

المستخدم **لا يرسل**:

```
reporter
reported_user
status
created_at
updated_at
```

### `reporter`

يتم أخذه من:

```
request.user
```

### `reported_user`

يتم أخذه من:

```
user_id
```

الموجود في الـ URL.

### `status`

يبدأ تلقائيًا:

```
pending
```

---

# 11. Response — نجاح إنشاء البلاغ

**201 Created**

مثال:

```
{
    "id": 5,
    "ride": 12,
    "type": "dangerous",
    "reason": "The driver was driving dangerously.",
    "status": "pending"
}
```

إذا لم يتم تحديد رحلة:

```
{
    "id": 6,
    "ride": null,
    "type": "harassment",
    "reason": "The user behaved inappropriately.",
    "status": "pending"
}
```

---

# 12. Report Workflow

                 User Profile
                      │
                      ▼
                  Report User
                      │
                      ▼
              GET Shared Rides
                      │
                      ▼
            Select Ride (Optional)
                      │
                      ▼
             Select Report Type
                      │
                      ▼
                Enter Reason
                      │
                      ▼
          POST Create Report
                      │
                      ▼
            status = pending
                      │
                      ▼
              Admin Reviews
                      │
             ┌────────┴────────┐
             │                 │
             ▼                 ▼
       No Admin Note      Add Admin Note
             │                 │
             └────────┬────────┘
                      ▼
              status = reviewed
                      │
                      ▼
             User opens My Reports
                      │
                      ▼
              GET /my_reports/
                      │
                      ▼
          View status + admin_note

---

# 13
## الخلاصة

المنطق النهائي عندك هو:

المستخدم يدخل بروفايل شخص → يضغط Report → التطبيق يجيب الرحلات المشتركة معه → يختار رحلة إذا أراد → يحدد نوع البلاغ → يكتب السبب → Backend يتحقق من الرحلة → ينشئ Report بحالة `pending` → الـ Admin يراجع البلاغ → يمكن للـ Admin إضافة `admin_note` → تصبح حالة البلاغ `reviewed` → يستطيع المستخدم عرض بلاغاته ومشاهدة حالة البلاغ وملاحظة الـ Admin من خلال `GET /my_reports/`.
