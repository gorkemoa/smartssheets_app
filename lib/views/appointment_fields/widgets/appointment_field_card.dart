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
        field.validationsJson?.min != null || field.validationsJson?.max != null;

    return Opacity(
      opacity: isActive ? 1.0 : 0.55,
      child: Container(
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
            // ── Header row ───────────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // label
                      Text(
                        field.label ?? '—',
                        style: TextStyle(
                          fontSize: SizeTokens.fontLG,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      SizedBox(height: SizeTokens.spaceXXS),
                      // key chip (monospace)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: SizeTokens.spaceSM,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceVariant,
                          borderRadius:
                              BorderRadius.circular(SizeTokens.radiusSM),
                          border: Border.all(color: AppTheme.border),
                        ),
                        child: Text(
                          field.key ?? '—',
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 11,
                            color: Colors.blueGrey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // edit button
                IconButton(
                  onPressed: onEdit,
                  icon: Icon(
                    Icons.edit_rounded,
                    size: SizeTokens.iconMD,
                    color: AppTheme.textSecondary,
                  ),
                  tooltip: l10n.fieldFormEditTitle,
                ),
              ],
            ),

            SizedBox(height: SizeTokens.spaceMD),

            // ── Badges row ──────────────────────────────────────────
            Wrap(
              spacing: SizeTokens.spaceSM,
              runSpacing: SizeTokens.spaceSM,
              children: [
                // type badge
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: SizeTokens.spaceSM,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: _typeBg(),
                    borderRadius: BorderRadius.circular(SizeTokens.radiusSM),
                  ),
                  child: Text(
                    _typeLabel(),
                    style: TextStyle(
                      fontSize: SizeTokens.fontXS,
                      fontWeight: FontWeight.w600,
                      color: _typeColor(),
                    ),
                  ),
                ),
                // required badge
                if (isRequired)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: SizeTokens.spaceSM,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(SizeTokens.radiusSM),
                    ),
                    child: Text(
                      l10n.fieldRequiredLabel,
                      style: TextStyle(
                        fontSize: SizeTokens.fontXS,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.error,
                      ),
                    ),
                  ),
                // inactive badge
                if (!isActive)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: SizeTokens.spaceSM,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.textSecondary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(SizeTokens.radiusSM),
                    ),
                    child: Text(
                      '● Pasif',
                      style: TextStyle(
                        fontSize: SizeTokens.fontXS,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                // options count for select/checkbox
                if ((field.type == 'select' || field.type == 'checkbox') &&
                    optionsCount > 0)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: SizeTokens.spaceSM,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.accent.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(SizeTokens.radiusSM),
                    ),
                    child: Text(
                      '$optionsCount ${l10n.fieldOptionsTitle}',
                      style: TextStyle(
                        fontSize: SizeTokens.fontXS,
                        color: AppTheme.accent,
                      ),
                    ),
                  ),
                // validations for number
                if (field.type == 'number' && hasValidations)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: SizeTokens.spaceSM,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(SizeTokens.radiusSM),
                    ),
                    child: Text(
                      '${l10n.fieldValidationMinLabel}: ${field.validationsJson?.min ?? '—'}'
                      '  ${l10n.fieldValidationMaxLabel}: ${field.validationsJson?.max ?? '—'}',
                      style: TextStyle(
                        fontSize: SizeTokens.fontXS,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
              ],
            ),

            // ── Help text ────────────────────────────────────────────
            if (field.helpText != null && field.helpText!.isNotEmpty) ...[
              SizedBox(height: SizeTokens.spaceMD),
              Text(
                field.helpText!,
                style: TextStyle(
                  fontSize: SizeTokens.fontSM,
                  color: AppTheme.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],

            // ── Sort order ───────────────────────────────────────────
            SizedBox(height: SizeTokens.spaceSM),
            Text(
              '${l10n.fieldSortOrderLabel}: ${field.sortOrder ?? '—'}',
              style: TextStyle(
                fontSize: SizeTokens.fontXS,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
