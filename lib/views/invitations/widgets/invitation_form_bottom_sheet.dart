import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/app_theme.dart';
import '../../../core/responsive/size_config.dart';
import '../../../core/responsive/size_tokens.dart';
import '../../../l10n/strings.dart';
import '../../../viewmodels/invitations_view_model.dart';

class InvitationFormBottomSheet extends StatefulWidget {
  const InvitationFormBottomSheet({super.key});

  static Future<bool?> show(BuildContext context) {
    final viewModel =
        Provider.of<InvitationsViewModel>(context, listen: false);
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: viewModel,
        child: const InvitationFormBottomSheet(),
      ),
    );
  }

  @override
  State<InvitationFormBottomSheet> createState() =>
      _InvitationFormBottomSheetState();
}

class _InvitationFormBottomSheetState
    extends State<InvitationFormBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  String _selectedRole = 'member';

  bool _permCreateAppointment = false;
  bool _permUploadResult = false;
  bool _permChangeStatus = false;
  bool _permManageMembers = false;
  bool _permManageStatuses = false;
  bool _permManageAppointmentFields = false;

  static const List<String> _roles = ['member', 'admin', 'owner'];

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit(
    InvitationsViewModel viewModel,
    AppStrings l10n,
  ) async {
    if (!_formKey.currentState!.validate()) return;

    final success = await viewModel.createInvitation(
      email: _emailController.text.trim(),
      role: _selectedRole,
      permCreateAppointment: _permCreateAppointment,
      permUploadResult: _permUploadResult,
      permChangeStatus: _permChangeStatus,
      permManageMembers: _permManageMembers,
      permManageStatuses: _permManageStatuses,
      permManageAppointmentFields: _permManageAppointmentFields,
    );

    if (success && mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppStrings.of(context);
    return Consumer<InvitationsViewModel>(
      builder: (context, viewModel, _) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.background,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(SizeTokens.radiusXL),
              ),
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                SizeTokens.paddingXL,
                SizeTokens.paddingLG,
                SizeTokens.paddingXL,
                SizeTokens.paddingXL,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ── Handle ─────────────────────────────────────────
                    Center(
                      child: Container(
                        width: SizeConfig.w(10),
                        height: SizeTokens.spaceXS,
                        decoration: BoxDecoration(
                          color: AppTheme.border,
                          borderRadius: BorderRadius.circular(
                              SizeTokens.radiusCircle),
                        ),
                      ),
                    ),
                    SizedBox(height: SizeTokens.spaceLG),
                    // ── Title ──────────────────────────────────────────
                    Text(
                      l10n.invitationFormCreateTitle,
                      style: TextStyle(
                        fontSize: SizeTokens.fontXL,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    SizedBox(height: SizeTokens.spaceLG),
                    // ── Email field ────────────────────────────────────
                    _FieldLabel(label: l10n.invitationEmailLabel),
                    SizedBox(height: SizeTokens.spaceXS),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: l10n.invitationEmailHint,
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return l10n.validatorEmailEmpty;
                        }
                        if (!v.contains('@')) {
                          return l10n.validatorEmailInvalid;
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: SizeTokens.spaceMD),
                    // ── Role dropdown ──────────────────────────────────
                    _FieldLabel(label: l10n.invitationRoleLabel),
                    SizedBox(height: SizeTokens.spaceXS),
                    DropdownButtonFormField<String>(
                      value: _selectedRole,
                      decoration: const InputDecoration(),
                      items: _roles.map((r) {
                        final label = switch (r) {
                          'owner' => l10n.membersRoleOwner,
                          'admin' => l10n.membersRoleAdmin,
                          _ => l10n.membersRoleMember,
                        };
                        return DropdownMenuItem(value: r, child: Text(label));
                      }).toList(),
                      onChanged: (v) {
                        if (v != null) setState(() => _selectedRole = v);
                      },
                    ),
                    SizedBox(height: SizeTokens.spaceLG),
                    // ── Permissions ────────────────────────────────────
                    Text(
                      l10n.invitationPermissionsTitle,
                      style: TextStyle(
                        fontSize: SizeTokens.fontMD,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    SizedBox(height: SizeTokens.spaceXS),
                    _PermToggle(
                      label: l10n.membersPermCreateAppointment,
                      value: _permCreateAppointment,
                      onChanged: (v) =>
                          setState(() => _permCreateAppointment = v),
                    ),
                    _PermToggle(
                      label: l10n.membersPermUploadResult,
                      value: _permUploadResult,
                      onChanged: (v) =>
                          setState(() => _permUploadResult = v),
                    ),
                    _PermToggle(
                      label: l10n.membersPermChangeStatus,
                      value: _permChangeStatus,
                      onChanged: (v) =>
                          setState(() => _permChangeStatus = v),
                    ),
                    _PermToggle(
                      label: l10n.membersPermManageMembers,
                      value: _permManageMembers,
                      onChanged: (v) =>
                          setState(() => _permManageMembers = v),
                    ),
                    _PermToggle(
                      label: l10n.membersPermManageStatuses,
                      value: _permManageStatuses,
                      onChanged: (v) =>
                          setState(() => _permManageStatuses = v),
                    ),
                    _PermToggle(
                      label: l10n.membersPermManageAppointmentFields,
                      value: _permManageAppointmentFields,
                      onChanged: (v) =>
                          setState(() => _permManageAppointmentFields = v),
                    ),
                    // ── Submit error ───────────────────────────────────
                    if (viewModel.submitError != null) ...[
                      SizedBox(height: SizeTokens.spaceMD),
                      Container(
                        padding: EdgeInsets.all(SizeTokens.paddingMD),
                        decoration: BoxDecoration(
                          color: AppTheme.errorLight,
                          borderRadius:
                              BorderRadius.circular(SizeTokens.radiusMD),
                          border: Border.all(
                              color: AppTheme.error.withValues(alpha: 0.4)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline_rounded,
                                color: AppTheme.error,
                                size: SizeTokens.iconMD),
                            SizedBox(width: SizeTokens.spaceXS),
                            Expanded(
                              child: Text(
                                viewModel.submitError!,
                                style: TextStyle(
                                  fontSize: SizeTokens.fontSM,
                                  color: AppTheme.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    SizedBox(height: SizeTokens.spaceLG),
                    // ── Submit button ──────────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: viewModel.isSubmitting
                            ? null
                            : () => _onSubmit(viewModel, l10n),
                        child: viewModel.isSubmitting
                            ? SizedBox(
                                width: SizeTokens.iconMD,
                                height: SizeTokens.iconMD,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppTheme.textOnPrimary,
                                ),
                              )
                            : Text(l10n.invitationFormCreateButton),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Field label ─────────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: SizeTokens.fontSM,
        fontWeight: FontWeight.w600,
        color: AppTheme.textSecondary,
      ),
    );
  }
}

// ── Permission toggle row ────────────────────────────────────────────────────

class _PermToggle extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _PermToggle({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: SizeTokens.fontSM,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppTheme.primary,
        ),
      ],
    );
  }
}
