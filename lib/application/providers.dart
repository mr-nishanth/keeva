import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/auth/local_auth_biometric_authenticator.dart';
import '../data/auth/platform_biometric_enrollment_guard.dart';
import '../data/auth/secure_session_store.dart';
import '../data/auth/session_store.dart';
import '../data/datasources/status_platform_datasource.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../data/repositories/status_repository_impl.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/repositories/biometric_authenticator.dart';
import '../domain/repositories/biometric_enrollment_guard.dart';
import '../domain/repositories/status_repository.dart';
import '../domain/use_cases/check_storage_access_use_case.dart';
import '../domain/use_cases/get_statuses_use_case.dart';
import '../domain/use_cases/get_thumbnail_use_case.dart';
import '../domain/use_cases/prepare_video_playback_use_case.dart';
import '../domain/use_cases/request_storage_access_use_case.dart';
import '../domain/use_cases/restore_auth_session_use_case.dart';
import '../domain/use_cases/save_status_use_case.dart';
import '../domain/use_cases/share_status_use_case.dart';
import '../domain/use_cases/sign_in_use_case.dart';
import '../platform/method_channel_status_scanner.dart';
import '../platform/status_scanner_platform_interface.dart';
import 'access/access_notifier.dart';
import 'access/access_state.dart';
import 'auth/auth_notifier.dart';
import 'auth/auth_state.dart';
import 'auth/biometric_settings_notifier.dart';
import 'saver/save_notifier.dart';
import 'saver/save_state.dart';
import 'statuses/status_list_notifier.dart';
import 'statuses/status_list_state.dart';
import 'viewer/viewer_notifier.dart';
import 'viewer/viewer_state.dart';

// =============================================================================
// PLATFORM & INFRASTRUCTURE PROVIDERS
// =============================================================================

/// On-device secure store for the local sign-in session.
///
/// Override in tests with an in-memory [SessionStore].
final sessionStoreProvider = Provider<SessionStore>((ref) {
  return SecureSessionStore();
});

/// Provides the platform scanner interface implementation.
///
/// In production, uses [MethodChannelStatusScanner]. Can be cleanly overridden
/// in widget/integration tests.
final statusScannerPlatformProvider = Provider<StatusScannerPlatformInterface>((
  ref,
) {
  return const MethodChannelStatusScanner();
});

// =============================================================================
// DATA LAYER PROVIDERS
// =============================================================================

/// Provides the platform datasource coordinating native channel communications.
final statusPlatformDatasourceProvider = Provider<StatusPlatformDatasource>((
  ref,
) {
  final platform = ref.watch(statusScannerPlatformProvider);
  return StatusPlatformDatasourceImpl(platform);
});

/// Provides the domain repository implementation.
final statusRepositoryProvider = Provider<StatusRepository>((ref) {
  final datasource = ref.watch(statusPlatformDatasourceProvider);
  return StatusRepositoryImpl(datasource);
});

/// Provides the local sign-in repository.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final sessionStore = ref.watch(sessionStoreProvider);
  return AuthRepositoryImpl(sessionStore);
});

/// Platform biometric prompt. Tests override this with a fake.
final biometricAuthenticatorProvider = Provider<BiometricAuthenticator>((ref) {
  return LocalAuthBiometricAuthenticator();
});

/// Enrollment-change binding for biometric unlock.
final biometricEnrollmentGuardProvider = Provider<BiometricEnrollmentGuard>((
  ref,
) {
  return PlatformBiometricEnrollmentGuard();
});

// =============================================================================
// DOMAIN USE CASE PROVIDERS
// =============================================================================

/// Provides [CheckStorageAccessUseCase] for verifying directory permissions.
final checkStorageAccessUseCaseProvider = Provider<CheckStorageAccessUseCase>((
  ref,
) {
  final repository = ref.watch(statusRepositoryProvider);
  return CheckStorageAccessUseCase(repository);
});

/// Provides [RequestStorageAccessUseCase] for launching SAF directory picker.
final requestStorageAccessUseCaseProvider =
    Provider<RequestStorageAccessUseCase>((ref) {
      final repository = ref.watch(statusRepositoryProvider);
      return RequestStorageAccessUseCase(repository);
    });

/// Provides [GetStatusesUseCase] for discovering status items.
final getStatusesUseCaseProvider = Provider<GetStatusesUseCase>((ref) {
  final repository = ref.watch(statusRepositoryProvider);
  return GetStatusesUseCase(repository);
});

/// Provides [GetThumbnailUseCase] for fetching native cached thumbnails.
final getThumbnailUseCaseProvider = Provider<GetThumbnailUseCase>((ref) {
  final repository = ref.watch(statusRepositoryProvider);
  return GetThumbnailUseCase(repository);
});

/// Provides [SaveStatusUseCase] for exporting media to the gallery.
final saveStatusUseCaseProvider = Provider<SaveStatusUseCase>((ref) {
  final repository = ref.watch(statusRepositoryProvider);
  return SaveStatusUseCase(repository);
});

/// Provides [PrepareVideoPlaybackUseCase] for on-demand video caching.
final prepareVideoPlaybackUseCaseProvider =
    Provider<PrepareVideoPlaybackUseCase>((ref) {
      final repository = ref.watch(statusRepositoryProvider);
      return PrepareVideoPlaybackUseCase(repository);
    });

/// Provides [ShareStatusUseCase] for native media sharing.
final shareStatusUseCaseProvider = Provider<ShareStatusUseCase>((ref) {
  final repository = ref.watch(statusRepositoryProvider);
  return ShareStatusUseCase(repository);
});

/// Provides [RestoreAuthSessionUseCase] for cold-start session restore.
final restoreAuthSessionUseCaseProvider = Provider<RestoreAuthSessionUseCase>((
  ref,
) {
  final repository = ref.watch(authRepositoryProvider);
  return RestoreAuthSessionUseCase(repository);
});

/// Provides [SignInUseCase] for the local username and password check.
final signInUseCaseProvider = Provider<SignInUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return SignInUseCase(repository);
});

// =============================================================================
// APPLICATION NOTIFIER PROVIDERS
// =============================================================================

/// Manages the local sign-in session that gates the rest of the app.
final authNotifierProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

/// Biometric unlock switch shown on the Settings screen.
final biometricSettingsProvider =
    AsyncNotifierProvider<BiometricSettingsNotifier, BiometricSettings>(
      BiometricSettingsNotifier.new,
    );

/// Manages SAF directory access state.
///
/// Lifecycle: Persistent across navigation to retain permission status.
final accessNotifierProvider = NotifierProvider<AccessNotifier, AccessState>(
  AccessNotifier.new,
);

/// Manages WhatsApp status discovery and background refresh.
///
/// Lifecycle: Persistent across navigation tabs so discovered media does not
/// unexpectedly clear or re-trigger discovery when switching between screens.
final statusListNotifierProvider =
    NotifierProvider<StatusListNotifier, StatusListState>(
      StatusListNotifier.new,
    );

/// Coordinates gallery export operations.
///
/// Lifecycle: Persistent across navigation to track active and recent save tasks.
final saveNotifierProvider = NotifierProvider<SaveNotifier, SaveState>(
  SaveNotifier.new,
);

/// Coordinates full-screen media preparation (video caching).
///
/// Lifecycle: Maintained as standard Notifier with explicit reset()
/// support to cleanly control media lifecycle across viewer sessions.
final viewerNotifierProvider = NotifierProvider<ViewerNotifier, ViewerState>(
  ViewerNotifier.new,
);
