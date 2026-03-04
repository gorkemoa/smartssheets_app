ZORUNLU KURAL — DİL DESTEĞİ (EN ÖNCELİKLİ)

0. ÇOK DİLLİ DESTEK (ZORUNLU)

Uygulama iki dili destekler: Türkçe ve İngilizce.

Cihaz dili Türkçe → uygulama Türkçe görünür.
Cihaz dili diğer tüm diller → uygulama İngilizce görünür.

Desteklenen lokaller:
  tr  — Türkçe (varsayılan)
  en  — İngilizce (fallback)

---

0.1 Metin yönetimi kuralları

View içinde hardcoded Türkçe veya İngilizce metin YASAK.
Tüm kullanıcıya gösterilen metinler strings.dart dosyasından gelir.

Tek çeviri dosyası:
  lib/l10n/strings.dart

Her anahtar iki dili yan yana tutar:
  'loginTitle': {'tr': 'Hoş Geldiniz', 'en': 'Welcome'},

---

0.2 Kullanım standartları

View: AppStrings.of(context) ile metin çeker.
Validator: Lokalize hata mesajları parametre olarak alır.
Service / ViewModel: Dilden bağımsız çalışır, AppStrings bilmez.
Yeni metin eklenirken önce strings.dart'a her iki dil eklenir, sonra View'de kullanılır.

---

0.3 Teknik altyapı

flutter_localizations: Cihaz locale tespiti için Flutter SDK paketi.
AppStrings.of(context): Locale'e göre TR veya EN string döndürür.
Kod üretimi (gen-l10n) YOKTUR — elle yönetilen tek dosya yeterlidir.

---

DEĞİŞTİRİLEMEZ KURALLAR (TARTIŞMASIZ)

1.1 Statik veri kesinlikle YASAK

Dummy / mock / hardcoded veri yok

Local JSON yok

“Şimdilik böyle gösterelim” yok

UI’da sahte metin / sayı / flag yok

Her şey API’dan gelir.

API eksikse AI SORAR.

---

1.2 API Response eksiksiz kullanılacak

Backend’in döndürdüğü alanlar:

data  
meta  
pagination  
status  
message  
errors  

vb.

alanların tamamı modele karşılık gelmek zorundadır.

“Lazım değil” denilerek atlanamaz.

---

1.3 Kurumsal disiplin

AI:

Feature ekleyemez

Field uyduramaz

Backend’de yokken UI state alanı üretip veri varmış gibi gösteremez

Onaysız refactor veya yeniden mimari öneremez

Emin değilse: SOR.

---

ZORUNLU MİMARİ

Bu proje sadece şu mimaride ilerler:

Models → Views → ViewModels → Services → Core

Başka mimari önerilemez:

Clean architecture

Bloc-first

Redux

MVC

vb.

---

ZORUNLU KLASÖR YAPISI

lib/

app/
app_constants.dart
api_constants.dart
app_theme.dart

core/

network/
api_client.dart
api_result.dart
api_exception.dart

responsive/
size_config.dart
size_tokens.dart

utils/
logger.dart
validators.dart

models/

services/

viewmodels/

views/

home/
home_view.dart

widgets/

job_detail/
job_detail_view.dart

widgets/

profile/
profile_view.dart

widgets/

---

GLOBAL WIDGETS KLASÖRÜ YASAK

Aşağıdakiler kesinlikle OLMAZ:

core/widgets/

common/widgets/

shared/widgets/

Her ekranın widgetları kendi klasöründe bulunur:

views/<screen>/widgets/

---

RESPONSIVE / ÖLÇÜ SİSTEMİ (ZORUNLU)

4.1 Sabit pixel kullanmak YASAK

Aşağıdaki kullanımlar View içinde yazılamaz:

padding: 16

fontSize: 14

height: 52

radius: 12

Bu tarz sabit değerler yasaktır.

---

4.2 Token bazlı ölçü sistemi

Tüm boyutlar şu dosyalardan alınır:

core/responsive/size_config.dart

core/responsive/size_tokens.dart

Padding  
Margin  
Radius  
Font size  
Icon size  
Container ölçüleri  

Sadece token kullanır.

---

4.3 Theme yönetimi

Renk  
Tipografi  
Spacing  

Sadece şu dosyalardan yönetilir:

app/app_theme.dart

core/responsive/size_tokens.dart

View içinde inline stil minimum.

---

4.4 Büyük ekran koruması (ZORUNLU)

iPhone Pro Max  
Tablet  
Büyük Android cihazlarda UI büyümesini engellemek için:

Scaling Cap uygulanır.

size_config.dart içinde hesaplama:

iPhone 13 referansı

Width: 390  
Height: 844

Bu sınırın üstünde UI büyümez.

---

Font Scaling Protection

main.dart içinde zorunlu ayar:

MediaQuery(
textScaler: TextScaler.noScaling
)

Bu sayede sistem font scaling UI bozmaz.

---

MVVM AKIŞI

View → ViewModel → Service → ApiClient → HTTP

---

5.1 View

View sadece UI render eder.

ViewModel state dinler.

Event çağırır.

View içinde aşağıdakiler YASAK:

API çağrısı

JSON parse

Business logic

---

5.2 ViewModel

Her ViewModel sadece bir ekrana hizmet eder.

Mega ViewModel YASAK.

Standart state:

bool isLoading

String? errorMessage

T? data veya List<T>

Pagination varsa:

page

hasMore

isLoadingMore

---

Zorunlu metodlar:

init()

refresh()

loadMore()

onRetry()

---

5.3 Service

Service görevleri:

Endpoint'e gider

Response'u model'e map eder

ViewModel'e model döndürür

Service içinde:

Endpoint string yazmak YASAK

ApiConstants kullanılmak zorundadır.

Ham HTTP response döndürmek YASAK.

---

5.4 Model

Her model:

fromJson(Map<String, dynamic>)

toJson()

Unused alanlar bile modelde bulunur.

Nullable olabilir.

Silinmez.

---

UI state alanları modele yazılmaz.

Örnek:

isSelected

isExpanded

Bunlar ViewModel state'idir.

---

API STANDARTLARI

6.1 Authorization header zorunlu

Tüm isteklerde:

Accept: application/json

Bu header olmadan istek atılamaz.

---

6.2 Endpoint yönetimi

Service veya ViewModel içinde endpoint string yazmak YASAK.

Örnek:

"/v1/jobs"

YASAK.

Tüm endpointler:

app/api_constants.dart

---

NETWORK STANDARDI

7.1 ApiClient

ApiClient şu işleri tek yerden yönetir:

baseUrl

ortak header

timeout

error handling

logging

---

7.2 ApiResult

Service dönüş tipi:

Success(data)

Failure(error)

---

7.3 ApiException

Hata tipleri normalize edilir:

network

timeout

401

403

404

500

parse error

ViewModel içinde:

statusCode == ... kontrolü YASAK.

---

LOGLAMA STANDARTI

Tüm API istekleri ve cevapları loglanmalıdır.

Logger dosyası:

core/utils/logger.dart

Print kullanımı kesinlikle YASAK.

Log seviyeleri:

INFO

ERROR

WARNING

DEBUG

REQUEST

RESPONSE

---

WIDGET TEKRAR KULLANIM KURALI

Bir widget 2 veya daha fazla ekranda kullanılacaksa:

AI önce sorar.

Onay alınırsa ortak alana taşınır.

Ortak klasör:

core/ui_components/

Onaysız ortak widget oluşturmak YASAK.

---

DOSYA İSİMLENDİRME

Dosyalar:

snake_case.dart

Sınıflar:

PascalCase

Örnek:

home_view.dart

home_view_model.dart

job_service.dart

job_detail_response.dart

---

TASARIM REFERANSI

Uygulama tasarım dili:

dryfix.com.tr

Renk

Tipografi

Spacing

Sadece:

AppTheme

SizeTokens

üzerinden yönetilir.

Keyfi UI/UX kararı YASAK.

---

AI İÇİN SON TALİMAT

AI:

Bu dokümana %100 uyar

Statik veri kullanmaz

Kafasına göre alan üretmez

Feature eklemez

Widgetları sadece ilgili ekran klasörüne koyar

Endpoint string yazmaz

Sadece ApiConstants kullanır

API response alanlarını eksiksiz modeller

Emin olmadığı her noktada SORAR.
