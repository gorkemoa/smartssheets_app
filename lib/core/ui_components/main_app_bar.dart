import 'package:flutter/material.dart';
import '../../app/app_theme.dart';
import '../responsive/size_config.dart';
import '../responsive/size_tokens.dart';

/// Onaylı paylaşılan AppBar — tüm ana sekme ekranları tarafından kullanılır.
/// Bkz. README: ONAYLANAN ORTAK WİDGETLAR
class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;

  const MainAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = false,
  });

  @override
  Size get preferredSize => Size.fromHeight(SizeTokens.appBarHeight);

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    return AppBar(
      backgroundColor: AppTheme.surface,
      foregroundColor: AppTheme.textPrimary,
      elevation: 0,
      centerTitle: centerTitle,
      automaticallyImplyLeading: false,
      leading: leading,
      titleSpacing: SizeTokens.paddingPage,
      title: Text(
        title,
        style: TextStyle(
          fontSize: SizeTokens.fontXL,
          fontWeight: FontWeight.w700,
          color: AppTheme.textPrimary,
          letterSpacing: -0.3,
        ),
      ),
      actions: [
        if (actions != null) ...actions!,
        SizedBox(width: SizeTokens.spaceXS),
      ],
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(SizeConfig.h(1)),
        child: Container(
          height: SizeConfig.h(1),
          color: AppTheme.divider,
        ),
      ),
    );
  }
}
