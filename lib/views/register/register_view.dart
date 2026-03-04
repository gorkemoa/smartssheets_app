import 'package:flutter/material.dart';
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
      create: (_) => RegisterViewModel(),
      child: Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          backgroundColor: AppTheme.background,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, size: SizeTokens.iconMD),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
          child: Consumer<RegisterViewModel>(
            builder: (context, viewModel, _) {
              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: SizeTokens.paddingPage),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: SizeTokens.spaceMD),
                      _buildHeader(),
                      SizedBox(height: SizeTokens.spaceXXL),
                      _buildForm(viewModel),
                      SizedBox(height: SizeTokens.spaceXL),
                      _buildErrorMessage(viewModel),
                      SizedBox(height: SizeTokens.spaceMD),
                      _buildRegisterButton(viewModel),
                      SizedBox(height: SizeTokens.spaceXL),
                      _buildLoginLink(),
                      SizedBox(height: SizeTokens.spaceXXL),
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
        Text(
          'Hesap Oluştur',
          style: TextStyle(
            fontSize: SizeTokens.fontDisplay,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: SizeTokens.spaceXXS),
        Text(
          'Ücretsiz hesabınızı şimdi oluşturun',
          style: TextStyle(
            fontSize: SizeTokens.fontMD,
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildForm(RegisterViewModel viewModel) {
    return Column(
      children: [
        AuthTextField(
          controller: _nameController,
          label: 'Ad Soyad',
          hint: 'Adınızı ve soyadınızı girin',
          keyboardType: TextInputType.name,
          textInputAction: TextInputAction.next,
          validator: Validators.name,
          onFieldSubmitted: (_) => _emailFocus.requestFocus(),
        ),
        SizedBox(height: SizeTokens.spaceMD),
        AuthTextField(
          controller: _emailController,
          focusNode: _emailFocus,
          label: 'E-posta',
          hint: 'ornek@email.com',
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          validator: Validators.email,
          onFieldSubmitted: (_) => _phoneFocus.requestFocus(),
        ),
        SizedBox(height: SizeTokens.spaceMD),
        AuthTextField(
          controller: _phoneController,
          focusNode: _phoneFocus,
          label: 'Telefon',
          hint: '+905551234567',
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
          validator: Validators.phone,
          onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
        ),
        SizedBox(height: SizeTokens.spaceMD),
        AuthTextField(
          controller: _passwordController,
          focusNode: _passwordFocus,
          label: 'Şifre',
          hint: '••••••••',
          isPassword: true,
          textInputAction: TextInputAction.next,
          validator: Validators.password,
          onFieldSubmitted: (_) => _passwordConfirmFocus.requestFocus(),
        ),
        SizedBox(height: SizeTokens.spaceMD),
        AuthTextField(
          controller: _passwordConfirmationController,
          focusNode: _passwordConfirmFocus,
          label: 'Şifre Tekrar',
          hint: '••••••••',
          isPassword: true,
          textInputAction: TextInputAction.done,
          validator: (value) => Validators.passwordConfirmation(
            value,
            _passwordController.text,
          ),
          onFieldSubmitted: (_) => _onRegisterPressed(viewModel),
        ),
      ],
    );
  }

  Widget _buildErrorMessage(RegisterViewModel viewModel) {
    if (viewModel.errorMessage == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(SizeTokens.paddingSM),
      decoration: BoxDecoration(
        color: AppTheme.errorLight,
        borderRadius: BorderRadius.circular(SizeTokens.radiusMD),
        border: Border.all(color: AppTheme.error.withOpacity(0.3)),
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

  Widget _buildRegisterButton(RegisterViewModel viewModel) {
    return SizedBox(
      width: double.infinity,
      height: SizeTokens.buttonHeight,
      child: ElevatedButton(
        onPressed: viewModel.isLoading ? null : () => _onRegisterPressed(viewModel),
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
                'Kayıt Ol',
                style: TextStyle(
                  fontSize: SizeTokens.fontLG,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textOnPrimary,
                ),
              ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Zaten hesabınız var mı? ',
          style: TextStyle(
            fontSize: SizeTokens.fontMD,
            color: AppTheme.textSecondary,
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Text(
            'Giriş Yap',
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
