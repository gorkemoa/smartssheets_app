import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/app_theme.dart';
import '../../../core/responsive/size_config.dart';
import '../../../core/responsive/size_tokens.dart';
import '../../../core/ui_components/auth_text_field.dart';
import '../../../l10n/strings.dart';
import '../../../models/change_password_request_model.dart';
import '../../../viewmodels/profile_view_model.dart';

class ChangePasswordSheet extends StatefulWidget {
  const ChangePasswordSheet({super.key});

  @override
  State<ChangePasswordSheet> createState() => _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends State<ChangePasswordSheet> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _onSave(AppStrings l10n) async {
    if (!_formKey.currentState!.validate()) return;

    final viewModel = context.read<ProfileViewModel>();
    try {
      await viewModel.changePassword(
        ChangePasswordRequestModel(
          currentPassword: _currentPasswordController.text,
          password: _newPasswordController.text,
          passwordConfirmation: _confirmPasswordController.text,
        ),
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.profileChangePasswordSuccess),
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
                l10n.profileChangePasswordTitle,
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
                      controller: _currentPasswordController,
                      label: l10n.profileCurrentPasswordLabel,
                      hint: l10n.profileCurrentPasswordHint,
                      isPassword: true,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n.validatorPasswordEmpty;
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: SizeTokens.spaceMD),
                    AuthTextField(
                      controller: _newPasswordController,
                      label: l10n.profileNewPasswordLabel,
                      hint: l10n.profileNewPasswordHint,
                      isPassword: true,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n.validatorPasswordEmpty;
                        }
                        if (value.length < 6) {
                          return l10n.validatorPasswordTooShort;
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: SizeTokens.spaceMD),
                    AuthTextField(
                      controller: _confirmPasswordController,
                      label: l10n.profileNewPasswordConfirmLabel,
                      hint: l10n.profileNewPasswordConfirmHint,
                      isPassword: true,
                      textInputAction: TextInputAction.done,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n.validatorPasswordConfirmEmpty;
                        }
                        if (value != _newPasswordController.text) {
                          return l10n.validatorPasswordMismatch;
                        }
                        return null;
                      },
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
                                  l10n.profileChangePasswordButton,
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
