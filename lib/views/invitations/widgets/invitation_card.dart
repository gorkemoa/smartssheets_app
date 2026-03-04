import 'package:flutter/material.dart';
import '../../../app/app_theme.dart';
import '../../../core/responsive/size_tokens.dart';
import '../../../l10n/strings.dart';
import '../../../models/invitation_model.dart';

class InvitationCard extends StatelessWidget {
  final InvitationModel invitation;
  final AppStrings l10n;
  final VoidCallback? onResend;
  final VoidCallback? onDelete;

  const InvitationCard({
    super.key,
    required this.invitation,
    required this.l10n,
    this.onResend,
    this.onDelete,
  });

  String _roleLabel() {
    switch (invitation.role) {
      case 'owner':
        return l10n.membersRoleOwner;
      case 'admin':
        return l10n.membersRoleAdmin;
      default:
        return l10n.membersRoleMember;
    }
  }

  Color _roleColor() {
    switch (invitation.role) {
      case 'owner':
        return AppTheme.primary;
      case 'admin':
        return AppTheme.accent;
      default:
        return AppTheme.textSecondary;
    }
  }

  Color _roleBg() => _roleColor().withValues(alpha: 0.1);

  String _formatDate(String? iso) {
    if (iso == null) return '—';
    try {
      final dt = DateTime.parse(iso).toLocal();
      return '${dt.day.toString().padLeft(2, '0')}.'
          '${dt.month.toString().padLeft(2, '0')}.'
          '${dt.year}';
    } catch (_) {
      return iso;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAccepted = invitation.acceptedAt != null;

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
          // ── Header row ─────────────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar placeholder (envelope icon)
              Container(
                width: SizeTokens.avatarMD,
                height: SizeTokens.avatarMD,
                decoration: BoxDecoration(
                  color: _roleColor().withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.mail_outline_rounded,
                  size: SizeTokens.iconMD,
                  color: _roleColor(),
                ),
              ),
              SizedBox(width: SizeTokens.spaceMD),
              // Email
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      invitation.email ?? '—',
                      style: TextStyle(
                        fontSize: SizeTokens.fontLG,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    SizedBox(height: SizeTokens.spaceXXS),
                    // Accepted / Pending status
                    Row(
                      children: [
                        _InvBadge(
                          label: isAccepted
                              ? l10n.invitationAcceptedLabel
                              : l10n.invitationPendingLabel,
                          color: isAccepted ? AppTheme.accent : AppTheme.primary,
                          background: isAccepted
                              ? AppTheme.accent.withValues(alpha: 0.1)
                              : AppTheme.primary.withValues(alpha: 0.1),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Role badge
              _InvBadge(
                label: _roleLabel(),
                color: _roleColor(),
                background: _roleBg(),
              ),
            ],
          ),
          SizedBox(height: SizeTokens.spaceMD),
          Divider(color: AppTheme.divider, height: SizeTokens.spaceXS),
          SizedBox(height: SizeTokens.spaceSM),
          // ── Dates ──────────────────────────────────────────────────────
          Row(
            children: [
              Icon(
                Icons.schedule_rounded,
                size: SizeTokens.iconSM,
                color: AppTheme.textSecondary,
              ),
              SizedBox(width: SizeTokens.spaceXXS),
              Text(
                '${l10n.invitationExpiresLabel}: ${_formatDate(invitation.expiresAt)}',
                style: TextStyle(
                  fontSize: SizeTokens.fontSM,
                  color: AppTheme.textSecondary,
                ),
              ),
              if (isAccepted) ...[
                SizedBox(width: SizeTokens.spaceMD),
                Icon(
                  Icons.check_circle_outline_rounded,
                  size: SizeTokens.iconSM,
                  color: AppTheme.accent,
                ),
                SizedBox(width: SizeTokens.spaceXXS),
                Text(
                  '${l10n.invitationAcceptedLabel}: ${_formatDate(invitation.acceptedAt)}',
                  style: TextStyle(
                    fontSize: SizeTokens.fontSM,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ],
          ),
          // ── Action buttons (only if not accepted) ──────────────────────
          if (!isAccepted && (onResend != null || onDelete != null)) ...[
            SizedBox(height: SizeTokens.spaceMD),
            Row(
              children: [
                if (onResend != null)
                  _ActionButton(
                    label: l10n.invitationResendButton,
                    icon: Icons.send_rounded,
                    color: AppTheme.primary,
                    onTap: onResend!,
                  ),
                if (onResend != null && onDelete != null)
                  SizedBox(width: SizeTokens.spaceSM),
                if (onDelete != null)
                  _ActionButton(
                    label: l10n.invitationDeleteButton,
                    icon: Icons.cancel_outlined,
                    color: AppTheme.error,
                    onTap: onDelete!,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ── Internal badge ──────────────────────────────────────────────────────────

class _InvBadge extends StatelessWidget {
  final String label;
  final Color color;
  final Color background;

  const _InvBadge({
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

// ── Action button ───────────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: SizeTokens.paddingMD,
          vertical: SizeTokens.spaceXXS + 2,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(SizeTokens.radiusMD),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: SizeTokens.iconSM, color: color),
            SizedBox(width: SizeTokens.spaceXXS),
            Text(
              label,
              style: TextStyle(
                fontSize: SizeTokens.fontXS,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
