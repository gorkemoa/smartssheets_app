import 'package:flutter/material.dart';
import 'package:smartssheets_app/l10n/strings.dart';
import 'package:provider/provider.dart';
import '../../../app/app_theme.dart';
import '../../../core/responsive/size_config.dart';
import '../../../core/responsive/size_tokens.dart';
import '../../../core/utils/validators.dart';
import '../../../viewmodels/login_view_model.dart';
import '../register/register_view.dart';
import '../../../core/ui_components/auth_text_field.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'owner@demo.local');
  final _passwordController = TextEditingController(text: 'password');
  final _passwordFocus = FocusNode();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _onLoginPressed(LoginViewModel viewModel) async {
    if (!_formKey.currentState!.validate()) return;

    final success = await viewModel.login(
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      // TODO: Navigate to home screen after auth flow is complete
      final l10n = AppStrings.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.loginWelcomeBack(viewModel.authResponse?.user?.name ?? ''),
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
      create: (_) => LoginViewModel(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: AppTheme.primary,
        body: Stack(
          children: [
            // ── Background image ──
            Positioned.fill(
              child: Image.asset('assets/login-reg.jpg', fit: BoxFit.cover),
            ),

            // ── Content ──
            SafeArea(
              child: Column(
                children: [
                  SizedBox(
                    height: SizeConfig.h(210),
                    child: Center(child: _buildBranding()),
                  ),
                  Expanded(
                    child: _LoginFormCard(
                      formKey: _formKey,
                      emailController: _emailController,
                      passwordController: _passwordController,
                      passwordFocus: _passwordFocus,
                      onLoginPressed: _onLoginPressed,
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
        SizedBox(height: SizeTokens.spaceMD),
        Image.asset(
          'assets/smartmetrics-logo.png',
          width: SizeTokens.logoSize * 2.5,
          height: SizeTokens.logoSize * 2.5,
          color: Colors.white,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Login Form Card
// ─────────────────────────────────────────────────────────────────────────────

class _LoginFormCard extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final FocusNode passwordFocus;
  final Future<void> Function(LoginViewModel) onLoginPressed;

  const _LoginFormCard({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.passwordFocus,
    required this.onLoginPressed,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppStrings.of(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(SizeTokens.radiusXL),
        ),
      ),
      child: Consumer<LoginViewModel>(
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
                    l10n.loginTitle,
                    style: TextStyle(
                      fontSize: SizeTokens.fontDisplay,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(height: SizeTokens.spaceXXS),
                  Text(
                    l10n.loginSubtitle,
                    style: TextStyle(
                      fontSize: SizeTokens.fontMD,
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: SizeTokens.spaceXXL),
                  AuthTextField(
                    controller: emailController,
                    label: l10n.loginEmailLabel,
                    hint: l10n.loginEmailHint,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    validator: (v) => Validators.email(
                      v,
                      emptyMessage: l10n.validatorEmailEmpty,
                      invalidMessage: l10n.validatorEmailInvalid,
                    ),
                    onFieldSubmitted: (_) => passwordFocus.requestFocus(),
                  ),
                  SizedBox(height: SizeTokens.spaceMD),
                  AuthTextField(
                    controller: passwordController,
                    focusNode: passwordFocus,
                    label: l10n.loginPasswordLabel,
                    hint: l10n.loginPasswordHint,
                    isPassword: true,
                    textInputAction: TextInputAction.done,
                    validator: (v) => Validators.password(
                      v,
                      emptyMessage: l10n.validatorPasswordEmpty,
                      tooShortMessage: l10n.validatorPasswordTooShort,
                    ),
                    onFieldSubmitted: (_) => onLoginPressed(viewModel),
                  ),
                  SizedBox(height: SizeTokens.spaceXL),
                  if (viewModel.errorMessage != null) ...[
                    _ErrorBanner(message: viewModel.errorMessage!),
                    SizedBox(height: SizeTokens.spaceMD),
                  ],
                  SizedBox(
                    width: double.infinity,
                    height: SizeTokens.buttonHeight,
                    child: ElevatedButton(
                      onPressed: viewModel.isLoading
                          ? null
                          : () => onLoginPressed(viewModel),
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
                              l10n.loginButton,
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
                        l10n.loginNoAccount,
                        style: TextStyle(
                          fontSize: SizeTokens.fontMD,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RegisterView(),
                          ),
                        ),
                        child: Text(
                          l10n.loginSignUp,
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
// Shared Error Banner
// ─────────────────────────────────────────────────────────────────────────────

class _ErrorBanner extends StatelessWidget {
  final String message;

  const _ErrorBanner({required this.message});

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
          Icon(
            Icons.error_outline_rounded,
            color: AppTheme.error,
            size: SizeTokens.iconMD,
          ),
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
