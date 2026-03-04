// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get onboardingSplashTitle => 'Streamline your\nbusiness processes.';

  @override
  String get onboardingPage2Text =>
      'Manage all your\nappointments in one place.';

  @override
  String get onboardingPage3Text =>
      'Stay connected with\nyour customers anytime.';

  @override
  String get onboardingBtnExplore => 'Explore';

  @override
  String get onboardingBtnContinue => 'Continue';

  @override
  String get onboardingBtnGetStarted => 'Let\'s Begin';

  @override
  String get loginTitle => 'Welcome';

  @override
  String get loginSubtitle => 'Sign in to your account';

  @override
  String get loginEmailLabel => 'Email';

  @override
  String get loginEmailHint => 'example@email.com';

  @override
  String get loginPasswordLabel => 'Password';

  @override
  String get loginPasswordHint => '••••••••';

  @override
  String get loginButton => 'Sign In';

  @override
  String get loginNoAccount => 'Don\'t have an account? ';

  @override
  String get loginSignUp => 'Sign Up';

  @override
  String loginWelcomeBack(String name) {
    return 'Welcome, $name!';
  }

  @override
  String get registerTitle => 'Create Account';

  @override
  String get registerSubtitle => 'Create your free account now';

  @override
  String get registerNameLabel => 'Full Name';

  @override
  String get registerNameHint => 'Enter your full name';

  @override
  String get registerEmailLabel => 'Email';

  @override
  String get registerEmailHint => 'example@email.com';

  @override
  String get registerPhoneLabel => 'Phone';

  @override
  String get registerPhoneHint => '+15551234567';

  @override
  String get registerPasswordLabel => 'Password';

  @override
  String get registerPasswordHint => '••••••••';

  @override
  String get registerPasswordConfirmLabel => 'Confirm Password';

  @override
  String get registerPasswordConfirmHint => '••••••••';

  @override
  String get registerButton => 'Sign Up';

  @override
  String get registerHasAccount => 'Already have an account? ';

  @override
  String get registerSignIn => 'Sign In';

  @override
  String registerWelcome(String name) {
    return 'Welcome, $name!';
  }

  @override
  String get validatorEmailEmpty => 'Email cannot be empty.';

  @override
  String get validatorEmailInvalid => 'Please enter a valid email address.';

  @override
  String get validatorPasswordEmpty => 'Password cannot be empty.';

  @override
  String get validatorPasswordTooShort =>
      'Password must be at least 6 characters.';

  @override
  String get validatorPasswordConfirmEmpty =>
      'Password confirmation cannot be empty.';

  @override
  String get validatorPasswordMismatch => 'Passwords do not match.';

  @override
  String get validatorNameEmpty => 'Full name cannot be empty.';

  @override
  String get validatorNameTooShort =>
      'Full name must be at least 2 characters.';

  @override
  String get validatorPhoneEmpty => 'Phone number cannot be empty.';

  @override
  String get validatorPhoneInvalid => 'Please enter a valid phone number.';
}
