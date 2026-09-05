import 'package:flutter/material.dart';

import 'package:whatsapp_status_saver/app/theme/app_typography.dart';

/// Formats duration in milliseconds into jitter-free tabular time strings.
///
/// Implements specification from docs/design/keeva-component-spec.md Section 2.10.
class DurationLabel extends StatelessWidget {
  final int durationMs;
  final TextStyle? style;

  const DurationLabel({super.key, required this.durationMs, this.style});

  /// Formats milliseconds into standard m:ss or h:mm:ss format.
  static String formatDuration(int ms) {
    if (ms <= 0) return '0:00';
    final duration = Duration(milliseconds: ms);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    final secondsStr = seconds.toString().padLeft(2, '0');

    if (hours > 0) {
      final minutesStr = minutes.toString().padLeft(2, '0');
      return '$hours:$minutesStr:$secondsStr';
    }
    return '$minutes:$secondsStr';
  }

  @override
  Widget build(BuildContext context) {
    final text = formatDuration(durationMs);
    return Text(
      text,
      style: (style ?? AppTypography.numericTabular).copyWith(
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
  }
}
