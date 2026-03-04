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
  };
}
