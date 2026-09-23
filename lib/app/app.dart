import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/access/access_state.dart';
import '../application/auth/auth_state.dart';
import '../application/providers.dart';
import '../domain/entities/status_item.dart';
import '../presentation/auth/login_screen.dart';
import '../presentation/kept/kept_vault_screen.dart';
import '../presentation/moments/moments_screen.dart';
import '../presentation/onboarding/permission_onboarding_screen.dart';
import '../presentation/settings/settings_screen.dart';
import '../presentation/shell/adaptive_navigation.dart';
import '../presentation/shell/app_shell.dart';
import '../presentation/viewer/media_viewer_screen.dart';
import 'theme/app_theme.dart';

/// Top-level application widget for Keeva.
///
/// Implements the complete production application flow:
/// - Restores the local sign-in session and shows [LoginScreen] until it is valid.
/// - Verifies SAF access on startup via [accessNotifierProvider] after sign-in.
/// - Displays 3-step [PermissionOnboardingScreen] if access has not been granted.
/// - Transitions to [AppShell] hosting Moments, Kept Vault, and Settings once granted.
/// - Manages full-screen [MediaViewerScreen] transitions with 300ms smooth transition.
class KeevaApp extends ConsumerStatefulWidget {
  const KeevaApp({super.key});

  @override
  ConsumerState<KeevaApp> createState() => _KeevaAppState();
}

class _KeevaAppState extends ConsumerState<KeevaApp> {
  NavDestination _activeDestination = NavDestination.moments;
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final authState = ref.read(authNotifierProvider);
      if (authState is AuthRestoring) {
        ref.read(authNotifierProvider.notifier).restore();
      } else if (authState.isAuthenticated) {
        ref.read(accessNotifierProvider.notifier).checkAccess();
      }
    });
  }

  void _openViewer(StatusItem item) {
    _navigatorKey.currentState?.push(
      PageRouteBuilder(
        opaque: false,
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 250),
        pageBuilder: (context, animation, secondaryAnimation) {
          return FadeTransition(
            opacity: animation,
            child: MediaViewerScreen(
              item: item,
              onShare: (mediaItem) async {
                final useCase = ref.read(shareStatusUseCaseProvider);
                await useCase(
                  id: mediaItem.id,
                  displayName: mediaItem.displayName,
                  mimeType: mediaItem.mimeType,
                  isVideo: mediaItem.isVideo,
                );
              },
              onNavigateToKept: () {
                setState(() => _activeDestination = NavDestination.kept);
              },
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final accessState = ref.watch(accessNotifierProvider);

    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (next.isAuthenticated && previous is! AuthAuthenticated) {
        ref.read(accessNotifierProvider.notifier).checkAccess();
      }
    });

    ref.listen<AccessState>(accessNotifierProvider, (previous, next) {
      if (next.isGranted && previous is! AccessGranted) {
        ref.read(statusListNotifierProvider.notifier).load();
      }
    });

    final Widget content;

    if (!authState.isAuthenticated) {
      content = authState is AuthRestoring
          ? const AuthRestoringView()
          : const LoginScreen();
    } else if (accessState.isGranted) {
      final activeScreen = switch (_activeDestination) {
        NavDestination.moments => MomentsScreen(
          onStatusSelected: (item) => _openViewer(item),
          onExploreKept: () {
            setState(() => _activeDestination = NavDestination.kept);
          },
        ),
        NavDestination.kept => KeptVaultScreen(
          onStatusSelected: (item) => _openViewer(item),
          onExploreMoments: () {
            setState(() => _activeDestination = NavDestination.moments);
          },
        ),
        NavDestination.settings => const SettingsScreen(),
      };

      content = AppShell(
        activeDestination: _activeDestination,
        onDestinationSelected: (dest) {
          setState(() => _activeDestination = dest);
        },
        body: activeScreen,
      );
    } else {
      content = PermissionOnboardingScreen(
        onAccessGranted: () {
          ref.read(statusListNotifierProvider.notifier).load();
        },
      );
    }

    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: 'Keeva',
      debugShowCheckedModeBanner: false,
      theme: KeevaTheme.lightTheme,
      darkTheme: KeevaTheme.darkTheme,
      themeMode: ThemeMode.dark, // Default to Quiet Obsidian
      home: content,
    );
  }
}
