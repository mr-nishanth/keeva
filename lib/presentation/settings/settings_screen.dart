import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_icons.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';
import '../../application/access/access_state.dart';
import '../../application/providers.dart';
import '../common/buttons/secondary_button.dart';
import '../common/controls/section_header.dart';
import '../common/sheets/bottom_sheet.dart';
import '../shell/top_bar.dart';

/// Settings & System Integration Screen.
///
/// Implements minimal, high-utility settings specified in Section 23:
/// - Storage Access & SAF connection status.
/// - Folder reconnection.
/// - Privacy & Local-first explanation.
/// - Application version & diagnostics.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accessState = ref.watch(accessNotifierProvider);
    final isGranted = accessState.isGranted;

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: TopBar.contextual(title: 'Settings'),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space16,
          vertical: AppSpacing.space16,
        ),
        children: [
          // 1. STORAGE ACCESS SECTION
          const SectionHeader(
            title: 'Storage & Access',
            subtitle: 'Android Storage Access Framework (SAF) configuration',
          ),
          const SizedBox(height: AppSpacing.space12),

          Container(
            padding: const EdgeInsets.all(AppSpacing.space16),
            decoration: BoxDecoration(
              color: AppColors.darkSurfaceLevel1,
              borderRadius: AppRadius.borderMd,
              border: Border.all(color: AppColors.darkBorderSubtle, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      isGranted ? AppIcons.actionCheck : AppIcons.errorWarning,
                      size: 20,
                      color: isGranted
                          ? AppColors.darkPrimary
                          : AppColors.darkWarning,
                    ),
                    const SizedBox(width: AppSpacing.space12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isGranted
                                ? 'Media Folder Connected'
                                : 'Folder Access Required',
                            style: AppTypography.titleMedium.copyWith(
                              color: AppColors.darkTextPrimary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.space2),
                          Text(
                            isGranted && accessState is AccessGranted
                                ? 'Target: ${accessState.targetPackage}'
                                : 'Select your WhatsApp media folder to discover moments',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.darkTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.space16),
                SecondaryButton(
                  label: isGranted ? 'Reconnect Folder' : 'Connect Folder',
                  leadingIcon: AppIcons.folderOpen,
                  isFullWidth: true,
                  onPressed: () =>
                      ref.read(accessNotifierProvider.notifier).requestAccess(),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.space32),

          // 2. PRIVACY & TRUST SECTION
          const SectionHeader(
            title: 'Privacy & Architecture',
            subtitle: 'On-device security and data guarantees',
          ),
          const SizedBox(height: AppSpacing.space12),

          InkWell(
            onTap: () => KeevaBottomSheet.showTrustDetails(context),
            borderRadius: AppRadius.borderMd,
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.space16),
              decoration: BoxDecoration(
                color: AppColors.darkSurfaceLevel1,
                borderRadius: AppRadius.borderMd,
                border: Border.all(color: AppColors.darkBorderSubtle, width: 1),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: AppColors.darkPrimaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        AppIcons.privacyShield,
                        size: 20,
                        color: AppColors.darkPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.space16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Private & Local-First',
                          style: AppTypography.titleMedium.copyWith(
                            color: AppColors.darkTextPrimary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.space2),
                        Text(
                          '100% On-Device • Zero Network • No Telemetry',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.darkTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    AppIcons.actionInfo,
                    size: 20,
                    color: AppColors.darkTextTertiary,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.space32),

          // 3. ABOUT APPLICATION SECTION
          const SectionHeader(
            title: 'About Keeva',
            subtitle: 'Application details and build information',
          ),
          const SizedBox(height: AppSpacing.space12),

          Container(
            padding: const EdgeInsets.all(AppSpacing.space16),
            decoration: BoxDecoration(
              color: AppColors.darkSurfaceLevel1,
              borderRadius: AppRadius.borderMd,
              border: Border.all(color: AppColors.darkBorderSubtle, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Version',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.darkTextPrimary,
                      ),
                    ),
                    Text(
                      '1.0.0 (Production Release)',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.darkTextSecondary,
                      ),
                    ),
                  ],
                ),
                const Divider(
                  color: AppColors.darkBorderSubtle,
                  height: AppSpacing.space24,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Target Platform',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.darkTextPrimary,
                      ),
                    ),
                    Text(
                      'Android (SAF Storage API 30+)',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.darkTextSecondary,
                      ),
                    ),
                  ],
                ),
                const Divider(
                  color: AppColors.darkBorderSubtle,
                  height: AppSpacing.space24,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Saved Media Album',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.darkTextPrimary,
                      ),
                    ),
                    Text(
                      'Pictures/SavedStatus',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.darkTextSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
