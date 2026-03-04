import 'package:flutter/widgets.dart';

/// Tek dosyada tüm çeviriler.
/// Her anahtar için: {'tr': '...', 'en': '...'}
/// Yeni metin eklemek için sadece _data map'ine satır eklenir.
class AppStrings {
  final String _lang;

  const AppStrings._(this._lang);

  static AppStrings of(BuildContext context) {
    final code = Localizations.localeOf(context).languageCode;
    return AppStrings._(code == 'tr' ? 'tr' : 'en');
  }

  String _t(String key) => _data[key]?[_lang] ?? _data[key]?['en'] ?? key;

  String _tp(String key, Map<String, String> args) {
    var s = _t(key);
    args.forEach((k, v) => s = s.replaceAll('{$k}', v));
    return s;
  }

  // ─── Onboarding ────────────────────────────────────────────────────────────
  String get onboardingSplashTitle => _t('onboardingSplashTitle');
  String get onboardingPage2Text => _t('onboardingPage2Text');
  String get onboardingPage3Text => _t('onboardingPage3Text');
  String get onboardingBtnExplore => _t('onboardingBtnExplore');
  String get onboardingBtnContinue => _t('onboardingBtnContinue');
  String get onboardingBtnGetStarted => _t('onboardingBtnGetStarted');

  // ─── Login ─────────────────────────────────────────────────────────────────
  String get loginTitle => _t('loginTitle');
  String get loginSubtitle => _t('loginSubtitle');
  String get loginEmailLabel => _t('loginEmailLabel');
  String get loginEmailHint => _t('loginEmailHint');
  String get loginPasswordLabel => _t('loginPasswordLabel');
  String get loginPasswordHint => _t('loginPasswordHint');
  String get loginButton => _t('loginButton');
  String get loginNoAccount => _t('loginNoAccount');
  String get loginSignUp => _t('loginSignUp');
  String loginWelcomeBack(String name) =>
      _tp('loginWelcomeBack', {'name': name});

  // ─── Register ──────────────────────────────────────────────────────────────
  String get registerTitle => _t('registerTitle');
  String get registerSubtitle => _t('registerSubtitle');
  String get registerNameLabel => _t('registerNameLabel');
  String get registerNameHint => _t('registerNameHint');
  String get registerEmailLabel => _t('registerEmailLabel');
  String get registerEmailHint => _t('registerEmailHint');
  String get registerPhoneLabel => _t('registerPhoneLabel');
  String get registerPhoneHint => _t('registerPhoneHint');
  String get registerPasswordLabel => _t('registerPasswordLabel');
  String get registerPasswordHint => _t('registerPasswordHint');
  String get registerPasswordConfirmLabel => _t('registerPasswordConfirmLabel');
  String get registerPasswordConfirmHint => _t('registerPasswordConfirmHint');
  String get registerButton => _t('registerButton');
  String get registerHasAccount => _t('registerHasAccount');
  String get registerSignIn => _t('registerSignIn');
  String registerWelcome(String name) => _tp('registerWelcome', {'name': name});

  // ─── Validators ────────────────────────────────────────────────────────────
  String get validatorEmailEmpty => _t('validatorEmailEmpty');
  String get validatorEmailInvalid => _t('validatorEmailInvalid');
  String get validatorPasswordEmpty => _t('validatorPasswordEmpty');
  String get validatorPasswordTooShort => _t('validatorPasswordTooShort');
  String get validatorPasswordConfirmEmpty =>
      _t('validatorPasswordConfirmEmpty');
  String get validatorPasswordMismatch => _t('validatorPasswordMismatch');
  String get validatorNameEmpty => _t('validatorNameEmpty');
  String get validatorNameTooShort => _t('validatorNameTooShort');
  String get validatorPhoneEmpty => _t('validatorPhoneEmpty');
  String get validatorPhoneInvalid => _t('validatorPhoneInvalid');

  // ─── Home ──────────────────────────────────────────────────────────────────
  String homeGreeting(String name) => _tp('homeGreeting', {'name': name});
  String get homeBrandTitle => _t('homeBrandTitle');
  String get homePlanLabel => _t('homePlanLabel');
  String get homeSubscriptionStatusLabel => _t('homeSubscriptionStatusLabel');
  String get homeSubscriptionActive => _t('homeSubscriptionActive');
  String get homeSubscriptionInactive => _t('homeSubscriptionInactive');
  String get homeSubscriptionExpires => _t('homeSubscriptionExpires');
  String get homeMemberLimitLabel => _t('homeMemberLimitLabel');
  String get homeRoleLabel => _t('homeRoleLabel');
  String get homePermissionsTitle => _t('homePermissionsTitle');
  String get homeLogout => _t('homeLogout');
  String get homeRetry => _t('homeRetry');
  String get homeTimezoneLabel => _t('homeTimezoneLabel');
  String get homePermCreateAppointment => _t('homePermCreateAppointment');
  String get homePermUploadResult => _t('homePermUploadResult');
  String get homePermChangeStatus => _t('homePermChangeStatus');
  String get homePermManageMembers => _t('homePermManageMembers');
  String get homePermManageStatuses => _t('homePermManageStatuses');
  String get homePermManageAppointmentFields =>
      _t('homePermManageAppointmentFields');
  String get homeMembershipsTitle => _t('homeMembershipsTitle');
  String get homeNoMemberships => _t('homeNoMemberships');
  String get homeErrorTitle => _t('homeErrorTitle');

  // ─── Navigation ────────────────────────────────────────────────────────────
  String get navHome => _t('navHome');
  String get navAppointments => _t('navAppointments');
  String get navMembers => _t('navMembers');
  String get navProfile => _t('navProfile');
  String get navComingSoon => _t('navComingSoon');

  // ─── Profile ───────────────────────────────────────────────────────────────
  String get profileTitle => _t('profileTitle');
  String get profileEmailLabel => _t('profileEmailLabel');
  String get profilePhoneLabel => _t('profilePhoneLabel');
  String get profileLogout => _t('profileLogout');
  String get profileRetry => _t('profileRetry');
  String get profileMembershipsTitle => _t('profileMembershipsTitle');
  String get profileRoleLabel => _t('profileRoleLabel');
  String get profilePermissionsTitle => _t('profilePermissionsTitle');
  String get profileNoMemberships => _t('profileNoMemberships');
  String get profileSubscriptionActive => _t('profileSubscriptionActive');
  String get profileSubscriptionInactive => _t('profileSubscriptionInactive');
  String get profileSubscriptionExpires => _t('profileSubscriptionExpires');
  String get profilePlanLabel => _t('profilePlanLabel');
  String get profileMemberLimitLabel => _t('profileMemberLimitLabel');
  String get profileTimezoneLabel => _t('profileTimezoneLabel');
  String get profilePermCreateAppointment => _t('profilePermCreateAppointment');
  String get profilePermUploadResult => _t('profilePermUploadResult');
  String get profilePermChangeStatus => _t('profilePermChangeStatus');
  String get profilePermManageMembers => _t('profilePermManageMembers');
  String get profilePermManageStatuses => _t('profilePermManageStatuses');
  String get profilePermManageAppointmentFields =>
      _t('profilePermManageAppointmentFields');

  // ─── Brand Form ─────────────────────────────────────────────────────────────
  String get homeBrandCreateTitle => _t('homeBrandCreateTitle');
  String get homeBrandEditTitle => _t('homeBrandEditTitle');
  String get homeBrandNameLabel => _t('homeBrandNameLabel');
  String get homeBrandNameHint => _t('homeBrandNameHint');
  String get homeBrandTimezoneLabel => _t('homeBrandTimezoneLabel');
  String get homeBrandTimezoneHint => _t('homeBrandTimezoneHint');
  String get homeBrandCreateButton => _t('homeBrandCreateButton');
  String get homeBrandSaveButton => _t('homeBrandSaveButton');
  String get homeBrandEditTooltip => _t('homeBrandEditTooltip');
  String get homeBrandNameEmpty => _t('homeBrandNameEmpty');
  String get homeBrandCreateSuccess => _t('homeBrandCreateSuccess');
  String get homeBrandUpdateSuccess => _t('homeBrandUpdateSuccess');

  // ─── Appointments ──────────────────────────────────────────────────────────
  String get appointmentsTitle => _t('appointmentsTitle');

  // ─── Members ───────────────────────────────────────────────────────────────
  String get membersTitle => _t('membersTitle');

  // ─── Translations ──────────────────────────────────────────────────────────
  // Format: 'key': {'tr': '...', 'en': '...'}
  // ──────────────────────────────────────────────────────────────────────────
  static const Map<String, Map<String, String>> _data = {
    // Onboarding
    'onboardingSplashTitle': {
      'tr': 'İş süreçlerinizi\nkolaylaştırın.',
      'en': 'Streamline your\nbusiness processes.',
    },
    'onboardingPage2Text': {
      'tr': 'Tüm randevularınızı\ntek yerden yönetin.',
      'en': 'Manage all your\nappointments in one place.',
    },
    'onboardingPage3Text': {
      'tr': 'Müşterilerinizle\nher an bağlantıda kalın.',
      'en': 'Stay connected with\nyour customers anytime.',
    },
    'onboardingBtnExplore': {'tr': 'Keşfet', 'en': 'Explore'},
    'onboardingBtnContinue': {'tr': 'Devam Et', 'en': 'Continue'},
    'onboardingBtnGetStarted': {'tr': 'Başlayalım', 'en': "Let's Begin"},

    // Login
    'loginTitle': {'tr': 'Hoş Geldiniz', 'en': 'Welcome'},
    'loginSubtitle': {
      'tr': 'Hesabınıza giriş yapın',
      'en': 'Sign in to your account',
    },
    'loginEmailLabel': {'tr': 'E-posta', 'en': 'Email'},
    'loginEmailHint': {'tr': 'ornek@email.com', 'en': 'example@email.com'},
    'loginPasswordLabel': {'tr': 'Şifre', 'en': 'Password'},
    'loginPasswordHint': {'tr': '••••••••', 'en': '••••••••'},
    'loginButton': {'tr': 'Giriş Yap', 'en': 'Sign In'},
    'loginNoAccount': {
      'tr': 'Hesabınız yok mu? ',
      'en': "Don't have an account? ",
    },
    'loginSignUp': {'tr': 'Kayıt Ol', 'en': 'Sign Up'},
    'loginWelcomeBack': {
      'tr': 'Hoş geldiniz, {name}!',
      'en': 'Welcome, {name}!',
    },

    // Register
    'registerTitle': {'tr': 'Hesap Oluştur', 'en': 'Create Account'},
    'registerSubtitle': {
      'tr': 'Ücretsiz hesabınızı şimdi oluşturun',
      'en': 'Create your free account now',
    },
    'registerNameLabel': {'tr': 'Ad Soyad', 'en': 'Full Name'},
    'registerNameHint': {
      'tr': 'Adınızı ve soyadınızı girin',
      'en': 'Enter your full name',
    },
    'registerEmailLabel': {'tr': 'E-posta', 'en': 'Email'},
    'registerEmailHint': {'tr': 'ornek@email.com', 'en': 'example@email.com'},
    'registerPhoneLabel': {'tr': 'Telefon', 'en': 'Phone'},
    'registerPhoneHint': {'tr': '+905551234567', 'en': '+15551234567'},
    'registerPasswordLabel': {'tr': 'Şifre', 'en': 'Password'},
    'registerPasswordHint': {'tr': '••••••••', 'en': '••••••••'},
    'registerPasswordConfirmLabel': {
      'tr': 'Şifre Tekrar',
      'en': 'Confirm Password',
    },
    'registerPasswordConfirmHint': {'tr': '••••••••', 'en': '••••••••'},
    'registerButton': {'tr': 'Kayıt Ol', 'en': 'Sign Up'},
    'registerHasAccount': {
      'tr': 'Zaten hesabınız var mı? ',
      'en': 'Already have an account? ',
    },
    'registerSignIn': {'tr': 'Giriş Yap', 'en': 'Sign In'},
    'registerWelcome': {
      'tr': 'Hoş geldiniz, {name}!',
      'en': 'Welcome, {name}!',
    },

    // Validators
    'validatorEmailEmpty': {
      'tr': 'E-posta adresi boş olamaz.',
      'en': 'Email cannot be empty.',
    },
    'validatorEmailInvalid': {
      'tr': 'Geçerli bir e-posta adresi girin.',
      'en': 'Please enter a valid email address.',
    },
    'validatorPasswordEmpty': {
      'tr': 'Şifre boş olamaz.',
      'en': 'Password cannot be empty.',
    },
    'validatorPasswordTooShort': {
      'tr': 'Şifre en az 6 karakter olmalıdır.',
      'en': 'Password must be at least 6 characters.',
    },
    'validatorPasswordConfirmEmpty': {
      'tr': 'Şifre tekrarı boş olamaz.',
      'en': 'Password confirmation cannot be empty.',
    },
    'validatorPasswordMismatch': {
      'tr': 'Şifreler eşleşmiyor.',
      'en': 'Passwords do not match.',
    },
    'validatorNameEmpty': {
      'tr': 'Ad Soyad boş olamaz.',
      'en': 'Full name cannot be empty.',
    },
    'validatorNameTooShort': {
      'tr': 'Ad Soyad en az 2 karakter olmalıdır.',
      'en': 'Full name must be at least 2 characters.',
    },
    'validatorPhoneEmpty': {
      'tr': 'Telefon numarası boş olamaz.',
      'en': 'Phone number cannot be empty.',
    },
    'validatorPhoneInvalid': {
      'tr': 'Geçerli bir telefon numarası girin.',
      'en': 'Please enter a valid phone number.',
    },

    // Home
    'homeGreeting': {
      'tr': 'Merhaba, {name}!',
      'en': 'Hello, {name}!',
    },
    'homeBrandTitle': {'tr': 'Markanız', 'en': 'Your Brand'},
    'homePlanLabel': {'tr': 'Plan', 'en': 'Plan'},
    'homeSubscriptionStatusLabel': {
      'tr': 'Abonelik Durumu',
      'en': 'Subscription Status',
    },
    'homeSubscriptionActive': {'tr': 'Aktif', 'en': 'Active'},
    'homeSubscriptionInactive': {'tr': 'Pasif', 'en': 'Inactive'},
    'homeSubscriptionExpires': {
      'tr': 'Abonelik Bitiyor',
      'en': 'Subscription Expires',
    },
    'homeMemberLimitLabel': {'tr': 'Üye Limiti', 'en': 'Member Limit'},
    'homeRoleLabel': {'tr': 'Rol', 'en': 'Role'},
    'homePermissionsTitle': {'tr': 'İzinler', 'en': 'Permissions'},
    'homeLogout': {'tr': 'Çıkış Yap', 'en': 'Log Out'},
    'homeRetry': {'tr': 'Tekrar Dene', 'en': 'Retry'},
    'homeTimezoneLabel': {'tr': 'Zaman Dilimi', 'en': 'Timezone'},
    'homePermCreateAppointment': {
      'tr': 'Randevu Oluştur',
      'en': 'Create Appointment',
    },
    'homePermUploadResult': {'tr': 'Sonuç Yükle', 'en': 'Upload Result'},
    'homePermChangeStatus': {'tr': 'Durum Değiştir', 'en': 'Change Status'},
    'homePermManageMembers': {'tr': 'Üye Yönet', 'en': 'Manage Members'},
    'homePermManageStatuses': {'tr': 'Durum Yönet', 'en': 'Manage Statuses'},
    'homePermManageAppointmentFields': {
      'tr': 'Randevu Alanları',
      'en': 'Appointment Fields',
    },
    'homeMembershipsTitle': {'tr': 'Üyeliklerim', 'en': 'My Memberships'},
    'homeNoMemberships': {
      'tr': 'Henüz bir üyeliğiniz yok.',
      'en': 'You have no memberships yet.',
    },
    'homeErrorTitle': {
      'tr': 'Bir hata oluştu',
      'en': 'An error occurred',
    },

    // Navigation
    'navHome': {'tr': 'Anasayfa', 'en': 'Home'},
    'navAppointments': {'tr': 'Randevular', 'en': 'Appointments'},
    'navMembers': {'tr': 'Üyeler', 'en': 'Members'},
    'navProfile': {'tr': 'Profil', 'en': 'Profile'},
    'navComingSoon': {'tr': 'Yakında', 'en': 'Coming Soon'},

    // Profile
    'profileTitle': {'tr': 'Profil', 'en': 'Profile'},
    'profileEmailLabel': {'tr': 'E-posta', 'en': 'Email'},
    'profilePhoneLabel': {'tr': 'Telefon', 'en': 'Phone'},
    'profileLogout': {'tr': 'Çıkış Yap', 'en': 'Log Out'},
    'profileRetry': {'tr': 'Tekrar Dene', 'en': 'Retry'},
    'profileMembershipsTitle': {'tr': 'Üyeliklerim', 'en': 'My Memberships'},
    'profileRoleLabel': {'tr': 'Rol', 'en': 'Role'},
    'profilePermissionsTitle': {'tr': 'İzinler', 'en': 'Permissions'},
    'profileNoMemberships': {
      'tr': 'Henüz bir üyeliğiniz yok.',
      'en': 'You have no memberships yet.',
    },
    'profileSubscriptionActive': {'tr': 'Aktif', 'en': 'Active'},
    'profileSubscriptionInactive': {'tr': 'Pasif', 'en': 'Inactive'},
    'profileSubscriptionExpires': {
      'tr': 'Abonelik Bitiyor',
      'en': 'Subscription Expires',
    },
    'profilePlanLabel': {'tr': 'Plan', 'en': 'Plan'},
    'profileMemberLimitLabel': {'tr': 'Üye Limiti', 'en': 'Member Limit'},
    'profileTimezoneLabel': {'tr': 'Zaman Dilimi', 'en': 'Timezone'},
    'profilePermCreateAppointment': {
      'tr': 'Randevu Oluştur',
      'en': 'Create Appointment',
    },
    'profilePermUploadResult': {'tr': 'Sonuç Yükle', 'en': 'Upload Result'},
    'profilePermChangeStatus': {'tr': 'Durum Değiştir', 'en': 'Change Status'},
    'profilePermManageMembers': {'tr': 'Üye Yönet', 'en': 'Manage Members'},
    'profilePermManageStatuses': {'tr': 'Durum Yönet', 'en': 'Manage Statuses'},
    'profilePermManageAppointmentFields': {
      'tr': 'Randevu Alanları',
      'en': 'Appointment Fields',
    },

    // Brand Form
    'homeBrandCreateTitle': {'tr': 'Marka Oluştur', 'en': 'Create Brand'},
    'homeBrandEditTitle': {'tr': 'Markayı Düzenle', 'en': 'Edit Brand'},
    'homeBrandNameLabel': {'tr': 'Marka Adı', 'en': 'Brand Name'},
    'homeBrandNameHint': {
      'tr': 'Marka adını girin',
      'en': 'Enter brand name',
    },
    'homeBrandTimezoneLabel': {'tr': 'Zaman Dilimi', 'en': 'Timezone'},
    'homeBrandTimezoneHint': {
      'tr': 'Örn: Europe/Istanbul',
      'en': 'e.g. Europe/Istanbul',
    },
    'homeBrandCreateButton': {'tr': 'Oluştur', 'en': 'Create'},
    'homeBrandSaveButton': {'tr': 'Kaydet', 'en': 'Save'},
    'homeBrandEditTooltip': {'tr': 'Düzenle', 'en': 'Edit'},
    'homeBrandNameEmpty': {
      'tr': 'Marka adı boş olamaz.',
      'en': 'Brand name cannot be empty.',
    },
    'homeBrandCreateSuccess': {
      'tr': 'Marka başarıyla oluşturuldu.',
      'en': 'Brand created successfully.',
    },
    'homeBrandUpdateSuccess': {
      'tr': 'Marka başarıyla güncellendi.',
      'en': 'Brand updated successfully.',
    },

    // Appointments
    'appointmentsTitle': {'tr': 'Randevular', 'en': 'Appointments'},

    // Members
    'membersTitle': {'tr': 'Üyeler', 'en': 'Members'},
  };
}
