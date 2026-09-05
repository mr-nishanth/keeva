import 'package:flutter/material.dart';

import 'package:whatsapp_status_saver/app/theme/app_colors.dart';
import 'package:whatsapp_status_saver/app/theme/app_icons.dart';
import 'package:whatsapp_status_saver/app/theme/app_spacing.dart';
import 'package:whatsapp_status_saver/app/theme/app_typography.dart';

import '../../../core/errors/app_failure.dart';
import '../buttons/primary_button.dart';
import '../buttons/secondary_button.dart';

/// Calm, human-friendly error and recovery component.
///
/// Implements specification from docs/design/keeva-ui-spec.md Screen G:
/// - Never exposes raw technical exceptions or stack traces.
class ErrorState extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;
  final String retryLabel;
  final VoidCallback? onSecondaryAction;
  final String? secondaryActionLabel;

  const ErrorState({
    super.key,
    this.title = 'Something interrupted this action',
    this.message = 'Please check your connection and storage, then try again.',
    this.onRetry,
    this.retryLabel = 'Try Again',
    this.onSecondaryAction,
    this.secondaryActionLabel,
  });

  /// Convenience factory creating an ErrorState from an [AppFailure].
  factory ErrorState.fromFailure({
    Key? key,
    required AppFailure failure,
    VoidCallback? onRetry,
    String retryLabel = 'Try Again',
  }) {
    return ErrorState(
      key: key,
      title: 'Unable to complete action',
      message: failure.message,
      onRetry: onRetry,
      retryLabel: retryLabel,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: Color(0x33F59E0B), // Soft amber translucent
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  AppIcons.errorWarning,
                  size: 32,
                  color: AppColors.darkWarning,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.space20),
            Text(
              title,
              style: AppTypography.titleLarge.copyWith(
                color: AppColors.darkTextPrimary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.space8),
            Text(
              message,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.darkTextSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.space24),
            if (onRetry != null)
              PrimaryButton(
                label: retryLabel,
                onPressed: onRetry,
                isFullWidth: false,
              ),
            if (onSecondaryAction != null && secondaryActionLabel != null) ...[
              const SizedBox(height: AppSpacing.space12),
              SecondaryButton(
                label: secondaryActionLabel!,
                onPressed: onSecondaryAction,
                variant: SecondaryButtonVariant.ghost,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
