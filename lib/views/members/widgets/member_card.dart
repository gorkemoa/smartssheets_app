import 'package:flutter/material.dart';
import '../../../app/app_theme.dart';
import '../../../core/responsive/size_tokens.dart';
import '../../../l10n/strings.dart';
import '../../../models/membership_model.dart';

class MemberCard extends StatelessWidget {
  final MembershipModel member;
  final AppStrings l10n;
  final VoidCallback? onEdit;

  const MemberCard({
    super.key,
    required this.member,
    required this.l10n,
    this.onEdit,
  });

  String _roleLabel() {
    switch (member.role) {
      case 'owner':
        return l10n.membersRoleOwner;
      case 'admin':
        return l10n.membersRoleAdmin;
      default:
        return l10n.membersRoleMember;
    }
  }

  Color _roleColor() {
    switch (member.role) {
      case 'owner':
        return AppTheme.primary;
      case 'admin':
        return AppTheme.accent;
      default:
        return AppTheme.textSecondary;
    }
  }

  Color _roleBg() => _roleColor().withValues(alpha: 0.1);

  @override
  Widget build(BuildContext context) {
    final isActive = member.status == 'active';
    final perms = member.permissionsJson;

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
          // ── Header row ───────────────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar circle
              Container(
                width: SizeTokens.avatarMD,
                height: SizeTokens.avatarMD,
                decoration: BoxDecoration(
                  color: _roleColor().withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    (member.user?.name ?? '?').substring(0, 1).toUpperCase(),
                    style: TextStyle(
                      fontSize: SizeTokens.fontLG,
                      fontWeight: FontWeight.w700,
                      color: _roleColor(),
                    ),
                  ),
                ),
              ),
              SizedBox(width: SizeTokens.spaceMD),
              // Name & email
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.user?.name ?? '—',
                      style: TextStyle(
                        fontSize: SizeTokens.fontLG,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    SizedBox(height: SizeTokens.spaceXXS),
                    Text(
                      member.user?.email ?? '—',
                      style: TextStyle(
                        fontSize: SizeTokens.fontSM,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: SizeTokens.spaceXS),
              // Status badge
              _Badge(
                label: isActive
                    ? l10n.membersStatusActive
                    : l10n.membersStatusInactive,
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
          // ── Role badge ───────────────────────────────────────────────────
          _Badge(
            label: _roleLabel(),
            color: _roleColor(),
            background: _roleBg(),
          ),
          // ── Permissions ──────────────────────────────────────────────────
          if (perms != null) ...[
            SizedBox(height: SizeTokens.spaceMD),
            Divider(color: AppTheme.divider, height: SizeTokens.spaceXS),
            SizedBox(height: SizeTokens.spaceSM),
            Text(
              l10n.membersPermissionsTitle,
              style: TextStyle(
                fontSize: SizeTokens.fontSM,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
            ),
            SizedBox(height: SizeTokens.spaceSM),
            Wrap(
              spacing: SizeTokens.spaceXS,
              runSpacing: SizeTokens.spaceXS,
              children: [
                if (perms.createAppointment == true)
                  _PermChip(label: l10n.membersPermCreateAppointment),
                if (perms.uploadResult == true)
                  _PermChip(label: l10n.membersPermUploadResult),
                if (perms.changeStatus == true)
                  _PermChip(label: l10n.membersPermChangeStatus),
                if (perms.manageMembers == true)
                  _PermChip(label: l10n.membersPermManageMembers),
                if (perms.manageStatuses == true)
                  _PermChip(label: l10n.membersPermManageStatuses),
                if (perms.manageAppointmentFields == true)
                  _PermChip(label: l10n.membersPermManageAppointmentFields),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Internal widgets ─────────────────────────────────────────────────────────

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  final Color background;

  const _Badge({
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

class _PermChip extends StatelessWidget {
  final String label;

  const _PermChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: SizeTokens.paddingSM,
        vertical: SizeTokens.spaceXXS,
      ),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(SizeTokens.radiusSM),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: SizeTokens.fontXS,
          fontWeight: FontWeight.w500,
          color: AppTheme.primary,
        ),
      ),
    );
  }
}
