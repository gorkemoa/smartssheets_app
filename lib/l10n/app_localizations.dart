import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr'),
  ];

  /// Onboarding splash page main title
  ///
  /// In tr, this message translates to:
  /// **'İş süreçlerinizi\nkolaylaştırın.'**
  String get onboardingSplashTitle;

  /// Onboarding second page text
  ///
  /// In tr, this message translates to:
  /// **'Tüm randevularınızı\ntek yerden yönetin.'**
  String get onboardingPage2Text;

  /// Onboarding third page text
  ///
  /// In tr, this message translates to:
  /// **'Müşterilerinizle\nher an bağlantıda kalın.'**
  String get onboardingPage3Text;

  /// Onboarding first page button label
  ///
  /// In tr, this message translates to:
  /// **'Keşfet'**
  String get onboardingBtnExplore;

  /// Onboarding middle page button label
  ///
  /// In tr, this message translates to:
  /// **'Devam Et'**
  String get onboardingBtnContinue;

  /// Onboarding last page button label
  ///
  /// In tr, this message translates to:
  /// **'Başlayalım'**
  String get onboardingBtnGetStarted;

  /// Login screen title
  ///
  /// In tr, this message translates to:
  /// **'Hoş Geldiniz'**
  String get loginTitle;

  /// Login screen subtitle
  ///
  /// In tr, this message translates to:
  /// **'Hesabınıza giriş yapın'**
  String get loginSubtitle;

  /// Email field label on login screen
  ///
  /// In tr, this message translates to:
  /// **'E-posta'**
  String get loginEmailLabel;

  /// Email field hint on login screen
  ///
  /// In tr, this message translates to:
  /// **'ornek@email.com'**
  String get loginEmailHint;

  /// Password field label on login screen
  ///
  /// In tr, this message translates to:
  /// **'Şifre'**
  String get loginPasswordLabel;

  /// Password field hint on login screen
  ///
  /// In tr, this message translates to:
  /// **'••••••••'**
  String get loginPasswordHint;

  /// Login button label
  ///
  /// In tr, this message translates to:
  /// **'Giriş Yap'**
  String get loginButton;

  /// No account prompt on login screen
  ///
  /// In tr, this message translates to:
  /// **'Hesabınız yok mu? '**
  String get loginNoAccount;

  /// Sign up link on login screen
  ///
  /// In tr, this message translates to:
  /// **'Kayıt Ol'**
  String get loginSignUp;

  /// Welcome message after successful login
  ///
  /// In tr, this message translates to:
  /// **'Hoş geldiniz, {name}!'**
  String loginWelcomeBack(String name);

  /// Register screen title
  ///
  /// In tr, this message translates to:
  /// **'Hesap Oluştur'**
  String get registerTitle;

  /// Register screen subtitle
  ///
  /// In tr, this message translates to:
  /// **'Ücretsiz hesabınızı şimdi oluşturun'**
  String get registerSubtitle;

  /// Full name field label on register screen
  ///
  /// In tr, this message translates to:
  /// **'Ad Soyad'**
  String get registerNameLabel;

  /// Full name field hint on register screen
  ///
  /// In tr, this message translates to:
  /// **'Adınızı ve soyadınızı girin'**
  String get registerNameHint;

  /// Email field label on register screen
  ///
  /// In tr, this message translates to:
  /// **'E-posta'**
  String get registerEmailLabel;

  /// Email field hint on register screen
  ///
  /// In tr, this message translates to:
  /// **'ornek@email.com'**
  String get registerEmailHint;

  /// Phone field label on register screen
  ///
  /// In tr, this message translates to:
  /// **'Telefon'**
  String get registerPhoneLabel;

  /// Phone field hint on register screen
  ///
  /// In tr, this message translates to:
  /// **'+905551234567'**
  String get registerPhoneHint;

  /// Password field label on register screen
  ///
  /// In tr, this message translates to:
  /// **'Şifre'**
  String get registerPasswordLabel;

  /// Password field hint on register screen
  ///
  /// In tr, this message translates to:
  /// **'••••••••'**
  String get registerPasswordHint;

  /// Password confirm field label on register screen
  ///
  /// In tr, this message translates to:
  /// **'Şifre Tekrar'**
  String get registerPasswordConfirmLabel;

  /// Password confirm field hint on register screen
  ///
  /// In tr, this message translates to:
  /// **'••••••••'**
  String get registerPasswordConfirmHint;

  /// Register button label
  ///
  /// In tr, this message translates to:
  /// **'Kayıt Ol'**
  String get registerButton;

  /// Has account prompt on register screen
  ///
  /// In tr, this message translates to:
  /// **'Zaten hesabınız var mı? '**
  String get registerHasAccount;

  /// Sign in link on register screen
  ///
  /// In tr, this message translates to:
  /// **'Giriş Yap'**
  String get registerSignIn;

  /// Welcome message after successful registration
  ///
  /// In tr, this message translates to:
  /// **'Hoş geldiniz, {name}!'**
  String registerWelcome(String name);

  /// Email empty validation error
  ///
  /// In tr, this message translates to:
  /// **'E-posta adresi boş olamaz.'**
  String get validatorEmailEmpty;

  /// Email invalid validation error
  ///
  /// In tr, this message translates to:
  /// **'Geçerli bir e-posta adresi girin.'**
  String get validatorEmailInvalid;

  /// Password empty validation error
  ///
  /// In tr, this message translates to:
  /// **'Şifre boş olamaz.'**
  String get validatorPasswordEmpty;

  /// Password too short validation error
  ///
  /// In tr, this message translates to:
  /// **'Şifre en az 6 karakter olmalıdır.'**
  String get validatorPasswordTooShort;

  /// Password confirm empty validation error
  ///
  /// In tr, this message translates to:
  /// **'Şifre tekrarı boş olamaz.'**
  String get validatorPasswordConfirmEmpty;

  /// Passwords mismatch validation error
  ///
  /// In tr, this message translates to:
  /// **'Şifreler eşleşmiyor.'**
  String get validatorPasswordMismatch;

  /// Name empty validation error
  ///
  /// In tr, this message translates to:
  /// **'Ad Soyad boş olamaz.'**
  String get validatorNameEmpty;

  /// Name too short validation error
  ///
  /// In tr, this message translates to:
  /// **'Ad Soyad en az 2 karakter olmalıdır.'**
  String get validatorNameTooShort;

  /// Phone empty validation error
  ///
  /// In tr, this message translates to:
  /// **'Telefon numarası boş olamaz.'**
  String get validatorPhoneEmpty;

  /// Phone invalid validation error
  ///
  /// In tr, this message translates to:
  /// **'Geçerli bir telefon numarası girin.'**
  String get validatorPhoneInvalid;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
