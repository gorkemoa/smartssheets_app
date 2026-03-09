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
      final value = int.parse(hex.length == 6 ? 'FF$hex' : hex, radix: 16);
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

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(SizeTokens.radiusLG),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: SizeTokens.paddingMD,
            vertical: SizeTokens.paddingSM,
          ),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(SizeTokens.radiusLG),
            border: Border.all(color: AppTheme.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Main Row ─────────────────────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Color swatch circle
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: brandColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: SizeTokens.spaceSM),
                  // Name
                  Expanded(
                    child: Text(
                      status.name ?? '—',
                      style: TextStyle(
                        fontSize: SizeTokens.fontMD,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                  SizedBox(width: SizeTokens.spaceSM),
                  // Sort Order (Small badge)
                  Text(
                    '#${status.sortOrder ?? '—'}',
                    style: TextStyle(
                      fontSize: SizeTokens.fontXS,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  SizedBox(width: SizeTokens.spaceSM),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: SizeTokens.iconMD,
                    color: AppTheme.border,
                  ),
                ],
              ),
              SizedBox(height: SizeTokens.spaceXS),
              // ── Badges row ─────────────────────────────────────────────
              Wrap(
                spacing: SizeTokens.spaceXS,
                runSpacing: SizeTokens.spaceXXS,
                children: [
                  // Active/Inactive badge
                  _StatusBadge(
                    label: isActive
                        ? l10n.membersStatusActive
                        : l10n.membersStatusInactive,
                    color: isActive ? AppTheme.accent : AppTheme.error,
                    background: isActive
                        ? AppTheme.accent.withValues(alpha: 0.1)
                        : AppTheme.errorLight,
                  ),
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
                ],
              ),
            ],
          ),
        ),
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
