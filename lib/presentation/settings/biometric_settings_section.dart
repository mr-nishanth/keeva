import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_icons.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';
import '../../application/auth/auth_copy.dart';
import '../../application/providers.dart';
import '../common/buttons/primary_button.dart';
import '../common/buttons/secondary_button.dart';
import '../common/controls/section_header.dart';

/// Settings controls for biometric unlock and sign-out.
class BiometricSettingsSection extends ConsumerWidget {
  const BiometricSettingsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(biometricSettingsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Sign-in',
          subtitle: 'Biometric unlock stays on this device',
        ),
        const SizedBox(height: AppSpacing.space12),
        Container(
          padding: const EdgeInsets.all(AppSpacing.space16),
          decoration: BoxDecoration(
            color: AppColors.darkSurfaceLevel1,
            borderRadius: AppRadius.borderMd,
            border: Border.all(color: AppColors.darkBorderSubtle, width: 1),
          ),
          child: settings.when(
            loading: () => Text(
              'Checking biometric unlock…',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.darkTextSecondary,
              ),
            ),
            error: (_, _) => Text(
              BiometricSettingsFallback.unavailable,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.darkTextSecondary,
              ),
            ),
            data: (value) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        AppIcons.fingerprint,
                        size: 20,
                        color: AppColors.darkPrimary,
                      ),
                      const SizedBox(width: AppSpacing.space12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Biometric unlock',
                              style: AppTypography.titleMedium.copyWith(
                                color: AppColors.darkTextPrimary,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.space2),
                            Text(
                              value.detail,
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.darkTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        key: const Key('settings_biometric_switch'),
                        value: value.enabled,
                        activeThumbColor: AppColors.darkOnPrimary,
                        activeTrackColor: AppColors.darkPrimary,
                        onChanged:
                            value.busy || (!value.available && !value.enabled)
                            ? null
                            : (next) {
                                ref
                                    .read(biometricSettingsProvider.notifier)
                                    .setEnabled(next);
                              },
                      ),
                    ],
                  ),
                  if (value.errorMessage != null) ...[
                    const SizedBox(height: AppSpacing.space12),
                    Text(
                      value.errorMessage!,
                      key: const Key('settings_biometric_error'),
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.darkError,
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.space12),
        SecondaryButton(
          key: const Key('settings_sign_out'),
          label: 'Sign out',
          leadingIcon: AppIcons.logout,
          isFullWidth: true,
          onPressed: () => _confirmSignOut(context, ref),
        ),
      ],
    );
  }

  Future<void> _confirmSignOut(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.darkSurfaceLevel2,
          title: Text(
            'Sign out?',
            style: AppTypography.titleLarge.copyWith(
              color: AppColors.darkTextPrimary,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Keeva will forget this sign-in and biometric unlock on this device. You will need your password next time.',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.darkTextSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.space20),
              PrimaryButton(
                key: const Key('settings_sign_out_confirm'),
                label: 'Sign out',
                isFullWidth: true,
                leadingIcon: AppIcons.logout,
                onPressed: () => Navigator.of(context).pop(true),
              ),
              const SizedBox(height: AppSpacing.space8),
              SecondaryButton(
                label: 'Cancel',
                isFullWidth: true,
                onPressed: () => Navigator.of(context).pop(false),
              ),
            ],
          ),
        );
      },
    );
    if (confirmed != true || !context.mounted) return;
    final signedOut = await ref.read(authNotifierProvider.notifier).signOut();
    if (!signedOut && context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(AuthCopy.signOutFailed)));
    }
  }
}

/// Copy used when biometric settings cannot be read.
abstract final class BiometricSettingsFallback {
  static const unavailable =
      'Biometric unlock is unavailable on this device. Password sign-in still works.';
}
