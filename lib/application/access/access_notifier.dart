import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/errors/app_failure.dart';
import '../../core/result/result.dart';
import '../../domain/entities/storage_access_state.dart';
import '../../domain/use_cases/check_storage_access_use_case.dart';
import '../../domain/use_cases/request_storage_access_use_case.dart';
import '../providers.dart';
import 'access_state.dart';

/// Manages the application lifecycle and state transitions for WhatsApp storage access.
///
/// Coordinates [CheckStorageAccessUseCase] and [RequestStorageAccessUseCase],
/// mapping domain results and failures into immutable [AccessState] representations.
class AccessNotifier extends Notifier<AccessState> {
  final CheckStorageAccessUseCase? _checkAccessOverride;
  final RequestStorageAccessUseCase? _requestAccessOverride;

  AccessNotifier({
    CheckStorageAccessUseCase? checkAccessUseCase,
    RequestStorageAccessUseCase? requestAccessUseCase,
  }) : _checkAccessOverride = checkAccessUseCase,
       _requestAccessOverride = requestAccessUseCase;

  CheckStorageAccessUseCase get _checkAccess =>
      _checkAccessOverride ?? ref.read(checkStorageAccessUseCaseProvider);

  RequestStorageAccessUseCase get _requestAccess =>
      _requestAccessOverride ?? ref.read(requestStorageAccessUseCaseProvider);

  @override
  AccessState build() => const AccessInitial();

  /// Verifies current access permissions for [targetPackage].
  ///
  /// Concurrency guard: Ignores reentrant requests while checking or requesting.
  Future<void> checkAccess({
    String targetPackage = AppConstants.whatsappStandardPackage,
  }) async {
    if (state.isChecking || state.isRequesting) {
      return;
    }

    state = const AccessChecking();

    try {
      final result = await _checkAccess(targetPackage: targetPackage);
      state = switch (result) {
        Success(:final data) => _mapDomainAccessState(data),
        Failure(:final failure) => AccessFailure(failure),
      };
    } on AppFailure catch (failure) {
      state = AccessFailure(failure);
    } catch (e) {
      state = AccessFailure(
        UnknownFailure('Unexpected failure verifying storage access: $e'),
      );
    }
  }

  /// Prompts the user via SAF directory picker to grant access to [targetPackage].
  ///
  /// Concurrency guard: Ignores reentrant requests while checking or requesting.
  Future<void> requestAccess({
    String targetPackage = AppConstants.whatsappStandardPackage,
  }) async {
    if (state.isRequesting || state.isChecking) {
      return;
    }

    state = const AccessRequesting();

    try {
      final result = await _requestAccess(targetPackage: targetPackage);
      state = switch (result) {
        Success(:final data) => _mapDomainAccessState(data),
        Failure(:final failure) => AccessFailure(failure),
      };
    } on AppFailure catch (failure) {
      state = AccessFailure(failure);
    } catch (e) {
      state = AccessFailure(
        UnknownFailure('Unexpected failure requesting storage access: $e'),
      );
    }
  }

  /// Refreshes current access status by re-checking storage permissions.
  Future<void> refreshAccess({
    String targetPackage = AppConstants.whatsappStandardPackage,
  }) {
    return checkAccess(targetPackage: targetPackage);
  }

  AccessState _mapDomainAccessState(StorageAccessState domainState) {
    return switch (domainState) {
      StorageAccessGranted(:final targetPackage) => AccessGranted(
        targetPackage: targetPackage,
      ),
      StorageAccessNotGranted() => const AccessNotGranted(),
      StorageAccessRevoked(:final reason) => AccessRevoked(reason: reason),
      StorageAccessInvalid(:final reason) => AccessInvalid(reason: reason),
      StorageAccessUnavailable(:final reason) => AccessUnavailable(
        reason: reason,
      ),
      StorageAccessInitial() => const AccessInitial(),
    };
  }
}
