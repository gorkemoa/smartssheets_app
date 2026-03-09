import 'package:flutter/material.dart';
import '../../../../app/app_theme.dart';
import '../../../../core/responsive/size_tokens.dart';

class ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? badge;
  final VoidCallback onTap;
  final bool isLast;

  const ProfileMenuItem({
    super.key,
    required this.icon,
    required this.label,
    this.badge,
    required this.onTap,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: SizeTokens.paddingXL,
          vertical: SizeTokens.paddingSM,
        ),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : Border(
                  bottom: BorderSide(
                    color: AppTheme.divider.withValues(alpha: 0.5),
                    width: 0.5,
                  ),
                ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: SizeTokens.iconMD,
              color: AppTheme.primary,
            ),
            SizedBox(width: SizeTokens.spaceMD),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: SizeTokens.fontMD,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
            if (badge != null) ...[
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: SizeTokens.spaceXS,
                  vertical: SizeTokens.spaceXXS,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(SizeTokens.radiusXS),
                ),
                child: Text(
                  badge!,
                  style: TextStyle(
                    fontSize: SizeTokens.fontXS,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.error,
                  ),
                ),
              ),
              SizedBox(width: SizeTokens.spaceXS),
            ],
            Icon(
              Icons.chevron_right_rounded,
              size: SizeTokens.iconMD,
              color: AppTheme.textHint,
            ),
          ],
        ),
      ),
    );
  }
}
