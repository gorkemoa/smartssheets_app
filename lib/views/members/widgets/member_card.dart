import 'package:flutter/material.dart';
import '../../../app/app_theme.dart';
import '../../../core/responsive/size_tokens.dart';
import '../../../l10n/strings.dart';
import '../../../models/membership_model.dart';

class MemberCard extends StatefulWidget {
  final MembershipModel member;
  final AppStrings l10n;
  final VoidCallback? onEdit;

  const MemberCard({
    super.key,
    required this.member,
    required this.l10n,
    this.onEdit,
  });

  @override
  State<MemberCard> createState() => _MemberCardState();
}

class _MemberCardState extends State<MemberCard> {
  bool _isExpanded = false;

  String _roleLabel() {
    switch (widget.member.role) {
      case 'owner':
        return widget.l10n.membersRoleOwner;
      case 'admin':
        return widget.l10n.membersRoleAdmin;
      default:
        return widget.l10n.membersRoleMember;
    }
  }

  Color _roleColor() {
    switch (widget.member.role) {
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
    final isActive = widget.member.status == 'active';
    final perms = widget.member.permissionsJson;
    final roleColor = _roleColor();

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(SizeTokens.radiusLG),
        border: Border(
          left: BorderSide(color: roleColor, width: SizeTokens.spaceXXS),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.05),
            blurRadius: SizeTokens.spaceXS,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: SizeTokens.paddingMD,
          vertical: SizeTokens.paddingSM,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                      // ── Header row ────────────────────────────────────────
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Status dot
                          Container(
                            width: SizeTokens.spaceXXS * 1.5,
                            height: SizeTokens.spaceXXS * 1.5,
                            decoration: BoxDecoration(
                              color: isActive ? AppTheme.success : AppTheme.textHint,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: SizeTokens.spaceXS),
                          // Name
                          Expanded(
                            child: Text(
                              widget.member.user?.name ?? '—',
                              style: TextStyle(
                                fontSize: SizeTokens.fontMD,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: SizeTokens.spaceXS),
                          // Role chip
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: SizeTokens.paddingSM,
                              vertical: SizeTokens.spaceXXS,
                            ),
                            decoration: BoxDecoration(
                              color: roleColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(SizeTokens.radiusCircle),
                            ),
                            child: Text(
                              _roleLabel(),
                              style: TextStyle(
                                fontSize: SizeTokens.fontXS,
                                fontWeight: FontWeight.w600,
                                color: roleColor,
                              ),
                            ),
                          ),
                          SizedBox(width: SizeTokens.spaceXS),
                          // Edit button
                          if (widget.onEdit != null)
                            GestureDetector(
                              onTap: widget.onEdit,
                              child: Icon(
                                Icons.edit_outlined,
                                size: SizeTokens.iconMD,
                                color: AppTheme.textHint,
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: SizeTokens.spaceXXS),
                      // Email
                      Text(
                        widget.member.user?.email ?? '—',
                        style: TextStyle(
                          fontSize: SizeTokens.fontXS,
                          color: AppTheme.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      // ── Permissions section (Accordion) ───────────────────
                      if (perms != null) ...[
                        SizedBox(height: SizeTokens.spaceMD),
                        Divider(
                            color: AppTheme.divider,
                            height: SizeTokens.spaceXS),
                        InkWell(
                          onTap: () => setState(() => _isExpanded = !_isExpanded),
                          borderRadius: BorderRadius.circular(SizeTokens.radiusSM),
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: SizeTokens.spaceSM),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.lock_outline_rounded,
                                  size: SizeTokens.iconSM,
                                  color: AppTheme.textHint,
                                ),
                                SizedBox(width: SizeTokens.spaceXXS),
                                Text(
                                  widget.l10n.membersPermissionsTitle,
                                  style: TextStyle(
                                    fontSize: SizeTokens.fontXS,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textHint,
                                    letterSpacing: 0.4,
                                  ),
                                ),
                                const Spacer(),
                                AnimatedRotation(
                                  duration: const Duration(milliseconds: 200),
                                  turns: _isExpanded ? 0.5 : 0,
                                  child: Icon(
                                    Icons.expand_more_rounded,
                                    size: SizeTokens.iconMD,
                                    color: AppTheme.textHint,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        AnimatedCrossFade(
                          firstChild: const SizedBox(width: double.infinity),
                          secondChild: Padding(
                            padding: EdgeInsets.only(bottom: SizeTokens.spaceSM),
                            child: Wrap(
                              spacing: SizeTokens.spaceXS,
                              runSpacing: SizeTokens.spaceXS,
                              children: [
                                if (perms.createAppointment == true)
                                  _PermChip(label: widget.l10n.membersPermCreateAppointment),
                                if (perms.uploadResult == true)
                                  _PermChip(label: widget.l10n.membersPermUploadResult),
                                if (perms.changeStatus == true)
                                  _PermChip(label: widget.l10n.membersPermChangeStatus),
                                if (perms.manageMembers == true)
                                  _PermChip(label: widget.l10n.membersPermManageMembers),
                                if (perms.manageStatuses == true)
                                  _PermChip(label: widget.l10n.membersPermManageStatuses),
                                if (perms.manageAppointmentFields == true)
                                  _PermChip(
                                      label: widget.l10n.membersPermManageAppointmentFields),
                              ],
                            ),
                          ),
                          crossFadeState: _isExpanded
                              ? CrossFadeState.showSecond
                              : CrossFadeState.showFirst,
                          duration: const Duration(milliseconds: 200),
                        ),
                      ],
                    ],
                  ),
                ),
            );
  }
}

// ─── Internal widgets ─────────────────────────────────────────────────────────

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
        color: AppTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(SizeTokens.radiusSM),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: SizeTokens.fontXS,
          fontWeight: FontWeight.w500,
          color: AppTheme.textSecondary,
        ),
      ),
    );
  }
}
