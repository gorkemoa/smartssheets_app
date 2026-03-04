import 'package:flutter/material.dart';
import '../../../app/app_theme.dart';
import '../../../core/responsive/size_tokens.dart';
import '../../../models/brand_model.dart';

class BrandCard extends StatelessWidget {
  final BrandModel brand;
  final String subscriptionActiveLabel;
  final String subscriptionInactiveLabel;
  final String planLabel;
  final String subscriptionStatusLabel;
  final String subscriptionExpiresLabel;
  final String memberLimitLabel;
  final String timezoneLabel;
  final String editTooltip;
  final VoidCallback? onEdit;

  const BrandCard({
    super.key,
    required this.brand,
    required this.subscriptionActiveLabel,
    required this.subscriptionInactiveLabel,
    required this.planLabel,
    required this.subscriptionStatusLabel,
    required this.subscriptionExpiresLabel,
    required this.memberLimitLabel,
    required this.timezoneLabel,
    required this.editTooltip,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = brand.subscriptionStatus == 'active';
    final statusLabel =
        isActive ? subscriptionActiveLabel : subscriptionInactiveLabel;
    final statusColor = isActive ? AppTheme.accent : AppTheme.error;
    final statusBg =
        isActive ? AppTheme.accent.withValues(alpha: 0.1) : AppTheme.errorLight;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(SizeTokens.paddingXL),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(SizeTokens.radiusXL),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  brand.name ?? '—',
                  style: TextStyle(
                    fontSize: SizeTokens.fontXL,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              SizedBox(width: SizeTokens.spaceXS),
              _StatusBadge(
                label: statusLabel,
                color: statusColor,
                background: statusBg,
              ),
              if (onEdit != null) ...[  
                SizedBox(width: SizeTokens.spaceXS),
                SizedBox(
                  width: SizeTokens.iconXL,
                  height: SizeTokens.iconXL,
                  child: IconButton(
                    onPressed: onEdit,
                    tooltip: editTooltip,
                    padding: EdgeInsets.zero,
                    icon: Icon(
                      Icons.edit_outlined,
                      size: SizeTokens.iconMD,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: SizeTokens.spaceMD),
          _InfoRow(
            icon: Icons.diamond_outlined,
            label: planLabel,
            value: (brand.currentPlan ?? '—').toUpperCase(),
          ),
          SizedBox(height: SizeTokens.spaceXS),
          _InfoRow(
            icon: Icons.people_outline_rounded,
            label: memberLimitLabel,
            value: brand.memberLimit?.toString() ?? '—',
          ),
          if (brand.subscriptionExpiresAt != null) ...[
            SizedBox(height: SizeTokens.spaceXS),
            _InfoRow(
              icon: Icons.calendar_today_outlined,
              label: subscriptionExpiresLabel,
              value: _formatDate(brand.subscriptionExpiresAt!),
            ),
          ],
          if (brand.timezone != null) ...[
            SizedBox(height: SizeTokens.spaceXS),
            _InfoRow(
              icon: Icons.public_outlined,
              label: timezoneLabel,
              value: brand.timezone!,
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';
    } catch (_) {
      return iso;
    }
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: SizeTokens.iconMD, color: AppTheme.textHint),
        SizedBox(width: SizeTokens.spaceXS),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: SizeTokens.fontSM,
            color: AppTheme.textSecondary,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: SizeTokens.fontSM,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final Color background;

  const _StatusBadge({
    required this.label,
    required this.color,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: SizeTokens.paddingSM,
        vertical: SizeTokens.spaceXXS,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(SizeTokens.radiusCircle),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: SizeTokens.fontXS,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
