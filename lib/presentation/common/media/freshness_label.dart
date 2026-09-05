import 'package:flutter/material.dart';

import 'package:whatsapp_status_saver/app/theme/app_colors.dart';
import 'package:whatsapp_status_saver/app/theme/app_typography.dart';

/// Communicates the relative freshness of temporary status moments.
///
/// Implements specification from docs/design/keeva-component-spec.md Section 2.11:
/// - Highlights in amber (#F59E0B) when < 2 hours remain before 24h expiration.
class FreshnessLabel extends StatelessWidget {
  final DateTime timestamp;
  final TextStyle? style;

  const FreshnessLabel({super.key, required this.timestamp, this.style});

  /// Formats a timestamp into human-friendly relative freshness string.
  static String formatFreshness(DateTime time, {DateTime? now}) {
    final current = now ?? DateTime.now();
    final difference = current.difference(time);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  /// WhatsApp statuses expire after 24 hours. If > 22h old, < 2h remain.
  bool get isExpiringSoon {
    final age = DateTime.now().difference(timestamp);
    return age.inHours >= 22 && age.inHours < 24;
  }

  @override
  Widget build(BuildContext context) {
    final text = formatFreshness(timestamp);
    final color = isExpiringSoon
        ? AppColors.darkWarning
        : AppColors.darkTextSecondary;

    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: (style ?? AppTypography.bodySmall).copyWith(
        color: color,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
  }
}
