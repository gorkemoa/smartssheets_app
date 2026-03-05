import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/app_theme.dart';
import '../../core/responsive/size_config.dart';
import '../../core/responsive/size_tokens.dart';
import '../../l10n/strings.dart';
import '../../models/appointment_model.dart';
import '../../viewmodels/appointments_view_model.dart';
import 'appointment_form_view.dart';

class AppointmentDetailView extends StatelessWidget {
  final int brandId;
  final AppointmentModel appointment;

  const AppointmentDetailView({
    super.key,
    required this.brandId,
    required this.appointment,
  });

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    return _AppointmentDetailBody(
      brandId: brandId,
      appointment: appointment,
    );
  }
}

class _AppointmentDetailBody extends StatelessWidget {
  final int brandId;
  final AppointmentModel appointment;

  const _AppointmentDetailBody({
    required this.brandId,
    required this.appointment,
  });

  Color _statusColor() {
    final color = appointment.status?.color;
    if (color == null) return AppTheme.primary;
    try {
      final hex = color.replaceFirst('#', '');
      return Color(int.parse(hex.length == 6 ? 'FF$hex' : hex, radix: 16));
    } catch (_) {
      return AppTheme.primary;
    }
  }

  String _formatDateTime(String? iso) {
    if (iso == null) return '—';
    try {
      final dt = DateTime.parse(iso).toLocal();
      final date =
          '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';
      final time =
          '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      return '$date $time';
    } catch (_) {
      return iso;
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final l10n = AppStrings.of(context);
    final statusColor = _statusColor();
    final customFields = appointment.customFields;
    final assignees = appointment.assignees ?? [];

    return Scaffold(
      backgroundColor: AppTheme.surfaceVariant,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        foregroundColor: AppTheme.textPrimary,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(SizeConfig.h(1)),
          child: Container(
            height: SizeConfig.h(1),
            color: AppTheme.divider,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            size: SizeTokens.iconMD,
          ),
        ),
        title: Text(
          appointment.title ?? l10n.appointmentDetailTitle,
          style: TextStyle(
            fontSize: SizeTokens.fontLG,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              final viewModel =
                  Provider.of<AppointmentsViewModel>(context, listen: false);
              final result = await Navigator.of(context).push<bool>(
                MaterialPageRoute(
                  builder: (_) => ChangeNotifierProvider.value(
                    value: viewModel,
                    child: AppointmentFormView(
                      brandId: brandId,
                      appointment: appointment,
                    ),
                  ),
                ),
              );
              if (result == true && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.appointmentUpdateSuccess),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                Navigator.of(context).pop(true);
              }
            },
            icon: Icon(
              Icons.edit_rounded,
              size: SizeTokens.iconMD,
              color: AppTheme.primary,
            ),
            tooltip: l10n.appointmentDetailEdit,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(SizeTokens.paddingPage),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Status + time card ───────────────────────────────────
            Container(
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
                  // Status badge
                  if (appointment.status != null)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: SizeTokens.spaceSM,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius:
                            BorderRadius.circular(SizeTokens.radiusSM),
                      ),
                      child: Text(
                        appointment.status!.name ?? '—',
                        style: TextStyle(
                          fontSize: SizeTokens.fontSM,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ),
                  SizedBox(height: SizeTokens.spaceMD),
                  // Start time
                  _DetailRow(
                    icon: Icons.schedule_rounded,
                    label: l10n.appointmentStartsAtLabel,
                    value: _formatDateTime(appointment.startsAt),
                  ),
                  SizedBox(height: SizeTokens.spaceSM),
                  // End time
                  _DetailRow(
                    icon: Icons.schedule_outlined,
                    label: l10n.appointmentEndsAtLabel,
                    value: _formatDateTime(appointment.endsAt),
                  ),
                  // Completed at
                  if (appointment.completedAt != null) ...[
                    SizedBox(height: SizeTokens.spaceSM),
                    _DetailRow(
                      icon: Icons.check_circle_outline_rounded,
                      label: l10n.appointmentDetailCompletedAt,
                      value: _formatDateTime(appointment.completedAt),
                    ),
                  ],
                ],
              ),
            ),

            SizedBox(height: SizeTokens.spaceMD),

            // ── Assignees ────────────────────────────────────────────
            if (assignees.isNotEmpty)
              _SectionCard(
                title: l10n.appointmentDetailAssignees,
                child: Wrap(
                  spacing: SizeTokens.spaceSM,
                  runSpacing: SizeTokens.spaceSM,
                  children: assignees
                      .map(
                        (a) => Chip(
                          avatar: CircleAvatar(
                            backgroundColor:
                                AppTheme.primary.withValues(alpha: 0.15),
                            child: Text(
                              (a.name ?? '?').substring(0, 1).toUpperCase(),
                              style: TextStyle(
                                fontSize: SizeTokens.fontXS,
                                color: AppTheme.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          label: Text(
                            a.name ?? a.email ?? '—',
                            style: TextStyle(
                              fontSize: SizeTokens.fontSM,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          backgroundColor: AppTheme.surfaceVariant,
                          side: BorderSide(color: AppTheme.border),
                        ),
                      )
                      .toList(),
                ),
              ),

            if (assignees.isNotEmpty) SizedBox(height: SizeTokens.spaceMD),

            // ── Notes ────────────────────────────────────────────────
            if (appointment.notes != null && appointment.notes!.isNotEmpty)
              _SectionCard(
                title: l10n.appointmentDetailNotes,
                child: Text(
                  appointment.notes!,
                  style: TextStyle(
                    fontSize: SizeTokens.fontMD,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),

            if (appointment.notes != null && appointment.notes!.isNotEmpty)
              SizedBox(height: SizeTokens.spaceMD),

            // ── Result notes ─────────────────────────────────────────
            if (appointment.resultNotes != null &&
                appointment.resultNotes!.isNotEmpty)
              _SectionCard(
                title: l10n.appointmentDetailResultNotes,
                child: Text(
                  appointment.resultNotes!,
                  style: TextStyle(
                    fontSize: SizeTokens.fontMD,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),

            if (appointment.resultNotes != null &&
                appointment.resultNotes!.isNotEmpty)
              SizedBox(height: SizeTokens.spaceMD),

            // ── Custom fields ────────────────────────────────────────
            if (customFields != null && customFields.isNotEmpty)
              _SectionCard(
                title: l10n.appointmentDetailCustomFields,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: customFields.entries.map((entry) {
                    final value = entry.value;
                    final displayValue = value is List
                        ? value.join(', ')
                        : value?.toString() ?? '—';
                    return Padding(
                      padding: EdgeInsets.only(bottom: SizeTokens.spaceSM),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: SizeTokens.spaceXS,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceVariant,
                              borderRadius:
                                  BorderRadius.circular(SizeTokens.radiusXS),
                              border: Border.all(color: AppTheme.border),
                            ),
                            child: Text(
                              entry.key,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 11,
                                color: Colors.blueGrey,
                              ),
                            ),
                          ),
                          SizedBox(width: SizeTokens.spaceSM),
                          Expanded(
                            child: Text(
                              displayValue,
                              style: TextStyle(
                                fontSize: SizeTokens.fontMD,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),

            SizedBox(height: SizeTokens.spaceXXL),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
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
          Text(
            title,
            style: TextStyle(
              fontSize: SizeTokens.fontSM,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: SizeTokens.spaceMD),
          child,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: SizeTokens.iconSM, color: AppTheme.textSecondary),
        SizedBox(width: SizeTokens.spaceSM),
        Text(
          '$label:  ',
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
              fontWeight: FontWeight.w500,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
