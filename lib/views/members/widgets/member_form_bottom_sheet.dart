import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/app_theme.dart';
import '../../../core/responsive/size_config.dart';
import '../../../core/responsive/size_tokens.dart';
import '../../../l10n/strings.dart';
import '../../../models/membership_model.dart';
import '../../../viewmodels/members_view_model.dart';

class MemberFormBottomSheet extends StatefulWidget {
  final MembershipModel? member;

  const MemberFormBottomSheet({super.key, this.member});

  bool get _isEditing => member != null;

  static Future<MemberFormResult?> show(
    BuildContext context, {
    MembershipModel? member,
  }) {
    final viewModel = Provider.of<MembersViewModel>(context, listen: false);
    return showModalBottomSheet<MemberFormResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (_) => ChangeNotifierProvider.value(
        value: viewModel,
        child: MemberFormBottomSheet(member: member),
      ),
    );
  }

  @override
  State<MemberFormBottomSheet> createState() =>
      _MemberFormBottomSheetState();
}

enum MemberFormResult { created, updated, deleted }

class _MemberFormBottomSheetState extends State<MemberFormBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _passwordController;

  late String _selectedRole;
  late String _selectedStatus;

  late bool _permCreateAppointment;
  late bool _permUploadResult;
  late bool _permChangeStatus;
  late bool _permManageMembers;
  late bool _permManageStatuses;
  late bool _permManageAppointmentFields;

  static const List<String> _roles = ['member', 'admin', 'owner'];
  static const List<String> _statuses = ['active', 'inactive'];

  @override
  void initState() {
    super.initState();
    final m = widget.member;
    final perms = m?.permissionsJson;

    _nameController = TextEditingController(text: m?.user?.name ?? '');
    _emailController = TextEditingController(text: m?.user?.email ?? '');
    _phoneController = TextEditingController();
    _passwordController = TextEditingController();

    _selectedRole = m?.role ?? 'member';
    _selectedStatus = m?.status ?? 'active';

    _permCreateAppointment = perms?.createAppointment ?? false;
    _permUploadResult = perms?.uploadResult ?? false;
    _permChangeStatus = perms?.changeStatus ?? false;
    _permManageMembers = perms?.manageMembers ?? false;
    _permManageStatuses = perms?.manageStatuses ?? false;
    _permManageAppointmentFields = perms?.manageAppointmentFields ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool get _isLastStep => _currentStep == 1;

  void _onNext() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _currentStep = 1);
  }

  void _onBack() {
    setState(() => _currentStep = 0);
  }

  Future<void> _onSubmit(
    MembersViewModel viewModel,
    AppStrings l10n,
  ) async {
    if (!_formKey.currentState!.validate()) return;

    bool success;
    if (widget._isEditing) {
      success = await viewModel.updateMember(
        widget.member!.id!,
        role: _selectedRole,
        status: _selectedStatus,
        permCreateAppointment: _permCreateAppointment,
        permUploadResult: _permUploadResult,
        permChangeStatus: _permChangeStatus,
        permManageMembers: _permManageMembers,
        permManageStatuses: _permManageStatuses,
        permManageAppointmentFields: _permManageAppointmentFields,
      );
    } else {
      success = await viewModel.createMember(
        email: _emailController.text.trim(),
        name: _nameController.text.trim(),
        password: _passwordController.text,
        role: _selectedRole,
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        permCreateAppointment: _permCreateAppointment,
        permUploadResult: _permUploadResult,
        permChangeStatus: _permChangeStatus,
        permManageMembers: _permManageMembers,
        permManageStatuses: _permManageStatuses,
        permManageAppointmentFields: _permManageAppointmentFields,
      );
    }

    if (!mounted) return;
    if (success) {
      Navigator.of(context).pop(
        widget._isEditing
            ? MemberFormResult.updated
            : MemberFormResult.created,
      );
    }
  }

  Future<void> _onDelete(
    MembersViewModel viewModel,
    AppStrings l10n,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.memberFormDeleteConfirmTitle),
        content: Text(l10n.memberFormDeleteConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              l10n.memberFormDeleteCancel,
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              l10n.memberFormDeleteConfirm,
              style: TextStyle(color: AppTheme.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final success = await viewModel.deleteMember(widget.member!.id!);
    if (!mounted) return;
    if (success) Navigator.of(context).pop(MemberFormResult.deleted);
  }

  String _stepTitle(AppStrings l10n) {
    if (_currentStep == 0) {
      return widget._isEditing
          ? l10n.memberFormEditTitle
          : l10n.memberFormCreateTitle;
    }
    return widget._isEditing
        ? l10n.memberFormPermissionsTitle
        : l10n.memberFormRolePermissionsTitle;
  }

  Widget _buildStep0(AppStrings l10n) {
    if (widget._isEditing) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _SectionLabel(
            label: l10n.memberFormRoleLabel,
            icon: Icons.shield_outlined,
          ),
          SizedBox(height: SizeTokens.spaceSM),
          _RoleDropdown(
            value: _selectedRole,
            roles: _roles,
            l10n: l10n,
            onChanged: (v) => setState(() => _selectedRole = v!),
          ),
          SizedBox(height: SizeTokens.spaceMD),
          _SectionLabel(
            label: l10n.memberFormStatusLabel,
            icon: Icons.radio_button_checked_rounded,
          ),
          SizedBox(height: SizeTokens.spaceSM),
          _StatusDropdown(
            value: _selectedStatus,
            statuses: _statuses,
            l10n: l10n,
            onChanged: (v) => setState(() => _selectedStatus = v!),
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _MemberTextField(
          controller: _nameController,
          label: l10n.memberFormNameLabel,
          hint: l10n.memberFormNameHint,
          textInputAction: TextInputAction.next,
          validator: (v) => (v == null || v.trim().isEmpty) ? '*' : null,
        ),
        SizedBox(height: SizeTokens.spaceMD),
        _MemberTextField(
          controller: _emailController,
          label: l10n.memberFormEmailLabel,
          hint: l10n.memberFormEmailHint,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          validator: (v) => (v == null || v.trim().isEmpty) ? '*' : null,
        ),
        SizedBox(height: SizeTokens.spaceMD),
        _MemberTextField(
          controller: _phoneController,
          label: l10n.memberFormPhoneLabel,
          hint: l10n.memberFormPhoneHint,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
        ),
        SizedBox(height: SizeTokens.spaceMD),
        _MemberTextField(
          controller: _passwordController,
          label: l10n.memberFormPasswordLabel,
          hint: l10n.memberFormPasswordHint,
          obscureText: true,
          textInputAction: TextInputAction.done,
          validator: (v) => (v == null || v.length < 8) ? '*' : null,
        ),
      ],
    );
  }

  Widget _buildStep1(AppStrings l10n) {
    final permsWidget = Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(SizeTokens.radiusLG),
      ),
      child: Column(
        children: [
          _PermSwitch(
            label: l10n.membersPermCreateAppointment,
            value: _permCreateAppointment,
            onChanged: (v) => setState(() => _permCreateAppointment = v),
            showDivider: true,
          ),
          _PermSwitch(
            label: l10n.membersPermUploadResult,
            value: _permUploadResult,
            onChanged: (v) => setState(() => _permUploadResult = v),
            showDivider: true,
          ),
          _PermSwitch(
            label: l10n.membersPermChangeStatus,
            value: _permChangeStatus,
            onChanged: (v) => setState(() => _permChangeStatus = v),
            showDivider: true,
          ),
          _PermSwitch(
            label: l10n.membersPermManageMembers,
            value: _permManageMembers,
            onChanged: (v) => setState(() => _permManageMembers = v),
            showDivider: true,
          ),
          _PermSwitch(
            label: l10n.membersPermManageStatuses,
            value: _permManageStatuses,
            onChanged: (v) => setState(() => _permManageStatuses = v),
            showDivider: true,
          ),
          _PermSwitch(
            label: l10n.membersPermManageAppointmentFields,
            value: _permManageAppointmentFields,
            onChanged: (v) =>
                setState(() => _permManageAppointmentFields = v),
            showDivider: false,
          ),
        ],
      ),
    );

    if (!widget._isEditing) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _SectionLabel(
            label: l10n.memberFormRoleLabel,
            icon: Icons.shield_outlined,
          ),
          SizedBox(height: SizeTokens.spaceSM),
          _RoleDropdown(
            value: _selectedRole,
            roles: _roles,
            l10n: l10n,
            onChanged: (v) => setState(() => _selectedRole = v!),
          ),
          SizedBox(height: SizeTokens.spaceMD),
          _SectionLabel(
            label: l10n.memberFormPermissionsTitle,
            icon: Icons.lock_outline_rounded,
          ),
          SizedBox(height: SizeTokens.spaceSM),
          permsWidget,
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _SectionLabel(
          label: l10n.memberFormPermissionsTitle,
          icon: Icons.lock_outline_rounded,
        ),
        SizedBox(height: SizeTokens.spaceSM),
        permsWidget,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final l10n = AppStrings.of(context);
    final viewModel = context.watch<MembersViewModel>();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(SizeTokens.radiusXXL),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Handle bar ───────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.only(top: SizeTokens.spaceMD),
              child: Center(
                child: Container(
                  width: SizeTokens.spaceXXXL,
                  height: SizeTokens.spaceXXS,
                  decoration: BoxDecoration(
                    color: AppTheme.border,
                    borderRadius:
                        BorderRadius.circular(SizeTokens.radiusCircle),
                  ),
                ),
              ),
            ),
            // ── Scrollable content ───────────────────────────────────────────
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  SizeTokens.paddingPage,
                  SizeTokens.spaceLG,
                  SizeTokens.paddingPage,
                  SizeTokens.spaceXXXL,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ── Title + step dots ──────────────────────────────────
                      Row(
                        children: [
                          Container(
                            width: SizeTokens.spaceXXS * 1.5,
                            height: SizeTokens.fontXXL,
                            decoration: BoxDecoration(
                              color: AppTheme.primary,
                              borderRadius: BorderRadius.circular(
                                  SizeTokens.radiusCircle),
                            ),
                          ),
                          SizedBox(width: SizeTokens.spaceSM),
                          Expanded(
                            child: Text(
                              _stepTitle(l10n),
                              style: TextStyle(
                                fontSize: SizeTokens.fontXXL,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                                letterSpacing: -0.4,
                              ),
                            ),
                          ),
                          _StepDots(
                            currentStep: _currentStep,
                            totalSteps: 2,
                          ),
                        ],
                      ),
                      SizedBox(height: SizeTokens.spaceXXL),

                      // ── Step content (animated) ────────────────────────────
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        transitionBuilder: (child, animation) =>
                            FadeTransition(
                          opacity: animation,
                          child: child,
                        ),
                        child: KeyedSubtree(
                          key: ValueKey(_currentStep),
                          child: _currentStep == 0
                              ? _buildStep0(l10n)
                              : _buildStep1(l10n),
                        ),
                      ),

                      // ── Submit error ────────────────────────────────────────
                      if (viewModel.submitError != null) ...[
                        SizedBox(height: SizeTokens.spaceMD),
                        Container(
                          padding: EdgeInsets.all(SizeTokens.paddingMD),
                          decoration: BoxDecoration(
                            color: AppTheme.errorLight,
                            borderRadius:
                                BorderRadius.circular(SizeTokens.radiusMD),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline_rounded,
                                size: SizeTokens.iconMD,
                                color: AppTheme.error,
                              ),
                              SizedBox(width: SizeTokens.spaceSM),
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
                      SizedBox(height: SizeTokens.spaceXXL),

                      // ── Navigation: Back / Next or Submit ─────────────────
                      Row(
                        children: [
                          if (_currentStep > 0) ...[
                            Expanded(
                              child: SizedBox(
                                height: SizeTokens.buttonHeight,
                                child: OutlinedButton(
                                  onPressed: viewModel.isSubmitting
                                      ? null
                                      : _onBack,
                                  style: OutlinedButton.styleFrom(
                                    side:
                                        BorderSide(color: AppTheme.border),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          SizeTokens.radiusLG),
                                    ),
                                  ),
                                  child: Text(
                                    l10n.memberFormBackButton,
                                    style: TextStyle(
                                      fontSize: SizeTokens.fontLG,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: SizeTokens.spaceSM),
                          ],
                          Expanded(
                            child: SizedBox(
                              height: SizeTokens.buttonHeight,
                              child: ElevatedButton(
                                onPressed: viewModel.isSubmitting
                                    ? null
                                    : _isLastStep
                                        ? () => _onSubmit(viewModel, l10n)
                                        : _onNext,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primary,
                                  disabledBackgroundColor:
                                      AppTheme.primaryLight,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        SizeTokens.radiusLG),
                                  ),
                                ),
                                child: viewModel.isSubmitting && _isLastStep
                                    ? SizedBox(
                                        width: SizeTokens.iconMD,
                                        height: SizeTokens.iconMD,
                                        child: CircularProgressIndicator(
                                          strokeWidth: SizeConfig.w(2),
                                          color: AppTheme.textOnPrimary,
                                        ),
                                      )
                                    : Text(
                                        _isLastStep
                                            ? (widget._isEditing
                                                ? l10n.memberFormSaveButton
                                                : l10n.memberFormCreateButton)
                                            : l10n.memberFormNextButton,
                                        style: TextStyle(
                                          fontSize: SizeTokens.fontLG,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.textOnPrimary,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // ── Delete button (edit only, last step) ───────────────
                      if (widget._isEditing && _isLastStep) ...[
                        SizedBox(height: SizeTokens.spaceMD),
                        SizedBox(
                          width: double.infinity,
                          height: SizeTokens.buttonHeight,
                          child: OutlinedButton(
                            onPressed: viewModel.isSubmitting
                                ? null
                                : () => _onDelete(viewModel, l10n),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: AppTheme.error),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    SizeTokens.radiusLG),
                              ),
                            ),
                            child: Text(
                              l10n.memberFormDeleteButton,
                              style: TextStyle(
                                fontSize: SizeTokens.fontLG,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.error,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
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

class _StepDots extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const _StepDots({required this.currentStep, required this.totalSteps});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        totalSteps,
        (i) => AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: EdgeInsets.only(left: SizeTokens.spaceXXS),
          width: i == currentStep
              ? SizeTokens.spaceLG
              : SizeTokens.spaceXXS * 1.5,
          height: SizeTokens.spaceXXS * 1.5,
          decoration: BoxDecoration(
            color:
                i == currentStep ? AppTheme.primary : AppTheme.border,
            borderRadius: BorderRadius.circular(SizeTokens.radiusCircle),
          ),
        ),
      ),
    );
  }
}

// ─── Internal widgets ─────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  final IconData? icon;

  const _SectionLabel({required this.label, this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(
            icon,
            size: SizeTokens.iconSM,
            color: AppTheme.textSecondary,
          ),
          SizedBox(width: SizeTokens.spaceXXS),
        ],
        Text(
          label,
          style: TextStyle(
            fontSize: SizeTokens.fontSM,
            fontWeight: FontWeight.w600,
            color: AppTheme.textSecondary,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}

class _PermSwitch extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool showDivider;

  const _PermSwitch({
    required this.label,
    required this.value,
    required this.onChanged,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: SizeTokens.paddingMD,
            vertical: SizeTokens.spaceXXS,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: SizeTokens.fontMD,
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
          ),
        ),
        if (showDivider)
          Divider(
            color: AppTheme.divider,
            height: SizeTokens.dividerHeight,
            indent: SizeTokens.paddingMD,
            endIndent: SizeTokens.paddingMD,
          ),
      ],
    );
  }
}

class _RoleDropdown extends StatelessWidget {
  final String value;
  final List<String> roles;
  final AppStrings l10n;
  final ValueChanged<String?> onChanged;

  const _RoleDropdown({
    required this.value,
    required this.roles,
    required this.l10n,
    required this.onChanged,
  });

  String _roleLabel(String role, AppStrings l10n) {
    switch (role) {
      case 'owner':
        return l10n.membersRoleOwner;
      case 'admin':
        return l10n.membersRoleAdmin;
      default:
        return l10n.membersRoleMember;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      onChanged: onChanged,
      decoration: _dropdownDecoration(),
      items: roles
          .map((r) => DropdownMenuItem(
                value: r,
                child: Text(_roleLabel(r, l10n)),
              ))
          .toList(),
    );
  }
}

class _StatusDropdown extends StatelessWidget {
  final String value;
  final List<String> statuses;
  final AppStrings l10n;
  final ValueChanged<String?> onChanged;

  const _StatusDropdown({
    required this.value,
    required this.statuses,
    required this.l10n,
    required this.onChanged,
  });

  String _statusLabel(String status, AppStrings l10n) {
    switch (status) {
      case 'active':
        return l10n.memberFormStatusActive;
      default:
        return l10n.memberFormStatusInactive;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      onChanged: onChanged,
      decoration: _dropdownDecoration(),
      items: statuses
          .map((s) => DropdownMenuItem(
                value: s,
                child: Text(_statusLabel(s, l10n)),
              ))
          .toList(),
    );
  }
}

InputDecoration _dropdownDecoration() {
  return InputDecoration(
    filled: true,
    fillColor: AppTheme.inputFill,
    contentPadding: EdgeInsets.symmetric(
      horizontal: SizeTokens.paddingMD,
      vertical: SizeTokens.paddingSM,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(SizeTokens.radiusMD),
      borderSide: const BorderSide(color: AppTheme.border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(SizeTokens.radiusMD),
      borderSide: const BorderSide(color: AppTheme.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(SizeTokens.radiusMD),
      borderSide: const BorderSide(color: AppTheme.borderFocused, width: 1.5),
    ),
  );
}

class _MemberTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final TextInputAction textInputAction;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;

  const _MemberTextField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.textInputAction,
    this.keyboardType,
    this.obscureText = false,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      textInputAction: textInputAction,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      style: TextStyle(
        fontSize: SizeTokens.fontLG,
        color: AppTheme.textPrimary,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: AppTheme.inputFill,
        labelStyle: TextStyle(
          fontSize: SizeTokens.fontMD,
          color: AppTheme.textSecondary,
        ),
        hintStyle: TextStyle(
          fontSize: SizeTokens.fontMD,
          color: AppTheme.textHint,
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: SizeTokens.paddingMD,
          vertical: SizeTokens.paddingSM,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SizeTokens.radiusMD),
          borderSide: const BorderSide(color: AppTheme.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SizeTokens.radiusMD),
          borderSide: const BorderSide(color: AppTheme.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SizeTokens.radiusMD),
          borderSide:
              const BorderSide(color: AppTheme.borderFocused, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SizeTokens.radiusMD),
          borderSide: const BorderSide(color: AppTheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SizeTokens.radiusMD),
          borderSide: const BorderSide(color: AppTheme.error, width: 1.5),
        ),
      ),
    );
  }
}
