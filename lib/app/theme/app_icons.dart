import 'package:flutter/material.dart';

/// Semantic iconography tokens for Keeva using Material Symbols / Icons Rounded.
///
/// Implements canonical semantic icon map from docs/design/keeva-design-system.md Section 8.
abstract final class AppIcons {
  // Primary Navigation
  static const IconData navMoments = Icons.auto_awesome_motion_rounded;
  static const IconData navKept = Icons.bookmark_rounded;
  static const IconData navSettings = Icons.tune_rounded;

  // Actions
  static const IconData actionKeep = Icons.bookmark_add_rounded;
  static const IconData actionKept = Icons.bookmark_added_rounded;
  static const IconData actionCheck = Icons.check_circle_rounded;
  static const IconData actionShare = Icons.share_rounded;
  static const IconData actionInfo = Icons.info_outline_rounded;
  static const IconData actionBack = Icons.arrow_back_rounded;
  static const IconData actionClose = Icons.close_rounded;
  static const IconData actionRefresh = Icons.refresh_rounded;
  static const IconData actionSearch = Icons.search_rounded;
  static const IconData actionMore = Icons.more_vert_rounded;

  // Media Types
  static const IconData typeVideo = Icons.play_arrow_rounded;
  static const IconData typeImage = Icons.image_rounded;

  // Trust, Privacy & Folders
  static const IconData privacyShield = Icons.verified_user_rounded;
  static const IconData lock = Icons.lock_outline_rounded;
  static const IconData folder = Icons.folder_rounded;
  static const IconData folderOpen = Icons.folder_open_rounded;

  // Status & Selection
  static const IconData selectionUnchecked =
      Icons.radio_button_unchecked_rounded;
  static const IconData selectionChecked = Icons.check_circle_rounded;
  static const IconData errorWarning = Icons.warning_amber_rounded;
  static const IconData errorCircle = Icons.error_outline_rounded;
}
