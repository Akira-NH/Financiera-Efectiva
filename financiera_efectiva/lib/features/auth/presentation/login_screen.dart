import 'package:flutter/material.dart';

import '../../../app/routes/route_names.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/services/firebase_auth_service.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/brand_logo.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await FirebaseAuthService.instance.signIn(
        email: _emailController.text,
        password: _passwordController.text,
      );
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, RouteNames.dashboard);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            FirebaseAuthService.instance.messageForAuthError(error),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navyDark,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 720;
            return Stack(
              children: [
                Positioned.fill(child: _LoginBackground(isCompact: isCompact)),
                Align(
                  alignment: isCompact
                      ? Alignment.center
                      : Alignment.centerRight,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(isCompact ? 16 : 20),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: isCompact ? constraints.maxWidth : 560,
                      ),
                      child: _LoginForm(
                        formKey: _formKey,
                        emailController: _emailController,
                        passwordController: _passwordController,
                        isLoading: _isLoading,
                        onLogin: _login,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _LoginBackground extends StatelessWidget {
  const _LoginBackground({required this.isCompact});

  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    if (isCompact) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primaryLight, AppColors.navyDark],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: const SizedBox.shrink(),
      );
    }

    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryLight, Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const SizedBox.shrink(),
          ),
        ),
        const Expanded(child: SizedBox()),
      ],
    );
  }
}

class _LoginForm extends StatefulWidget {
  const _LoginForm({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.isLoading,
    required this.onLogin,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isLoading;
  final VoidCallback? onLogin;

  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: Form(
        key: widget.formKey,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 30, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Center(child: BrandLogo(light: true)),
              const SizedBox(height: 34),
              const _FieldLabel('Correo electrónico'),
              AppTextField(
                label: '',
                hint: 'Ingresa tu correo Gmail',
                controller: widget.emailController,
                keyboardType: TextInputType.emailAddress,
                validator: Validators.email,
              ),
              const SizedBox(height: 14),
              const _FieldLabel('Contraseña'),
              AppTextField(
                label: '',
                hint: 'Ingresa tu contraseña',
                controller: widget.passwordController,
                obscureText: _obscurePassword,
                suffixIcon: IconButton(
                  tooltip: _obscurePassword
                      ? 'Mostrar contraseña'
                      : 'Ocultar contraseña',
                  onPressed: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                ),
                validator: Validators.password,
              ),
              const SizedBox(height: 14),
              AppButton(
                label: widget.isLoading ? 'Ingresando...' : 'Continuar',
                icon: Icons.arrow_forward,
                onPressed: widget.isLoading ? null : widget.onLogin,
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, RouteNames.forgotPassword);
                },
                child: const Text(
                  '¿Olvidaste tu contraseña?',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const Divider(color: Colors.white24),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, RouteNames.register);
                },
                child: const Text(
                  'Crear cuenta de cliente',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
