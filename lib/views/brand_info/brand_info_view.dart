import 'package:flutter/material.dart';
import '../../app/app_theme.dart';
import '../../core/responsive/size_config.dart';
import '../../core/responsive/size_tokens.dart';
import '../../l10n/strings.dart';
import '../members/members_view.dart';
import '../statuses/appointment_statuses_view.dart';
import '../appointment_fields/appointment_fields_view.dart';

class BrandInfoView extends StatelessWidget {
  final int brandId;
  final String? brandName;

  const BrandInfoView({
    super.key,
    required this.brandId,
    this.brandName,
  });

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final l10n = AppStrings.of(context);

    return Scaffold(
      backgroundColor: AppTheme.surfaceVariant,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        foregroundColor: AppTheme.textPrimary,
        elevation: 0,
        titleSpacing: SizeTokens.paddingPage,
        title: Text(
          brandName != null
              ? '${l10n.brandInfoTitle} — $brandName'
              : l10n.brandInfoTitle,
          style: TextStyle(
            fontSize: SizeTokens.fontXL,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(SizeConfig.h(1)),
          child: Container(height: SizeConfig.h(1), color: AppTheme.divider),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          SizeTokens.paddingPage,
          SizeTokens.spaceXL,
          SizeTokens.paddingPage,
          SizeTokens.spaceXXXL,
        ),
        children: [
          _BrandInfoTile(
            icon: Icons.people_outline_rounded,
            label: l10n.brandInfoMembers,
            iconColor: AppTheme.primary,
            iconBackground: AppTheme.primary.withValues(alpha: 0.08),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => MembersView(
                  brandId: brandId,
                  brandName: brandName,
                ),
              ),
            ),
          ),
          SizedBox(height: SizeTokens.spaceXS),
          _BrandInfoTile(
            icon: Icons.palette_outlined,
            label: l10n.brandInfoStatuses,
            iconColor: AppTheme.success,
            iconBackground: AppTheme.successLight,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => AppointmentStatusesView(
                  brandId: brandId,
                  brandName: brandName,
                ),
              ),
            ),
          ),
          SizedBox(height: SizeTokens.spaceXS),
          _BrandInfoTile(
            icon: Icons.tune_rounded,
            label: l10n.brandInfoFields,
            iconColor: AppTheme.warning,
            iconBackground: AppTheme.warningLight,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => AppointmentFieldsView(
                  brandId: brandId,
                  brandName: brandName,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BrandInfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  final Color iconBackground;
  final VoidCallback onTap;

  const _BrandInfoTile({
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.iconBackground,
    required this.onTap,
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
          padding: EdgeInsets.symmetric(
            horizontal: SizeTokens.paddingMD,
            vertical: SizeTokens.spaceMD,
          ),
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
