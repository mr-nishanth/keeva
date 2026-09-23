import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/biometric_capability.dart';
import '../providers.dart';
import 'auth_copy.dart';

/// Settings snapshot for the biometric unlock switch.
final class BiometricSettings {
  final bool available;
  final bool enabled;
  final bool busy;
  final String detail;
  final String? errorMessage;

  const BiometricSettings({
    required this.available,
    required this.enabled,
    required this.detail,
    this.busy = false,
    this.errorMessage,
  });

  BiometricSettings copyWith({
    bool? available,
    bool? enabled,
    bool? busy,
    String? detail,
    String? errorMessage,
    bool clearError = false,
  }) {
    return BiometricSettings(
      available: available ?? this.available,
      enabled: enabled ?? this.enabled,
      busy: busy ?? this.busy,
      detail: detail ?? this.detail,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

/// Loads and changes the biometric unlock preference shown in Settings.
class BiometricSettingsNotifier extends AsyncNotifier<BiometricSettings> {
  @override
  Future<BiometricSettings> build() => _load();

  Future<void> setEnabled(bool enabled) async {
    final current = state.asData?.value;
    if (current == null || current.busy) return;
    if (enabled && !current.available) return;

    state = AsyncData(current.copyWith(busy: true, clearError: true));
    final auth = ref.read(authNotifierProvider.notifier);
    final saved = enabled
        ? await auth.enableBiometricUnlock()
        : await auth.disableBiometricUnlock();
    if (!ref.mounted) return;
    final loaded = await _load();
    state = AsyncData(
      saved
          ? loaded
          : loaded.copyWith(
              errorMessage: enabled ? AuthCopy.enableFailed : null,
            ),
    );
  }

  Future<BiometricSettings> _load() async {
    final capability = await ref
        .read(biometricAuthenticatorProvider)
        .capability();
    final preference = await ref
        .read(authRepositoryProvider)
        .readBiometricUnlock();
    final enabled = preference.dataOrNull?.enabled ?? false;
    final available = capability.canAuthenticate;
    return BiometricSettings(
      available: available,
      enabled: enabled,
      detail: _detail(capability, enabled: enabled, available: available),
    );
  }

  String _detail(
    BiometricCapability capability, {
    required bool enabled,
    required bool available,
  }) {
    if (enabled && !available) {
      return 'Biometric unlock is on, but this device cannot prompt right now. You can turn it off and use your password.';
    }
    return capability.summary;
  }
}
