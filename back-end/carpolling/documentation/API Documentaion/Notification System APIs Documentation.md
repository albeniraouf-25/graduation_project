
## 1. نظرة عامة على نظام الإشعارات

تم تنفيذ نظام الإشعارات باستخدام **Firebase Cloud Messaging (FCM)** لإرسال الإشعارات الفورية إلى أجهزة المستخدمين.

يعتمد النظام على تسجيل **FCM Device Token** الخاص بجهاز المستخدم وربطه بحسابه في قاعدة البيانات. بعد ذلك يتم استخدام هذا الـ Token لإرسال الإشعارات تلقائياً عند حدوث أحداث معينة داخل النظام.

تتكون رسالة الإشعار من:

- `notification`: تحتوي على عنوان ونص الإشعار لعرضه للمستخدم.
    
- `data`: تحتوي على معلومات إضافية يستخدمها تطبيق Flutter لمعرفة نوع الحدث والعناصر المرتبطة به، مثل `reservation_id` و`ride_id`.
    

### آلية عمل النظام

```text
المستخدم يفتح التطبيق
        ↓
Firebase يولد FCM Device Token
        ↓
Flutter يرسل Token إلى Backend
        ↓
POST /register-device/
        ↓
تخزين Token في DeviceToken
        ↓
حدوث حدث داخل النظام
        ↓
safe_send_notification()
        ↓
Firebase Cloud Messaging
        ↓
جهاز المستخدم
        ↓
ظهور الإشعار
```

---

# 2. نموذج DeviceToken

يُستخدم نموذج `DeviceToken` لتخزين رموز أجهزة المستخدمين التي يتم استخدامها لإرسال إشعارات Firebase.

## جدول الحقول

|الحقل|نوع البيانات|إجباري؟|الوصف|
|---|---|---|---|
|`id`|Integer|تلقائي|المعرّف الفريد لسجل الجهاز.|
|`user`|ForeignKey|نعم|المستخدم المرتبط بالجهاز.|
|`token`|String|نعم|رمز FCM الفريد الخاص بالجهاز.|
|`created_at`|DateTime|تلقائي|تاريخ إنشاء سجل الجهاز.|
|`updated_at`|DateTime|تلقائي|تاريخ آخر تحديث لسجل الجهاز.|

### خصائص النموذج

يتم تعريف `token` على أنه فريد:

```python
unique = True
```

وبالتالي لا يمكن تسجيل نفس Device Token أكثر من مرة في قاعدة البيانات.

كما يتم ترتيب السجلات حسب:

```text
updated_at DESC
```

بحيث تظهر الأجهزة التي تم تحديثها مؤخراً أولاً.

---

# 3. تسجيل جهاز المستخدم

## `POST /register-device/`

يُستخدم هذا الـ endpoint لتسجيل **FCM Device Token** الخاص بجهاز المستخدم وربطه بحسابه.

يتم استدعاء هذا الـ endpoint من تطبيق Flutter بعد الحصول على Firebase Device Token.

### Headers

```text
Authorization: Bearer <access_token>
Content-Type: application/json
```

### Request

```json
{
    "token": "FCM_DEVICE_TOKEN"
}
```

### Response

**200 OK**

```json
{
    "message": "Device token registered successfully.",
    "token_id": 1
}
```

### آلية التنفيذ

```text
FCM Token
    ↓
التحقق من Token
    ↓
البحث عن Token في قاعدة البيانات
    ↓
إذا كان موجوداً → تحديث المستخدم المرتبط به
    ↓
إذا لم يكن موجوداً → إنشاء سجل جديد
    ↓
إرجاع نجاح العملية
```

يتم استخدام:

```python
update_or_create()
```

لتجنب إنشاء سجلات مكررة لنفس Device Token.

### شروط الاستخدام

- يجب أن يكون المستخدم مصادقاً عليه.
    
- يجب إرسال `token`.
    
- يجب ألا تكون قيمة `token` فارغة.
    
- يتم ربط Device Token بالمستخدم الحالي.
    
- يمكن للمستخدم امتلاك أكثر من Device Token عند استخدام أكثر من جهاز.
    

### الخطأ

**400 Bad Request**

في حال عدم إرسال Token:

```json
{
    "token": [
        "Device token is required."
    ]
}
```

---

# 4. دوال إرسال الإشعارات

يتم إرسال الإشعارات من Backend باستخدام Firebase Cloud Messaging.

تم إنشاء مجموعة من الدوال لتسهيل عملية إرسال الإشعارات.

## `send_notification_to_token()`

تُستخدم لإرسال إشعار إلى Device Token محدد.

## `send_notification_to_user()`

تُستخدم لإرسال الإشعار إلى جميع الأجهزة المسجلة للمستخدم.

## `send_notification_to_users()`

تُستخدم لإرسال نفس الإشعار إلى مجموعة من المستخدمين.

## `safe_send_notification()`

تُستخدم لإرسال الإشعار بطريقة آمنة بحيث لا يؤدي فشل Firebase في إرسال الإشعار إلى فشل العملية الأساسية في النظام.

مثال:

```text
إنشاء حجز
    ↓
نجاح إنشاء الحجز
    ↓
إرسال Notification
    ↓
Firebase Error
    ↓
تسجيل الخطأ في Log
    ↓
الحجز يبقى ناجحاً
```

وبالتالي يعتبر إرسال الإشعار عملية مساندة للعملية الأساسية وليس شرطاً لنجاحها.

---

# 5. أنواع الإشعارات المستخدمة في النظام

يحتوي النظام الحالي على خمسة أنواع من الإشعارات:

|النوع `type`|المستلم|الحدث|
|---|---|---|
|`new_reservation`|Driver|إنشاء حجز جديد|
|`reservation_accepted`|Rider|قبول الحجز|
|`reservation_rejected`|Rider|رفض الحجز|
|`ride_cancelled`|Rider|إلغاء الرحلة|
|`payment_received`|Driver|إكمال الرحلة وإضافة الأرباح إلى محفظة السائق|

> لا يوجد في النظام الحالي Notification مستقل باسم `payment_success`.

---

# 6. إشعار الحجز الجديد

## `new_reservation`

يتم إرسال هذا الإشعار إلى السائق عندما يقوم أحد الركاب بإنشاء حجز على إحدى رحلاته.

### API المرتبط

`CreateReservationView`

### المستلم

**Driver**

### Title

```text
New Reservation
```

### Body

```text
{rider_name} requested a reservation for your ride from {location} to {destination}.
```

### Data

```json
{
    "type": "new_reservation",
    "reservation_id": "1",
    "ride_id": "10"
}
```

### وقت الإرسال

يتم إرسال الإشعار بعد نجاح إنشاء الحجز:

```text
Create Reservation
        ↓
Reservation Created
        ↓
safe_send_notification()
        ↓
Driver receives notification
```

---

# 7. إشعار قبول الحجز

## `reservation_accepted`

يتم إرسال هذا الإشعار إلى الراكب عندما يقوم السائق بقبول طلب الحجز.

### API المرتبط

`AcceptReservationView`

### المستلم

**Rider**

### Title

```text
Reservation Accepted
```

### Body

```text
Your reservation for {location} to {destination} has been accepted.
```

### Data

```json
{
    "type": "reservation_accepted",
    "reservation_id": "1",
    "ride_id": "10"
}
```

### آلية التنفيذ

عند قبول الحجز يتم:

```text
Driver accepts reservation
        ↓
التحقق من أن الحجز Pending
        ↓
التحقق من رصيد Wallet الراكب
        ↓
خصم تكلفة الرحلة من Wallet
        ↓
إنشاء Transaction من نوع PAYMENT
        ↓
تغيير Reservation إلى ACCEPTED
        ↓
تغيير Payment إلى PAID
        ↓
إرسال Notification
```

### ملاحظة

لذلك `reservation_accepted` ليس مجرد تغيير لحالة الحجز، وإنما في الكود الحالي يترافق مع تنفيذ عملية الدفع من Wallet الراكب.

---

# 8. إشعار رفض الحجز

## `reservation_rejected`

يتم إرسال هذا الإشعار إلى الراكب عندما يقوم السائق برفض طلب الحجز.

### API المرتبط

`RejectReservationView`

### المستلم

**Rider**

### Title

```text
Reservation Rejected
```

### Body

```text
Your reservation for {location} to {destination} has been rejected.
```

### Data

```json
{
    "type": "reservation_rejected",
    "reservation_id": "1",
    "ride_id": "10"
}
```

### آلية التنفيذ

```text
Driver rejects reservation
        ↓
التحقق من أن Reservation = PENDING
        ↓
تغيير الحالة إلى REJECTED
        ↓
حفظ التغيير
        ↓
إرسال Notification
```

### ملاحظة

في النسخة الحالية **لا يتم تنفيذ Refund عند رفض الحجز**.

كما أن عملية الرفض لا تتضمن إنشاء Transaction أو تعديل Wallet، لأن الكود الحالي يسمح بالرفض فقط عندما تكون حالة الحجز:

```text
PENDING
```

---

# 9. إشعار إلغاء الرحلة

## `ride_cancelled`

يتم إرسال هذا الإشعار إلى الركاب المرتبطين بالرحلة عندما يقوم السائق بإلغاء رحلة نشطة.

### API المرتبط

`CancelRideView`

### المستلمون

**Riders**

ويتم إرسال الإشعار إلى الركاب الذين حجوزاتهم بحالة:

```text
PENDING
ACCEPTED
```

### Title

```text
Ride Cancelled
```

### Body

```text
The ride from {location} to {destination} has been cancelled.
```

### Data

```json
{
    "type": "ride_cancelled",
    "ride_id": "10",
    "reservation_id": "1"
}
```

### آلية التنفيذ

```text
Driver cancels ride
        ↓
التحقق من أن المستخدم Driver
        ↓
التحقق من أن الرحلة تخص السائق
        ↓
التحقق من أن Ride = ACTIVE
        ↓
تغيير Ride إلى CANCELLED
        ↓
جلب Reservations بحالة PENDING أو ACCEPTED
        ↓
إرسال Notification لكل Rider
        ↓
تغيير Reservations إلى CANCELLED
```

### ملاحظة

يتم إرسال إشعار منفصل لكل حجز، لذلك يحتوي كل إشعار على `reservation_id` الخاص بالراكب بالإضافة إلى `ride_id`.

---

# 10. إشعار استلام الأرباح

## `payment_received`

يتم إرسال هذا الإشعار إلى السائق بعد إكمال الرحلة وإضافة إجمالي المبالغ المدفوعة إلى محفظته.

### API المرتبط

`CompleteRideView`

### المستلم

**Driver**

### Title

```text
Payment Received
```

### Body

```text
The payment for your ride from {location} to {destination} has been added to your wallet.
```

### Data

```json
{
    "type": "payment_received",
    "ride_id": "10",
    "amount": "150000.00"
}
```

### آلية التنفيذ

عند إكمال الرحلة:

```text
Complete Ride
        ↓
جلب الحجوزات المدفوعة
        ↓
حساب إجمالي الأرباح
        ↓
إضافة المبلغ إلى Wallet السائق
        ↓
إنشاء Transaction من نوع EARNING
        ↓
تغيير Ride إلى COMPLETED
        ↓
إرسال Payment Received Notification
```

### حساب الأرباح

يتم حساب الأرباح من الحجوزات التي تكون:

```text
payment = PAID
```

ويتم جمع تكلفة الرحلة لهذه الحجوزات.

مثلاً:

```text
Ride.cost = 50,000

عدد الحجوزات المدفوعة = 3
```

إذن:

```text
Total Earnings = 50,000 × 3
                = 150,000
```

ويتم إرسال:

```json
{
    "type": "payment_received",
    "ride_id": "10",
    "amount": "150000.00"
}
```

إلى السائق.

---

# 11. العلاقة بين APIs والإشعارات

الإشعارات ليست APIs مستقلة يستدعيها المستخدم مباشرة، وإنما يتم تشغيلها تلقائياً داخل الـ API المسؤول عن العملية.

|API|العملية|المستلم|Notification|
|---|---|---|---|
|`POST /register-device/`|تسجيل جهاز|المستخدم الحالي|لا يوجد|
|`POST CreateReservationView`|إنشاء حجز|Driver|`new_reservation`|
|`POST AcceptReservationView`|قبول حجز|Rider|`reservation_accepted`|
|`POST RejectReservationView`|رفض حجز|Rider|`reservation_rejected`|
|`DELETE CancelRideView`|إلغاء رحلة|Riders|`ride_cancelled`|
|`POST CompleteRideView`|إكمال رحلة|Driver|`payment_received`|

---

# 12. دورة الإشعارات في النظام

```text
                 Notification System
                         │
          ┌──────────────┴──────────────┐
          │                             │
     Device Token                  System Event
          │                             │
          ↓                             ↓
 /register-device/              Business Operation
          │                             │
          ↓                             ↓
    DeviceToken DB              safe_send_notification()
                                        │
                                        ↓
                             Firebase Cloud Messaging
                                        │
                                        ↓
                                  User's Device
```

---

# 13. الأحداث التي تؤدي إلى إرسال الإشعارات

|العملية|المستخدم المتأثر|نوع الإشعار|
|---|---|---|
|إنشاء حجز|Driver|`new_reservation`|
|قبول حجز|Rider|`reservation_accepted`|
|رفض حجز|Rider|`reservation_rejected`|
|إلغاء رحلة|Rider|`ride_cancelled`|
|إكمال رحلة وإضافة الأرباح|Driver|`payment_received`|

---

# 14. الصلاحيات العامة

## تسجيل Device Token

يتطلب:

```text
Authorization: Bearer <access_token>
```

ويجب أن يكون المستخدم مصادقاً عليه.

يتم ربط Device Token بالمستخدم الذي قام بإرسال الطلب.

## إرسال الإشعارات

لا يستطيع المستخدم إرسال Notification بشكل مباشر.

يتم إرسال الإشعارات تلقائياً من Backend عند تنفيذ العمليات المحددة، مثل:

- إنشاء حجز.
    
- قبول حجز.
    
- رفض حجز.
    
- إلغاء رحلة.
    
- إكمال رحلة.
    

---

# 15. معالجة فشل الإشعارات

يستخدم النظام:

```python
safe_send_notification()
```

لضمان عدم تأثير فشل Firebase على العملية الأساسية.

مثلاً عند إكمال رحلة:

```text
Complete Ride
      ↓
إضافة الأرباح إلى Wallet
      ↓
إنشاء EARNING Transaction
      ↓
تغيير Ride إلى COMPLETED
      ↓
إرسال Notification
      ↓
Firebase Error
      ↓
تسجيل الخطأ
```

حتى لو فشل إرسال الإشعار، تبقى عملية إكمال الرحلة ناجحة.

---

# 16. ملاحظات مهمة

- يتم استخدام **Firebase Cloud Messaging (FCM)** لإرسال الإشعارات.
    
- يتم تخزين FCM Device Tokens في جدول `DeviceToken`.
    
- يمكن للمستخدم امتلاك أكثر من Device Token عند استخدام أكثر من جهاز.
    
- يتم إرسال الإشعار إلى جميع الأجهزة المرتبطة بالمستخدم.
    
- يتم استخدام `safe_send_notification()` لمنع فشل Firebase من التأثير على العمليات الأساسية.
    
- يتم تمرير `reservation_id` و`ride_id` ضمن `data` عند الحاجة.
    
- يتم تمرير `amount` ضمن `data` في إشعار `payment_received`.
    
- يجب أن تكون قيم `data` المرسلة إلى Firebase من نوع `String`، لذلك يتم تحويل المعرفات والمبالغ باستخدام `str()`.
    
- الإشعارات الحالية مرتبطة مباشرة بالعمليات الموجودة في Backend وليست APIs مستقلة.
    
- لا يوجد في النظام الحالي إشعار باسم `payment_success`.
    
- عند **رفض الحجز** لا يتم تنفيذ Refund في النسخة الحالية.
    
- عند **قبول الحجز** يتم خصم تكلفة الرحلة من Wallet الراكب وإنشاء Transaction من نوع `PAYMENT`.
    
- عند **إكمال الرحلة** يتم حساب أرباح السائق من الحجوزات المدفوعة وإضافتها إلى Wallet السائق، ثم إنشاء Transaction من نوع `EARNING` وإرسال `payment_received`.
    

## الخلاصة

النظام الحالي يحتوي على:

```text
1. Device Registration
       ↓
2. FCM Device Token Storage
       ↓
3. Business Event
       ↓
4. safe_send_notification()
       ↓
5. Firebase Cloud Messaging
       ↓
6. User Device
```

والـ Notification Events المستخدمة فعلياً هي:

```text
new_reservation
reservation_accepted
reservation_rejected
ride_cancelled
payment_received
```