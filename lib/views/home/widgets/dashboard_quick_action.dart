import 'package:flutter/material.dart';
import '../../../app/app_theme.dart';
import '../../../core/responsive/size_tokens.dart';

class DashboardQuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  final Color iconBackground;
  final VoidCallback? onTap;

  const DashboardQuickAction({
    super.key,
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.iconBackground,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(SizeTokens.radiusLG),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(SizeTokens.radiusLG),
        child: Container(
          padding: EdgeInsets.all(SizeTokens.paddingMD),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(SizeTokens.radiusLG),
            border: Border.all(color: AppTheme.divider),
          ),
          child: Row(
            children: [
              Container(
                width: SizeTokens.iconXL,
                height: SizeTokens.iconXL,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(SizeTokens.radiusSM),
                ),
                child: Icon(
                  icon,
                  size: SizeTokens.iconMD,
                  color: iconColor,
                ),
              ),
              SizedBox(width: SizeTokens.spaceSM),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: SizeTokens.fontMD,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: SizeTokens.iconMD,
                color: AppTheme.textHint,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
