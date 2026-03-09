import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/app_theme.dart';
import '../../core/responsive/size_config.dart';
import '../../core/responsive/size_tokens.dart';
import '../../core/ui_components/main_app_bar.dart';
import '../../l10n/strings.dart';
import '../../models/membership_model.dart';
import '../../viewmodels/appointments_view_model.dart';
import '../../viewmodels/home_view_model.dart';
import '../../viewmodels/members_view_model.dart';
import '../appointments/appointment_form_view.dart';
import '../invitations/invitations_view.dart';
import 'widgets/member_card.dart';
import 'widgets/member_form_bottom_sheet.dart';

class MembersView extends StatelessWidget {
  final int? brandId;
  final String? brandName;

  const MembersView({super.key, this.brandId, this.brandName});

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final l10n = AppStrings.of(context);

    // Shell tab — use active brand from HomeViewModel
    if (brandId == null) {
      return Consumer<HomeViewModel>(
        builder: (context, homeVm, _) {
          final brand = homeVm.selectedBrand;
          if (homeVm.isLoading || brand == null || brand.id == null) {
            return Scaffold(
              appBar: MainAppBar(title: l10n.membersTitle),
              backgroundColor: AppTheme.surfaceVariant,
              body: const Center(child: CircularProgressIndicator()),
            );
          }
          return ChangeNotifierProvider(
            key: ValueKey(brand.id),
            create: (_) => MembersViewModel(brandId: brand.id!)..init(),
            child: _MembersBody(brandId: brand.id!, brandName: brand.name),
          );
        },
      );
    }

    return ChangeNotifierProvider(
      create: (_) => MembersViewModel(brandId: brandId!)..init(),
      child: _MembersBody(brandId: brandId!, brandName: brandName),
    );
  }
}

class _MembersBody extends StatefulWidget {
  final int brandId;
  final String? brandName;

  const _MembersBody({required this.brandId, this.brandName});

  @override
  State<_MembersBody> createState() => _MembersBodyState();
}

class _MembersBodyState extends State<_MembersBody> {
  Future<void> _openCreateMember(BuildContext context, AppStrings l10n) async {
    context.read<MembersViewModel>().clearSubmitError();
    final result = await MemberFormBottomSheet.show(context);
    if (result == MemberFormResult.created && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.memberCreateSuccess),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _openEditMember(
    BuildContext context,
    AppStrings l10n,
    MembershipModel member,
  ) async {
    context.read<MembersViewModel>().clearSubmitError();
    final result = await MemberFormBottomSheet.show(context, member: member);
    if (!mounted) return;
    if (result == MemberFormResult.updated) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.memberUpdateSuccess),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (result == MemberFormResult.deleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.memberDeleteSuccess),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final l10n = AppStrings.of(context);

    return Scaffold(
      backgroundColor: AppTheme.surfaceVariant,
      appBar: MainAppBar(
        title: l10n.membersTitle,
        leading: Navigator.of(context).canPop()
            ? IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(
                  Icons.arrow_back_ios_rounded,
                  size: SizeTokens.iconMD,
                  color: AppTheme.textPrimary,
                ),
              )
            : null,
        actions: [
          Consumer<HomeViewModel>(
            builder: (context, homeVm, _) => IconButton(
              onPressed: () async {
                final brand = homeVm.selectedBrand;
                if (brand?.id == null) return;
                final apptVm = AppointmentsViewModel(brandId: brand!.id!)
                  ..init();
                final result = await Navigator.of(context).push<bool>(
                  MaterialPageRoute(
                    builder: (_) => ChangeNotifierProvider.value(
                      value: apptVm,
                      child: AppointmentFormView(brandId: brand.id!),
                    ),
                  ),
                );
                if (result == true && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.appointmentCreateSuccess),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              icon: Icon(
                Icons.add_rounded,
                size: SizeTokens.iconLG,
                color: AppTheme.primary,
              ),
              tooltip: l10n.appointmentFormCreateTitle,
            ),
          ),
        ],
      ),
      body: Consumer<MembersViewModel>(
        builder: (context, viewModel, _) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.errorMessage != null) {
            return _ErrorState(
              message: viewModel.errorMessage!,
              retryLabel: l10n.membersRetry,
              onRetry: () => viewModel.onRetry(),
            );
          }

          if (viewModel.members.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(SizeTokens.paddingPage),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: SizeTokens.iconXL * 2,
                      height: SizeTokens.iconXL * 2,
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceVariant,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.group_outlined,
                        size: SizeTokens.iconXL,
                        color: AppTheme.textHint,
                      ),
                    ),
                    SizedBox(height: SizeTokens.spaceLG),
                    Text(
                      l10n.membersEmpty,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: SizeTokens.fontLG,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            color: AppTheme.primary,
            onRefresh: () => viewModel.refresh(),
            child: CustomScrollView(
              slivers: [
                // ── Member count header ───────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      SizeTokens.paddingPage,
                      SizeTokens.paddingPage,
                      SizeTokens.paddingPage,
                      SizeTokens.spaceSM,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: SizeTokens.spaceXXS * 1.5,
                          height: SizeTokens.spaceMD,
                          decoration: BoxDecoration(
                            color: AppTheme.primary,
                            borderRadius: BorderRadius.circular(
                              SizeTokens.radiusCircle,
                            ),
                          ),
                        ),
                        SizedBox(width: SizeTokens.spaceXS),
                        Text(
                          '${viewModel.members.length}',
                          style: TextStyle(
                            fontSize: SizeTokens.fontXL,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                            letterSpacing: -0.3,
                          ),
                        ),
                        SizedBox(width: SizeTokens.spaceXXS),
                        Text(
                          l10n.membersTitle,
                          style: TextStyle(
                            fontSize: SizeTokens.fontMD,
                            fontWeight: FontWeight.w400,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const Spacer(),
                        // Invitations button
                        GestureDetector(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => InvitationsView(
                                brandId: widget.brandId,
                                brandName: widget.brandName,
                              ),
                            ),
                          ),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: SizeTokens.paddingSM,
                              vertical: SizeTokens.spaceXXS,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.surface,
                              borderRadius: BorderRadius.circular(
                                SizeTokens.radiusSM,
                              ),
                              border: Border.all(color: AppTheme.border),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.mail_outline_rounded,
                                  size: SizeTokens.iconSM,
                                  color: AppTheme.textSecondary,
                                ),
                                SizedBox(width: SizeTokens.spaceXXS),
                                Text(
                                  l10n.invitationsNavButton,
                                  style: TextStyle(
                                    fontSize: SizeTokens.fontXS,
                                    fontWeight: FontWeight.w500,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: SizeTokens.spaceXS),
                        // Add member button
                        GestureDetector(
                          onTap: () => _openCreateMember(context, l10n),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: SizeTokens.paddingSM,
                              vertical: SizeTokens.spaceXXS,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primary,
                              borderRadius: BorderRadius.circular(
                                SizeTokens.radiusSM,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.add_rounded,
                                  size: SizeTokens.iconSM,
                                  color: AppTheme.textOnPrimary,
                                ),
                                SizedBox(width: SizeTokens.spaceXXS),
                                Text(
                                  l10n.memberFormCreateTitle,
                                  style: TextStyle(
                                    fontSize: SizeTokens.fontXS,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textOnPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // ── Member list ───────────────────────────────────────────
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    SizeTokens.paddingPage,
                    SizeTokens.spaceSM,
                    SizeTokens.paddingPage,
                    SizeTokens.paddingPage,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, index) => Padding(
                        padding: EdgeInsets.only(bottom: SizeTokens.spaceMD),
                        child: MemberCard(
                          member: viewModel.members[index],
                          l10n: l10n,
                          onEdit: () => _openEditMember(
                            context,
                            l10n,
                            viewModel.members[index],
                          ),
                        ),
                      ),
                      childCount: viewModel.members.length,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
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
            Container(
              width: SizeTokens.iconXL * 2,
              height: SizeTokens.iconXL * 2,
              decoration: BoxDecoration(
                color: AppTheme.errorLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: SizeTokens.iconXL,
                color: AppTheme.error,
              ),
            ),
            SizedBox(height: SizeTokens.spaceLG),
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(SizeTokens.radiusLG),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: SizeTokens.paddingXL,
                  ),
                ),
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
