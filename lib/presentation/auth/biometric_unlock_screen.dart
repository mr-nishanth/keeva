import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_icons.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';
import '../../application/auth/auth_state.dart';
import '../../application/providers.dart';
import '../common/brand/keeva_logo.dart';
import '../common/buttons/primary_button.dart';
import '../common/buttons/secondary_button.dart';

/// Shown when a saved session exists and biometric unlock is armed.
///
/// The platform prompt starts once. Cancel, failure, and lockout fall back
/// to the username and password form.
class BiometricUnlockScreen extends ConsumerStatefulWidget {
  const BiometricUnlockScreen({super.key});

  @override
  ConsumerState<BiometricUnlockScreen> createState() =>
      _BiometricUnlockScreenState();
}

class _BiometricUnlockScreenState extends ConsumerState<BiometricUnlockScreen> {
  var _started = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _started) return;
      _started = true;
      ref.read(authNotifierProvider.notifier).unlockWithBiometrics();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final prompting = authState is AuthBiometricLocked && authState.isPrompting;
    final errorMessage = authState.errorMessage;

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.space24,
                vertical: AppSpacing.space32,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(child: KeevaLogo(size: 72)),
                  const SizedBox(height: AppSpacing.space20),
                  Text(
                    'Unlock Keeva',
                    style: AppTypography.displayMedium.copyWith(
                      color: AppColors.darkTextPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.space8),
                  Text(
                    'Confirm your fingerprint or face to open your saved session.',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.darkTextSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (errorMessage != null) ...[
                    const SizedBox(height: AppSpacing.space16),
                    _UnlockMessage(message: errorMessage),
                  ],
                  const SizedBox(height: AppSpacing.space24),
                  PrimaryButton(
                    key: const Key('biometric_unlock'),
                    label: prompting ? 'Waiting for biometrics' : 'Unlock',
                    isFullWidth: true,
                    leadingIcon: AppIcons.fingerprint,
                    onPressed: prompting
                        ? null
                        : () {
                            ref
                                .read(authNotifierProvider.notifier)
                                .unlockWithBiometrics();
                          },
                  ),
                  const SizedBox(height: AppSpacing.space12),
                  SecondaryButton(
                    key: const Key('biometric_use_password'),
                    label: 'Use password',
                    isFullWidth: true,
                    leadingIcon: AppIcons.lock,
                    onPressed: prompting
                        ? null
                        : () {
                            ref
                                .read(authNotifierProvider.notifier)
                                .usePasswordInstead();
                          },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _UnlockMessage extends StatelessWidget {
  final String message;

  const _UnlockMessage({required this.message});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Text(
        message,
        key: const Key('biometric_unlock_message'),
        style: AppTypography.bodySmall.copyWith(
          color: AppColors.darkTextSecondary,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

/// Asks once, after the first password sign-in, whether to arm biometric unlock.
Future<bool> showBiometricSetupDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (context) => const BiometricSetupDialog(),
  ).then((value) => value ?? false);
}

class BiometricSetupDialog extends StatelessWidget {
  const BiometricSetupDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.darkSurfaceLevel2,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      title: Text(
        'Unlock with biometrics?',
        style: AppTypography.titleLarge.copyWith(
          color: AppColors.darkTextPrimary,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Next time, Keeva can open your saved session with this device’s fingerprint or face unlock. Your password is not stored, and you can turn this off in Settings.',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.darkTextSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.space20),
          PrimaryButton(
            key: const Key('biometric_offer_enable'),
            label: 'Enable',
            isFullWidth: true,
            leadingIcon: AppIcons.fingerprint,
            onPressed: () => Navigator.of(context).pop(true),
          ),
          const SizedBox(height: AppSpacing.space8),
          SecondaryButton(
            key: const Key('biometric_offer_dismiss'),
            label: 'Not now',
            isFullWidth: true,
            onPressed: () => Navigator.of(context).pop(false),
          ),
        ],
      ),
    );
  }
}
