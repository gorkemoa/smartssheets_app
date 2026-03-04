import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/app_theme.dart';
import '../../core/responsive/size_config.dart';
import '../../core/responsive/size_tokens.dart';
import '../../core/ui_components/main_app_bar.dart';
import '../../l10n/strings.dart';
import '../../viewmodels/appointment_statuses_view_model.dart';
import 'widgets/appointment_status_card.dart';
import 'widgets/appointment_status_form_bottom_sheet.dart';

class AppointmentStatusesView extends StatelessWidget {
  final int brandId;
  final String? brandName;

  const AppointmentStatusesView({
    super.key,
    required this.brandId,
    this.brandName,
  });

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    return ChangeNotifierProvider(
      create: (_) =>
          AppointmentStatusesViewModel(brandId: brandId)..init(),
      child: _AppointmentStatusesBody(brandName: brandName),
    );
  }
}

class _AppointmentStatusesBody extends StatefulWidget {
  final String? brandName;

  const _AppointmentStatusesBody({this.brandName});

  @override
  State<_AppointmentStatusesBody> createState() =>
      _AppointmentStatusesBodyState();
}

class _AppointmentStatusesBodyState
    extends State<_AppointmentStatusesBody> {
  Future<void> _openCreate(BuildContext context, AppStrings l10n) async {
    context.read<AppointmentStatusesViewModel>().clearSubmitError();
    final result = await AppointmentStatusFormBottomSheet.show(context);
    if (result == StatusFormResult.created && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.statusCreateSuccess),
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
    final viewModel = context.read<AppointmentStatusesViewModel>();
    viewModel.clearSubmitError();
    final result = await AppointmentStatusFormBottomSheet.show(
      context,
      status: viewModel.statuses[index],
    );
    if (!mounted) return;
    if (result == StatusFormResult.updated) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.statusUpdateSuccess),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (result == StatusFormResult.deleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.statusDeleteSuccess),
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
        title: widget.brandName != null
            ? '${widget.brandName} — ${l10n.statusesTitle}'
            : l10n.statusesTitle,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            size: SizeTokens.iconMD,
            color: AppTheme.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _openCreate(context, l10n),
            icon: Icon(
              Icons.add_rounded,
              size: SizeTokens.iconLG,
              color: AppTheme.primary,
            ),
            tooltip: l10n.statusFormCreateTitle,
          ),
        ],
      ),
      body: Consumer<AppointmentStatusesViewModel>(
        builder: (context, viewModel, _) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.errorMessage != null) {
            return _ErrorState(
              message: viewModel.errorMessage!,
              retryLabel: l10n.statusesRetry,
              onRetry: viewModel.onRetry,
            );
          }

          if (viewModel.statuses.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(SizeTokens.paddingPage),
                child: Text(
                  l10n.statusesEmpty,
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
              itemCount: viewModel.statuses.length,
              separatorBuilder: (_, __) =>
                  SizedBox(height: SizeTokens.spaceMD),
              itemBuilder: (_, index) => AppointmentStatusCard(
                status: viewModel.statuses[index],
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
