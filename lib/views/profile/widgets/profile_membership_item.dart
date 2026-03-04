import 'package:flutter/material.dart';
import '../../../app/app_theme.dart';
import '../../../core/responsive/size_tokens.dart';
import '../../../models/membership_model.dart';
import '../../../models/membership_permissions_model.dart';

class ProfileMembershipItem extends StatelessWidget {
  final MembershipModel membership;
  final String roleLabel;
  final String permissionsTitle;
  final String planLabel;
  final String subscriptionActiveLabel;
  final String subscriptionInactiveLabel;
  final String subscriptionExpiresLabel;
  final String memberLimitLabel;
  final String timezoneLabel;
  final Map<String, String> permissionLabels;

  const ProfileMembershipItem({
    super.key,
    required this.membership,
    required this.roleLabel,
    required this.permissionsTitle,
    required this.planLabel,
    required this.subscriptionActiveLabel,
    required this.subscriptionInactiveLabel,
    required this.subscriptionExpiresLabel,
    required this.memberLimitLabel,
    required this.timezoneLabel,
    required this.permissionLabels,
  });

  @override
  Widget build(BuildContext context) {
    final permissions = membership.permissionsJson;
    final brand = membership.brand;
    final isActive = membership.status == 'active';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(SizeTokens.radiusXL),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header: brand + role ────────────────────────────────────────────
          Container(
            padding: EdgeInsets.all(SizeTokens.paddingXL),
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(SizeTokens.radiusXL),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        brand?.name ?? '—',
                        style: TextStyle(
                          fontSize: SizeTokens.fontLG,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textOnPrimary,
                        ),
                      ),
                      SizedBox(height: SizeTokens.spaceXXS),
                      Row(
                        children: [
                          _RoleBadge(role: membership.role ?? '—'),
                          if (isActive) ...[
                            SizedBox(width: SizeTokens.spaceXS),
                            _ActiveDot(),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                if (brand?.subscriptionStatus != null)
                  _SubStatusBadge(
                    isActive: brand!.subscriptionStatus == 'active',
                    activeLabel: subscriptionActiveLabel,
                    inactiveLabel: subscriptionInactiveLabel,
                  ),
              ],
            ),
          ),

          // ── Brand info ─────────────────────────────────────────────────────
          if (brand != null)
            Padding(
              padding: EdgeInsets.fromLTRB(
                SizeTokens.paddingXL,
                SizeTokens.spaceMD,
                SizeTokens.paddingXL,
                0,
              ),
              child: Column(
                children: [
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
            ),

          // ── Permissions ────────────────────────────────────────────────────
          if (permissions != null) ...[
            Padding(
              padding: EdgeInsets.fromLTRB(
                SizeTokens.paddingXL,
                SizeTokens.spaceMD,
                SizeTokens.paddingXL,
                0,
              ),
              child: Text(
                permissionsTitle,
                style: TextStyle(
                  fontSize: SizeTokens.fontSM,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                SizeTokens.paddingXL,
                SizeTokens.spaceXS,
                SizeTokens.paddingXL,
                SizeTokens.paddingXL,
              ),
              child: _PermissionsWrap(
                permissions: permissions,
                permissionLabels: permissionLabels,
              ),
            ),
          ] else
            SizedBox(height: SizeTokens.paddingXL),
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

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _RoleBadge extends StatelessWidget {
  final String role;
  const _RoleBadge({required this.role});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: SizeTokens.paddingSM,
        vertical: SizeTokens.spaceXXS,
      ),
      decoration: BoxDecoration(
        color: AppTheme.textOnPrimary.withValues(alpha: 0.15),
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
      ],
    );
  }
}

class _SubStatusBadge extends StatelessWidget {
  final bool isActive;
  final String activeLabel;
  final String inactiveLabel;

  const _SubStatusBadge({
    required this.isActive,
    required this.activeLabel,
    required this.inactiveLabel,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? const Color(0xFF34C759) : AppTheme.error;
    final bg = isActive
        ? const Color(0xFF34C759).withValues(alpha: 0.15)
        : AppTheme.error.withValues(alpha: 0.15);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: SizeTokens.paddingSM,
        vertical: SizeTokens.spaceXXS,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(SizeTokens.radiusCircle),
      ),
      child: Text(
        isActive ? activeLabel : inactiveLabel,
        style: TextStyle(
          fontSize: SizeTokens.fontXS,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
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

class _PermissionsWrap extends StatelessWidget {
  final MembershipPermissionsModel permissions;
  final Map<String, String> permissionLabels;

  const _PermissionsWrap({
    required this.permissions,
    required this.permissionLabels,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      _PermItem(
        label: permissionLabels['create_appointment'] ?? '',
        granted: permissions.createAppointment ?? false,
      ),
      _PermItem(
        label: permissionLabels['upload_result'] ?? '',
        granted: permissions.uploadResult ?? false,
      ),
      _PermItem(
        label: permissionLabels['change_status'] ?? '',
        granted: permissions.changeStatus ?? false,
      ),
      _PermItem(
        label: permissionLabels['manage_members'] ?? '',
        granted: permissions.manageMembers ?? false,
      ),
      _PermItem(
        label: permissionLabels['manage_statuses'] ?? '',
        granted: permissions.manageStatuses ?? false,
      ),
      _PermItem(
        label: permissionLabels['manage_appointment_fields'] ?? '',
        granted: permissions.manageAppointmentFields ?? false,
      ),
    ];

    return Wrap(
      spacing: SizeTokens.spaceXS,
      runSpacing: SizeTokens.spaceXS,
      children: items.map((item) {
        final color =
            item.granted ? const Color(0xFF34C759) : AppTheme.textHint;
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
                item.granted
                    ? Icons.check_circle_rounded
                    : Icons.remove_circle_outline_rounded,
                size: SizeTokens.iconSM,
                color: color,
              ),
              SizedBox(width: SizeTokens.spaceXXS),
              Text(
                item.label,
                style: TextStyle(
                  fontSize: SizeTokens.fontXS,
                  color:
                      item.granted ? AppTheme.textPrimary : AppTheme.textHint,
                  fontWeight:
                      item.granted ? FontWeight.w500 : FontWeight.w400,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _PermItem {
  final String label;
  final bool granted;
  const _PermItem({required this.label, required this.granted});
}
