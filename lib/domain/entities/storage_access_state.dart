/// Represents the current state of WhatsApp status folder access.
///
/// Encapsulates platform access state without leaking Android SAF or DocumentsUI
/// implementation specifics into domain or presentation code.
sealed class StorageAccessState {
  const StorageAccessState();

  /// Whether storage access is actively granted and ready for scanning.
  bool get isGranted => this is StorageAccessGranted;

  /// Whether storage access has not yet been granted.
  bool get isNotGranted => this is StorageAccessNotGranted;

  /// Whether access was revoked or requires user re-authorization.
  bool get isRevoked => this is StorageAccessRevoked;

  /// Whether the folder structure is invalid.
  bool get isInvalid => this is StorageAccessInvalid;

  /// Whether WhatsApp statuses are unavailable on this device.
  bool get isUnavailable => this is StorageAccessUnavailable;
}

/// Initial uninitialized state before access check completes.
final class StorageAccessInitial extends StorageAccessState {
  const StorageAccessInitial();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StorageAccessInitial && other.runtimeType == runtimeType);

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'StorageAccessInitial()';
}

/// Access has been verified and granted for the target WhatsApp package.
final class StorageAccessGranted extends StorageAccessState {
  /// The target WhatsApp package identifier (e.g. 'com.whatsapp').
  final String targetPackage;

  const StorageAccessGranted({this.targetPackage = 'com.whatsapp'});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StorageAccessGranted &&
          other.runtimeType == runtimeType &&
          other.targetPackage == targetPackage);

  @override
  int get hashCode => Object.hash(runtimeType, targetPackage);

  @override
  String toString() => 'StorageAccessGranted(targetPackage: $targetPackage)';
}

/// Access has not yet been granted by the user.
final class StorageAccessNotGranted extends StorageAccessState {
  const StorageAccessNotGranted();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StorageAccessNotGranted && other.runtimeType == runtimeType);

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'StorageAccessNotGranted()';
}

/// Storage access permission was granted previously but was revoked by the user or OS.
final class StorageAccessRevoked extends StorageAccessState {
  final String? reason;

  const StorageAccessRevoked({this.reason});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StorageAccessRevoked &&
          other.runtimeType == runtimeType &&
          other.reason == reason);

  @override
  int get hashCode => Object.hash(runtimeType, reason);

  @override
  String toString() => 'StorageAccessRevoked(reason: $reason)';
}

/// Selected folder is invalid or does not match expected WhatsApp media hierarchy.
final class StorageAccessInvalid extends StorageAccessState {
  final String? reason;

  const StorageAccessInvalid({this.reason});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StorageAccessInvalid &&
          other.runtimeType == runtimeType &&
          other.reason == reason);

  @override
  int get hashCode => Object.hash(runtimeType, reason);

  @override
  String toString() => 'StorageAccessInvalid(reason: $reason)';
}

/// WhatsApp status directory is unavailable on this device.
final class StorageAccessUnavailable extends StorageAccessState {
  final String? reason;

  const StorageAccessUnavailable({this.reason});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StorageAccessUnavailable &&
          other.runtimeType == runtimeType &&
          other.reason == reason);

  @override
  int get hashCode => Object.hash(runtimeType, reason);

  @override
  String toString() => 'StorageAccessUnavailable(reason: $reason)';
}
