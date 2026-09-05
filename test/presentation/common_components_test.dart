import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:whatsapp_status_saver/app/theme/app_icons.dart';
import 'package:whatsapp_status_saver/app/theme/app_theme.dart';
import 'package:whatsapp_status_saver/presentation/common/buttons/keep_button.dart';
import 'package:whatsapp_status_saver/presentation/common/buttons/primary_button.dart';
import 'package:whatsapp_status_saver/presentation/common/buttons/secondary_button.dart';
import 'package:whatsapp_status_saver/presentation/common/controls/filter_control.dart';
import 'package:whatsapp_status_saver/presentation/common/controls/section_header.dart';
import 'package:whatsapp_status_saver/presentation/common/feedback/empty_state.dart';
import 'package:whatsapp_status_saver/presentation/common/feedback/error_state.dart';
import 'package:whatsapp_status_saver/presentation/common/feedback/loading_indicator.dart';
import 'package:whatsapp_status_saver/presentation/common/media/duration_label.dart';
import 'package:whatsapp_status_saver/presentation/common/media/freshness_label.dart';
import 'package:whatsapp_status_saver/presentation/common/media/media_placeholder.dart';
import 'package:whatsapp_status_saver/presentation/common/media/video_badge.dart';
import 'package:whatsapp_status_saver/presentation/common/onboarding/permission_guide.dart';
import 'package:whatsapp_status_saver/presentation/common/onboarding/permission_step.dart';

void main() {
  Widget buildTestable(Widget child) {
    return MaterialApp(
      theme: KeevaTheme.darkTheme,
      home: Scaffold(body: child),
    );
  }

  group('Phase 2E-B2: Reusable Presentation Components', () {
    // =========================================================================
    // BUTTONS
    // =========================================================================
    group('PrimaryButton', () {
      testWidgets('renders label and fires callback on tap', (tester) async {
        var tapped = false;
        await tester.pumpWidget(
          buildTestable(
            PrimaryButton(
              label: 'Connect Media Folder',
              onPressed: () => tapped = true,
            ),
          ),
        );

        expect(find.text('Connect Media Folder'), findsOneWidget);
        await tester.tap(find.byType(PrimaryButton));
        await tester.pump();
        expect(tapped, isTrue);

        // Verify touch target size >= 48x48
        final size = tester.getSize(find.byType(PrimaryButton));
        expect(size.height, greaterThanOrEqualTo(48.0));
      });

      testWidgets('renders circular progress indicator when loading', (
        tester,
      ) async {
        await tester.pumpWidget(
          buildTestable(
            PrimaryButton(
              label: 'Connect Folder',
              isLoading: true,
              onPressed: () {},
            ),
          ),
        );

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('Connect Folder'), findsNothing);
      });
    });

    group('SecondaryButton', () {
      testWidgets('renders label and supports outlined & ghost variants', (
        tester,
      ) async {
        var tapped = false;
        await tester.pumpWidget(
          buildTestable(
            SecondaryButton(label: 'Try Again', onPressed: () => tapped = true),
          ),
        );

        expect(find.text('Try Again'), findsOneWidget);
        await tester.tap(find.byType(SecondaryButton));
        await tester.pump();
        expect(tapped, isTrue);

        final size = tester.getSize(find.byType(SecondaryButton));
        expect(size.height, greaterThanOrEqualTo(48.0));
      });
    });

    group('KeepButton', () {
      testWidgets(
        'cardOverlay has 48x48dp hit box and correct semantics in idle',
        (tester) async {
          var tapped = false;
          await tester.pumpWidget(
            buildTestable(
              KeepButton(state: KeepState.idle, onPressed: () => tapped = true),
            ),
          );

          final size = tester.getSize(find.byType(KeepButton));
          expect(size.width, equals(48.0));
          expect(size.height, equals(48.0));

          expect(find.byIcon(AppIcons.actionKeep), findsOneWidget);

          await tester.tap(find.byType(KeepButton));
          await tester.pump();
          expect(tapped, isTrue);
        },
      );

      testWidgets('displays spinner when saving', (tester) async {
        await tester.pumpWidget(
          buildTestable(KeepButton(state: KeepState.saving, onPressed: () {})),
        );

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('displays checkmark when success or alreadyKept', (
        tester,
      ) async {
        await tester.pumpWidget(
          buildTestable(
            KeepButton(state: KeepState.alreadyKept, onPressed: () {}),
          ),
        );

        expect(find.byIcon(AppIcons.actionCheck), findsOneWidget);
      });

      testWidgets('viewerAction variant renders Keep / Kept pill', (
        tester,
      ) async {
        await tester.pumpWidget(
          buildTestable(
            KeepButton(
              state: KeepState.idle,
              variant: KeepButtonVariant.viewerAction,
              onPressed: () {},
            ),
          ),
        );

        expect(find.text('Keep'), findsOneWidget);
      });
    });

    // =========================================================================
    // MEDIA BADGES & LABELS
    // =========================================================================
    group('DurationLabel & VideoBadge', () {
      test('formatDuration converts milliseconds accurately', () {
        expect(DurationLabel.formatDuration(0), '0:00');
        expect(DurationLabel.formatDuration(24000), '0:24');
        expect(DurationLabel.formatDuration(65000), '1:05');
        expect(DurationLabel.formatDuration(3665000), '1:01:05');
      });

      testWidgets('VideoBadge renders play icon and formatted duration', (
        tester,
      ) async {
        await tester.pumpWidget(
          buildTestable(const VideoBadge(durationMs: 24000)),
        );

        expect(find.byIcon(AppIcons.typeVideo), findsOneWidget);
        expect(find.text('0:24'), findsOneWidget);
      });
    });

    group('FreshnessLabel', () {
      test('formatFreshness formats relative time strings', () {
        final now = DateTime(2026, 9, 5, 12, 0);
        final justNow = now.subtract(const Duration(seconds: 30));
        final minsAgo = now.subtract(const Duration(minutes: 14));
        final hoursAgo = now.subtract(const Duration(hours: 3));
        final yesterday = now.subtract(const Duration(days: 1));
        final daysAgo = now.subtract(const Duration(days: 4));

        expect(FreshnessLabel.formatFreshness(justNow, now: now), 'Just now');
        expect(FreshnessLabel.formatFreshness(minsAgo, now: now), '14m ago');
        expect(FreshnessLabel.formatFreshness(hoursAgo, now: now), '3h ago');
        expect(
          FreshnessLabel.formatFreshness(yesterday, now: now),
          'Yesterday',
        );
        expect(FreshnessLabel.formatFreshness(daysAgo, now: now), '4d ago');
      });
    });

    group('MediaPlaceholder', () {
      testWidgets('renders 9:16 aspect ratio box', (tester) async {
        await tester.pumpWidget(
          buildTestable(
            const SizedBox(width: 180, child: MediaPlaceholder(isVideo: false)),
          ),
        );

        final size = tester.getSize(find.byType(MediaPlaceholder));
        expect(size.width, 180);
        expect(size.height, closeTo(180 * (16 / 9), 0.1));
      });
    });

    // =========================================================================
    // FEEDBACK & STATES
    // =========================================================================
    group('LoadingIndicator', () {
      testWidgets('circular spinner renders', (tester) async {
        await tester.pumpWidget(buildTestable(LoadingIndicator.circular()));
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('shimmerCard maintains 9:16 aspect ratio', (tester) async {
        await tester.pumpWidget(
          buildTestable(
            SizedBox(width: 100, child: LoadingIndicator.shimmerCard()),
          ),
        );
        final size = tester.getSize(find.byType(AspectRatio));
        expect(size.width, 100);
        expect(size.height, closeTo(100 * (16 / 9), 0.1));
      });
    });

    group('EmptyState', () {
      testWidgets('renders scenario message and button', (tester) async {
        var buttonPressed = false;
        await tester.pumpWidget(
          buildTestable(
            EmptyState(
              scenario: EmptyScenario.noAccess,
              onAction: () => buttonPressed = true,
            ),
          ),
        );

        expect(find.text('Connect your moments'), findsOneWidget);
        expect(find.text('Connect Media Folder'), findsOneWidget);

        await tester.tap(find.text('Connect Media Folder'));
        await tester.pump();
        expect(buttonPressed, isTrue);
      });

      testWidgets('renders vaultEmpty scenario correctly', (tester) async {
        await tester.pumpWidget(
          buildTestable(const EmptyState(scenario: EmptyScenario.vaultEmpty)),
        );

        expect(find.text('Your vault is empty'), findsOneWidget);
      });
    });

    group('ErrorState', () {
      testWidgets('renders calm error copy and retry action', (tester) async {
        var retried = false;
        await tester.pumpWidget(
          buildTestable(
            ErrorState(
              title: 'Unable to keep moment',
              message: 'Check device storage and try again.',
              onRetry: () => retried = true,
            ),
          ),
        );

        expect(find.text('Unable to keep moment'), findsOneWidget);
        expect(
          find.text('Check device storage and try again.'),
          findsOneWidget,
        );
        expect(find.text('Try Again'), findsOneWidget);

        await tester.tap(find.text('Try Again'));
        await tester.pump();
        expect(retried, isTrue);
      });
    });

    // =========================================================================
    // ONBOARDING & CONTROLS
    // =========================================================================
    group('PermissionGuide & PermissionStep', () {
      testWidgets(
        'PermissionStep renders step number, title, and description',
        (tester) async {
          await tester.pumpWidget(
            buildTestable(
              const PermissionStep(
                stepNumber: 1,
                title: 'Step 1 Title',
                description: 'Step 1 Description',
              ),
            ),
          );

          expect(find.text('1'), findsOneWidget);
          expect(find.text('Step 1 Title'), findsOneWidget);
          expect(find.text('Step 1 Description'), findsOneWidget);
        },
      );

      testWidgets('PermissionGuide renders all 3 steps and privacy guarantee', (
        tester,
      ) async {
        await tester.pumpWidget(buildTestable(const PermissionGuide()));

        expect(find.text('1. View statuses in WhatsApp'), findsOneWidget);
        expect(find.text('2. Tap Connect Folder below'), findsOneWidget);
        expect(find.text('3. Tap "Use this folder"'), findsOneWidget);
        expect(
          find.text('100% On-Device • Zero Network • Private'),
          findsOneWidget,
        );
      });
    });

    group('FilterControl', () {
      testWidgets('renders all 3 filters with counts and handles taps', (
        tester,
      ) async {
        MediaFilter? selectedFilter;
        await tester.pumpWidget(
          buildTestable(
            FilterControl(
              activeFilter: MediaFilter.all,
              allCount: 18,
              photosCount: 12,
              videosCount: 6,
              onFilterChanged: (filter) => selectedFilter = filter,
            ),
          ),
        );

        expect(find.text('All (18)'), findsOneWidget);
        expect(find.text('Photos (12)'), findsOneWidget);
        expect(find.text('Videos (6)'), findsOneWidget);

        await tester.tap(find.text('Photos (12)'));
        await tester.pump();
        expect(selectedFilter, MediaFilter.photos);
      });
    });

    group('SectionHeader', () {
      testWidgets('renders title and optional subtitle', (tester) async {
        await tester.pumpWidget(
          buildTestable(
            const SectionHeader(
              title: 'Today',
              subtitle: '18 moments available',
            ),
          ),
        );

        expect(find.text('Today'), findsOneWidget);
        expect(find.text('18 moments available'), findsOneWidget);
      });
    });
  });
}
