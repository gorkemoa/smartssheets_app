import 'package:flutter/material.dart';
import '../../../app/app_theme.dart';
import '../../../core/responsive/size_tokens.dart';
import '../../../l10n/strings.dart';
import '../../../models/appointment_field_model.dart';

class AppointmentFieldCard extends StatelessWidget {
  final AppointmentFieldModel field;
  final AppStrings l10n;
  final VoidCallback? onEdit;

  const AppointmentFieldCard({
    super.key,
    required this.field,
    required this.l10n,
    this.onEdit,
  });

  String _typeLabel() {
    switch (field.type) {
      case 'number':
        return l10n.fieldTypeNumber;
      case 'select':
        return l10n.fieldTypeSelect;
      case 'checkbox':
        return l10n.fieldTypeCheckbox;
      case 'date':
        return l10n.fieldTypeDate;
      default:
        return l10n.fieldTypeText;
    }
  }

  Color _typeBg() {
    switch (field.type) {
      case 'number':
        return AppTheme.primary.withValues(alpha: 0.1);
      case 'select':
        return AppTheme.accent.withValues(alpha: 0.1);
      case 'checkbox':
        return Colors.purple.withValues(alpha: 0.1);
      case 'date':
        return Colors.teal.withValues(alpha: 0.1);
      default:
        return AppTheme.textSecondary.withValues(alpha: 0.1);
    }
  }

  Color _typeColor() {
    switch (field.type) {
      case 'number':
        return AppTheme.primary;
      case 'select':
        return AppTheme.accent;
      case 'checkbox':
        return Colors.purple;
      case 'date':
        return Colors.teal;
      default:
        return AppTheme.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isActive = field.isActive ?? true;
    final isRequired = field.required ?? false;
    final optionsCount = field.optionsJson?.length ?? 0;
    final hasValidations =
        field.validationsJson?.min != null ||
        field.validationsJson?.max != null;

    return Opacity(
      opacity: isActive ? 1.0 : 0.6,
      child: Material(
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
                // ── Header Row ───────────────────────────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                field.label ?? '—',
                                style: TextStyle(
                                  fontSize: SizeTokens.fontMD,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              if (isRequired) ...[
                                SizedBox(width: SizeTokens.spaceXXS),
                                Text(
                                  '*',
                                  style: TextStyle(
                                    color: AppTheme.error,
                                    fontSize: SizeTokens.fontMD,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          Text(
                            field.key ?? '—',
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: SizeTokens.fontXS,
                              color: AppTheme.textSecondary.withValues(
                                alpha: 0.7,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: SizeTokens.spaceSM),
                    // Type Badge (small)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: SizeTokens.spaceXS,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _typeBg(),
                        borderRadius: BorderRadius.circular(
                          SizeTokens.radiusXS,
                        ),
                      ),
                      child: Text(
                        _typeLabel(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: _typeColor(),
                        ),
                      ),
                    ),
                    SizedBox(width: SizeTokens.spaceXS),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: SizeTokens.iconMD,
                      color: AppTheme.border,
                    ),
                  ],
                ),

                if ((field.helpText != null && field.helpText!.isNotEmpty) ||
                    !isActive ||
                    optionsCount > 0 ||
                    hasValidations) ...[
                  SizedBox(height: SizeTokens.spaceSM),
                  // ── Badges & Info row ──────────────────────────────────────────
                  Wrap(
                    spacing: SizeTokens.spaceXS,
                    runSpacing: SizeTokens.spaceXXS,
                    children: [
                      // Inactive badge
                      if (!isActive)
                        _SmallBadge(
                          label: 'Pasif',
                          color: AppTheme.textSecondary,
                          background: AppTheme.textSecondary.withValues(
                            alpha: 0.08,
                          ),
                        ),
                      // Options count
                      if ((field.type == 'select' ||
                              field.type == 'checkbox') &&
                          optionsCount > 0)
                        _SmallBadge(
                          label: '$optionsCount ${l10n.fieldOptionsTitle}',
                          color: AppTheme.accent,
                          background: AppTheme.accent.withValues(alpha: 0.08),
                        ),
                      // Validations
                      if (field.type == 'number' && hasValidations)
                        _SmallBadge(
                          label:
                              '${field.validationsJson?.min ?? '0'} - ${field.validationsJson?.max ?? '∞'}',
                          color: AppTheme.primary,
                          background: AppTheme.primary.withValues(alpha: 0.08),
                        ),
                    ],
                  ),
                  if (field.helpText != null && field.helpText!.isNotEmpty) ...[
                    SizedBox(height: SizeTokens.spaceXS),
                    Text(
                      field.helpText!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: SizeTokens.fontXS,
                        color: AppTheme.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SmallBadge extends StatelessWidget {
  final String label;
  final Color color;
  final Color background;

  const _SmallBadge({
    required this.label,
    required this.color,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: SizeTokens.spaceXS,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(SizeTokens.radiusXS),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
