import 'package:flutter/material.dart';
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
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Hoş geldiniz, ${viewModel.authResponse?.user?.name ?? ''}!',
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
        backgroundColor: AppTheme.background,
        body: SafeArea(
          child: Consumer<LoginViewModel>(
            builder: (context, viewModel, _) {
              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: SizeTokens.paddingPage),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: SizeTokens.spaceXXXL),
                      _buildHeader(),
                      SizedBox(height: SizeTokens.spaceXXL),
                      _buildForm(viewModel),
                      SizedBox(height: SizeTokens.spaceXL),
                      _buildErrorMessage(viewModel),
                      SizedBox(height: SizeTokens.spaceMD),
                      _buildLoginButton(viewModel),
                      SizedBox(height: SizeTokens.spaceXL),
                      _buildRegisterLink(),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: SizeTokens.logoSize,
          height: SizeTokens.logoSize,
          decoration: BoxDecoration(
            color: AppTheme.primary,
            borderRadius: BorderRadius.circular(SizeTokens.radiusLG),
          ),
          child: Icon(
            Icons.grid_view_rounded,
            color: AppTheme.textOnPrimary,
            size: SizeTokens.iconXL,
          ),
        ),
        SizedBox(height: SizeTokens.spaceXL),
        Text(
          'Hoş Geldiniz',
          style: TextStyle(
            fontSize: SizeTokens.fontDisplay,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: SizeTokens.spaceXXS),
        Text(
          'Hesabınıza giriş yapın',
          style: TextStyle(
            fontSize: SizeTokens.fontMD,
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildForm(LoginViewModel viewModel) {
    return Column(
      children: [
        AuthTextField(
          controller: _emailController,
          label: 'E-posta',
          hint: 'ornek@email.com',
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          validator: Validators.email,
          onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
        ),
        SizedBox(height: SizeTokens.spaceMD),
        AuthTextField(
          controller: _passwordController,
          focusNode: _passwordFocus,
          label: 'Şifre',
          hint: '••••••••',
          isPassword: true,
          textInputAction: TextInputAction.done,
          validator: Validators.password,
          onFieldSubmitted: (_) => _onLoginPressed(viewModel),
        ),
      ],
    );
  }

  Widget _buildErrorMessage(LoginViewModel viewModel) {
    if (viewModel.errorMessage == null) return const SizedBox.shrink();

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
          Icon(Icons.error_outline_rounded, color: AppTheme.error, size: SizeTokens.iconMD),
          SizedBox(width: SizeTokens.spaceXS),
          Expanded(
            child: Text(
              viewModel.errorMessage!,
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

  Widget _buildLoginButton(LoginViewModel viewModel) {
    return SizedBox(
      width: double.infinity,
      height: SizeTokens.buttonHeight,
      child: ElevatedButton(
        onPressed: viewModel.isLoading ? null : () => _onLoginPressed(viewModel),
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
                'Giriş Yap',
                style: TextStyle(
                  fontSize: SizeTokens.fontLG,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textOnPrimary,
                ),
              ),
      ),
    );
  }

  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Hesabınız yok mu? ',
          style: TextStyle(
            fontSize: SizeTokens.fontMD,
            color: AppTheme.textSecondary,
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const RegisterView()),
          ),
          child: Text(
            'Kayıt Ol',
            style: TextStyle(
              fontSize: SizeTokens.fontMD,
              color: AppTheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
