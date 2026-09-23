import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:whatsapp_status_saver/data/auth/platform_biometric_enrollment_guard.dart';
import 'package:whatsapp_status_saver/domain/repositories/biometric_enrollment_guard.dart';
import 'package:whatsapp_status_saver/platform/channel_constants.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel(ChannelConstants.biometricGuardChannelName);

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  group('parseEnrollmentStatus', () {
    test('maps native statuses and treats unknown as unsupported', () {
      expect(
        parseEnrollmentStatus('unchanged'),
        EnrollmentContinuity.unchanged,
      );
      expect(parseEnrollmentStatus('changed'), EnrollmentContinuity.changed);
      expect(
        parseEnrollmentStatus('unavailable'),
        EnrollmentContinuity.unavailable,
      );
      expect(
        parseEnrollmentStatus('unsupported'),
        EnrollmentContinuity.unsupported,
      );
      expect(parseEnrollmentStatus(null), EnrollmentContinuity.unsupported);
    });
  });

  group('PlatformBiometricEnrollmentGuard', () {
    test('bind and check round-trip the native status', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            switch (call.method) {
              case 'bind':
                return 'domain-state';
              case 'check':
                final token = (call.arguments as Map)['token'];
                return token == 'domain-state' ? 'unchanged' : 'changed';
              case 'clear':
                return null;
              default:
                return null;
            }
          });

      final guard = PlatformBiometricEnrollmentGuard();
      expect(await guard.bind(), 'domain-state');
      expect(await guard.check('domain-state'), EnrollmentContinuity.unchanged);
      expect(await guard.check('old-state'), EnrollmentContinuity.changed);
      await guard.clear();
    });

    test('a missing plugin does not look like an enrollment change', () async {
      final guard = PlatformBiometricEnrollmentGuard();

      expect(await guard.bind(), isNull);
      expect(await guard.check('token'), EnrollmentContinuity.unsupported);
      await guard.clear();
    });
  });
}
