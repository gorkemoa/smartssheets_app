# Smartsheet API Dokümantasyonu (Tam, Türkçe, Detaylı)

Oluşturulma tarihi: 4 Mart 2026

Bu doküman, kod tabanındaki güncel Laravel API davranışına göre hazırlanmıştır. Kaynaklar: `routes/api.php`, `app/Http/Controllers/Api/*`, `app/Http/Requests/Api/*`, `app/Http/Resources/*`, `app/Policies/*`, `app/Http/Middleware/*`.

## 1) Genel Bilgiler

### 1.1 Base URL

- Yerel: `https://smart-sheet.getsmarty.com.tr/api`

### 1.2 Kimlik Doğrulama (Authentication)

- Korunan endpointler Sanctum Bearer Token ile çalışır.
- Header:
  - `Authorization: Bearer <token>`
  - `Accept: application/json`
- JSON body kullanılan isteklerde ayrıca:
  - `Content-Type: application/json`

### 1.3 Public Endpointler (Token Gerektirmez)

- `POST /auth/register`
- `POST /auth/login`
- `POST /invitations/accept`
- `POST /billing/apple/notifications`
- `POST /billing/google/notifications`

### 1.4 Orta Katman (Middleware) Kuralları

#### Brand Context (`resolve.brand`)

`/brands/{brand}` içeren route'larda:

- Kullanıcı login değilse: `401 UNAUTHENTICATED`
- Brand bulunamazsa: `404 BRAND_NOT_FOUND`
- Kullanıcı brand içinde aktif üyelikte değilse: `403 FORBIDDEN`

#### Billing Lock (`brand.unlocked`)

Brand kilitli ise (abonelik/trial durumu):

- Domain endpointleri bloklanır: `403 SUBSCRIPTION_REQUIRED`
- İstisna: `/brands/{brand}/billing/*` endpointleri çalışmaya devam eder.

### 1.5 Rate Limitler

- `POST /auth/login` -> `10/dakika`
- `POST /invitations/accept` -> `10/dakika`
- `POST /brands/{brand}/appointments/{appointment}/results/files` -> `20/dakika`

---

## 2) Standart Yanıt Formatı

### 2.1 Başarılı Yanıt

Sabit bir zorunlu zarf yoktur; endpoint'e göre değişir. En yaygın yapı:

```json
{
  "data": { ... }
}
```

veya:

```json
{
  "message": "..."
}
```

### 2.2 Hata Yanıtı

Tüm API hata yanıtları aynı formatı kullanır:

```json
{
  "message": "Hata açıklaması",
  "code": "HATA_KODU",
  "errors": {
    "alan": ["detay"]
  }
}
```

`errors` alanı her zaman gelmez; özellikle validation ve bazı özel doğrulama hatalarında gelir.

### 2.3 Global Hata Kodları

- `UNAUTHENTICATED` (401)
- `FORBIDDEN` (403)
- `VALIDATION_ERROR` (422)
- `RESOURCE_NOT_FOUND` (404)
- `HTTP_<status>`

---

## 3) Yetki ve Rol Özeti

### 3.1 Roller

- `owner`
- `admin`
- `member`

### 3.2 Üyelik İzinleri (`permissions_json`)

Sistemde kullanılan ana izinler:

- `create_appointment`
- `change_status`
- `upload_result`
- `manage_members`
- `manage_statuses`
- `manage_appointment_fields`

### 3.3 Policy Davranışları

- **Appointment görüntüleme**:
  - Owner/Admin -> görebilir
  - Member -> sadece atandığı appointment'ı görebilir
- **Appointment oluşturma**:
  - `create_appointment` izni gerekir (owner/admin zaten geçer)
- **Appointment güncelleme / atama değişikliği**:
  - Owner/Admin veya `change_status`
- **Result notu/dosya işlemleri**:
  - Owner/Admin veya `upload_result`
- **Status yönetimi**:
  - Owner/Admin
- **Member yönetimi**:
  - Owner/Admin
- **Appointment custom field yönetimi**:
  - Owner/Admin veya `manage_appointment_fields`

---

## 4) Kaynak Modellerinin API Çıktıları

### 4.1 BrandResource

Alanlar:

- `id`
- `name`
- `timezone`
- `trial_starts_at`
- `trial_ends_at`
- `subscription_status`
- `current_plan`
- `member_limit`
- `subscription_expires_at`
- `last_billing_check_at`
- `created_at`
- `updated_at`

### 4.2 MembershipResource

- `id`
- `brand_id`
- `user_id`
- `role`
- `permissions_json`
- `status`
- `user`:
  - `id`, `name`, `email`
- `created_at`, `updated_at`

### 4.3 InvitationResource

- `id`, `brand_id`, `email`, `role`, `permissions_json`
- `expires_at`, `accepted_at`, `created_at`

### 4.4 AppointmentStatusResource

- `id`, `brand_id`, `name`, `color`
- `sort_order`, `is_default`, `is_active`, `status_type`

### 4.5 AppointmentCustomFieldResource

- `id`, `brand_id`
- `key` (brand içinde unique slug)
- `label`
- `type` (`text|textarea|number|date|select|radio|checkbox`)
- `required`
- `is_active`
- `sort_order`
- `options_json`
- `help_text`
- `validations_json`
- `created_by_membership_id`
- `created_at`, `updated_at`

### 4.6 AppointmentResource

- `id`, `brand_id`, `title`, `starts_at`, `ends_at`
- `status`: `{ id, name, status_type, color }`
- `notes`, `result_notes`, `completed_at`
- `custom_fields`: key-value map
- `assignees`: `[ { membership_id, user_id, name, email } ]`
- `created_at`, `updated_at`

### 4.7 AppointmentResultFileResource

- `id`, `brand_id`, `appointment_id`
- `original_name`, `mime`, `size_bytes`, `sha256`
- `created_at`

---

## 5) Endpoint Referansı

## 5.1 Auth

### 5.1.1 Register

- **Method/URL**: `POST /auth/register`
- **Auth**: Public
- **Amaç**: Yeni kullanıcı oluşturur, token döner.

#### Body

- `name` (zorunlu, string, max:120)
- `email` (zorunlu, email, unique)
- `phone` (zorunlu, string, unique)
- `password` (zorunlu, min:8)
- `password_confirmation` (zorunlu, password ile aynı)

#### Örnek Request

```json
{
  "name": "API User",
  "email": "api.user@demo.local",
  "phone": "+905550000010",
  "password": "password123",
  "password_confirmation": "password123"
}
```

#### Başarılı Yanıt (201)

```json
{
  "token": "1|...",
  "user": {
    "id": 12,
    "name": "API User",
    "email": "api.user@demo.local",
    "phone": "+905550000010"
  }
}
```

#### Olası Hatalar

- `VALIDATION_ERROR` (422)

---

### 5.1.2 Login

- **Method/URL**: `POST /auth/login`
- **Auth**: Public
- **Amaç**: Kullanıcı girişi yapar, access token döner.

#### Body

- `email` (zorunlu)
- `password` (zorunlu)
- `device_name` (opsiyonel)

#### Örnek Request

```json
{
  "email": "owner@demo.local",
  "password": "password",
  "device_name": "postman"
}
```

#### Başarılı Yanıt (200)

```json
{
  "token": "2|...",
  "user": {
    "id": 1,
    "name": "Owner",
    "email": "owner@demo.local",
    "phone": "+90555..."
  }
}
```

#### Olası Hatalar

- `INVALID_CREDENTIALS` (422)
- `VALIDATION_ERROR` (422)

---

### 5.1.3 Logout

- **Method/URL**: `POST /auth/logout`
- **Auth**: Bearer
- **Amaç**: O anki token'ı iptal eder.

#### Başarılı Yanıt (200)

```json
{
  "message": "Logged out"
}
```

---

### 5.1.4 Me

- **Method/URL**: `GET /auth/me`
- **Auth**: Bearer
- **Amaç**: Oturumdaki kullanıcı ve üyeliklerini döner.

#### Başarılı Yanıt (200)

```json
{
  "user": {
    "id": 1,
    "name": "Owner",
    "email": "owner@demo.local",
    "memberships": [
      {
        "id": 1,
        "brand_id": 1,
        "role": "owner",
        "brand": {
          "id": 1,
          "name": "Demo Brand"
        }
      }
    ]
  }
}
```

---

## 5.2 Public Davet ve Billing Webhook

### 5.2.1 Accept Invitation

- **Method/URL**: `POST /invitations/accept`
- **Auth**: Public
- **Amaç**: Davet token'ı ile üyeliği tamamlar, kullanıcıya token döner.

#### Body

- `token` (zorunlu)
- `name` (zorunlu, max:120)
- `phone` (zorunlu, max:30)
- `password` (zorunlu, min:8)
- `password_confirmation` (zorunlu)

#### Başarılı Yanıt (200)

```json
{
  "token": "3|...",
  "membership_id": 45,
  "brand_id": 1
}
```

#### Özel Hatalar

- `INVITATION_INVALID` (422)
- `MEMBER_LIMIT_REACHED` (422)
- `PHONE_ALREADY_USED` (422)
- `PHONE_MISMATCH` (422)

---

### 5.2.2 Apple Notifications

- **Method/URL**: `POST /billing/apple/notifications`
- **Auth**: Public
- **Amaç**: Apple billing event'i kabul eder, asenkron işlem kuyruğa alınır.

#### Başarılı Yanıt (202)

```json
{
  "message": "accepted"
}
```

---

### 5.2.3 Google Notifications

- **Method/URL**: `POST /billing/google/notifications`
- **Auth**: Public
- **Amaç**: Google billing event'i kabul eder, asenkron işlem kuyruğa alınır.

#### Başarılı Yanıt (202)

```json
{
  "message": "accepted"
}
```

---

## 5.3 Device Tokens

### 5.3.1 Register/Update Token

- **Method/URL**: `POST /device-tokens`
- **Auth**: Bearer
- **Amaç**: FCM token kaydı yapar veya var olanı günceller.

#### Body

- `platform` (zorunlu: `ios|android`)
- `fcm_token` (zorunlu)
- `app_version` (opsiyonel)
- `brand_id` (opsiyonel, mevcut brand)

#### Başarılı Yanıt (201)

```json
{
  "data": {
    "id": 10,
    "user_id": 1,
    "brand_id": 1,
    "platform": "ios",
    "fcm_token": "...",
    "is_active": true,
    "last_seen_at": "2026-03-04T..."
  }
}
```

---

### 5.3.2 Delete Token

- **Method/URL**: `DELETE /device-tokens/{token}`
- **Auth**: Bearer
- **Amaç**: Token'ı pasife alır (`is_active=false`).

#### Başarılı Yanıt (200)

```json
{
  "message": "Token deactivated"
}
```

#### Hata

- `FORBIDDEN` (403) -> token başka kullanıcıya aitse

---

## 5.4 Brand

### 5.4.1 List Brands

- **Method/URL**: `GET /brands`
- **Auth**: Bearer
- **Amaç**: Kullanıcının aktif üyeliği olan brand'leri listeler.

#### Başarılı Yanıt (200)

```json
{
  "data": [
    {
      "id": 1,
      "name": "Demo Brand",
      "timezone": "Europe/Istanbul",
      "subscription_status": "none"
    }
  ]
}
```

---

### 5.4.2 Create Brand

- **Method/URL**: `POST /brands`
- **Auth**: Bearer
- **Amaç**: Yeni brand açar; owner membership ve default status'leri otomatik oluşturur.

#### Body

- `name` (zorunlu)
- `timezone` (opsiyonel)

#### Başarılı Yanıt (201)

```json
{
  "data": {
    "id": 5,
    "name": "Yeni Brand",
    "timezone": "Europe/Istanbul",
    "member_limit": 10
  }
}
```

#### Özel Hata

- `BRAND_LIMIT_REACHED` (422) -> kullanıcı ikinci brand'i owner olarak açmaya çalışırsa

---

### 5.4.3 Show Brand

- **Method/URL**: `GET /brands/{brand}`
- **Auth**: Bearer + brand erişimi
- **Amaç**: Brand detayını döner.

### 5.4.4 Update Brand

- **Method/URL**: `PATCH /brands/{brand}`
- **Auth**: Bearer + owner/admin
- **Amaç**: Brand ad/zaman dilimi günceller.
- **Body**: `name`, `timezone` (ikisi de opsiyonel)

---

## 5.5 Billing (Brand Altı)

### 5.5.1 Plans

- **Method/URL**: `GET /brands/{brand}/billing/plans`
- **Auth**: Bearer + brand üyelik
- **Amaç**: Desteklenen planları döner.

### 5.5.2 Status

- **Method/URL**: `GET /brands/{brand}/billing/status`
- **Auth**: Bearer
- **Amaç**: Abonelik/trial/lock bilgisini döner.

#### Başarılı Yanıt (200)

```json
{
  "status": "none",
  "plan": "basic",
  "trial_ends_at": "2026-03-10T...",
  "expires_at": null,
  "locked": false
}
```

### 5.5.3 Verify

- **Method/URL**: `POST /brands/{brand}/billing/verify`
- **Auth**: Bearer
- **Amaç**: IAP doğrulama sonucu aboneliği aktive/günceller.

#### Body

- `provider` (`apple|google`)
- `product_id`
- `receipt_or_token`
- `transaction_id` (opsiyonel)
- `metadata` (opsiyonel)

#### Başarılı Yanıt (200)

```json
{
  "status": "active",
  "expires_at": "2026-04-30T23:59:59+03:00",
  "plan": "basic"
}
```

#### Hata

- `BILLING_VERIFY_FAILED` (422)

### 5.5.4 Restore

- **Method/URL**: `POST /brands/{brand}/billing/restore`
- **Auth**: Bearer
- **Amaç**: Verify ile aynı kurallarda restore akışı.

---

## 5.6 Members

### 5.6.1 List Members

- **Method/URL**: `GET /brands/{brand}/members`
- **Auth**: Bearer + `manage-members`
- **Amaç**: Üyeleri listeler.

### 5.6.2 Create Member

- **Method/URL**: `POST /brands/{brand}/members`
- **Auth**: Bearer + `manage-members`
- **Amaç**: Yeni kullanıcı + üyelik oluşturur veya mevcut kullanıcıyı üyeliğe bağlar.

#### Body

- `email` (zorunlu)
- `phone` (zorunlu)
- `name` (opsiyonel)
- `password` (opsiyonel)
- `role` (`admin|member`)
- `permissions_json` (opsiyonel)
- `status` (`active|inactive`, opsiyonel)

#### Başarılı Yanıt (201)

```json
{
  "data": {
    "id": 9,
    "brand_id": 1,
    "role": "member",
    "permissions_json": {
      "create_appointment": true,
      "upload_result": false,
      "change_status": false
    },
    "status": "active",
    "user": {
      "id": 21,
      "name": "Yeni Uye",
      "email": "uye@demo.local"
    }
  }
}
```

#### Özel Hatalar

- `MEMBER_LIMIT_REACHED` (422)
- `PHONE_ALREADY_USED` (422)
- `PHONE_MISMATCH` (422)

### 5.6.3 Update Member

- **Method/URL**: `PATCH /brands/{brand}/members/{membership}`
- **Auth**: Bearer + `manage-members`
- **Body**: `role`, `permissions_json`, `status`
- **Hatalar**:
  - `MEMBER_NOT_FOUND` (404)
  - `OWNER_IMMUTABLE` (422)

### 5.6.4 Delete Member

- **Method/URL**: `DELETE /brands/{brand}/members/{membership}`
- **Auth**: Bearer + `manage-members`
- **Hatalar**:
  - `MEMBER_NOT_FOUND` (404)
  - `OWNER_IMMUTABLE` (422)

---

## 5.7 Invitations (Brand Altı)

### 5.7.1 List Invitations

- **Method/URL**: `GET /brands/{brand}/invitations`
- **Auth**: Bearer + `manage-members`

### 5.7.2 Create Invitation

- **Method/URL**: `POST /brands/{brand}/invitations`
- **Auth**: Bearer + `manage-members`
- **Body**:
  - `email` (zorunlu)
  - `role` (`admin|member`)
  - `permissions_json` (opsiyonel)
  - `expires_at` (opsiyonel, gelecekte olmalı)

#### Başarılı Yanıt (201)

```json
{
  "data": {
    "id": 7,
    "email": "invitee@demo.local",
    "role": "member",
    "expires_at": "2026-03-11T..."
  },
  "invite_token": "plain_invite_token"
}
```

### 5.7.3 Resend Invitation

- **Method/URL**: `POST /brands/{brand}/invitations/{inv}/resend`
- **Auth**: Bearer + `manage-members`
- **Başarılı Yanıt**: `data + invite_token`
- **Hata**: `INVITATION_NOT_FOUND` (404)

### 5.7.4 Delete Invitation

- **Method/URL**: `DELETE /brands/{brand}/invitations/{inv}`
- **Auth**: Bearer + `manage-members`
- **Hata**: `INVITATION_NOT_FOUND` (404)

---

## 5.8 Appointment Statuses

### 5.8.1 List Statuses

- **Method/URL**: `GET /brands/{brand}/statuses`
- **Auth**: Bearer + brand üyelik

### 5.8.2 Create Status

- **Method/URL**: `POST /brands/{brand}/statuses`
- **Auth**: Bearer + `manage-statuses`
- **Body**:
  - `name` (zorunlu)
  - `color` (opsiyonel)
  - `sort_order` (opsiyonel)
  - `is_default` (opsiyonel)
  - `is_active` (opsiyonel)
  - `status_type` (`active|invalid|neutral`, opsiyonel)
- **Özel Hata**: `STATUS_LIMIT_REACHED` (422), max 8 status

### 5.8.3 Update Status

- **Method/URL**: `PATCH /brands/{brand}/statuses/{status}`
- **Auth**: Bearer + `manage-statuses`
- **Hata**: `STATUS_NOT_FOUND` (404)

### 5.8.4 Delete Status

- **Method/URL**: `DELETE /brands/{brand}/statuses/{status}`
- **Auth**: Bearer + `manage-statuses`
- **Hatalar**:
  - `STATUS_NOT_FOUND` (404)
  - `STATUS_IN_USE` (422)

---

## 5.9 Appointment Custom Fields (Dinamik Randevu Alanları)

### 5.9.1 List Active Fields

- **Method/URL**: `GET /brands/{brand}/settings/appointment-fields`
- **Auth**: Bearer + `manage-appointment-fields`
- **Amaç**: Aktif field tanımlarını `sort_order` sırasıyla getirir.

### 5.9.2 Create Field

- **Method/URL**: `POST /brands/{brand}/settings/appointment-fields`
- **Auth**: Bearer + `manage-appointment-fields`

#### Body

- `key` (zorunlu, brand içinde unique, regex: `^[a-z][a-z0-9_]*$`)
- `label` (zorunlu)
- `type` (zorunlu):
  - `text`, `textarea`, `number`, `date`, `select`, `radio`, `checkbox`
- `required` (opsiyonel, bool)
- `is_active` (opsiyonel, bool)
- `sort_order` (opsiyonel, int)
- `options_json` (opsiyonel, select/radio/checkbox için zorunlu)
- `help_text` (opsiyonel)
- `validations_json` (opsiyonel)
  - `min`, `max`, `max_length`, `regex`

#### options_json örneği

```json
[
  { "value": "consultation", "label": "Konsultasyon" },
  { "value": "followup", "label": "Kontrol" }
]
```

### 5.9.3 Update Field

- **Method/URL**: `PATCH /brands/{brand}/settings/appointment-fields/{field}`
- **Auth**: Bearer + `manage-appointment-fields`
- **Amaç**: label/type/options/required/is_active/sort_order vb. günceller.
- **Hata**: `APPOINTMENT_FIELD_NOT_FOUND` (404)

### 5.9.4 Deactivate Field

- **Method/URL**: `DELETE /brands/{brand}/settings/appointment-fields/{field}`
- **Auth**: Bearer + `manage-appointment-fields`
- **Amaç**: Hard delete değil, `is_active=false` yapar.
- **Hata**: `APPOINTMENT_FIELD_NOT_FOUND` (404)

---

## 5.10 Calendar ve Appointments

### 5.10.1 Calendar

- **Method/URL**: `GET /brands/{brand}/calendar`
- **Auth**: Bearer + brand üyelik

#### Query

- `from` (zorunlu, tarih)
- `to` (zorunlu, tarih, `to >= from`)

#### Başarılı Yanıt

```json
{
  "data": [
    {
      "id": 100,
      "title": "Kontrol Randevusu",
      "custom_fields": {
        "price": 1200.5,
        "service_type": "consultation"
      }
    }
  ]
}
```

Not: Member sadece atandığı kayıtları görür.

---

### 5.10.2 Appointment Detail

- **Method/URL**: `GET /brands/{brand}/appointments/{appointment}`
- **Auth**: Bearer
- **Hatalar**:
  - `APPOINTMENT_NOT_FOUND` (404)
  - `FORBIDDEN` (403) (atamasız member)

---

### 5.10.3 Create Appointment

- **Method/URL**: `POST /brands/{brand}/appointments`
- **Auth**: Bearer
- **Yetki**: `create_appointment` (owner/admin her zaman geçer)

#### Body

- `title` (zorunlu, string, max 190)
- `starts_at` (zorunlu, date/datetime)
- `ends_at` (opsiyonel, `>= starts_at`)
- `status_id` (zorunlu, mevcut status ve aynı brand)
- `notes` (opsiyonel)
- `assignment_membership_ids` (zorunlu array, min 1)
- `custom_fields` (opsiyonel object)

#### custom_fields örnek

```json
{
  "price": 1200.50,
  "service_type": "consultation",
  "needs_invoice": ["yes"]
}
```

#### Başarılı Yanıt (201)

```json
{
  "data": {
    "id": 321,
    "title": "Muayene",
    "status": {
      "id": 1,
      "name": "Planned",
      "status_type": "neutral",
      "color": "#2563eb"
    },
    "custom_fields": {
      "price": 1200.5,
      "service_type": "consultation",
      "needs_invoice": ["yes"]
    }
  }
}
```

#### Özel Hatalar

- `FORBIDDEN` (403)
- `INVALID_STATUS` (422)
- `INVALID_CUSTOM_FIELD` (422)
- `CUSTOM_FIELD_TYPE_MISMATCH` (422)
- `CUSTOM_FIELD_REQUIRED` (422)

---

### 5.10.4 Update Appointment

- **Method/URL**: `PATCH /brands/{brand}/appointments/{appointment}`
- **Auth**: Bearer
- **Yetki**: owner/admin veya `change_status`
- **Body** (tamamı opsiyonel):
  - `title`, `starts_at`, `ends_at`, `status_id`, `notes`, `completed_at`
  - `assignment_membership_ids`
  - `custom_fields`

#### Örnek Body

```json
{
  "notes": "Randevu güncellendi",
  "custom_fields": {
    "price": 1500,
    "needs_invoice": ["yes", "e_archive"]
  }
}
```

#### Hatalar

- `APPOINTMENT_NOT_FOUND` (404)
- `FORBIDDEN` (403)
- `INVALID_STATUS` (422)
- `INVALID_CUSTOM_FIELD` (422)
- `CUSTOM_FIELD_TYPE_MISMATCH` (422)
- `CUSTOM_FIELD_REQUIRED` (422)

---

### 5.10.5 Delete Appointment

- **Method/URL**: `DELETE /brands/{brand}/appointments/{appointment}`
- **Auth**: Bearer
- **Yetki**: sadece owner/admin
- **Başarılı**: `{ "message": "Appointment deleted" }`

---

### 5.10.6 Set Assignments

- **Method/URL**: `POST /brands/{brand}/appointments/{appointment}/assignments`
- **Auth**: Bearer
- **Yetki**: appointment update ile aynı

#### Body

- `assignment_membership_ids` (zorunlu array, min 1)

#### Başarılı Yanıt

- Güncel `AppointmentResource` döner.

---

## 5.11 Result Notları ve Dosyaları

### 5.11.1 Set Result Notes

- **Method/URL**: `POST /brands/{brand}/appointments/{appointment}/results/notes`
- **Auth**: Bearer
- **Yetki**: owner/admin veya `upload_result`

#### Body

- `result_notes` (nullable string)

#### Başarılı Yanıt

- Güncel `AppointmentResource` döner.

---

### 5.11.2 Upload Result Files

- **Method/URL**: `POST /brands/{brand}/appointments/{appointment}/results/files`
- **Auth**: Bearer
- **Yetki**: owner/admin veya `upload_result`
- **Content-Type**: `multipart/form-data`

#### Body (form-data)

- `files[]` (zorunlu)
  - min 1 dosya
  - max 10 dosya
  - dosya başına max 10MB (`max:10240` KB)

#### Başarılı Yanıt (201)

```json
{
  "data": [
    {
      "id": 55,
      "appointment_id": 321,
      "original_name": "rapor.pdf",
      "mime": "application/pdf",
      "size_bytes": 94812,
      "sha256": "..."
    }
  ]
}
```

---

### 5.11.3 List Result Files

- **Method/URL**: `GET /brands/{brand}/appointments/{appointment}/results/files`
- **Auth**: Bearer
- **Yetki**: appointment view yetkisi

### 5.11.4 Download Result File

- **Method/URL**: `GET /brands/{brand}/results/files/{file}/download`
- **Auth**: Bearer
- **Yetki**: appointment view yetkisi

#### Yanıt

- Bazı disk sürücülerinde:
  - JSON: `{ "url": "temporary-url" }`
- Aksi halde:
  - Dosya binary stream olarak iner.

#### Hatalar

- `FILE_NOT_FOUND` (404)
- `FORBIDDEN` (403)

### 5.11.5 Delete Result File

- **Method/URL**: `DELETE /brands/{brand}/appointments/{appointment}/results/files/{file}`
- **Auth**: Bearer
- **Yetki**: owner/admin veya `upload_result`
- **Başarılı**: `{ "message": "File deleted" }`

---

## 5.12 Stats

### 5.12.1 Summary

- **Method/URL**: `GET /brands/{brand}/stats/summary`
- **Auth**: Bearer
- **Amaç**: Genel özet metrikleri döner.

#### Başarılı Yanıt (200)

```json
{
  "total_appointments": 120,
  "this_month_created": 14,
  "by_status": [
    { "status_id": 1, "name": "Planned", "count": 8 },
    { "status_id": 2, "name": "Completed", "count": 5 }
  ],
  "active_count": 5,
  "invalid_count": 2,
  "upcoming_7_days": 11
}
```

### 5.12.2 Monthly

- **Method/URL**: `GET /brands/{brand}/stats/monthly?months=12`
- **Auth**: Bearer

#### Query

- `months` (opsiyonel, min 1 max 36, default 12)

#### Başarılı Yanıt

```json
{
  "data": [
    { "month": "2025-12", "count": 3 },
    { "month": "2026-01", "count": 7 },
    { "month": "2026-02", "count": 9 }
  ]
}
```

---

## 6) Custom Fields Tip ve Doğrulama Detayları

Appointment create/update sırasında `custom_fields` doğrulama kuralları:

### 6.1 text / textarea

- Gelen değer string olmalı.
- Kayıt kolonu: `value_text`
- `validations_json.max_length` ve `validations_json.regex` uygulanır.

### 6.2 number

- Numeric olmalı.
- Kayıt kolonu: `value_number` (`decimal(12,2)`)
- `validations_json.min` / `max` uygulanır.

### 6.3 date

- Format: `YYYY-MM-DD`
- Kayıt kolonu: `value_date`

### 6.4 select / radio

- Scalar değer olmalı.
- Değer `options_json[].value` içinde bulunmalı.
- Kayıt kolonu: `value_text`

### 6.5 checkbox

- Array olmalı.
- Her eleman `options_json[].value` içinde olmalı.
- Kayıt kolonu: `value_json` (array)

### 6.6 Hata Kodları

- Tanımsız veya pasif key: `INVALID_CUSTOM_FIELD`
- Tip veya seçenek uyumsuzluğu: `CUSTOM_FIELD_TYPE_MISMATCH`
- `required=true` field boş/eksik: `CUSTOM_FIELD_REQUIRED`

---

## 7) Sık Kullanılan Özel Hata Kodları Sözlüğü

- `INVALID_CREDENTIALS`
- `BRAND_LIMIT_REACHED`
- `MEMBER_LIMIT_REACHED`
- `PHONE_ALREADY_USED`
- `PHONE_MISMATCH`
- `OWNER_IMMUTABLE`
- `INVITATION_INVALID`
- `INVITATION_NOT_FOUND`
- `STATUS_LIMIT_REACHED`
- `STATUS_NOT_FOUND`
- `STATUS_IN_USE`
- `INVALID_STATUS`
- `APPOINTMENT_NOT_FOUND`
- `FILE_NOT_FOUND`
- `APPOINTMENT_FIELD_NOT_FOUND`
- `INVALID_CUSTOM_FIELD`
- `CUSTOM_FIELD_TYPE_MISMATCH`
- `CUSTOM_FIELD_REQUIRED`
- `SUBSCRIPTION_REQUIRED`

---

## 8) Önerilen Uçtan Uca Test Sırası

1. `POST /auth/login`
2. `GET /brands`
3. `GET /brands/{brand}/statuses`
4. `POST /brands/{brand}/settings/appointment-fields` (field tanımları)
5. `POST /brands/{brand}/appointments` (`custom_fields` ile)
6. `GET /brands/{brand}/appointments/{appointment}`
7. `POST /brands/{brand}/appointments/{appointment}/results/notes`
8. `POST /brands/{brand}/appointments/{appointment}/results/files`
9. `GET /brands/{brand}/stats/summary`
10. `GET /brands/{brand}/billing/status`

---

## 9) Notlar

- Tüm brand domain endpointleri tenant izolasyonu içerir.
- Member görünürlüğü appointment seviyesinde assignment'a bağlıdır.
- Appointment custom field tanımları brand metadata tablosunda tutulur.
- Field deaktif edilse bile geçmiş appointment custom value kayıtları korunur.
- Audit log kayıtları appointment ve custom field olaylarında yazılır.

