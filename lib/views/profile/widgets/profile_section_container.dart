import 'package:flutter/material.dart';
import '../../../../app/app_theme.dart';
import '../../../../core/responsive/size_tokens.dart';

class ProfileSectionContainer extends StatelessWidget {
  final String? title;
  final List<Widget> children;

  const ProfileSectionContainer({
    super.key,
    this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Padding(
            padding: EdgeInsets.only(
              left: SizeTokens.paddingXL,
              bottom: SizeTokens.spaceSM,
            ),
            child: Text(
              title!,
              style: TextStyle(
                fontSize: SizeTokens.fontLG,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        ],
        Container(
          margin: EdgeInsets.symmetric(horizontal: SizeTokens.paddingMD),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(SizeTokens.radiusXL),
            border: Border.all(color: AppTheme.border),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withValues(alpha: 0.04),
                blurRadius: SizeTokens.spaceMD,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }
}
