import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../app/app_theme.dart';
import '../../core/responsive/size_config.dart';
import '../../core/responsive/size_tokens.dart';
import '../../core/ui_components/brand_picker_scaffold.dart';
import '../../core/ui_components/main_app_bar.dart';
import '../../l10n/strings.dart';
import '../../viewmodels/appointments_view_model.dart';
import 'appointment_detail_view.dart';
import 'appointment_form_view.dart';
import 'widgets/appointment_card.dart';

class AppointmentsView extends StatelessWidget {
  final int? brandId;
  final String? brandName;

  const AppointmentsView({super.key, this.brandId, this.brandName});

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final l10n = AppStrings.of(context);

    // Shell tab — no brand selected: show brand picker
    if (brandId == null) {
      return BrandPickerScaffold(
        title: l10n.appointmentsTitle,
        onBrandSelected: (brand) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => AppointmentsView(
                brandId: brand.id!,
                brandName: brand.name,
              ),
            ),
          );
        },
      );
    }

    return ChangeNotifierProvider(
      create: (_) => AppointmentsViewModel(brandId: brandId!)..init(),
      child: _AppointmentsBody(
        brandId: brandId!,
        brandName: brandName,
      ),
    );
  }
}

class _AppointmentsBody extends StatelessWidget {
  final int brandId;
  final String? brandName;

  const _AppointmentsBody({required this.brandId, this.brandName});

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final l10n = AppStrings.of(context);

    return Scaffold(
      backgroundColor: AppTheme.surfaceVariant,
      appBar: MainAppBar(
        title: brandName != null
            ? '${brandName!} — ${l10n.appointmentsTitle}'
            : l10n.appointmentsTitle,
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
          Consumer<AppointmentsViewModel>(
            builder: (context, viewModel, _) => IconButton(
              onPressed: () async {
                viewModel.clearSubmitError();
                final result = await Navigator.of(context).push<bool>(
                  MaterialPageRoute(
                    builder: (_) => ChangeNotifierProvider.value(
                      value: viewModel,
                      child: AppointmentFormView(brandId: brandId),
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
      body: Consumer<AppointmentsViewModel>(
        builder: (context, viewModel, _) {
          if (viewModel.isLoading && viewModel.appointments.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.errorMessage != null &&
              viewModel.appointments.isEmpty) {
            return _ErrorState(
              message: viewModel.errorMessage!,
              retryLabel: l10n.appointmentsRetry,
              onRetry: viewModel.onRetry,
            );
          }

          return Column(
            children: [
              // ── Monthly calendar ──────────────────────────────────
              Container(
                color: AppTheme.surface,
                child: TableCalendar<dynamic>(
                  firstDay: DateTime(2020),
                  lastDay: DateTime(2030),
                  focusedDay: viewModel.focusedDay,
                  selectedDayPredicate: (day) =>
                      isSameDay(day, viewModel.selectedDay),
                  eventLoader: viewModel.eventsForDay,
                  calendarFormat: CalendarFormat.month,
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle: TextStyle(
                      fontSize: SizeTokens.fontMD,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                    leftChevronIcon: Icon(
                      Icons.chevron_left_rounded,
                      color: AppTheme.textSecondary,
                      size: SizeTokens.iconMD,
                    ),
                    rightChevronIcon: Icon(
                      Icons.chevron_right_rounded,
                      color: AppTheme.textSecondary,
                      size: SizeTokens.iconMD,
                    ),
                  ),
                  calendarStyle: CalendarStyle(
                    outsideDaysVisible: false,
                    todayDecoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    todayTextStyle: TextStyle(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: SizeTokens.fontSM,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: AppTheme.primary,
                      shape: BoxShape.circle,
                    ),
                    selectedTextStyle: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: SizeTokens.fontSM,
                    ),
                    defaultTextStyle: TextStyle(
                      fontSize: SizeTokens.fontSM,
                      color: AppTheme.textPrimary,
                    ),
                    weekendTextStyle: TextStyle(
                      fontSize: SizeTokens.fontSM,
                      color: AppTheme.textPrimary,
                    ),
                    markerDecoration: BoxDecoration(
                      color: AppTheme.accent,
                      shape: BoxShape.circle,
                    ),
                    markerSize: 5,
                  ),
                  daysOfWeekStyle: DaysOfWeekStyle(
                    weekdayStyle: TextStyle(
                      fontSize: SizeTokens.fontXS,
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                    weekendStyle: TextStyle(
                      fontSize: SizeTokens.fontXS,
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onDaySelected: viewModel.onDaySelected,
                  onPageChanged: viewModel.onPageChanged,
                ),
              ),
              Divider(height: 1, color: AppTheme.divider),

              // ── Daily appointment list ─────────────────────────────
              Expanded(
                child: RefreshIndicator(
                  color: AppTheme.primary,
                  onRefresh: viewModel.refresh,
                  child: viewModel.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : viewModel.selectedDayAppointments.isEmpty
                          ? ListView(
                              padding:
                                  EdgeInsets.all(SizeTokens.paddingPage),
                              children: [
                                SizedBox(height: SizeTokens.spaceXXL),
                                Center(
                                  child: Text(
                                    l10n.appointmentsEmpty,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: SizeTokens.fontLG,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : ListView.separated(
                              padding:
                                  EdgeInsets.all(SizeTokens.paddingPage),
                              itemCount: viewModel
                                  .selectedDayAppointments.length,
                              separatorBuilder: (_, __) =>
                                  SizedBox(height: SizeTokens.spaceMD),
                              itemBuilder: (_, index) {
                                final appt = viewModel
                                    .selectedDayAppointments[index];
                                return AppointmentCard(
                                  appointment: appt,
                                  onTap: () async {
                                    final result = await Navigator.of(
                                            context)
                                        .push<bool>(
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            ChangeNotifierProvider.value(
                                          value: viewModel,
                                          child: AppointmentDetailView(
                                            brandId: brandId,
                                            appointment: appt,
                                          ),
                                        ),
                                      ),
                                    );
                                    if (result == true &&
                                        context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            l10n.appointmentUpdateSuccess,
                                          ),
                                          behavior:
                                              SnackBarBehavior.floating,
                                        ),
                                      );
                                    }
                                  },
                                );
                              },
                            ),
                ),
              ),
            ],
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
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: SizeTokens.fontLG,
                color: AppTheme.textSecondary,
              ),
            ),
            SizedBox(height: SizeTokens.spaceLG),
            TextButton(
              onPressed: onRetry,
              child: Text(retryLabel),
            ),
          ],
        ),
      ),
    );
  }
}