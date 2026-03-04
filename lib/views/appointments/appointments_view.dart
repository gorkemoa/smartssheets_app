import 'package:flutter/material.dart';
import '../../app/app_theme.dart';
import '../../core/responsive/size_config.dart';
import '../../core/responsive/size_tokens.dart';
import '../../core/ui_components/main_app_bar.dart';
import '../../l10n/strings.dart';

class AppointmentsView extends StatelessWidget {
  const AppointmentsView({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final l10n = AppStrings.of(context);

    return Scaffold(
      backgroundColor: AppTheme.surfaceVariant,
      appBar: MainAppBar(title: l10n.appointmentsTitle),
      body: Center(
        child: Text(
          l10n.navComingSoon,
          style: TextStyle(
            fontSize: SizeTokens.fontLG,
            color: AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }
}
