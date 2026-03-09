import 'package:flutter/material.dart';
import '../../../app/app_theme.dart';
import '../../../core/responsive/size_config.dart';
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
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(SizeTokens.radiusMD),
        border: Border.all(color: AppTheme.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(SizeTokens.radiusMD),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Left role accent bar ──────────────────────────────────
              Container(
                width: SizeConfig.w(3),
                color: _roleColor(),
              ),
              // ── Card content ──────────────────────────────────────────
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: SizeTokens.paddingMD,
                    vertical: SizeTokens.spaceSM,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Row 1: email + role badge
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              invitation.email ?? '—',
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
                          _InvBadge(
                            label: _roleLabel(),
                            color: _roleColor(),
                            background: _roleColor().withValues(alpha: 0.1),
                          ),
                        ],
                      ),
                      SizedBox(height: SizeTokens.spaceXXS),
                      // Row 2: status badge + expiry date
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _InvBadge(
                            label: isAccepted
                                ? l10n.invitationAcceptedLabel
                                : l10n.invitationPendingLabel,
                            color: isAccepted
                                ? AppTheme.accent
                                : AppTheme.warning,
                            background: isAccepted
                                ? AppTheme.accent.withValues(alpha: 0.1)
                                : AppTheme.warning.withValues(alpha: 0.1),
                          ),
                          SizedBox(width: SizeTokens.spaceXS),
                          Icon(
                            Icons.schedule_rounded,
                            size: SizeTokens.iconSM,
                            color: AppTheme.textHint,
                          ),
                          SizedBox(width: SizeTokens.spaceXXS),
                          Text(
                            _formatDate(invitation.expiresAt),
                            style: TextStyle(
                              fontSize: SizeTokens.fontXS,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      // Row 3: action buttons (only if not accepted)
                      if (!isAccepted &&
                          (onResend != null || onDelete != null)) ...[
                        SizedBox(height: SizeTokens.spaceSM),
                        Row(
                          children: [
                            if (onResend != null)
                              _TextAction(
                                label: l10n.invitationResendButton,
                                color: AppTheme.primary,
                                onTap: onResend!,
                              ),
                            if (onResend != null && onDelete != null)
                              SizedBox(width: SizeTokens.spaceXS),
                            if (onDelete != null)
                              _TextAction(
                                label: l10n.invitationDeleteButton,
                                color: AppTheme.error,
                                onTap: onDelete!,
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
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
        horizontal: SizeTokens.paddingXS,
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

// ── Text action button ───────────────────────────────────────────────────────

class _TextAction extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _TextAction({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: SizeTokens.paddingXS,
          vertical: SizeTokens.spaceXXS,
        ),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(SizeTokens.radiusSM),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: SizeTokens.fontXS,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}


