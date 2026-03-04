import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/app_theme.dart';
import '../../core/responsive/size_config.dart';
import '../../core/responsive/size_tokens.dart';
import '../../core/ui_components/main_app_bar.dart';
import '../../l10n/strings.dart';
import '../../viewmodels/invitations_view_model.dart';
import 'widgets/invitation_card.dart';
import 'widgets/invitation_form_bottom_sheet.dart';

class InvitationsView extends StatelessWidget {
  final int brandId;
  final String? brandName;

  const InvitationsView({
    super.key,
    required this.brandId,
    this.brandName,
  });

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    return ChangeNotifierProvider(
      create: (_) => InvitationsViewModel(brandId: brandId)..init(),
      child: _InvitationsBody(brandName: brandName),
    );
  }
}

class _InvitationsBody extends StatefulWidget {
  final String? brandName;

  const _InvitationsBody({this.brandName});

  @override
  State<_InvitationsBody> createState() => _InvitationsBodyState();
}

class _InvitationsBodyState extends State<_InvitationsBody> {
  Future<void> _openCreateInvitation(
    BuildContext context,
    AppStrings l10n,
  ) async {
    context.read<InvitationsViewModel>().clearSubmitError();
    final success = await InvitationFormBottomSheet.show(context);
    if ((success ?? false) && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.invitationCreateSuccess),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _onResend(
    BuildContext context,
    AppStrings l10n,
    int invitationId,
  ) async {
    final viewModel = context.read<InvitationsViewModel>();
    final success = await viewModel.resendInvitation(invitationId);
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.invitationResendSuccess),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (viewModel.submitError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(viewModel.submitError!),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppTheme.error,
        ),
      );
      viewModel.clearSubmitError();
    }
  }

  Future<void> _onDelete(
    BuildContext context,
    AppStrings l10n,
    int invitationId,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(l10n.invitationDeleteConfirmTitle),
        content: Text(l10n.invitationDeleteConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: Text(l10n.invitationDeleteCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            child: Text(
              l10n.invitationDeleteConfirm,
              style: TextStyle(color: AppTheme.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final viewModel = context.read<InvitationsViewModel>();
    final success = await viewModel.deleteInvitation(invitationId);
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.invitationDeleteSuccess),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (viewModel.submitError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(viewModel.submitError!),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppTheme.error,
        ),
      );
      viewModel.clearSubmitError();
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
            ? '${widget.brandName} — ${l10n.invitationsTitle}'
            : l10n.invitationsTitle,
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
            onPressed: () => _openCreateInvitation(context, l10n),
            icon: Icon(
              Icons.add_rounded,
              size: SizeTokens.iconLG,
              color: AppTheme.primary,
            ),
            tooltip: l10n.invitationFormCreateTitle,
          ),
        ],
      ),
      body: Consumer<InvitationsViewModel>(
        builder: (context, viewModel, _) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.errorMessage != null) {
            return _ErrorState(
              message: viewModel.errorMessage!,
              retryLabel: l10n.invitationsRetry,
              onRetry: viewModel.onRetry,
            );
          }

          if (viewModel.invitations.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(SizeTokens.paddingPage),
                child: Text(
                  l10n.invitationsEmpty,
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
              itemCount: viewModel.invitations.length,
              separatorBuilder: (_, __) =>
                  SizedBox(height: SizeTokens.spaceMD),
              itemBuilder: (_, index) {
                final inv = viewModel.invitations[index];
                final invId = inv.id;
                return InvitationCard(
                  invitation: inv,
                  l10n: l10n,
                  onResend: invId != null
                      ? () => _onResend(context, l10n, invId)
                      : null,
                  onDelete: invId != null
                      ? () => _onDelete(context, l10n, invId)
                      : null,
                );
              },
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
