import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/app_theme.dart';
import '../../core/responsive/size_config.dart';
import '../../core/responsive/size_tokens.dart';
import '../../core/ui_components/main_app_bar.dart';
import '../../l10n/strings.dart';
import '../../viewmodels/appointment_fields_view_model.dart';
import '../../viewmodels/appointments_view_model.dart';
import '../../viewmodels/home_view_model.dart';
import '../appointments/appointment_form_view.dart';
import 'widgets/appointment_field_card.dart';
import 'widgets/appointment_field_form_bottom_sheet.dart';

class AppointmentFieldsView extends StatelessWidget {
  final int brandId;
  final String? brandName;

  const AppointmentFieldsView({
    super.key,
    required this.brandId,
    this.brandName,
  });

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    return ChangeNotifierProvider(
      create: (_) => AppointmentFieldsViewModel(brandId: brandId)..init(),
      child: _AppointmentFieldsBody(brandName: brandName),
    );
  }
}

class _AppointmentFieldsBody extends StatefulWidget {
  final String? brandName;

  const _AppointmentFieldsBody({this.brandName});

  @override
  State<_AppointmentFieldsBody> createState() => _AppointmentFieldsBodyState();
}

class _AppointmentFieldsBodyState extends State<_AppointmentFieldsBody> {
  Future<void> _openCreate(BuildContext context, AppStrings l10n) async {
    context.read<AppointmentFieldsViewModel>().clearSubmitError();
    final result = await AppointmentFieldFormBottomSheet.show(context);
    if (result == FieldFormResult.created && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.fieldCreateSuccess),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _openEdit(
    BuildContext context,
    AppStrings l10n,
    int index,
  ) async {
    final viewModel = context.read<AppointmentFieldsViewModel>();
    viewModel.clearSubmitError();
    final result = await AppointmentFieldFormBottomSheet.show(
      context,
      field: viewModel.fields[index],
    );
    if (!mounted) return;
    if (result == FieldFormResult.updated) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.fieldUpdateSuccess),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (result == FieldFormResult.deleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.fieldDeleteSuccess),
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
        title: l10n.fieldsTitle,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            size: SizeTokens.iconMD,
            color: AppTheme.textPrimary,
          ),
        ),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openCreate(context, l10n),
        backgroundColor: AppTheme.primary,
        foregroundColor: AppTheme.textOnPrimary,
        tooltip: l10n.fieldFormCreateTitle,
        icon: Icon(Icons.add_rounded, size: SizeTokens.iconLG),
        label: Text(l10n.fieldFormCreateTitle),
      ),
      body: Consumer<AppointmentFieldsViewModel>(
        builder: (context, viewModel, _) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.errorMessage != null) {
            return _ErrorState(
              message: viewModel.errorMessage!,
              retryLabel: l10n.fieldsRetry,
              onRetry: viewModel.onRetry,
            );
          }

          if (viewModel.fields.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(SizeTokens.paddingPage),
                child: Text(
                  l10n.fieldsEmpty,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: SizeTokens.fontLG,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
            );
          }

          return RefreshIndicator(
            color: AppTheme.primary,
            onRefresh: () => viewModel.refresh(),
            child: ListView.separated(
              padding: EdgeInsets.all(SizeTokens.paddingPage),
              itemCount: viewModel.fields.length,
              separatorBuilder: (_, __) => SizedBox(height: SizeTokens.spaceMD),
              itemBuilder: (_, index) => AppointmentFieldCard(
                field: viewModel.fields[index],
                l10n: l10n,
                onEdit: () => _openEdit(context, l10n, index),
              ),
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
            TextButton(onPressed: onRetry, child: Text(retryLabel)),
          ],
        ),
      ),
    );
  }
}
