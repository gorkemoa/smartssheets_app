import 'package:flutter/material.dart';
import '../../../app/app_theme.dart';
import '../../../core/responsive/size_tokens.dart';
import '../../../l10n/strings.dart';
import '../../../models/appointment_status_model.dart';

class AppointmentStatusCard extends StatelessWidget {
  final AppointmentStatusModel status;
  final AppStrings l10n;
  final VoidCallback? onEdit;

  const AppointmentStatusCard({
    super.key,
    required this.status,
    required this.l10n,
    this.onEdit,
  });

  Color _parsedColor() {
    try {
      final hex = (status.color ?? '#888888').replaceFirst('#', '');
      final value = int.parse(
        hex.length == 6 ? 'FF$hex' : hex,
        radix: 16,
      );
      return Color(value);
    } catch (_) {
      return AppTheme.textSecondary;
    }
  }

  String _statusTypeLabel() {
    switch (status.statusType) {
      case 'active':
        return l10n.statusTypeActive;
      case 'invalid':
        return l10n.statusTypeInvalid;
      default:
        return l10n.statusTypeNeutral;
    }
  }

  Color _statusTypeBg() {
    switch (status.statusType) {
      case 'active':
        return AppTheme.accent.withValues(alpha: 0.1);
      case 'invalid':
        return AppTheme.error.withValues(alpha: 0.1);
      default:
        return AppTheme.textSecondary.withValues(alpha: 0.1);
    }
  }

  Color _statusTypeColor() {
    switch (status.statusType) {
      case 'active':
        return AppTheme.accent;
      case 'invalid':
        return AppTheme.error;
      default:
        return AppTheme.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final brandColor = _parsedColor();
    final isActive = status.isActive ?? true;

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
          // ── Header row ─────────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Color swatch circle
              Container(
                width: SizeTokens.avatarMD,
                height: SizeTokens.avatarMD,
                decoration: BoxDecoration(
                  color: brandColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.border,
                    width: 2,
                  ),
                ),
              ),
              SizedBox(width: SizeTokens.spaceMD),
              // Name + sort order
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      status.name ?? '—',
                      style: TextStyle(
                        fontSize: SizeTokens.fontLG,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    SizedBox(height: SizeTokens.spaceXXS),
                    Text(
                      '#${status.sortOrder ?? '—'}',
                      style: TextStyle(
                        fontSize: SizeTokens.fontXS,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // Active badge
              _StatusBadge(
                label: isActive ? l10n.membersStatusActive : l10n.membersStatusInactive,
                color: isActive ? AppTheme.accent : AppTheme.error,
                background: isActive
                    ? AppTheme.accent.withValues(alpha: 0.1)
                    : AppTheme.errorLight,
              ),
              if (onEdit != null) ...[
                SizedBox(width: SizeTokens.spaceXS),
                SizedBox(
                  width: SizeTokens.iconXL,
                  height: SizeTokens.iconXL,
                  child: IconButton(
                    onPressed: onEdit,
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
          Divider(color: AppTheme.divider, height: SizeTokens.spaceXS),
          SizedBox(height: SizeTokens.spaceSM),
          // ── Badges row ─────────────────────────────────────────────
          Wrap(
            spacing: SizeTokens.spaceXS,
            runSpacing: SizeTokens.spaceXS,
            children: [
              // Status type badge
              _StatusBadge(
                label: _statusTypeLabel(),
                color: _statusTypeColor(),
                background: _statusTypeBg(),
              ),
              // Default badge
              if (status.isDefault == true)
                _StatusBadge(
                  label: l10n.statusDefaultBadge,
                  color: AppTheme.primary,
                  background: AppTheme.primary.withValues(alpha: 0.1),
                ),
              // Hex color chip
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: SizeTokens.paddingSM,
                  vertical: SizeTokens.spaceXXS,
                ),
                decoration: BoxDecoration(
                  color: brandColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(SizeTokens.radiusSM),
                  border: Border.all(color: brandColor.withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: SizeTokens.spaceXS,
                      height: SizeTokens.spaceXS,
                      decoration: BoxDecoration(
                        color: brandColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: SizeTokens.spaceXXS),
                    Text(
                      status.color ?? '',
                      style: TextStyle(
                        fontSize: SizeTokens.fontXS,
                        fontWeight: FontWeight.w600,
                        color: brandColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
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
        borderRadius: BorderRadius.circular(SizeTokens.radiusSM),
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
