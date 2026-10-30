import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/constants/app_constants.dart';
import '../../core/routes/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/core_providers.dart';
import '../../providers/user_provider.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/gradient_button.dart';

/// Combined login / sign-up form with validation and Google sign-in.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _signUp = false;
  bool _loading = false;
  bool _googleLoading = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  // --- Validators ---
  static final _emailRegex = RegExp(r'^[\w.+\-]+@[\w\-]+\.[\w.\-]+$');

  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email is required';
    if (!_emailRegex.hasMatch(v.trim())) return 'Enter a valid email';
    return null;
  }

  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Password is required';
    if (v.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  String? _validateName(String? v) =>
      (v == null || v.trim().length < 2) ? 'Please enter your name' : null;

  // --- Actions ---
  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final notifier = ref.read(userProvider.notifier);
    try {
      if (_signUp) {
        await notifier.signUp(_name.text.trim(), _email.text.trim(), _password.text);
      } else {
        await notifier.login(_email.text.trim(), _password.text);
      }
      _afterAuth();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _google() async {
    setState(() => _googleLoading = true);
    try {
      await ref.read(userProvider.notifier).signInWithGoogle();
      _afterAuth();
    } finally {
      if (mounted) setState(() => _googleLoading = false);
    }
  }

  /// New users (no connected accounts) go to Connect Accounts; returning users go Home.
  void _afterAuth() {
    if (!mounted) return;
    final user = ref.read(userProvider);
    final hasData = (user?.connectedAccounts.isNotEmpty ?? false) ||
        ref.read(storageProvider).getJsonList(AppConstants.kPosts).isNotEmpty;
    context.go(hasData ? Routes.home : Routes.connect);
  }

  void _forgotPassword() {
    final controller = TextEditingController(text: _email.text);
    final key = GlobalKey<FormState>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        var sending = false;
        return StatefulBuilder(builder: (ctx, setSheet) {
          return Padding(
            padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.viewInsetsOf(ctx).bottom + 24),
            child: Form(
              key: key,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Reset password', style: ctx.text.titleLarge),
                  const SizedBox(height: 6),
                  Text('We\'ll email you a link to reset your password.', style: ctx.text.bodyMedium),
                  const SizedBox(height: 20),
                  CustomTextField(
                    controller: controller,
                    hint: 'you@example.com',
                    icon: LucideIcons.mail,
                    keyboardType: TextInputType.emailAddress,
                    validator: _validateEmail,
                  ),
                  const SizedBox(height: 20),
                  GradientButton(
                    label: 'Send reset link',
                    loading: sending,
                    onPressed: () async {
                      if (!key.currentState!.validate()) return;
                      setSheet(() => sending = true);
                      final messenger = ScaffoldMessenger.of(context);
                      await ref.read(apiServiceProvider).sendPasswordReset(controller.text.trim());
                      if (!ctx.mounted) return;
                      Navigator.pop(ctx);
                      messenger.showSnackBar(
                        const SnackBar(content: Text('Reset link sent! Check your inbox.')),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        });
      },
    ).whenComplete(controller.dispose);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.gutter),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Form(
                key: _formKey,
                child: AutofillGroup(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 12),
                      Center(
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(LucideIcons.sparkles, color: Colors.white, size: 30),
                        ),
                      ).animate().scaleXY(begin: 0.6, end: 1, duration: 500.ms, curve: Curves.easeOutBack),
                      const SizedBox(height: 24),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: Text(
                          _signUp ? 'Create your account' : 'Welcome back 👋',
                          key: ValueKey(_signUp),
                          textAlign: TextAlign.center,
                          style: context.text.headlineMedium,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _signUp ? 'Start growing smarter with CreateIQ' : 'Log in to see how your content is doing',
                        textAlign: TextAlign.center,
                        style: context.text.bodyMedium?.copyWith(color: context.colors.onSurfaceVariant),
                      ),
                      const SizedBox(height: 32),

                      // Name field only shown when signing up.
                      AnimatedSize(
                        duration: const Duration(milliseconds: 250),
                        child: _signUp
                            ? Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: CustomTextField(
                                  controller: _name,
                                  label: 'Full name',
                                  hint: 'Alex Rivera',
                                  icon: LucideIcons.user,
                                  validator: _validateName,
                                  textInputAction: TextInputAction.next,
                                  autofillHints: const [AutofillHints.name],
                                ),
                              )
                            : const SizedBox(width: double.infinity),
                      ),
                      CustomTextField(
                        controller: _email,
                        label: 'Email',
                        hint: 'you@example.com',
                        icon: LucideIcons.mail,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: _validateEmail,
                        autofillHints: const [AutofillHints.email],
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _password,
                        label: 'Password',
                        hint: '••••••••',
                        icon: LucideIcons.lock,
                        obscure: true,
                        textInputAction: TextInputAction.done,
                        validator: _validatePassword,
                        onSubmitted: (_) => _submit(),
                        autofillHints: const [AutofillHints.password],
                      ),
                      if (!_signUp)
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: _forgotPassword,
                            child: const Text('Forgot password?'),
                          ),
                        )
                      else
                        const SizedBox(height: 16),
                      const SizedBox(height: 8),
                      GradientButton(
                        label: _signUp ? 'Sign Up' : 'Log In',
                        loading: _loading,
                        onPressed: _googleLoading ? null : _submit,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          const Expanded(child: Divider()),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text('or continue with', style: context.text.bodySmall),
                          ),
                          const Expanded(child: Divider()),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 56,
                        child: OutlinedButton(
                          onPressed: _loading || _googleLoading ? null : _google,
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                            ),
                            side: BorderSide(color: context.colors.onSurfaceVariant.withValues(alpha: 0.3)),
                          ),
                          child: _googleLoading
                              ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5))
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const _GoogleLogo(),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Continue with Google',
                                      style: TextStyle(fontWeight: FontWeight.w600, color: context.colors.onSurface),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(_signUp ? 'Already have an account?' : 'New to CreateIQ?', style: context.text.bodyMedium),
                          TextButton(
                            onPressed: () => setState(() {
                              _signUp = !_signUp;
                              _formKey.currentState?.reset();
                            }),
                            child: Text(_signUp ? 'Log in' : 'Create account',
                                style: const TextStyle(fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Simple four-colour "G" mark drawn without an image asset.
class _GoogleLogo extends StatelessWidget {
  const _GoogleLogo();

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (r) => const SweepGradient(
        colors: [Color(0xFFEA4335), Color(0xFFFBBC05), Color(0xFF34A853), Color(0xFF4285F4), Color(0xFFEA4335)],
      ).createShader(r),
      child: const Text('G', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
    );
  }
}
