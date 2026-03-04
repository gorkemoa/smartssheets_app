import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:smartssheets_app/l10n/app_localizations.dart';
import 'app/app_theme.dart';
import 'views/login/login_view.dart';
import 'views/onboarding/onboarding_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // TODO: Gerçek modda aşağıdaki satırı aktif et, dev satırını sil
  // final prefs = await SharedPreferences.getInstance();
  // final onboardingDone = prefs.getBool(AppConstants.keyOnboardingCompleted) ?? false;
  const onboardingDone = false; // DEV: onboarding her zaman göster
  runApp(SmartSheetsApp(showOnboarding: !onboardingDone));
}

class SmartSheetsApp extends StatelessWidget {
  final bool showOnboarding;

  const SmartSheetsApp({super.key, required this.showOnboarding});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartSheets',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('tr'),
        Locale('en'),
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        if (locale?.languageCode == 'tr') return const Locale('tr');
        return const Locale('en');
      },
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.noScaling,
          ),
          child: child!,
        );
      },
      home: showOnboarding ? const OnboardingView() : const LoginView(),
    );
  }
}
