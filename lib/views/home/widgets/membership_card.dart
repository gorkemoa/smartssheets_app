import 'package:flutter/material.dart';
import '../../../app/app_theme.dart';
import '../../../core/responsive/size_tokens.dart';
import '../../../models/membership_model.dart';
import '../../../models/membership_permissions_model.dart';

class MembershipCard extends StatelessWidget {
  final MembershipModel membership;
  final String roleLabel;
  final String permissionsTitle;
  final Map<String, String> permissionLabels;

  const MembershipCard({
    super.key,
    required this.membership,
    required this.roleLabel,
    required this.permissionsTitle,
    required this.permissionLabels,
  });

  @override
  Widget build(BuildContext context) {
    final permissions = membership.permissionsJson;

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
            children: [
              _RoleBadge(role: membership.role ?? '—'),
              SizedBox(width: SizeTokens.spaceXS),
              if (membership.status == 'active')
                _ActiveDot(),
            ],
          ),
          if (permissions != null) ...[
            SizedBox(height: SizeTokens.spaceMD),
            Text(
              permissionsTitle,
              style: TextStyle(
                fontSize: SizeTokens.fontSM,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
            ),
            SizedBox(height: SizeTokens.spaceXS),
            _PermissionsGrid(
              permissions: permissions,
              permissionLabels: permissionLabels,
            ),
          ],
        ],
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  final String role;

  const _RoleBadge({required this.role});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: SizeTokens.paddingMD,
        vertical: SizeTokens.spaceXXS,
      ),
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.circular(SizeTokens.radiusCircle),
      ),
      child: Text(
        role.toUpperCase(),
        style: TextStyle(
          fontSize: SizeTokens.fontXS,
          fontWeight: FontWeight.w700,
          color: AppTheme.textOnPrimary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _ActiveDot extends StatelessWidget {
  const _ActiveDot();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: SizeTokens.spaceXS,
          height: SizeTokens.spaceXS,
          decoration: const BoxDecoration(
            color: Color(0xFF34C759),
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: SizeTokens.spaceXXS),
        Text(
          'active',
          style: TextStyle(
            fontSize: SizeTokens.fontXS,
            color: const Color(0xFF34C759),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _PermissionsGrid extends StatelessWidget {
  final MembershipPermissionsModel permissions;
  final Map<String, String> permissionLabels;

  const _PermissionsGrid({
    required this.permissions,
    required this.permissionLabels,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      _PermItem(
        label: permissionLabels['create_appointment'] ?? 'Create Appointment',
        granted: permissions.createAppointment ?? false,
      ),
      _PermItem(
        label: permissionLabels['upload_result'] ?? 'Upload Result',
        granted: permissions.uploadResult ?? false,
      ),
      _PermItem(
        label: permissionLabels['change_status'] ?? 'Change Status',
        granted: permissions.changeStatus ?? false,
      ),
      _PermItem(
        label: permissionLabels['manage_members'] ?? 'Manage Members',
        granted: permissions.manageMembers ?? false,
      ),
      _PermItem(
        label: permissionLabels['manage_statuses'] ?? 'Manage Statuses',
        granted: permissions.manageStatuses ?? false,
      ),
      _PermItem(
        label:
            permissionLabels['manage_appointment_fields'] ?? 'Appointment Fields',
        granted: permissions.manageAppointmentFields ?? false,
      ),
    ];

    return Wrap(
      spacing: SizeTokens.spaceXS,
      runSpacing: SizeTokens.spaceXS,
      children: items.map((item) => _PermChip(item: item)).toList(),
    );
  }
}

class _PermItem {
  final String label;
  final bool granted;

  const _PermItem({required this.label, required this.granted});
}

class _PermChip extends StatelessWidget {
  final _PermItem item;

  const _PermChip({required this.item});

  @override
  Widget build(BuildContext context) {
    final color = item.granted ? const Color(0xFF34C759) : AppTheme.textHint;
    final bgColor = item.granted
        ? const Color(0xFF34C759).withValues(alpha: 0.1)
        : AppTheme.surfaceVariant;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: SizeTokens.paddingSM,
        vertical: SizeTokens.spaceXXS,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(SizeTokens.radiusCircle),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            item.granted ? Icons.check_circle_rounded : Icons.remove_circle_outline_rounded,
            size: SizeTokens.iconSM,
            color: color,
          ),
          SizedBox(width: SizeTokens.spaceXXS),
          Text(
            item.label,
            style: TextStyle(
              fontSize: SizeTokens.fontXS,
              color: item.granted ? AppTheme.textPrimary : AppTheme.textHint,
              fontWeight: item.granted ? FontWeight.w500 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
