import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/app_theme.dart';
import '../../core/responsive/size_config.dart';
import '../../core/responsive/size_tokens.dart';
import '../../core/ui_components/brand_picker_scaffold.dart';
import '../../core/ui_components/main_app_bar.dart';
import '../../l10n/strings.dart';
import '../../models/membership_model.dart';
import '../../viewmodels/members_view_model.dart';
import '../invitations/invitations_view.dart';
import '../statuses/appointment_statuses_view.dart';
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

    // No brand selected — show brand picker
    if (brandId == null) {
      return BrandPickerScaffold(
        title: l10n.membersTitle,
        onBrandSelected: (brand) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => MembersView(
                brandId: brand.id!,
                brandName: brand.name,
              ),
            ),
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
  Future<void> _openCreateMember(
    BuildContext context,
    AppStrings l10n,
  ) async {
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
        title: widget.brandName ?? l10n.membersTitle,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            size: SizeTokens.iconMD,
            color: AppTheme.textPrimary,
          ),
        ),
        actions: [
          // Navigate to statuses screen
          IconButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => AppointmentStatusesView(
                  brandId: widget.brandId,
                  brandName: widget.brandName,
                ),
              ),
            ),
            icon: Icon(
              Icons.palette_outlined,
              size: SizeTokens.iconMD,
              color: AppTheme.textSecondary,
            ),
            tooltip: l10n.statusesNavButton,
          ),
          // Navigate to invitations screen
          IconButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => InvitationsView(
                  brandId: widget.brandId,
                  brandName: widget.brandName,
                ),
              ),
            ),
            icon: Icon(
              Icons.mail_outline_rounded,
              size: SizeTokens.iconMD,
              color: AppTheme.textSecondary,
            ),
            tooltip: l10n.invitationsNavButton,
          ),
          IconButton(
            onPressed: () => _openCreateMember(context, l10n),
            icon: Icon(
              Icons.add_rounded,
              size: SizeTokens.iconLG,
              color: AppTheme.primary,
            ),
            tooltip: l10n.memberFormCreateTitle,
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
                child: Text(
                  l10n.membersEmpty,
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
              itemCount: viewModel.members.length,
              separatorBuilder: (_, __) =>
                  SizedBox(height: SizeTokens.spaceMD),
              itemBuilder: (_, index) => MemberCard(
                member: viewModel.members[index],
                l10n: l10n,
                onEdit: () => _openEditMember(
                  context,
                  l10n,
                  viewModel.members[index],
                ),
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

