import '../../core/constants/app_constants.dart';
import '../../core/errors/app_failure.dart';

/// Sealed hierarchy representing the application state of WhatsApp folder access.
///
/// Decoupled completely from Android SAF, DocumentsUI, and Flutter UI layers.
sealed class AccessState {
  const AccessState();

  bool get isInitial => this is AccessInitial;
  bool get isChecking => this is AccessChecking;
  bool get isRequesting => this is AccessRequesting;
  bool get isGranted => this is AccessGranted;
  bool get isNotGranted => this is AccessNotGranted;
  bool get isRevoked => this is AccessRevoked;
  bool get isInvalid => this is AccessInvalid;
  bool get isUnavailable => this is AccessUnavailable;
  bool get isFailure => this is AccessFailure;
}

/// Initial uninitialized state.
final class AccessInitial extends AccessState {
  const AccessInitial();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AccessInitial && other.runtimeType == runtimeType);

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'AccessInitial()';
}

/// Asynchronous access check is in progress.
final class AccessChecking extends AccessState {
  const AccessChecking();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AccessChecking && other.runtimeType == runtimeType);

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'AccessChecking()';
}

/// SAF directory picker request is currently active.
final class AccessRequesting extends AccessState {
  const AccessRequesting();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AccessRequesting && other.runtimeType == runtimeType);

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'AccessRequesting()';
}

/// Access is actively verified and granted for [targetPackage].
final class AccessGranted extends AccessState {
  final String targetPackage;

  const AccessGranted({
    this.targetPackage = AppConstants.whatsappStandardPackage,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AccessGranted &&
          other.runtimeType == runtimeType &&
          other.targetPackage == targetPackage);

  @override
  int get hashCode => Object.hash(runtimeType, targetPackage);

  @override
  String toString() => 'AccessGranted(targetPackage: $targetPackage)';
}

/// Storage access has not yet been granted.
final class AccessNotGranted extends AccessState {
  const AccessNotGranted();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AccessNotGranted && other.runtimeType == runtimeType);

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'AccessNotGranted()';
}

/// Previously granted access was revoked by OS or user.
final class AccessRevoked extends AccessState {
  final String? reason;

  const AccessRevoked({this.reason});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AccessRevoked &&
          other.runtimeType == runtimeType &&
          other.reason == reason);

  @override
  int get hashCode => Object.hash(runtimeType, reason);

  @override
  String toString() => 'AccessRevoked(reason: $reason)';
}

/// Selected folder does not match expected WhatsApp media structure.
final class AccessInvalid extends AccessState {
  final String? reason;

  const AccessInvalid({this.reason});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AccessInvalid &&
          other.runtimeType == runtimeType &&
          other.reason == reason);

  @override
  int get hashCode => Object.hash(runtimeType, reason);

  @override
  String toString() => 'AccessInvalid(reason: $reason)';
}

/// WhatsApp status folder is unavailable on this device.
final class AccessUnavailable extends AccessState {
  final String? reason;

  const AccessUnavailable({this.reason});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AccessUnavailable &&
          other.runtimeType == runtimeType &&
          other.reason == reason);

  @override
  int get hashCode => Object.hash(runtimeType, reason);

  @override
  String toString() => 'AccessUnavailable(reason: $reason)';
}

/// Operation failed with a domain-safe [AppFailure].
final class AccessFailure extends AccessState {
  final AppFailure failure;

  const AccessFailure(this.failure);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AccessFailure &&
          other.runtimeType == runtimeType &&
          other.failure == failure);

  @override
  int get hashCode => Object.hash(runtimeType, failure);

  @override
  String toString() => 'AccessFailure($failure)';
}
