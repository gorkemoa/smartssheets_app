import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/app_theme.dart';
import '../../core/responsive/size_config.dart';
import '../../core/responsive/size_tokens.dart';
import '../../l10n/strings.dart';
import '../../models/appointment_model.dart';
import '../../models/brand_model.dart';
import '../../models/stats_monthly_item_model.dart';
import '../../models/stats_monthly_response_model.dart';
import '../../models/stats_summary_model.dart';
import '../../viewmodels/appointments_view_model.dart';
import '../../viewmodels/home_view_model.dart';
import 'widgets/brand_form_bottom_sheet.dart';
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
          final greeting = userName != null
              ? l10n.homeGreeting(userName)
              : l10n.navHome;

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
                    selectedBrandIndex: viewModel.selectedBrandIndex,
                    onBrandSelected: (index) {
                      viewModel.setSelectedBrandIndex(index);
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

class _DashboardContent extends StatefulWidget {
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
  State<_DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<_DashboardContent> {
  bool _statsExpanded = false;

  @override
  Widget build(BuildContext context) {
    final viewModel = widget.viewModel;
    final l10n = widget.l10n;
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

    final safeIndex = widget.selectedBrandIndex.clamp(0, brands.length - 1);
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
            onSelected: widget.onBrandSelected,
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
          // ── 4-Grid Stats ────────────────────────────────────────────
          _StatsGrid(summary: summary, l10n: l10n),
          SizedBox(height: SizeTokens.spaceMD),
          // ── Upcoming Appointments Slider ────────────────────────────
          _UpcomingAppointmentsSlider(
            appointments: brand.id != null
                ? viewModel.upcomingAppointmentsMap[brand.id]
                : null,
            l10n: l10n,
          ),

          // ── Quick Actions ───────────────────────────────────────────
          _QuickActionsSection(
            l10n: l10n,
            brand: brand,
            onTapAppointments: () => widget.onTapAppointments(brand),
            onTapBrandInfo: () => widget.onTapBrandInfo(brand),
          ),
          SizedBox(height: SizeTokens.spaceMD),

          // ── Statistics Accordion ────────────────────────────────────
          _StatsAccordion(
            l10n: l10n,
            summary: summary,
            monthly: monthly,
            expanded: _statsExpanded,
            onToggle: () => setState(() => _statsExpanded = !_statsExpanded),
          ),
          SizedBox(height: SizeTokens.spaceMD),
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
                padding: EdgeInsets.symmetric(horizontal: SizeTokens.paddingMD),
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
                            borderRadius: BorderRadius.circular(
                              SizeTokens.radiusSM,
                            ),
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
                            borderRadius: BorderRadius.circular(
                              SizeTokens.radiusCircle,
                            ),
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
// Upcoming Appointments Slider
// ─────────────────────────────────────────────────────────────────────────────

class _UpcomingAppointmentsSlider extends StatelessWidget {
  final List<AppointmentModel>? appointments;
  final AppStrings l10n;

  const _UpcomingAppointmentsSlider({
    required this.appointments,
    required this.l10n,
  });

  static Color _hexColor(String? hex) {
    if (hex == null || hex.isEmpty) return Colors.grey;
    final clean = hex.replaceAll('#', '');
    if (clean.length == 6) {
      return Color(int.parse('0xFF$clean'));
    }
    return Colors.grey;
  }

  static String _formatTime(String? iso) {
    if (iso == null) return '';
    try {
      final dt = DateTime.parse(iso).toLocal();
      final h = dt.hour.toString().padLeft(2, '0');
      final m = dt.minute.toString().padLeft(2, '0');
      return '$h:$m';
    } catch (_) {
      return '';
    }
  }

  static String _formatDate(String? iso) {
    if (iso == null) return '';
    try {
      final dt = DateTime.parse(iso).toLocal();
      return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final list = appointments;
    if (list == null || list.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.homeUpcomingTitle,
          style: TextStyle(
            fontSize: SizeConfig.sp(13),
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        SizedBox(height: SizeTokens.spaceSM),
        SizedBox(
          height: SizeConfig.h(110),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.zero,
            itemCount: list.length,
            separatorBuilder: (_, __) => SizedBox(width: SizeTokens.spaceSM),
            itemBuilder: (context, index) {
              final appt = list[index];
              final statusColor = _hexColor(appt.status?.color);
              final time = _formatTime(appt.startsAt);
              final date = _formatDate(appt.startsAt);
              return Container(
                width: SizeConfig.w(160),
                padding: EdgeInsets.all(SizeTokens.spaceSM),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(SizeTokens.radiusMD),
                  border: Border(
                    left: BorderSide(color: statusColor, width: 3),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Date + time row
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: SizeConfig.sp(11),
                          color: AppTheme.textSecondary,
                        ),
                        SizedBox(width: SizeConfig.w(3)),
                        Text(
                          '$date  $time',
                          style: TextStyle(
                            fontSize: SizeConfig.sp(10),
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    // Title
                    Text(
                      appt.title ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: SizeConfig.sp(11.5),
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                        height: 1.3,
                      ),
                    ),
                    // Status badge
                    if (appt.status?.name != null)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: SizeConfig.w(6),
                          vertical: SizeConfig.h(2),
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(
                            SizeTokens.radiusSM,
                          ),
                        ),
                        child: Text(
                          appt.status!.name!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: SizeConfig.sp(9.5),
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
        SizedBox(height: SizeTokens.spaceMD),
      ],
    );
  }
}

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
                iconColor: Colors.white,
                iconBackground: AppTheme.accent,
              ),
            ),
            SizedBox(width: SizeTokens.spaceSM),
            Expanded(
              child: DashboardStatTile(
                icon: Icons.date_range_rounded,
                value: '${summary?.thisMonthCreated ?? 0}',
                label: l10n.homeStatsThisMonthLabel,
                iconColor: Colors.white,
                iconBackground: AppTheme.primary,
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
                iconColor: Colors.white,
                iconBackground: AppTheme.success,
              ),
            ),
            SizedBox(width: SizeTokens.spaceSM),
            Expanded(
              child: DashboardStatTile(
                icon: Icons.schedule_rounded,
                value: '${summary?.upcoming7Days ?? 0}',
                label: l10n.homeStatsUpcoming7DaysLabel,
                iconColor: Colors.white,
                iconBackground: AppTheme.warning,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Stats Accordion
// ─────────────────────────────────────────────────────────────────────────────

class _StatsAccordion extends StatelessWidget {
  final AppStrings l10n;
  final dynamic summary;
  final StatsMonthlyResponseModel? monthly;
  final bool expanded;
  final VoidCallback onToggle;

  const _StatsAccordion({
    required this.l10n,
    required this.summary,
    required this.monthly,
    required this.expanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(SizeTokens.radiusLG),
        border: Border.all(color: AppTheme.divider),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // ── Header (tappable) ───────────────────────────────────────
          InkWell(
            onTap: onToggle,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: SizeTokens.paddingMD,
                vertical: SizeTokens.spaceMD,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.bar_chart_rounded,
                    size: SizeTokens.iconSM,
                    color: AppTheme.primary,
                  ),
                  SizedBox(width: SizeTokens.spaceXS),
                  Expanded(
                    child: Text(
                      l10n.homeStatsTitle,
                      style: TextStyle(
                        fontSize: SizeTokens.fontMD,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: expanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 250),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: SizeTokens.iconMD,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // ── Collapsible body ────────────────────────────────────────
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 300),
            crossFadeState: expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              children: [
                Divider(height: 1, color: AppTheme.divider),
                if (summary != null || monthly != null) ...[
                  Divider(height: 1, color: AppTheme.divider),
                  _StatsAndMonthlyCard(
                    summary: summary,
                    monthly: monthly,
                    l10n: l10n,
                    showHeader: false,
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

// ─────────────────────────────────────────────────────────────────────────────
// Stats & Monthly Card
// ─────────────────────────────────────────────────────────────────────────────

class _StatsAndMonthlyCard extends StatelessWidget {
  final StatsSummaryModel? summary;
  final StatsMonthlyResponseModel? monthly;
  final AppStrings l10n;
  final bool showHeader;

  const _StatsAndMonthlyCard({
    this.summary,
    this.monthly,
    required this.l10n,
    this.showHeader = true,
  });

  @override
  Widget build(BuildContext context) {
    if (summary?.byStatus?.isNotEmpty != true &&
        monthly?.data?.isNotEmpty != true) {
      return const SizedBox.shrink();
    }

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Header ──────────────────────────────────────────────────
        Padding(
          padding: EdgeInsets.all(SizeTokens.paddingMD),
          child: Row(
            children: [
              Icon(
                Icons.analytics_outlined,
                size: SizeTokens.iconSM,
                color: AppTheme.primary,
              ),
              SizedBox(width: SizeTokens.spaceXS),
              Text(
                l10n.homeStatsTitle,
                style: TextStyle(
                  fontSize: SizeTokens.fontMD,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
        Divider(height: 1, color: AppTheme.divider),

        // ── Pie Chart (Durum Dağılımı) ──────────────────────────────
        if (summary?.byStatus?.isNotEmpty == true) ...[
          Padding(
            padding: EdgeInsets.fromLTRB(
              SizeTokens.paddingMD,
              SizeTokens.paddingMD,
              SizeTokens.paddingMD,
              0,
            ),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  SizedBox(
                    width: SizeConfig.w(80),
                    height: SizeConfig.h(80),
                    child: CustomPaint(
                      painter: _PieChartPainter(
                        items: summary!.byStatus!,
                        colors: _kPieColors,
                      ),
                    ),
                  ),
                  SizedBox(width: SizeTokens.spaceLG),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.homeStatsByStatusTitle,
                          style: TextStyle(
                            fontSize: SizeTokens.fontSM,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        SizedBox(height: SizeTokens.spaceXS),
                        Text(
                          '${summary?.totalAppointments ?? 0}',
                          style: TextStyle(
                            fontSize: SizeTokens.fontXXL,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          l10n.homeStatsTotalLabel,
                          style: TextStyle(
                            fontSize: SizeTokens.fontXS,
                            color: AppTheme.textHint,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => showGeneralDialog(
                      context: context,
                      barrierDismissible: true,
                      barrierLabel: '',
                      transitionDuration: const Duration(milliseconds: 300),
                      pageBuilder: (context, anim1, anim2) =>
                          _StatusDetailDialog(
                            byStatus: summary!.byStatus!,
                            title: l10n.homeStatsByStatusTitle,
                          ),
                      transitionBuilder: (context, anim1, anim2, child) {
                        return ScaleTransition(
                          scale: CurvedAnimation(
                            parent: anim1,
                            curve: Curves.easeOutBack,
                          ),
                          child: FadeTransition(opacity: anim1, child: child),
                        );
                      },
                    ),
                    icon: Icon(
                      Icons.open_in_new_rounded,
                      size: SizeTokens.iconSM,
                      color: AppTheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: SizeTokens.spaceSM),
          // ── Legend (Minik renkler) ──────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(horizontal: SizeTokens.paddingMD),
            child: Wrap(
              spacing: SizeTokens.spaceSM,
              runSpacing: SizeTokens.spaceXXS,
              children: List.generate(summary!.byStatus!.length, (i) {
                final item = summary!.byStatus![i];
                if ((item.count ?? 0) == 0) return const SizedBox.shrink();
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _kPieColors[i % _kPieColors.length],
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 4),
                    Text(
                      item.name ?? '',
                      style: TextStyle(
                        fontSize: SizeTokens.fontXS,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
          SizedBox(height: SizeTokens.spaceMD),
        ],
        Divider(height: 1, color: AppTheme.divider),

        // ── Monthly List (Aylık Randevular) ─────────────────────────
        if (monthly?.data?.where((e) => (e.count ?? 0) > 0).isNotEmpty ==
            true) ...[
          Padding(
            padding: EdgeInsets.all(SizeTokens.paddingMD),
            child: Text(
              l10n.homeStatsMonthlyTitle,
              style: TextStyle(
                fontSize: SizeTokens.fontSM,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          Builder(
            builder: (context) {
              final activeItems = monthly!.data!
                  .where((e) => (e.count ?? 0) > 0)
                  .toList();
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: SizeTokens.paddingMD),
                itemCount: activeItems.length,
                separatorBuilder: (_, __) =>
                    SizedBox(height: SizeTokens.spaceXS),
                itemBuilder: (context, index) {
                  final item = activeItems[index];
                  final count = item.count ?? 0;

                  return Container(
                    padding: EdgeInsets.all(SizeTokens.spaceSM),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceVariant.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(SizeTokens.radiusMD),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: SizeConfig.w(65),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _formatMonth(item.month),
                            style: TextStyle(
                              fontSize: SizeTokens.fontSM,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(
                              SizeTokens.radiusCircle,
                            ),
                            child: LinearProgressIndicator(
                              value: _getProgress(monthly!.data!, count),
                              minHeight: 6,
                              backgroundColor: AppTheme.divider,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppTheme.accent,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: SizeTokens.spaceSM),
                        Text(
                          '$count',
                          style: TextStyle(
                            fontSize: SizeTokens.fontSM,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
          SizedBox(height: SizeTokens.paddingMD),
        ],
      ],
    );

    if (!showHeader) return content;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(SizeTokens.radiusLG),
        border: Border.all(color: AppTheme.divider),
      ),
      child: content,
    );
  }

  String _formatMonth(String? month) {
    if (month == null || month.length < 7) return '—';
    try {
      final mIdx = int.parse(month.substring(5, 7));
      final months = [
        'Ocak',
        'Şubat',
        'Mart',
        'Nisan',
        'Mayıs',
        'Haziran',
        'Temmuz',
        'Ağustos',
        'Eylül',
        'Ekim',
        'Kasım',
        'Aralık',
      ];
      return months[mIdx - 1];
    } catch (_) {
      return month;
    }
  }

  double _getProgress(List<StatsMonthlyItemModel> data, int current) {
    final maxVal = data.fold<int>(0, (maxV, e) => max(maxV, e.count ?? 0));
    return maxVal > 0 ? (current / maxVal).clamp(0, 1) : 0;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Quick Actions Section (2×2 grid)
// ─────────────────────────────────────────────────────────────────────────────

// Palette for pie slices (cycles if more statuses than colors)
const _kPieColors = [
  Color(0xFF5C6BC0),
  Color(0xFF26A69A),
  Color(0xFFEF5350),
  Color(0xFFFF7043),
  Color(0xFF66BB6A),
  Color(0xFFAB47BC),
  Color(0xFF29B6F6),
  Color(0xFFFFCA28),
  Color(0xFF8D6E63),
  Color(0xFF78909C),
];

class _PieChartPainter extends CustomPainter {
  final List<dynamic> items;
  final List<Color> colors;

  const _PieChartPainter({required this.items, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final total = items.fold<int>(0, (s, e) => s + ((e.count as int?) ?? 0));
    if (total == 0) return;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    double startAngle = -pi / 2;

    for (var i = 0; i < items.length; i++) {
      final count = (items[i].count as int?) ?? 0;
      if (count == 0) continue;
      final sweep = (count / total) * 2 * pi;
      final paint = Paint()
        ..color = colors[i % colors.length]
        ..style = PaintingStyle.fill;
      canvas.drawArc(rect, startAngle, sweep, true, paint);
      startAngle += sweep;
    }
    // Inner circle for donut effect
    final innerPaint = Paint()
      ..color = AppTheme.surface
      ..style = PaintingStyle.fill;
    final innerRadius = size.width * 0.32;
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      innerRadius,
      innerPaint,
    );
  }

  @override
  bool shouldRepaint(_PieChartPainter old) => old.items != items;
}

// Detail dialog shown on pie tap
class _StatusDetailDialog extends StatefulWidget {
  final List<dynamic> byStatus;
  final String title;

  const _StatusDetailDialog({required this.byStatus, required this.title});

  @override
  State<_StatusDetailDialog> createState() => _StatusDetailDialogState();
}

class _StatusDetailDialogState extends State<_StatusDetailDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.byStatus.fold<int>(
      0,
      (s, e) => s + ((e.count as int?) ?? 0),
    );

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SizeTokens.radiusXL),
      ),
      backgroundColor: AppTheme.surface,
      insetPadding: EdgeInsets.all(SizeTokens.paddingLG),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(SizeTokens.paddingXL),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Header ──────────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: SizeTokens.fontLG,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.close_rounded,
                      color: AppTheme.textSecondary,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              Divider(height: SizeTokens.spaceXL, color: AppTheme.divider),

              // ── Animated Pie in Popup ───────────────────────────────
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: SizeConfig.w(140),
                  height: SizeConfig.h(140),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withValues(alpha: 0.1),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: CustomPaint(
                    painter: _PieChartPainter(
                      items: widget.byStatus,
                      colors: _kPieColors,
                    ),
                  ),
                ),
              ),
              SizedBox(height: SizeTokens.spaceXL),

              // ── Stats List with Anim ────────────────────────────────
              ...List.generate(widget.byStatus.length, (i) {
                final item = widget.byStatus[i];
                final count = (item.count as int?) ?? 0;
                if (count == 0) return const SizedBox.shrink();

                final pct = total > 0 ? count / total : 0.0;
                final color = _kPieColors[i % _kPieColors.length];

                return FadeTransition(
                  opacity: _controller,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: SizeTokens.spaceMD),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            SizedBox(width: SizeTokens.spaceSM),
                            Expanded(
                              child: Text(
                                item.name ?? '—',
                                style: TextStyle(
                                  fontSize: SizeTokens.fontSM,
                                  color: AppTheme.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Text(
                              '$count',
                              style: TextStyle(
                                fontSize: SizeTokens.fontSM,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            SizedBox(width: SizeTokens.spaceXS),
                            Text(
                              '(${(pct * 100).toStringAsFixed(1)}%)',
                              style: TextStyle(
                                fontSize: SizeTokens.fontXS,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: SizeTokens.spaceXS),
                        Stack(
                          children: [
                            Container(
                              height: 8,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceVariant,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 1000),
                              curve: Curves.easeOutCubic,
                              height: 8,
                              width: SizeConfig.screenWidth * 0.6 * pct,
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(4),
                                boxShadow: [
                                  BoxShadow(
                                    color: color.withValues(alpha: 0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

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
                  padding: EdgeInsets.symmetric(vertical: SizeTokens.spaceSM),
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
                              builder: (_) =>
                                  AppointmentsView(brandName: brandName),
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
