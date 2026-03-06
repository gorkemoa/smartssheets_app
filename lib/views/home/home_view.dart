import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/app_theme.dart';
import '../../core/responsive/size_config.dart';
import '../../core/responsive/size_tokens.dart';
import '../../l10n/strings.dart';
import '../../models/brand_model.dart';
import '../../viewmodels/appointments_view_model.dart';
import '../../viewmodels/home_view_model.dart';
import 'widgets/brand_form_bottom_sheet.dart';
import 'widgets/brand_stats_card.dart';
import 'widgets/dashboard_stat_tile.dart';
import 'widgets/dashboard_quick_action.dart';
import '../appointments/appointments_view.dart';
import '../appointments/widgets/appointment_card.dart';
import '../brand_info/brand_info_view.dart';

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
  int _selectedBrandIndex = 0;

  void _openAppointmentsSheet(BuildContext context, BrandModel brand) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => ChangeNotifierProvider(
        create: (_) => AppointmentsViewModel(brandId: brand.id!)..init(),
        child: _AppointmentsSheet(brandName: brand.name),
      ),
    );
  }

  Future<void> _openEditBrand(
    BuildContext context,
    AppStrings l10n,
    BrandModel brand,
  ) async {
    context.read<HomeViewModel>().clearSubmitError();
    final success = await BrandFormBottomSheet.show(context, brand: brand);
    if (success == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.homeBrandUpdateSuccess),
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
                        ? _DashboardContent(
                            viewModel: viewModel,
                            l10n: l10n,
                            selectedBrandIndex: _selectedBrandIndex,
                            onBrandSelected: (index) {
                              setState(() => _selectedBrandIndex = index);
                            },
                            onEditBrand: (brand) =>
                                _openEditBrand(context, l10n, brand),
                            onTapAppointments: (brand) {
                              if (brand.id == null) return;
                              _openAppointmentsSheet(context, brand);
                            },
                            onTapBrandInfo: (brand) {
                              if (brand.id == null) return;
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => BrandInfoView(
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

// ─────────────────────────────────────────────────────────────────────────────
// Dashboard Content
// ─────────────────────────────────────────────────────────────────────────────

class _DashboardContent extends StatelessWidget {
  final HomeViewModel viewModel;
  final AppStrings l10n;
  final int selectedBrandIndex;
  final ValueChanged<int> onBrandSelected;
  final void Function(BrandModel brand) onEditBrand;
  final void Function(BrandModel brand) onTapAppointments;
  final void Function(BrandModel brand) onTapBrandInfo;

  const _DashboardContent({
    required this.viewModel,
    required this.l10n,
    required this.selectedBrandIndex,
    required this.onBrandSelected,
    required this.onEditBrand,
    required this.onTapAppointments,
    required this.onTapBrandInfo,
  });

  @override
  Widget build(BuildContext context) {
    final brands = viewModel.brandsResponse?.data ?? [];

    if (brands.isEmpty) {
      return Center(
        child: Text(
          l10n.homeNoMemberships,
          style: TextStyle(
            fontSize: SizeTokens.fontMD,
            color: AppTheme.textSecondary,
          ),
        ),
      );
    }

    final safeIndex = selectedBrandIndex.clamp(0, brands.length - 1);
    final brand = brands[safeIndex];
    final summary = brand.id != null
        ? viewModel.statsSummaryMap[brand.id]
        : null;
    final monthly = brand.id != null
        ? viewModel.statsMonthlyMap[brand.id]
        : null;
    return RefreshIndicator(
      onRefresh: viewModel.refresh,
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          SizeTokens.paddingPage,
          SizeTokens.spaceMD,
          SizeTokens.paddingPage,
          SizeTokens.spaceXXXL,
        ),
        children: [
          // ── Brand Selector ──────────────────────────────────────────
          _BrandSelectorBox(
            brands: brands,
            selectedIndex: safeIndex,
            onSelected: onBrandSelected,
            onCreateBrand: () async {
              final vm = context.read<HomeViewModel>();
              vm.clearSubmitError();
              final success = await BrandFormBottomSheet.show(context);
              if (success == true) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.homeBrandCreateSuccess),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            createLabel: l10n.homeBrandCreateTitle,
            selectLabel: l10n.homeBrandTitle,
          ),
          SizedBox(height: SizeTokens.spaceMD),

          // ── Brand Header ────────────────────────────────────────────


          // ── 4-Grid Stats ────────────────────────────────────────────
          _StatsGrid(summary: summary, l10n: l10n),
          SizedBox(height: SizeTokens.spaceMD),

          // ── By Status ───────────────────────────────────────────────
          if (summary?.byStatus?.isNotEmpty == true) ...[
            _ByStatusSection(
              byStatus: summary!.byStatus!,
              l10n: l10n,
            ),
            SizedBox(height: SizeTokens.spaceMD),
          ],

          // ── Quick Actions ───────────────────────────────────────────
          _QuickActionsSection(
            l10n: l10n,
            brand: brand,
            onTapAppointments: () => onTapAppointments(brand),
            onTapBrandInfo: () => onTapBrandInfo(brand),
          ),
          SizedBox(height: SizeTokens.spaceMD),

          // ── Monthly Chart ───────────────────────────────────────────
          if (monthly?.data?.isNotEmpty == true) ...[
            SizedBox(height: SizeTokens.spaceMD),
            BrandStatsCard(
              summary: null,
              monthly: monthly,
              l10n: l10n,
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Brand Selector Box — opens a bottom sheet
// ─────────────────────────────────────────────────────────────────────────────

class _BrandSelectorBox extends StatelessWidget {
  final List<BrandModel> brands;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final VoidCallback onCreateBrand;
  final String createLabel;
  final String selectLabel;

  const _BrandSelectorBox({
    required this.brands,
    required this.selectedIndex,
    required this.onSelected,
    required this.onCreateBrand,
    required this.createLabel,
    required this.selectLabel,
  });

  Future<void> _openSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _BrandPickerSheet(
        brands: brands,
        selectedIndex: selectedIndex,
        onSelected: (index) {
          Navigator.of(context).pop();
          onSelected(index);
        },
        onCreateBrand: () {
          Navigator.of(context).pop();
          onCreateBrand();
        },
        createLabel: createLabel,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedName = brands[selectedIndex].name ?? '—';
    return Material(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(SizeTokens.radiusLG),
      child: InkWell(
        onTap: () => _openSheet(context),
        borderRadius: BorderRadius.circular(SizeTokens.radiusLG),
        child: Container(
          height: SizeTokens.buttonHeight,
          padding: EdgeInsets.symmetric(horizontal: SizeTokens.paddingMD),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(SizeTokens.radiusLG),
            border: Border.all(color: AppTheme.border),
          ),
          child: Row(
            children: [
              Icon(
                Icons.storefront_outlined,
                size: SizeTokens.iconMD,
                color: AppTheme.textSecondary,
              ),
              SizedBox(width: SizeTokens.spaceSM),
              Expanded(
                child: Text(
                  selectedName,
                  style: TextStyle(
                    fontSize: SizeTokens.fontMD,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                Icons.expand_more_rounded,
                size: SizeTokens.iconMD,
                color: AppTheme.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Brand Picker Bottom Sheet
// ─────────────────────────────────────────────────────────────────────────────

class _BrandPickerSheet extends StatelessWidget {
  final List<BrandModel> brands;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final VoidCallback onCreateBrand;
  final String createLabel;

  const _BrandPickerSheet({
    required this.brands,
    required this.selectedIndex,
    required this.onSelected,
    required this.onCreateBrand,
    required this.createLabel,
  });

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(SizeTokens.radiusXL),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        SizeTokens.paddingPage,
        SizeTokens.spaceXL,
        SizeTokens.paddingPage,
        SizeTokens.spaceXXXL,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: SizeConfig.w(40),
              height: SizeConfig.h(4),
              decoration: BoxDecoration(
                color: AppTheme.border,
                borderRadius: BorderRadius.circular(SizeTokens.radiusCircle),
              ),
            ),
          ),
          SizedBox(height: SizeTokens.spaceXL),

          // ── Create Brand button ─────────────────────────────────────
          Material(
            color: AppTheme.primary,
            borderRadius: BorderRadius.circular(SizeTokens.radiusLG),
            child: InkWell(
              onTap: onCreateBrand,
              borderRadius: BorderRadius.circular(SizeTokens.radiusLG),
              child: Container(
                width: double.infinity,
                height: SizeTokens.buttonHeight,
                padding: EdgeInsets.symmetric(
                  horizontal: SizeTokens.paddingMD,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_rounded,
                      size: SizeTokens.iconMD,
                      color: AppTheme.textOnPrimary,
                    ),
                    SizedBox(width: SizeTokens.spaceXS),
                    Text(
                      createLabel,
                      style: TextStyle(
                        fontSize: SizeTokens.fontMD,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textOnPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SizedBox(height: SizeTokens.spaceLG),

          // ── Brand list ──────────────────────────────────────────────
          ...List.generate(brands.length, (index) {
            final brand = brands[index];
            final isSelected = index == selectedIndex;
            final isActive = brand.subscriptionStatus == 'active';
            return Padding(
              padding: EdgeInsets.only(bottom: SizeTokens.spaceXS),
              child: Material(
                color: isSelected
                    ? AppTheme.primary.withValues(alpha: 0.06)
                    : AppTheme.surface,
                borderRadius: BorderRadius.circular(SizeTokens.radiusMD),
                child: InkWell(
                  onTap: () => onSelected(index),
                  borderRadius: BorderRadius.circular(SizeTokens.radiusMD),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: SizeTokens.paddingMD,
                      vertical: SizeTokens.spaceSM,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(SizeTokens.radiusMD),
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.primary.withValues(alpha: 0.4)
                            : AppTheme.divider,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: SizeTokens.iconXL,
                          height: SizeTokens.iconXL,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppTheme.primary.withValues(alpha: 0.1)
                                : AppTheme.surfaceVariant,
                            borderRadius:
                                BorderRadius.circular(SizeTokens.radiusSM),
                          ),
                          child: Icon(
                            Icons.storefront_outlined,
                            size: SizeTokens.iconMD,
                            color: isSelected
                                ? AppTheme.primary
                                : AppTheme.textSecondary,
                          ),
                        ),
                        SizedBox(width: SizeTokens.spaceSM),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                brand.name ?? '—',
                                style: TextStyle(
                                  fontSize: SizeTokens.fontMD,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? AppTheme.primary
                                      : AppTheme.textPrimary,
                                ),
                              ),
                              if (brand.currentPlan != null) ...[  
                                SizedBox(height: SizeTokens.spaceXXS),
                                Text(
                                  brand.currentPlan!.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: SizeTokens.fontXS,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: SizeTokens.paddingXS,
                            vertical: SizeTokens.spaceXXS,
                          ),
                          decoration: BoxDecoration(
                            color: isActive
                                ? AppTheme.successLight
                                : AppTheme.errorLight,
                            borderRadius:
                                BorderRadius.circular(SizeTokens.radiusCircle),
                          ),
                          child: Text(
                            isActive ? 'Active' : 'Inactive',
                            style: TextStyle(
                              fontSize: SizeTokens.fontXS,
                              fontWeight: FontWeight.w600,
                              color: isActive
                                  ? AppTheme.success
                                  : AppTheme.error,
                            ),
                          ),
                        ),
                        if (isSelected) ...[  
                          SizedBox(width: SizeTokens.spaceXS),
                          Icon(
                            Icons.check_rounded,
                            size: SizeTokens.iconMD,
                            color: AppTheme.primary,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Brand Header (compact)
// ─────────────────────────────────────────────────────────────────────────────


// ─────────────────────────────────────────────────────────────────────────────
// 2×2 Stats Grid
// ─────────────────────────────────────────────────────────────────────────────

class _StatsGrid extends StatelessWidget {
  final dynamic summary;
  final AppStrings l10n;

  const _StatsGrid({required this.summary, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: DashboardStatTile(
                icon: Icons.calendar_month_rounded,
                value: '${summary?.totalAppointments ?? 0}',
                label: l10n.homeStatsTotalLabel,
                iconColor: AppTheme.accent,
                iconBackground: AppTheme.accent.withValues(alpha: 0.1),
              ),
            ),
            SizedBox(width: SizeTokens.spaceSM),
            Expanded(
              child: DashboardStatTile(
                icon: Icons.date_range_rounded,
                value: '${summary?.thisMonthCreated ?? 0}',
                label: l10n.homeStatsThisMonthLabel,
                iconColor: AppTheme.primary,
                iconBackground: AppTheme.primary.withValues(alpha: 0.08),
              ),
            ),
          ],
        ),
        SizedBox(height: SizeTokens.spaceSM),
        Row(
          children: [
            Expanded(
              child: DashboardStatTile(
                icon: Icons.check_circle_outline_rounded,
                value: '${summary?.activeCount ?? 0}',
                label: l10n.homeStatsActiveLabel,
                iconColor: AppTheme.success,
                iconBackground: AppTheme.successLight,
              ),
            ),
            SizedBox(width: SizeTokens.spaceSM),
            Expanded(
              child: DashboardStatTile(
                icon: Icons.schedule_rounded,
                value: '${summary?.upcoming7Days ?? 0}',
                label: l10n.homeStatsUpcoming7DaysLabel,
                iconColor: AppTheme.warning,
                iconBackground: AppTheme.warningLight,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// By Status Section
// ─────────────────────────────────────────────────────────────────────────────

class _ByStatusSection extends StatelessWidget {
  final List<dynamic> byStatus;
  final AppStrings l10n;

  const _ByStatusSection({required this.byStatus, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(SizeTokens.paddingMD),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(SizeTokens.radiusLG),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.homeStatsByStatusTitle,
            style: TextStyle(
              fontSize: SizeTokens.fontMD,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: SizeTokens.spaceSM),
          Wrap(
            spacing: SizeTokens.spaceXS,
            runSpacing: SizeTokens.spaceXS,
            children: byStatus.map<Widget>((item) {
              return Container(
                padding: EdgeInsets.symmetric(
                  horizontal: SizeTokens.spaceSM,
                  vertical: SizeTokens.spaceXXS,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceVariant,
                  borderRadius:
                      BorderRadius.circular(SizeTokens.radiusCircle),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${item.name ?? ''}',
                      style: TextStyle(
                        fontSize: SizeTokens.fontSM,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    SizedBox(width: SizeTokens.spaceXXS),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: SizeTokens.spaceXXS,
                        vertical: SizeConfig.h(1),
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.accent.withValues(alpha: 0.15),
                        borderRadius:
                            BorderRadius.circular(SizeTokens.radiusCircle),
                      ),
                      child: Text(
                        '${item.count ?? 0}',
                        style: TextStyle(
                          fontSize: SizeTokens.fontXS,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.accent,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Quick Actions Section (2×2 grid)
// ─────────────────────────────────────────────────────────────────────────────

class _QuickActionsSection extends StatelessWidget {
  final AppStrings l10n;
  final BrandModel brand;
  final VoidCallback onTapAppointments;
  final VoidCallback onTapBrandInfo;

  const _QuickActionsSection({
    required this.l10n,
    required this.brand,
    required this.onTapAppointments,
    required this.onTapBrandInfo,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.homeDashboardQuickActions,
          style: TextStyle(
            fontSize: SizeTokens.fontMD,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        SizedBox(height: SizeTokens.spaceSM),
        DashboardQuickAction(
          icon: Icons.calendar_month_rounded,
          label: l10n.homeQuickAppointments,
          iconColor: AppTheme.accent,
          iconBackground: AppTheme.accent.withValues(alpha: 0.1),
          onTap: brand.id != null ? onTapAppointments : null,
        ),
        SizedBox(height: SizeTokens.spaceSM),
        DashboardQuickAction(
          icon: Icons.info_outline_rounded,
          label: l10n.homeQuickBrandInfo,
          iconColor: AppTheme.primary,
          iconBackground: AppTheme.primary.withValues(alpha: 0.08),
          onTap: brand.id != null ? onTapBrandInfo : null,
        ),
      ],
    );
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
// Appointments Bottom Sheet
// ─────────────────────────────────────────────────────────────────────────────

class _AppointmentsSheet extends StatelessWidget {
  final String? brandName;

  const _AppointmentsSheet({this.brandName});

  @override
  Widget build(BuildContext context) {
    final l10n = AppStrings.of(context);
    return Consumer<AppointmentsViewModel>(
      builder: (context, vm, _) {
        final appointments = vm.selectedDayAppointments;
        return DraggableScrollableSheet(
          initialChildSize: 0.65,
          minChildSize: 0.4,
          maxChildSize: 0.92,
          builder: (_, scrollController) => Container(
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(SizeTokens.radiusXL),
              ),
            ),
            child: Column(
              children: [
                // Handle
                Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: SizeTokens.spaceSM,
                  ),
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.divider,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                // Header
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: SizeTokens.paddingPage,
                  ).copyWith(bottom: SizeTokens.spaceSM),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.homeQuickAppointments,
                          style: TextStyle(
                            fontSize: SizeTokens.fontXL,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => AppointmentsView(
                                brandName: brandName,
                              ),
                            ),
                          );
                        },
                        child: Text(
                          l10n.seeAll,
                          style: TextStyle(
                            fontSize: SizeTokens.fontSM,
                            color: AppTheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, color: AppTheme.divider),
                // List
                Expanded(
                  child: vm.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : appointments.isEmpty
                          ? Center(
                              child: Text(
                                l10n.appointmentsEmpty,
                                style: TextStyle(
                                  fontSize: SizeTokens.fontMD,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            )
                          : ListView.builder(
                              controller: scrollController,
                              padding: EdgeInsets.all(SizeTokens.paddingPage),
                              itemCount: appointments.length,
                              itemBuilder: (_, i) => Padding(
                                padding: EdgeInsets.only(
                                  bottom: SizeTokens.spaceSM,
                                ),
                                child: AppointmentCard(
                                  appointment: appointments[i],
                                ),
                              ),
                            ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
