import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/app_theme.dart';
import '../../core/responsive/size_config.dart';
import '../../core/responsive/size_tokens.dart';
import '../../l10n/strings.dart';
import '../../viewmodels/profile_view_model.dart';
import '../login/login_view.dart';
import 'widgets/profile_membership_item.dart';
import 'widgets/profile_menu_item.dart';
import 'widgets/profile_section_container.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProfileViewModel(),
      child: const _ProfileBody(),
    );
  }
}

class _ProfileBody extends StatefulWidget {
  const _ProfileBody();

  @override
  State<_ProfileBody> createState() => _ProfileBodyState();
}

class _ProfileBodyState extends State<_ProfileBody> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<ProfileViewModel>().init();
    });
  }

  Future<void> _onLogout(ProfileViewModel viewModel) async {
    final success = await viewModel.logout();
    if (!mounted) return;
    if (success) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginView()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final l10n = AppStrings.of(context);

    return Scaffold(
      backgroundColor: AppTheme.surfaceVariant,
      body: Consumer<ProfileViewModel>(
        builder: (context, viewModel, _) {
          return NestedScrollView(
            headerSliverBuilder: (_, __) => [
              SliverAppBar(
                pinned: true,
                backgroundColor: AppTheme.surface,
                foregroundColor: AppTheme.textPrimary,
                automaticallyImplyLeading: false,
                toolbarHeight: SizeTokens.appBarHeight,
                title: Text(
                  l10n.profileTitle,
                  style: TextStyle(
                    fontSize: SizeTokens.fontXL,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                titleSpacing: SizeTokens.paddingMD,
                actions: [
                  IconButton(
                    onPressed: () => _onLogout(viewModel),
                    icon: Icon(Icons.logout_rounded, color: AppTheme.error),
                    tooltip: l10n.profileLogout,
                  ),
                  SizedBox(width: SizeTokens.spaceXS),
                ],
                bottom: PreferredSize(
                  preferredSize: Size.fromHeight(SizeConfig.h(1)),
                  child: Container(
                    height: SizeConfig.h(0.5),
                    color: AppTheme.divider,
                  ),
                ),
              ),
            ],
            body: viewModel.isLoading
                ? const Center(child: CircularProgressIndicator())
                : viewModel.errorMessage != null
                    ? _ErrorState(
                        message: viewModel.errorMessage!,
                        retryLabel: l10n.profileRetry,
                        onRetry: () => viewModel.onRetry(),
                      )
                    : viewModel.meResponse != null
                        ? _ProfileContent(
                            viewModel: viewModel,
                            l10n: l10n,
                            onLogout: () => _onLogout(viewModel),
                          )
                        : const SizedBox.shrink(),
          );
        },
      ),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  final ProfileViewModel viewModel;
  final AppStrings l10n;
  final VoidCallback onLogout;

  const _ProfileContent({
    required this.viewModel,
    required this.l10n,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final user = viewModel.meResponse!.user;

    return RefreshIndicator(
      onRefresh: viewModel.refresh,
      child: ListView(
        padding: EdgeInsets.symmetric(vertical: SizeTokens.spaceXL),
        children: [
          _UserCard(user: user, l10n: l10n),
          SizedBox(height: SizeTokens.spaceXL),

          _MembershipsSection(viewModel: viewModel, l10n: l10n),
          SizedBox(height: SizeTokens.spaceXL),

          ProfileSectionContainer(
            title: l10n.profileSectionAccountHelp,
            children: [
              ProfileMenuItem(
                icon: Icons.person_outline_rounded,
                label: l10n.profileUserInformation,
                onTap: () {},
              ),
              ProfileMenuItem(
                icon: Icons.lock_outline_rounded,
                label: l10n.profileChangePassword,
                isLast: true,
                onTap: () {},
              ),
            ],
          ),
          SizedBox(height: SizeTokens.spaceXXL),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: SizeTokens.paddingMD),
            child: _LogoutButton(label: l10n.profileLogout, onLogout: onLogout),
          ),
          SizedBox(height: SizeTokens.spaceXXXL),
        ],
      ),
    );
  }
}

class _MembershipsSection extends StatefulWidget {
  final ProfileViewModel viewModel;
  final AppStrings l10n;

  const _MembershipsSection({
    required this.viewModel,
    required this.l10n,
  });

  @override
  State<_MembershipsSection> createState() => _MembershipsSectionState();
}

class _MembershipsSectionState extends State<_MembershipsSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final memberships = widget.viewModel.meResponse?.user?.memberships ?? [];
    final l10n = widget.l10n;
    final permissionLabels = {
      'create_appointment': l10n.profilePermCreateAppointment,
      'upload_result': l10n.profilePermUploadResult,
      'change_status': l10n.profilePermChangeStatus,
      'manage_members': l10n.profilePermManageMembers,
      'manage_statuses': l10n.profilePermManageStatuses,
      'manage_appointment_fields': l10n.profilePermManageAppointmentFields,
    };

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: SizeTokens.paddingMD),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(SizeTokens.radiusXL),
          border: Border.all(color: AppTheme.border),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withValues(alpha: 0.04),
              blurRadius: SizeTokens.spaceMD,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            InkWell(
              onTap: memberships.isEmpty
                  ? null
                  : () => setState(() => _expanded = !_expanded),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(SizeTokens.radiusXL),
                bottom: _expanded
                    ? Radius.zero
                    : Radius.circular(SizeTokens.radiusXL),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: SizeTokens.paddingXL,
                  vertical: SizeTokens.paddingMD,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.business_center_outlined,
                      size: SizeTokens.iconMD,
                      color: AppTheme.primary,
                    ),
                    SizedBox(width: SizeTokens.spaceMD),
                    Expanded(
                      child: Text(
                        l10n.profileMembershipsTitle,
                        style: TextStyle(
                          fontSize: SizeTokens.fontMD,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                    if (memberships.isNotEmpty)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: SizeTokens.spaceXS,
                          vertical: SizeTokens.spaceXXS,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.1),
                          borderRadius:
                              BorderRadius.circular(SizeTokens.radiusXS),
                        ),
                        child: Text(
                          '${memberships.length}',
                          style: TextStyle(
                            fontSize: SizeTokens.fontXS,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primary,
                          ),
                        ),
                      ),
                    SizedBox(width: SizeTokens.spaceXS),
                    Icon(
                      memberships.isEmpty
                          ? Icons.chevron_right_rounded
                          : _expanded
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                      size: SizeTokens.iconMD,
                      color: AppTheme.textHint,
                    ),
                  ],
                ),
              ),
            ),
            if (_expanded && memberships.isNotEmpty) ...[
              Container(height: 0.5, color: AppTheme.divider),
              Padding(
                padding: EdgeInsets.all(SizeTokens.paddingMD),
                child: Column(
                  children: memberships
                      .map(
                        (membership) => Padding(
                          padding: EdgeInsets.only(bottom: SizeTokens.spaceMD),
                          child: ProfileMembershipItem(
                            membership: membership,
                            roleLabel: l10n.profileRoleLabel,
                            permissionsTitle: l10n.profilePermissionsTitle,
                            planLabel: l10n.profilePlanLabel,
                            subscriptionActiveLabel:
                                l10n.profileSubscriptionActive,
                            subscriptionInactiveLabel:
                                l10n.profileSubscriptionInactive,
                            subscriptionExpiresLabel:
                                l10n.profileSubscriptionExpires,
                            memberLimitLabel: l10n.profileMemberLimitLabel,
                            timezoneLabel: l10n.profileTimezoneLabel,
                            permissionLabels: permissionLabels,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
            if (!_expanded && memberships.isEmpty)
              Padding(
                padding: EdgeInsets.fromLTRB(
                  SizeTokens.paddingXL,
                  0,
                  SizeTokens.paddingXL,
                  SizeTokens.paddingMD,
                ),
                child: Text(
                  l10n.profileNoMemberships,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: SizeTokens.fontSM,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final dynamic user;
  final AppStrings l10n;

  const _UserCard({required this.user, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final initials = _initials(user?.name);

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: SizeTokens.paddingMD),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(SizeTokens.radiusXL),
        border: Border.all(color: AppTheme.border),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.06),
            blurRadius: SizeTokens.spaceMD,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(SizeTokens.radiusXL),
        child: Padding(
          padding: EdgeInsets.all(SizeTokens.paddingXL),
          child: Row(
            children: [
              Container(
                width: SizeConfig.r(64),
                height: SizeConfig.r(64),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.primary.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  initials,
                  style: TextStyle(
                    fontSize: SizeTokens.fontXL,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primary,
                  ),
                ),
              ),
              SizedBox(width: SizeTokens.spaceXL),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.name ?? '—',
                      style: TextStyle(
                        fontSize: SizeTokens.fontLG,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    SizedBox(height: SizeTokens.spaceXXS),
                    Text(
                      user?.email ?? '—',
                      style: TextStyle(
                        fontSize: SizeTokens.fontSM,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    if (user?.phone != null) ...[
                      SizedBox(height: SizeTokens.spaceXXS),
                      Text(
                        user!.phone!,
                        style: TextStyle(
                          fontSize: SizeTokens.fontSM,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: AppTheme.textHint,
                size: SizeTokens.iconLG,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _initials(String? name) {
    if (name == null || name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return parts.first[0].toUpperCase();
  }
}

class _LogoutButton extends StatelessWidget {
  final String label;
  final VoidCallback onLogout;

  const _LogoutButton({required this.label, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: SizeTokens.buttonHeight,
      child: OutlinedButton.icon(
        onPressed: onLogout,
        icon: Icon(Icons.logout_rounded, size: SizeTokens.iconMD),
        label: Text(
          label,
          style: TextStyle(
            fontSize: SizeTokens.fontLG,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTheme.error,
          side: BorderSide(color: AppTheme.error.withValues(alpha: 0.4)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SizeTokens.radiusLG),
          ),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final String retryLabel;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.message,
    required this.retryLabel,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(SizeTokens.paddingPage),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: SizeTokens.iconXL,
              color: AppTheme.error,
            ),
            SizedBox(height: SizeTokens.spaceMD),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: SizeTokens.fontMD,
                color: AppTheme.textSecondary,
              ),
            ),
            SizedBox(height: SizeTokens.spaceXL),
            SizedBox(
              height: SizeTokens.buttonHeight,
              child: ElevatedButton(
                onPressed: onRetry,
                child: Text(
                  retryLabel,
                  style: TextStyle(
                    fontSize: SizeTokens.fontLG,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textOnPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
