import 'package:flutter/material.dart';
import '../../../app/app_theme.dart';
import '../../../core/responsive/size_tokens.dart';

class DashboardStatTile extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color iconColor;
  final Color iconBackground;

  const DashboardStatTile({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    required this.iconColor,
    required this.iconBackground,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(SizeTokens.paddingMD),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(SizeTokens.radiusLG),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
          SizedBox(height: SizeTokens.spaceSM),
          Text(
            value,
            style: TextStyle(
              fontSize: SizeTokens.fontXXL,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: SizeTokens.spaceXXS),
          Text(
            label,
            style: TextStyle(
              fontSize: SizeTokens.fontSM,
              fontWeight: FontWeight.w400,
              color: AppTheme.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
