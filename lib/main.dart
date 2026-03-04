import 'package:flutter/material.dart';
import 'app/app_theme.dart';
import 'views/login/login_view.dart';

void main() {
  runApp(const SmartSheetsApp());
}

class SmartSheetsApp extends StatelessWidget {
  const SmartSheetsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartSheets',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.noScaling,
          ),
          child: child!,
        );
      },
      home: const LoginView(),
    );
  }
}
