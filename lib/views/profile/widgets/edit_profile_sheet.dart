import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/app_theme.dart';
import '../../../core/responsive/size_config.dart';
import '../../../core/responsive/size_tokens.dart';
import '../../../core/ui_components/auth_text_field.dart';
import '../../../l10n/strings.dart';
import '../../../models/update_profile_request_model.dart';
import '../../../models/user_model.dart';
import '../../../viewmodels/profile_view_model.dart';

class EditProfileSheet extends StatefulWidget {
  final UserModel? user;

  const EditProfileSheet({super.key, required this.user});

  @override
  State<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<EditProfileSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user?.name ?? '');
    _emailController = TextEditingController(text: widget.user?.email ?? '');
    _phoneController = TextEditingController(text: widget.user?.phone ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _onSave(AppStrings l10n) async {
    if (!_formKey.currentState!.validate()) return;

    final viewModel = context.read<ProfileViewModel>();
    try {
      await viewModel.updateProfile(
        UpdateProfileRequestModel(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
        ),
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.profileEditSuccess),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (errorMessage) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage.toString()),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final l10n = AppStrings.of(context);

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
            SizedBox(height: SizeTokens.spaceMD),
            Container(
              width: SizeConfig.w(40),
              height: SizeConfig.h(4),
              decoration: BoxDecoration(
                color: AppTheme.divider,
                borderRadius: BorderRadius.circular(SizeTokens.radiusCircle),
              ),
            ),
            SizedBox(height: SizeTokens.spaceLG),
            Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: SizeTokens.paddingPage),
              child: Text(
                l10n.profileEditTitle,
                style: TextStyle(
                  fontSize: SizeTokens.fontXL,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
            ),
            SizedBox(height: SizeTokens.spaceXL),
            Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: SizeTokens.paddingPage),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    AuthTextField(
                      controller: _nameController,
                      label: l10n.profileEditNameLabel,
                      hint: l10n.profileEditNameHint,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return l10n.validatorNameEmpty;
                        }
                        if (value.trim().length < 2) {
                          return l10n.validatorNameTooShort;
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: SizeTokens.spaceMD),
                    AuthTextField(
                      controller: _emailController,
                      label: l10n.profileEditEmailLabel,
                      hint: l10n.profileEditEmailHint,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return l10n.validatorEmailEmpty;
                        }
                        final emailRegex =
                            RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                        if (!emailRegex.hasMatch(value.trim())) {
                          return l10n.validatorEmailInvalid;
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: SizeTokens.spaceMD),
                    AuthTextField(
                      controller: _phoneController,
                      label: l10n.profileEditPhoneLabel,
                      hint: l10n.profileEditPhoneHint,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.done,
                    ),
                    SizedBox(height: SizeTokens.spaceXXL),
                    Consumer<ProfileViewModel>(
                      builder: (context, viewModel, _) => SizedBox(
                        width: double.infinity,
                        height: SizeTokens.buttonHeight,
                        child: ElevatedButton(
                          onPressed: viewModel.isSubmitting
                              ? null
                              : () => _onSave(l10n),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            foregroundColor: AppTheme.textOnPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                SizeTokens.radiusLG,
                              ),
                            ),
                          ),
                          child: viewModel.isSubmitting
                              ? SizedBox(
                                  width: SizeTokens.iconMD,
                                  height: SizeTokens.iconMD,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppTheme.textOnPrimary,
                                  ),
                                )
                              : Text(
                                  l10n.profileEditSaveButton,
                                  style: TextStyle(
                                    fontSize: SizeTokens.fontLG,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    SizedBox(height: SizeTokens.spaceXXXL),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
