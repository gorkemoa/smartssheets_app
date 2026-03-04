import 'package:flutter/material.dart';
import 'package:smartssheets_app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../../app/app_theme.dart';
import '../../../core/responsive/size_config.dart';
import '../../../core/responsive/size_tokens.dart';
import '../../../core/ui_components/auth_text_field.dart';
import '../../../core/utils/validators.dart';
import '../../../viewmodels/register_view_model.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmationController = TextEditingController();

  final _emailFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _passwordConfirmFocus = FocusNode();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _passwordConfirmationController.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    _passwordFocus.dispose();
    _passwordConfirmFocus.dispose();
    super.dispose();
  }

  Future<void> _onRegisterPressed(RegisterViewModel viewModel) async {
    if (!_formKey.currentState!.validate()) return;

    final success = await viewModel.register(
      name: _nameController.text,
      email: _emailController.text,
      phone: _phoneController.text,
      password: _passwordController.text,
      passwordConfirmation: _passwordConfirmationController.text,
    );

    if (!mounted) return;

    if (success) {
      // TODO: Navigate to home screen after auth flow is complete
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.registerWelcome(viewModel.authResponse?.user?.name ?? ''),
            style: TextStyle(fontSize: SizeTokens.fontMD),
          ),
          backgroundColor: AppTheme.accent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    return ChangeNotifierProvider(
      create: (_) => RegisterViewModel(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: AppTheme.primary,
        body: Stack(
          children: [
            // ── Background image ──
            Positioned.fill(
              child: Image.asset(
                'assets/login-reg.jpg',
                fit: BoxFit.cover,
              ),
            ),
            // ── Gradient overlay ──
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0x55000000),
                      AppTheme.primary.withValues(alpha: 0.55),
                      AppTheme.primary.withValues(alpha: 0.92),
                    ],
                    stops: const [0.0, 0.30, 0.60],
                  ),
                ),
              ),
            ),
            // ── Content ──
            SafeArea(
              child: Column(
                children: [
                  // Top narrow branding strip with back button
                  SizedBox(
                    height: SizeConfig.h(130),
                    child: Stack(
                      children: [
                        Center(child: _buildBranding()),
                        Positioned(
                          left: SizeTokens.paddingXS,
                          top: 0,
                          bottom: 0,
                          child: IconButton(
                            icon: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: Colors.white,
                            ),
                            iconSize: SizeTokens.iconMD,
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // White form card (scrollable)
                  Expanded(
                    child: _RegisterFormCard(
                      formKey: _formKey,
                      nameController: _nameController,
                      emailController: _emailController,
                      phoneController: _phoneController,
                      passwordController: _passwordController,
                      passwordConfirmationController:
                          _passwordConfirmationController,
                      emailFocus: _emailFocus,
                      phoneFocus: _phoneFocus,
                      passwordFocus: _passwordFocus,
                      passwordConfirmFocus: _passwordConfirmFocus,
                      onRegisterPressed: _onRegisterPressed,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBranding() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: SizeTokens.logoSize * 0.75,
          height: SizeTokens.logoSize * 0.75,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(SizeTokens.radiusMD),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.25),
              width: 1,
            ),
          ),
          child: Icon(
            Icons.grid_view_rounded,
            color: Colors.white,
            size: SizeTokens.iconLG,
          ),
        ),
        SizedBox(height: SizeTokens.spaceXS),
        Text(
          'SmartSheets',
          style: TextStyle(
            fontSize: SizeTokens.fontXL,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Register Form Card
// ─────────────────────────────────────────────────────────────────────────────

class _RegisterFormCard extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController passwordController;
  final TextEditingController passwordConfirmationController;
  final FocusNode emailFocus;
  final FocusNode phoneFocus;
  final FocusNode passwordFocus;
  final FocusNode passwordConfirmFocus;
  final Future<void> Function(RegisterViewModel) onRegisterPressed;

  const _RegisterFormCard({
    required this.formKey,
    required this.nameController,
    required this.emailController,
    required this.phoneController,
    required this.passwordController,
    required this.passwordConfirmationController,
    required this.emailFocus,
    required this.phoneFocus,
    required this.passwordFocus,
    required this.passwordConfirmFocus,
    required this.onRegisterPressed,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(SizeTokens.radiusXL),
        ),
      ),
      child: Consumer<RegisterViewModel>(
        builder: (context, viewModel, _) {
          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              SizeTokens.paddingPage,
              SizeTokens.spaceXXL,
              SizeTokens.paddingPage,
              SizeTokens.spaceXXXL,
            ),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.registerTitle,
                    style: TextStyle(
                      fontSize: SizeTokens.fontDisplay,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(height: SizeTokens.spaceXXS),
                  Text(
                    l10n.registerSubtitle,
                    style: TextStyle(
                      fontSize: SizeTokens.fontMD,
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: SizeTokens.spaceXXL),
                  AuthTextField(
                    controller: nameController,
                    label: l10n.registerNameLabel,
                    hint: l10n.registerNameHint,
                    keyboardType: TextInputType.name,
                    textInputAction: TextInputAction.next,
                    validator: (v) => Validators.name(v,
                        emptyMessage: l10n.validatorNameEmpty,
                        tooShortMessage: l10n.validatorNameTooShort),
                    onFieldSubmitted: (_) => emailFocus.requestFocus(),
                  ),
                  SizedBox(height: SizeTokens.spaceMD),
                  AuthTextField(
                    controller: emailController,
                    focusNode: emailFocus,
                    label: l10n.registerEmailLabel,
                    hint: l10n.registerEmailHint,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    validator: (v) => Validators.email(v,
                        emptyMessage: l10n.validatorEmailEmpty,
                        invalidMessage: l10n.validatorEmailInvalid),
                    onFieldSubmitted: (_) => phoneFocus.requestFocus(),
                  ),
                  SizedBox(height: SizeTokens.spaceMD),
                  AuthTextField(
                    controller: phoneController,
                    focusNode: phoneFocus,
                    label: l10n.registerPhoneLabel,
                    hint: l10n.registerPhoneHint,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    validator: (v) => Validators.phone(v,
                        emptyMessage: l10n.validatorPhoneEmpty,
                        invalidMessage: l10n.validatorPhoneInvalid),
                    onFieldSubmitted: (_) => passwordFocus.requestFocus(),
                  ),
                  SizedBox(height: SizeTokens.spaceMD),
                  AuthTextField(
                    controller: passwordController,
                    focusNode: passwordFocus,
                    label: l10n.registerPasswordLabel,
                    hint: l10n.registerPasswordHint,
                    isPassword: true,
                    textInputAction: TextInputAction.next,
                    validator: (v) => Validators.password(v,
                        emptyMessage: l10n.validatorPasswordEmpty,
                        tooShortMessage: l10n.validatorPasswordTooShort),
                    onFieldSubmitted: (_) => passwordConfirmFocus.requestFocus(),
                  ),
                  SizedBox(height: SizeTokens.spaceMD),
                  AuthTextField(
                    controller: passwordConfirmationController,
                    focusNode: passwordConfirmFocus,
                    label: l10n.registerPasswordConfirmLabel,
                    hint: l10n.registerPasswordConfirmHint,
                    isPassword: true,
                    textInputAction: TextInputAction.done,
                    validator: (value) => Validators.passwordConfirmation(
                      value,
                      passwordController.text,
                      emptyMessage: l10n.validatorPasswordConfirmEmpty,
                      mismatchMessage: l10n.validatorPasswordMismatch,
                    ),
                    onFieldSubmitted: (_) => onRegisterPressed(viewModel),
                  ),
                  SizedBox(height: SizeTokens.spaceXL),
                  if (viewModel.errorMessage != null) ...[
                    _RegisterErrorBanner(message: viewModel.errorMessage!),
                    SizedBox(height: SizeTokens.spaceMD),
                  ],
                  SizedBox(
                    width: double.infinity,
                    height: SizeTokens.buttonHeight,
                    child: ElevatedButton(
                      onPressed: viewModel.isLoading
                          ? null
                          : () => onRegisterPressed(viewModel),
                      child: viewModel.isLoading
                          ? SizedBox(
                              width: SizeTokens.iconMD,
                              height: SizeTokens.iconMD,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppTheme.textOnPrimary,
                              ),
                            )
                          : Text(
                              l10n.registerButton,
                              style: TextStyle(
                                fontSize: SizeTokens.fontLG,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textOnPrimary,
                              ),
                            ),
                    ),
                  ),
                  SizedBox(height: SizeTokens.spaceXL),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        l10n.registerHasAccount,
                        style: TextStyle(
                          fontSize: SizeTokens.fontMD,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Text(
                          l10n.registerSignIn,
                          style: TextStyle(
                            fontSize: SizeTokens.fontMD,
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Error Banner
// ─────────────────────────────────────────────────────────────────────────────

class _RegisterErrorBanner extends StatelessWidget {
  final String message;

  const _RegisterErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(SizeTokens.paddingSM),
      decoration: BoxDecoration(
        color: AppTheme.errorLight,
        borderRadius: BorderRadius.circular(SizeTokens.radiusMD),
        border: Border.all(color: AppTheme.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded,
              color: AppTheme.error, size: SizeTokens.iconMD),
          SizedBox(width: SizeTokens.spaceXS),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: SizeTokens.fontSM,
                color: AppTheme.error,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
