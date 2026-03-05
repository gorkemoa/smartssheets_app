import 'package:flutter/material.dart';
import '../../../app/app_theme.dart';
import '../../../core/responsive/size_tokens.dart';
import '../../../models/appointment_model.dart';

class AppointmentCard extends StatelessWidget {
  final AppointmentModel appointment;
  final VoidCallback? onTap;

  const AppointmentCard({
    super.key,
    required this.appointment,
    this.onTap,
  });

  Color _statusColor() {
    final color = appointment.status?.color;
    if (color == null) return AppTheme.textSecondary;
    try {
      final hex = color.replaceFirst('#', '');
      return Color(int.parse(hex.length == 6 ? 'FF$hex' : hex, radix: 16));
    } catch (_) {
      return AppTheme.textSecondary;
    }
  }

  String _formatTime(DateTime? dt) {
    if (dt == null) return '—';
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor();
    final startTime = _formatTime(appointment.startsAtDateTime);
    final endTime = _formatTime(appointment.endsAtDateTime);
    final hasAssignees =
        appointment.assignees != null && appointment.assignees!.isNotEmpty;

    return Material(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(SizeTokens.radiusXL),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(SizeTokens.radiusXL),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(SizeTokens.radiusXL),
            border: Border.all(color: AppTheme.border),
          ),
          child: IntrinsicHeight(
            child: Row(
              children: [
                // Status color strip
                Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(SizeTokens.radiusXL),
                      bottomLeft: Radius.circular(SizeTokens.radiusXL),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(SizeTokens.paddingMD),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title + time row
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                appointment.title ?? '—',
                                style: TextStyle(
                                  fontSize: SizeTokens.fontMD,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            ),
                            SizedBox(width: SizeTokens.spaceXS),
                            Text(
                              '$startTime – $endTime',
                              style: TextStyle(
                                fontSize: SizeTokens.fontXS,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        // Status badge
                        if (appointment.status?.name != null) ...[
                          SizedBox(height: SizeTokens.spaceXXS),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: SizeTokens.spaceSM,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.12),
                              borderRadius:
                                  BorderRadius.circular(SizeTokens.radiusSM),
                            ),
                            child: Text(
                              appointment.status!.name!,
                              style: TextStyle(
                                fontSize: SizeTokens.fontXS,
                                fontWeight: FontWeight.w600,
                                color: statusColor,
                              ),
                            ),
                          ),
                        ],
                        // Assignees
                        if (hasAssignees) ...[
                          SizedBox(height: SizeTokens.spaceXXS),
                          Row(
                            children: [
                              Icon(
                                Icons.people_outline_rounded,
                                size: SizeTokens.iconSM,
                                color: AppTheme.textSecondary,
                              ),
                              SizedBox(width: SizeTokens.spaceXXS),
                              Text(
                                appointment.assignees!
                                    .map((a) => a.name ?? '')
                                    .join(', '),
                                style: TextStyle(
                                  fontSize: SizeTokens.fontXS,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                        // Notes preview
                        if (appointment.notes != null &&
                            appointment.notes!.isNotEmpty) ...[
                          SizedBox(height: SizeTokens.spaceXXS),
                          Text(
                            appointment.notes!,
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
                    ),
                  ),
                ),
                // Chevron
                Padding(
                  padding: EdgeInsets.only(right: SizeTokens.spaceMD),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    size: SizeTokens.iconMD,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
