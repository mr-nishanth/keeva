import 'package:flutter_test/flutter_test.dart';
import 'package:whatsapp_status_saver/core/errors/app_failure.dart';
import 'package:whatsapp_status_saver/core/result/result.dart';

void main() {
  group('Result<T>', () {
    test('Success holds value and reports correct flags', () {
      const result = Result.success(42);

      expect(result.isSuccess, isTrue);
      expect(result.isFailure, isFalse);
      expect(result.dataOrNull, equals(42));
      expect(result.failureOrNull, isNull);

      final folded = result.fold(
        onSuccess: (data) => 'Value: $data',
        onFailure: (failure) => 'Failed: ${failure.message}',
      );
      expect(folded, equals('Value: 42'));
    });

    test('Failure holds AppFailure and reports correct flags', () {
      const failure = DocumentNotFoundFailure('Item not found');
      const result = Result<int>.failure(failure);

      expect(result.isSuccess, isFalse);
      expect(result.isFailure, isTrue);
      expect(result.dataOrNull, isNull);
      expect(result.failureOrNull, equals(failure));

      final folded = result.fold(
        onSuccess: (data) => 'Value: $data',
        onFailure: (failure) => failure.message,
      );
      expect(folded, equals('Item not found'));
    });

    test('map transforms success value and preserves failure', () {
      const success = Result.success('hello');
      final mappedSuccess = success.map((s) => s.length);
      expect(mappedSuccess, equals(const Result.success(5)));

      const failure = Result<String>.failure(ReadFailedFailure('read error'));
      final mappedFailure = failure.map((s) => s.length);
      expect(mappedFailure.isFailure, isTrue);
      expect(mappedFailure.failureOrNull?.message, equals('read error'));
    });

    test('mapFailure transforms failure and preserves success', () {
      const failure = Result<int>.failure(UnknownFailure('bad'));
      final transformed = failure.mapFailure(
        (f) => SaveFailedFailure(f.message),
      );
      expect(transformed.failureOrNull, isA<SaveFailedFailure>());

      const success = Result.success(100);
      final mappedSuccess = success.mapFailure(
        (f) => SaveFailedFailure(f.message),
      );
      expect(mappedSuccess.dataOrNull, equals(100));
    });

    test('equality and hashcode contracts', () {
      const s1 = Result.success('item');
      const s2 = Result.success('item');
      const s3 = Result.success('different');

      expect(s1, equals(s2));
      expect(s1.hashCode, equals(s2.hashCode));
      expect(s1, isNot(equals(s3)));

      const f1 = Result<int>.failure(AccessNotGrantedFailure('denied'));
      const f2 = Result<int>.failure(AccessNotGrantedFailure('denied'));
      const f3 = Result<int>.failure(AccessRevokedFailure('revoked'));

      expect(f1, equals(f2));
      expect(f1.hashCode, equals(f2.hashCode));
      expect(f1, isNot(equals(f3)));
    });
  });
}
