import 'package:flutter/material.dart';
import '../../../app/app_theme.dart';
import '../../../core/responsive/size_config.dart';
import '../../../core/responsive/size_tokens.dart';
import '../../../models/membership_model.dart';
import '../../../models/membership_permissions_model.dart';

class ProfileMembershipItem extends StatefulWidget {
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
  State<ProfileMembershipItem> createState() => _ProfileMembershipItemState();
}

class _ProfileMembershipItemState extends State<ProfileMembershipItem> {
  bool _permissionsExpanded = false;

  Color _roleColor(String? role) {
    switch (role) {
      case 'owner':
        return AppTheme.primary;
      case 'admin':
        return AppTheme.accent;
      default:
        return AppTheme.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final permissions = widget.membership.permissionsJson;
    final brand = widget.membership.brand;
    final roleColor = _roleColor(widget.membership.role);
    final brandInitial = (brand?.name?.isNotEmpty == true)
        ? brand!.name![0].toUpperCase()
        : '?';

    return ClipRRect(
      borderRadius: BorderRadius.circular(SizeTokens.radiusMD),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(SizeTokens.radiusMD),
          border: Border.all(color: AppTheme.border),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Sol aksent çizgisi
              Container(width: 3, color: roleColor),
              Expanded(
                child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header satırı ─────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: SizeTokens.paddingMD,
              vertical: SizeTokens.paddingSM,
            ),
            child: Row(
              children: [
                Container(
                  width: SizeConfig.r(32),
                  height: SizeConfig.r(32),
                  decoration: BoxDecoration(
                    color: roleColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(SizeTokens.radiusSM),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    brandInitial,
                    style: TextStyle(
                      fontSize: SizeTokens.fontMD,
                      fontWeight: FontWeight.w700,
                      color: roleColor,
                    ),
                  ),
                ),
                SizedBox(width: SizeTokens.spaceSM),
                Expanded(
                  child: Text(
                    brand?.name ?? '—',
                    style: TextStyle(
                      fontSize: SizeTokens.fontMD,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                      letterSpacing: -0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: SizeTokens.spaceXS),
                _RoleBadge(role: widget.membership.role ?? '—', color: roleColor),
                if (brand?.subscriptionStatus != null) ...[
                  SizedBox(width: SizeTokens.spaceXS),
                  _SubStatusBadge(
                    isActive: brand!.subscriptionStatus == 'active',
                    activeLabel: widget.subscriptionActiveLabel,
                    inactiveLabel: widget.subscriptionInactiveLabel,
                  ),
                ],
              ],
            ),
          ),

          // ── Brand info satırları ──────────────────────────────────────────
          if (brand != null) ...[
            Container(height: 0.5, color: AppTheme.divider),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: SizeTokens.paddingMD,
                vertical: SizeTokens.paddingSM,
              ),
              child: Column(
                children: [
                  _InfoRow(
                    icon: Icons.layers_outlined,
                    label: widget.planLabel,
                    value: (brand.currentPlan ?? '—').toUpperCase(),
                  ),
                  _InfoRow(
                    icon: Icons.group_outlined,
                    label: widget.memberLimitLabel,
                    value: brand.memberLimit?.toString() ?? '—',
                  ),
                  if (brand.subscriptionExpiresAt != null)
                    _InfoRow(
                      icon: Icons.event_outlined,
                      label: widget.subscriptionExpiresLabel,
                      value: _formatDate(brand.subscriptionExpiresAt!),
                    ),
                  if (brand.timezone != null)
                    _InfoRow(
                      icon: Icons.schedule_outlined,
                      label: widget.timezoneLabel,
                      value: brand.timezone!,
                    ),
                ],
              ),
            ),
          ],

          // ── İzinler accordion ─────────────────────────────────────────────
          if (permissions != null) ...[
            Container(height: 0.5, color: AppTheme.divider),
            InkWell(
              onTap: () =>
                  setState(() => _permissionsExpanded = !_permissionsExpanded),
              borderRadius: BorderRadius.vertical(
                bottom: _permissionsExpanded
                    ? Radius.zero
                    : Radius.circular(SizeTokens.radiusMD),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: SizeTokens.paddingMD,
                  vertical: SizeTokens.paddingSM,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.shield_outlined,
                      size: SizeTokens.iconSM,
                      color: AppTheme.textHint,
                    ),
                    SizedBox(width: SizeTokens.spaceXS),
                    Text(
                      widget.permissionsTitle,
                      style: TextStyle(
                        fontSize: SizeTokens.fontXS,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textSecondary,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      _permissionsExpanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      size: SizeTokens.iconSM,
                      color: AppTheme.textHint,
                    ),
                  ],
                ),
              ),
            ),
            if (_permissionsExpanded) ...[
              Container(height: 0.5, color: AppTheme.divider),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  SizeTokens.paddingMD,
                  SizeTokens.spaceXS,
                  SizeTokens.paddingMD,
                  SizeTokens.paddingMD,
                ),
                child: _PermissionsWrap(
                  permissions: permissions,
                  permissionLabels: widget.permissionLabels,
                ),
              ),
            ],
          ],
        ],
              ),
            ),
            ],
          ),
        ),
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
  final Color color;
  const _RoleBadge({required this.role, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: SizeTokens.spaceXS,
        vertical: SizeTokens.spaceXXS,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        border: Border.all(color: color.withValues(alpha: 0.25)),
        borderRadius: BorderRadius.circular(SizeTokens.radiusXS),
      ),
      child: Text(
        role.toUpperCase(),
        style: TextStyle(
          fontSize: SizeTokens.fontXS,
          fontWeight: FontWeight.w600,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
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
    return Padding(
      padding: EdgeInsets.symmetric(vertical: SizeTokens.spaceXXS),
      child: Row(
        children: [
          Icon(icon, size: SizeTokens.iconSM, color: AppTheme.textHint),
          SizedBox(width: SizeTokens.spaceXS),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: SizeTokens.fontXS,
                    color: AppTheme.textSecondary,
                  ),
                ),
                Flexible(
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: SizeTokens.fontXS,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
            item.granted ? AppTheme.success : AppTheme.textHint;
        final bgColor = item.granted
            ? AppTheme.successLight
            : AppTheme.surfaceVariant;
        final borderColor = item.granted
            ? AppTheme.success.withValues(alpha: 0.3)
            : AppTheme.border;

        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: SizeTokens.paddingSM,
            vertical: SizeTokens.spaceXXS,
          ),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(SizeTokens.radiusCircle),
            border: Border.all(color: borderColor),
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
