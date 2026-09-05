import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_icons.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';
import '../../application/access/access_state.dart';
import '../../application/providers.dart';
import '../common/brand/keeva_logo.dart';
import '../common/buttons/primary_button.dart';
import '../common/onboarding/permission_guide.dart';
import '../common/sheets/bottom_sheet.dart';

/// Screen A: Polished First-Launch & SAF Onboarding Screen.
///
/// Implements specification from Phase 2H Brand Identity & Launch Experience:
/// - Real Keeva logo mark with ambient Aurora glow.
/// - Calm, trustworthy copy emphasizing privacy and local-first storage.
/// - 3-step structured guidance for Android SAF folder selection.
/// - Inline loading indicator during system DocumentsUI picker interaction.
/// - Error and recovery feedback banners.
class PermissionOnboardingScreen extends ConsumerWidget {
  final VoidCallback? onAccessGranted;

  const PermissionOnboardingScreen({super.key, this.onAccessGranted});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accessState = ref.watch(accessNotifierProvider);

    ref.listen<AccessState>(accessNotifierProvider, (previous, next) {
      if (next.isGranted) {
        onAccessGranted?.call();
      }
    });

    final isLoading = accessState.isRequesting || accessState.isChecking;

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 540),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.space24,
                vertical: AppSpacing.space24,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Signature Keeva Vector Logo Mark with Aurora Glow
                  const KeevaLogo(size: 80),
                  const SizedBox(height: AppSpacing.space20),

                  // Display Headline
                  Text(
                    'Welcome to Keeva',
                    style: AppTypography.displayMedium.copyWith(
                      color: AppColors.darkTextPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.space8),

                  // Subhead
                  Text(
                    'Your private place for the moments you want to keep.',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.darkTextSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.space24),

                  // Contextual feedback banner for invalid / revoked / failure states
                  if (accessState is AccessInvalid ||
                      accessState is AccessRevoked ||
                      accessState is AccessUnavailable ||
                      accessState is AccessFailure) ...[
                    _buildFeedbackBanner(context, accessState),
                    const SizedBox(height: AppSpacing.space16),
                  ],

                  // 3-step structured guidance
                  const PermissionGuide(),
                  const SizedBox(height: AppSpacing.space24),

                  // Primary Connect CTA
                  PrimaryButton(
                    label: 'Connect Media Folder',
                    leadingIcon: AppIcons.folder,
                    isLoading: isLoading,
                    onPressed: isLoading
                        ? null
                        : () => ref
                              .read(accessNotifierProvider.notifier)
                              .requestAccess(),
                  ),
                  const SizedBox(height: AppSpacing.space16),

                  // Secondary action: Trust & privacy sheet
                  TextButton(
                    onPressed: () => KeevaBottomSheet.showTrustDetails(context),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.darkTextTertiary,
                      minimumSize: const Size(48, 48),
                    ),
                    child: Text(
                      'Learn how Keeva protects you',
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.darkTextTertiary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeedbackBanner(BuildContext context, AccessState state) {
    final String message;
    final IconData icon;
    final Color color;

    switch (state) {
      case AccessInvalid(:final reason):
        message = reason ?? 'Please select the WhatsApp media folder so Keeva can discover moments.';
        icon = AppIcons.errorWarning;
        color = AppColors.darkWarning;
      case AccessRevoked(:final reason):
        message = reason ?? 'Folder access was revoked. Please reconnect your WhatsApp media folder.';
        icon = AppIcons.errorWarning;
        color = AppColors.darkWarning;
      case AccessUnavailable(:final reason):
        message =
            reason ?? 'WhatsApp status folder was not found on this device.';
        icon = AppIcons.errorWarning;
        color = AppColors.darkWarning;
      case AccessFailure(:final failure):
        message = failure.message.isNotEmpty
            ? failure.message
            : 'Unable to connect folder. Tap below to try again.';
        icon = AppIcons.errorCircle;
        color = AppColors.darkError;
      default:
        return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space16,
        vertical: AppSpacing.space12,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: AppRadius.borderMd,
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: AppSpacing.space12),
          Expanded(
            child: Text(
              message,
              style: AppTypography.bodySmall.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}
