import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:home_widget/home_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app/app_constants.dart';
import 'app/app_theme.dart';
import 'core/network/api_exception.dart';
import 'core/network/api_result.dart';
import 'services/auth_service.dart';
import 'views/login/login_view.dart';
import 'views/onboarding/onboarding_view.dart';
import 'views/shell/main_shell_view.dart';

import 'package:smartssheets_app/viewmodels/home_view_model.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isIOS) {
    try {
      await HomeWidget.setAppGroupId('group.com.smartmetrics.smartsheetsapp')
          .timeout(const Duration(seconds: 5));
    } catch (_) {
      // Widget extension kurulu değilse veya platform channel gecikirse
      // uygulamanın açılmasını bloklamaması için sessizce geç.
    }
  }

  final Widget homeWidget = await _resolveInitialRoute();

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => HomeViewModel())],
      child: SmartSheetsApp(home: homeWidget),
    ),
  );
}

/// Uygulama açılışında hangi ekranın gösterileceğini belirler.
///
/// 1. Kaydedilmiş token varsa → me() ile doğrula.
///    - Geçerliyse → MainShellView (yeniden giriş gereksiz).
///    - 401/403 → token geçersiz, oturumu temizle → LoginView.
///    - Ağ/sunucu hatası → token hâlâ geçerli olabilir → MainShellView.
/// 2. Token yoksa → onboarding durumuna göre OnboardingView veya LoginView.
Future<Widget> _resolveInitialRoute() async {
  final hasSession = await AuthService.instance.restoreSession();

  if (hasSession) {
    final result = await AuthService.instance.me();
    switch (result) {
      case ApiSuccess():
        return const MainShellView();
      case ApiFailure(:final exception):
        if (exception.type == ApiExceptionType.unauthorized ||
            exception.type == ApiExceptionType.forbidden) {
          await AuthService.instance.clearSession();
          return const LoginView();
        }
        // Ağ hatası veya geçici sunucu hatası — token süresi dolmamış olabilir.
        return const MainShellView();
    }
  }

  final prefs = await SharedPreferences.getInstance();
  final onboardingDone =
      prefs.getBool(AppConstants.keyOnboardingCompleted) ?? false;
  return onboardingDone ? const LoginView() : const OnboardingView();
}

class SmartSheetsApp extends StatelessWidget {
  final Widget home;

  const SmartSheetsApp({super.key, required this.home});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartSheets',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('tr'), Locale('en')],
      localeResolutionCallback: (locale, supportedLocales) {
        if (locale?.languageCode == 'tr') return const Locale('tr');
        return const Locale('en');
      },
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.noScaling),
          child: child!,
        );
      },
      home: home,
    );
  }
}
