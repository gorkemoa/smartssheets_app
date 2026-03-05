import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/app_theme.dart';
import '../../core/responsive/size_config.dart';
import '../../core/responsive/size_tokens.dart';
import '../../l10n/strings.dart';
import '../../models/brand_model.dart';
import '../../viewmodels/home_view_model.dart';
import 'widgets/brand_card.dart';
import 'widgets/brand_form_bottom_sheet.dart';
import 'widgets/brand_stats_card.dart';
import '../members/members_view.dart';
import '../statuses/appointment_statuses_view.dart';
import '../appointment_fields/appointment_fields_view.dart';
import '../appointments/appointments_view.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return const _HomeBody();
  }
}

class _HomeBody extends StatefulWidget {
  const _HomeBody();

  @override
  State<_HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<_HomeBody> {
  Future<void> _openCreateBrand(
    BuildContext context,
    AppStrings l10n,
  ) async {
    final viewModel = context.read<HomeViewModel>();
    viewModel.clearSubmitError();
    final success = await BrandFormBottomSheet.show(context);
    if (success == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.homeBrandCreateSuccess),
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
      body: Consumer<HomeViewModel>(
        builder: (context, viewModel, _) {
          final userName = viewModel.meResponse?.user?.name;
          final greeting =
              userName != null ? l10n.homeGreeting(userName) : l10n.navHome;

          return NestedScrollView(
            headerSliverBuilder: (_, __) => [
              SliverAppBar(
                pinned: true,
                backgroundColor: AppTheme.surface,
                foregroundColor: AppTheme.textPrimary,
                automaticallyImplyLeading: false,
                toolbarHeight: SizeTokens.appBarHeight,
                title: Text(
                  greeting,
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
                    onPressed: () => _openCreateBrand(context, l10n),
                    icon: Icon(
                      Icons.add_rounded,
                      size: SizeTokens.iconLG,
                      color: AppTheme.primary,
                    ),
                    tooltip: l10n.homeBrandCreateTitle,
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
                        retryLabel: l10n.homeRetry,
                        onRetry: () => viewModel.onRetry(),
                      )
                    : viewModel.meResponse != null
                        ? _HomeContent(
                            viewModel: viewModel,
                            l10n: l10n,
                            onEditBrand: (brand) async {
                              context.read<HomeViewModel>().clearSubmitError();
                              final success = await BrandFormBottomSheet.show(
                                context,
                                brand: brand,
                              );
                              if (success == true && mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(l10n.homeBrandUpdateSuccess),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            },
                            onTapBrand: (brand) {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => MembersView(
                                    brandId: brand.id,
                                    brandName: brand.name,
                                  ),
                                ),
                              );
                            },
                            onTapStatuses: (brand) {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => AppointmentStatusesView(
                                    brandId: brand.id!,
                                    brandName: brand.name,
                                  ),
                                ),
                              );
                            },
                            onTapFields: (brand) {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => AppointmentFieldsView(
                                    brandId: brand.id!,
                                    brandName: brand.name,
                                  ),
                                ),
                              );
                            },
                            onTapAppointments: (brand) {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => AppointmentsView(
                                    brandId: brand.id!,
                                    brandName: brand.name,
                                  ),
                                ),
                              );
                            },
                          )
                        : const SizedBox.shrink(),
          );
        },
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  final HomeViewModel viewModel;
  final AppStrings l10n;
  final void Function(BrandModel brand) onEditBrand;
  final void Function(BrandModel brand) onTapBrand;
  final void Function(BrandModel brand) onTapStatuses;
  final void Function(BrandModel brand) onTapFields;
  final void Function(BrandModel brand) onTapAppointments;

  const _HomeContent({
    required this.viewModel,
    required this.l10n,
    required this.onEditBrand,
    required this.onTapBrand,
    required this.onTapStatuses,
    required this.onTapFields,
    required this.onTapAppointments,
  });

  @override
  Widget build(BuildContext context) {
    final brands = viewModel.brandsResponse?.data ?? [];

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
          if (brands.isEmpty)
            Center(
              child: Text(
                l10n.homeNoMemberships,
                style: TextStyle(
                  fontSize: SizeTokens.fontMD,
                  color: AppTheme.textSecondary,
                ),
              ),
            )
          else
            ...brands.map(
              (brand) => Padding(
                padding: EdgeInsets.only(bottom: SizeTokens.spaceXL),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    BrandCard(
                      brand: brand,
                      subscriptionActiveLabel: l10n.homeSubscriptionActive,
                      subscriptionInactiveLabel: l10n.homeSubscriptionInactive,
                      planLabel: l10n.homePlanLabel,
                      subscriptionStatusLabel: l10n.homeSubscriptionStatusLabel,
                      subscriptionExpiresLabel: l10n.homeSubscriptionExpires,
                      memberLimitLabel: l10n.homeMemberLimitLabel,
                      timezoneLabel: l10n.homeTimezoneLabel,
                      editTooltip: l10n.homeBrandEditTooltip,
                      statusesTooltip: l10n.statusesNavButton,
                      fieldsTooltip: l10n.fieldsNavButton,
                      appointmentsTooltip: l10n.appointmentsNavButton,
                      onEdit: () => onEditBrand(brand),
                      onTap: () => onTapBrand(brand),
                      onTapStatuses: () => onTapStatuses(brand),
                      onTapFields: () => onTapFields(brand),
                      onTapAppointments: () => onTapAppointments(brand),
                    ),
                    if (brand.id != null) ...[  
                      SizedBox(height: SizeTokens.spaceSM),
                      BrandStatsCard(
                        summary: viewModel.statsSummaryMap[brand.id],
                        monthly: viewModel.statsMonthlyMap[brand.id],
                        l10n: l10n,
                      ),
                    ],
                  ],
                ),
              ),
            ),
        ],
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
