// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get onboardingSplashTitle => 'İş süreçlerinizi\nkolaylaştırın.';

  @override
  String get onboardingPage2Text => 'Tüm randevularınızı\ntek yerden yönetin.';

  @override
  String get onboardingPage3Text =>
      'Müşterilerinizle\nher an bağlantıda kalın.';

  @override
  String get onboardingBtnExplore => 'Keşfet';

  @override
  String get onboardingBtnContinue => 'Devam Et';

  @override
  String get onboardingBtnGetStarted => 'Başlayalım';

  @override
  String get loginTitle => 'Hoş Geldiniz';

  @override
  String get loginSubtitle => 'Hesabınıza giriş yapın';

  @override
  String get loginEmailLabel => 'E-posta';

  @override
  String get loginEmailHint => 'ornek@email.com';

  @override
  String get loginPasswordLabel => 'Şifre';

  @override
  String get loginPasswordHint => '••••••••';

  @override
  String get loginButton => 'Giriş Yap';

  @override
  String get loginNoAccount => 'Hesabınız yok mu? ';

  @override
  String get loginSignUp => 'Kayıt Ol';

  @override
  String loginWelcomeBack(String name) {
    return 'Hoş geldiniz, $name!';
  }

  @override
  String get registerTitle => 'Hesap Oluştur';

  @override
  String get registerSubtitle => 'Ücretsiz hesabınızı şimdi oluşturun';

  @override
  String get registerNameLabel => 'Ad Soyad';

  @override
  String get registerNameHint => 'Adınızı ve soyadınızı girin';

  @override
  String get registerEmailLabel => 'E-posta';

  @override
  String get registerEmailHint => 'ornek@email.com';

  @override
  String get registerPhoneLabel => 'Telefon';

  @override
  String get registerPhoneHint => '+905551234567';

  @override
  String get registerPasswordLabel => 'Şifre';

  @override
  String get registerPasswordHint => '••••••••';

  @override
  String get registerPasswordConfirmLabel => 'Şifre Tekrar';

  @override
  String get registerPasswordConfirmHint => '••••••••';

  @override
  String get registerButton => 'Kayıt Ol';

  @override
  String get registerHasAccount => 'Zaten hesabınız var mı? ';

  @override
  String get registerSignIn => 'Giriş Yap';

  @override
  String registerWelcome(String name) {
    return 'Hoş geldiniz, $name!';
  }

  @override
  String get validatorEmailEmpty => 'E-posta adresi boş olamaz.';

  @override
  String get validatorEmailInvalid => 'Geçerli bir e-posta adresi girin.';

  @override
  String get validatorPasswordEmpty => 'Şifre boş olamaz.';

  @override
  String get validatorPasswordTooShort => 'Şifre en az 6 karakter olmalıdır.';

  @override
  String get validatorPasswordConfirmEmpty => 'Şifre tekrarı boş olamaz.';

  @override
  String get validatorPasswordMismatch => 'Şifreler eşleşmiyor.';

  @override
  String get validatorNameEmpty => 'Ad Soyad boş olamaz.';

  @override
  String get validatorNameTooShort => 'Ad Soyad en az 2 karakter olmalıdır.';

  @override
  String get validatorPhoneEmpty => 'Telefon numarası boş olamaz.';

  @override
  String get validatorPhoneInvalid => 'Geçerli bir telefon numarası girin.';
}
