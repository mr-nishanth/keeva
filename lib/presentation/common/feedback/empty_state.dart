import 'package:flutter/material.dart';

import 'package:whatsapp_status_saver/app/theme/app_colors.dart';
import 'package:whatsapp_status_saver/app/theme/app_icons.dart';
import 'package:whatsapp_status_saver/app/theme/app_spacing.dart';
import 'package:whatsapp_status_saver/app/theme/app_typography.dart';

import '../buttons/primary_button.dart';

enum EmptyScenario {
  noAccess,
  noStatuses,
  filterEmpty,
  vaultEmpty,
  folderMoved,
  permissionRevoked,
  momentExpired,
}

/// Comprehensive empty states for Keeva.
///
/// Implements the 7 scenarios from docs/design/keeva-ui-spec.md Screen F.
class EmptyState extends StatelessWidget {
  final EmptyScenario scenario;
  final VoidCallback? onAction;
  final String? customTitle;
  final String? customSubtitle;
  final String? customActionLabel;

  const EmptyState({
    super.key,
    required this.scenario,
    this.onAction,
    this.customTitle,
    this.customSubtitle,
    this.customActionLabel,
  });

  (IconData icon, String title, String subtitle, String actionLabel)
  _scenarioConfig() {
    return switch (scenario) {
      EmptyScenario.noAccess => (
        AppIcons.privacyShield,
        'Connect your moments',
        'Select your WhatsApp media folder to discover statuses before they expire.',
        'Connect Media Folder',
      ),
      EmptyScenario.noStatuses => (
        AppIcons.navMoments,
        'No moments right now',
        'Statuses appear here after you view them in WhatsApp. Go view a few statuses and return.',
        'Refresh',
      ),
      EmptyScenario.filterEmpty => (
        AppIcons.actionSearch,
        'No matching moments',
        'No moments match the active filter. Switch filters to view all available statuses.',
        'Show All Moments',
      ),
      EmptyScenario.vaultEmpty => (
        AppIcons.navKept,
        'Your vault is empty',
        'Keep your favorite moments before they vanish in 24 hours. Tapping Keep saves them forever.',
        'Explore Moments',
      ),
      EmptyScenario.folderMoved => (
        AppIcons.folderOpen,
        'Media folder unavailable',
        'Android could not reach the connected folder. WhatsApp may have updated its storage location.',
        'Reconnect Folder',
      ),
      EmptyScenario.permissionRevoked => (
        AppIcons.errorWarning,
        'Access needs renewal',
        'Android permissions were reset or revoked. Reconnect your folder in one tap.',
        'Renew Access',
      ),
      EmptyScenario.momentExpired => (
        AppIcons.errorCircle,
        'Moment expired',
        'This moment was removed or expired before it could be saved.',
        'Return to Moments',
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final (defaultIcon, defaultTitle, defaultSubtitle, defaultActionLabel) =
        _scenarioConfig();

    final title = customTitle ?? defaultTitle;
    final subtitle = customSubtitle ?? defaultSubtitle;
    final actionLabel = customActionLabel ?? defaultActionLabel;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon container with soft mint/slate aura
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.darkSurfaceLevel1,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.darkBorderSubtle, width: 1),
              ),
              child: Center(
                child: Icon(
                  defaultIcon,
                  size: 36,
                  color: AppColors.darkPrimary,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.space24),
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
              subtitle,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.darkTextSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (onAction != null) ...[
              const SizedBox(height: AppSpacing.space24),
              PrimaryButton(
                label: actionLabel,
                onPressed: onAction,
                isFullWidth: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
