import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_icons.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';
import '../../application/providers.dart';
import '../common/brand/keeva_logo.dart';
import '../common/buttons/primary_button.dart';
import '../common/buttons/secondary_button.dart';

/// Shown while the saved on-device session is being read.
class AuthRestoringView extends StatelessWidget {
  const AuthRestoringView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              KeevaLogo(size: 72),
              SizedBox(height: AppSpacing.space20),
              SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.darkPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Local sign-in screen shown before onboarding and the main shell.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _passwordFocusNode = FocusNode();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    await ref
        .read(authNotifierProvider.notifier)
        .signIn(
          username: _usernameController.text,
          password: _passwordController.text,
        );
  }

  void _onFieldChanged(String _) {
    ref.read(authNotifierProvider.notifier).clearError();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isSubmitting = authState.isSubmitting;
    final errorMessage = authState.errorMessage;
    final canRetryBiometric = authState.canRetryBiometric;

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.space24,
                vertical: AppSpacing.space32,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(child: KeevaLogo(size: 72)),
                  const SizedBox(height: AppSpacing.space20),
                  Text(
                    'Sign in to Keeva',
                    style: AppTypography.displayMedium.copyWith(
                      color: AppColors.darkTextPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.space8),
                  Text(
                    'Your moments stay on this device. Sign in to continue.',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.darkTextSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.space32),
                  TextField(
                    key: const Key('login_username'),
                    controller: _usernameController,
                    enabled: !isSubmitting,
                    autofillHints: const [AutofillHints.username],
                    textInputAction: TextInputAction.next,
                    autocorrect: false,
                    enableSuggestions: false,
                    keyboardType: TextInputType.text,
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.darkTextPrimary,
                    ),
                    cursorColor: AppColors.darkPrimary,
                    onChanged: _onFieldChanged,
                    onSubmitted: (_) => _passwordFocusNode.requestFocus(),
                    decoration: _fieldDecoration(
                      label: 'Username',
                      icon: AppIcons.person,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space16),
                  TextField(
                    key: const Key('login_password'),
                    controller: _passwordController,
                    focusNode: _passwordFocusNode,
                    enabled: !isSubmitting,
                    autofillHints: const [AutofillHints.password],
                    textInputAction: TextInputAction.done,
                    obscureText: _obscurePassword,
                    autocorrect: false,
                    enableSuggestions: false,
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.darkTextPrimary,
                    ),
                    cursorColor: AppColors.darkPrimary,
                    onChanged: _onFieldChanged,
                    onSubmitted: (_) {
                      _submit();
                    },
                    decoration: _fieldDecoration(
                      label: 'Password',
                      icon: AppIcons.lock,
                      suffix: IconButton(
                        tooltip: _obscurePassword
                            ? 'Show password'
                            : 'Hide password',
                        onPressed: isSubmitting
                            ? null
                            : () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                        icon: Icon(
                          _obscurePassword
                              ? AppIcons.visibility
                              : AppIcons.visibilityOff,
                          color: AppColors.darkTextSecondary,
                        ),
                      ),
                    ),
                  ),
                  if (errorMessage != null) ...[
                    const SizedBox(height: AppSpacing.space16),
                    _LoginErrorBanner(message: errorMessage),
                  ],
                  if (canRetryBiometric) ...[
                    const SizedBox(height: AppSpacing.space24),
                    SecondaryButton(
                      key: const Key('login_biometric_retry'),
                      label: 'Unlock with biometrics',
                      isFullWidth: true,
                      leadingIcon: AppIcons.fingerprint,
                      onPressed: isSubmitting
                          ? null
                          : () {
                              ref
                                  .read(authNotifierProvider.notifier)
                                  .unlockWithBiometrics();
                            },
                    ),
                  ],
                  const SizedBox(height: AppSpacing.space24),
                  PrimaryButton(
                    key: const Key('login_submit'),
                    label: 'Sign in',
                    isFullWidth: true,
                    isLoading: isSubmitting,
                    leadingIcon: AppIcons.lock,
                    onPressed: isSubmitting ? null : () => _submit(),
                  ),
                  const SizedBox(height: AppSpacing.space16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        AppIcons.privacyShield,
                        size: 16,
                        color: AppColors.darkTextTertiary,
                      ),
                      const SizedBox(width: AppSpacing.space8),
                      Flexible(
                        child: Text(
                          'Sign-in is stored only on this device.',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.darkTextTertiary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration({
    required String label,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: AppTypography.bodyMedium.copyWith(
        color: AppColors.darkTextSecondary,
      ),
      prefixIcon: Icon(icon, color: AppColors.darkTextSecondary),
      suffixIcon: suffix,
      filled: true,
      fillColor: AppColors.darkSurfaceLevel1,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space16,
        vertical: AppSpacing.space16,
      ),
      enabledBorder: const OutlineInputBorder(
        borderRadius: AppRadius.borderMd,
        borderSide: BorderSide(color: AppColors.darkBorderSubtle),
      ),
      disabledBorder: const OutlineInputBorder(
        borderRadius: AppRadius.borderMd,
        borderSide: BorderSide(color: AppColors.darkBorderSubtle),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: AppRadius.borderMd,
        borderSide: BorderSide(color: AppColors.darkPrimary, width: 1.5),
      ),
      errorBorder: const OutlineInputBorder(
        borderRadius: AppRadius.borderMd,
        borderSide: BorderSide(color: AppColors.darkError),
      ),
    );
  }
}

class _LoginErrorBanner extends StatelessWidget {
  final String message;

  const _LoginErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Container(
        key: const Key('login_error'),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space16,
          vertical: AppSpacing.space12,
        ),
        decoration: BoxDecoration(
          color: AppColors.darkError.withValues(alpha: 0.1),
          borderRadius: AppRadius.borderMd,
          border: Border.all(color: AppColors.darkError.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(
              AppIcons.errorCircle,
              size: 20,
              color: AppColors.darkError,
            ),
            const SizedBox(width: AppSpacing.space12),
            Expanded(
              child: Text(
                message,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.darkError,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
