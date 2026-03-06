import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/app_theme.dart';
import '../../core/responsive/size_config.dart';
import '../../core/responsive/size_tokens.dart';
import '../../l10n/strings.dart';
import '../../models/billing_plans_response_model.dart';
import '../../models/billing_status_model.dart';
import '../../viewmodels/profile_view_model.dart';
import '../login/login_view.dart';
import 'widgets/profile_membership_item.dart';

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

// ─────────────────────────────────────────────────────────────────────────────
// Body
// ─────────────────────────────────────────────────────────────────────────────

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
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                titleSpacing: SizeTokens.paddingPage,
                actions: [
                  IconButton(
                    onPressed: () => _onLogout(viewModel),
                    icon: Icon(
                      Icons.logout_rounded,
                      size: SizeTokens.iconLG,
                      color: AppTheme.error,
                    ),
                    tooltip: l10n.profileLogout,
                  ),
                  SizedBox(width: SizeTokens.spaceXS),
                ],
                bottom: PreferredSize(
                  preferredSize: Size.fromHeight(SizeConfig.h(1)),
                  child: Container(
                    height: SizeConfig.h(1),
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
                        ? _ProfileContent(viewModel: viewModel, l10n: l10n)
                        : const SizedBox.shrink(),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Profile Content
// ─────────────────────────────────────────────────────────────────────────────

class _ProfileContent extends StatelessWidget {
  final ProfileViewModel viewModel;
  final AppStrings l10n;

  const _ProfileContent({required this.viewModel, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final user = viewModel.meResponse!.user;
    final memberships = user?.memberships ?? [];

    return RefreshIndicator(
      onRefresh: viewModel.refresh,
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          SizeTokens.paddingPage,
          SizeTokens.spaceXL,
          SizeTokens.paddingPage,
          SizeTokens.spaceXXXL,
        ),
        children: [
          // ── User Info Card ─────────────────────────────────────────────────
          _UserCard(user: user, l10n: l10n),
          SizedBox(height: SizeTokens.spaceXXL),

          // ── Memberships ────────────────────────────────────────────────────
          Text(
            l10n.profileMembershipsTitle,
            style: TextStyle(
              fontSize: SizeTokens.fontLG,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: SizeTokens.spaceMD),
          if (memberships.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: SizeTokens.spaceXL),
                child: Text(
                  l10n.profileNoMemberships,
                  style: TextStyle(
                    fontSize: SizeTokens.fontMD,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
            )
          else
            ...memberships.map((m) {
              final brandId = m.brand?.id ?? m.brandId;
              final hasBilling = brandId != null &&
                  (viewModel.billingStatusMap[brandId] != null ||
                      viewModel.billingPlansMap[brandId] != null);
              return Padding(
                padding: EdgeInsets.only(bottom: SizeTokens.spaceXL),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ProfileMembershipItem(
                      membership: m,
                      roleLabel: l10n.profileRoleLabel,
                      permissionsTitle: l10n.profilePermissionsTitle,
                      planLabel: l10n.profilePlanLabel,
                      subscriptionActiveLabel: l10n.profileSubscriptionActive,
                      subscriptionInactiveLabel: l10n.profileSubscriptionInactive,
                      subscriptionExpiresLabel: l10n.profileSubscriptionExpires,
                      memberLimitLabel: l10n.profileMemberLimitLabel,
                      timezoneLabel: l10n.profileTimezoneLabel,
                      permissionLabels: {
                        'create_appointment': l10n.profilePermCreateAppointment,
                        'upload_result': l10n.profilePermUploadResult,
                        'change_status': l10n.profilePermChangeStatus,
                        'manage_members': l10n.profilePermManageMembers,
                        'manage_statuses': l10n.profilePermManageStatuses,
                        'manage_appointment_fields':
                            l10n.profilePermManageAppointmentFields,
                      },
                    ),
                    if (hasBilling) ...
                      [
                        SizedBox(height: SizeTokens.spaceSM),
                        _BillingCard(
                          billingStatus: viewModel.billingStatusMap[brandId],
                          billingPlans: viewModel.billingPlansMap[brandId],
                          l10n: l10n,
                        ),
                      ],
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// User Card
// ─────────────────────────────────────────────────────────────────────────────

class _UserCard extends StatelessWidget {
  final dynamic user;
  final AppStrings l10n;

  const _UserCard({required this.user, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final initials = _initials(user?.name);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(SizeTokens.paddingXL),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(SizeTokens.radiusXL),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: SizeConfig.r(56),
            height: SizeConfig.r(56),
            decoration: BoxDecoration(
              color: AppTheme.primary,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: TextStyle(
                fontSize: SizeTokens.fontXXL,
                fontWeight: FontWeight.w700,
                color: AppTheme.textOnPrimary,
              ),
            ),
          ),
          SizedBox(width: SizeTokens.spaceMD),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.name ?? '—',
                  style: TextStyle(
                    fontSize: SizeTokens.fontXL,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                SizedBox(height: SizeTokens.spaceXXS),
                Row(
                  children: [
                    Icon(
                      Icons.email_outlined,
                      size: SizeTokens.iconSM,
                      color: AppTheme.textHint,
                    ),
                    SizedBox(width: SizeTokens.spaceXXS),
                    Expanded(
                      child: Text(
                        user?.email ?? '—',
                        style: TextStyle(
                          fontSize: SizeTokens.fontSM,
                          color: AppTheme.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (user?.phone != null) ...[
                  SizedBox(height: SizeTokens.spaceXXS),
                  Row(
                    children: [
                      Icon(
                        Icons.phone_outlined,
                        size: SizeTokens.iconSM,
                        color: AppTheme.textHint,
                      ),
                      SizedBox(width: SizeTokens.spaceXXS),
                      Text(
                        user!.phone!,
                        style: TextStyle(
                          fontSize: SizeTokens.fontSM,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
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

// ─────────────────────────────────────────────────────────────────────────────
// Error State
// ─────────────────────────────────────────────────────────────────────────────

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

// ─────────────────────────────────────────────────────────────────────────────
// Billing Card
// ─────────────────────────────────────────────────────────────────────────────

class _BillingCard extends StatelessWidget {
  final BillingStatusModel? billingStatus;
  final BillingPlansResponseModel? billingPlans;
  final AppStrings l10n;

  const _BillingCard({
    required this.l10n,
    this.billingStatus,
    this.billingPlans,
  });

  @override
  Widget build(BuildContext context) {
    final status = billingStatus;
    final plans = billingPlans?.data ?? [];
    final isActive = status?.status == 'active';
    final statusColor = isActive ? AppTheme.success : AppTheme.warning;
    final statusBg = isActive ? AppTheme.successLight : AppTheme.warningLight;

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
          // Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: SizeTokens.paddingXL,
              vertical: SizeTokens.paddingMD,
            ),
            decoration: BoxDecoration(
              color: AppTheme.surfaceVariant,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(SizeTokens.radiusXL),
              ),
              border: Border(
                bottom: BorderSide(color: AppTheme.divider),
              ),
            ),
            child: Text(
              l10n.homeBillingTitle,
              style: TextStyle(
                fontSize: SizeTokens.fontSM,
                fontWeight: FontWeight.w700,
                color: AppTheme.textSecondary,
                letterSpacing: 0.3,
              ),
            ),
          ),
          // Body
          Padding(
            padding: EdgeInsets.all(SizeTokens.paddingXL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status + Plan row
                Row(
                  children: [
                    if (status?.status != null) ...[
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: SizeTokens.paddingSM,
                          vertical: SizeTokens.spaceXXS,
                        ),
                        decoration: BoxDecoration(
                          color: statusBg,
                          borderRadius:
                              BorderRadius.circular(SizeTokens.radiusCircle),
                        ),
                        child: Text(
                          status!.status!,
                          style: TextStyle(
                            fontSize: SizeTokens.fontXS,
                            fontWeight: FontWeight.w700,
                            color: statusColor,
                          ),
                        ),
                      ),
                      SizedBox(width: SizeTokens.spaceSM),
                    ],
                    if (status?.plan != null)
                      Expanded(
                        child: Text(
                          status!.plan!,
                          style: TextStyle(
                            fontSize: SizeTokens.fontMD,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
                if (status?.expiresAt != null) ...[
                  SizedBox(height: SizeTokens.spaceXS),
                  Text(
                    '${l10n.homeBillingExpiresLabel}: ${status!.expiresAt!}',
                    style: TextStyle(
                      fontSize: SizeTokens.fontSM,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
                if (status?.trialEndsAt != null) ...[
                  SizedBox(height: SizeTokens.spaceXS),
                  Text(
                    '${l10n.homeBillingTrialLabel}: ${status!.trialEndsAt!}',
                    style: TextStyle(
                      fontSize: SizeTokens.fontSM,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
                if (status?.locked == true) ...[
                  SizedBox(height: SizeTokens.spaceXS),
                  Text(
                    l10n.homeBillingLockedLabel,
                    style: TextStyle(
                      fontSize: SizeTokens.fontSM,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.error,
                    ),
                  ),
                ],
                if (plans.isNotEmpty) ...[
                  SizedBox(height: SizeTokens.spaceSM),
                  Divider(height: 1, color: AppTheme.divider),
                  SizedBox(height: SizeTokens.spaceSM),
                  ...plans.map(
                    (plan) => Padding(
                      padding: EdgeInsets.only(bottom: SizeTokens.spaceXS),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              plan.name ?? '',
                              style: TextStyle(
                                fontSize: SizeTokens.fontSM,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ),
                          if (plan.memberLimit != null)
                            Text(
                              '${l10n.homeBillingMemberLimitLabel}: ${plan.memberLimit}',
                              style: TextStyle(
                                fontSize: SizeTokens.fontXS,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          if (plan.priceDisplay != null) ...[
                            SizedBox(width: SizeTokens.spaceSM),
                            Text(
                              plan.priceDisplay!,
                              style: TextStyle(
                                fontSize: SizeTokens.fontSM,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
