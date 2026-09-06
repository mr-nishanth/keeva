import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/release.dart';

void main() {
  group('PubspecVersion', () {
    test('parses valid pubspec version string', () {
      final v = PubspecVersion.parseString('1.2.3+4');
      expect(v.major, equals(1));
      expect(v.minor, equals(2));
      expect(v.patch, equals(3));
      expect(v.build, equals(4));
      expect(v.semVer, equals('1.2.3'));
      expect(v.full, equals('1.2.3+4'));
    });

    test('parses version from pubspec.yaml file content', () {
      const content = '''
name: test_app
description: A sample app
version: 2.15.0+42
environment:
  sdk: ^3.0.0
''';
      final v = PubspecVersion.parse(content);
      expect(v.semVer, equals('2.15.0'));
      expect(v.build, equals(42));
    });

    test('throws on invalid version format', () {
      expect(() => PubspecVersion.parseString('1.0.0'), throwsFormatException);
      expect(
        () => PubspecVersion.parseString('v1.0.0+1'),
        throwsFormatException,
      );
      expect(
        () => PubspecVersion.parseString('invalid'),
        throwsFormatException,
      );
    });
  });

  group('ConventionalCommit Parsing', () {
    test('detects release commit and skip flags', () {
      final c1 = ConventionalCommit(
        hash: 'abc1234',
        subject: 'chore(release): v1.0.0',
        body: '',
      );
      expect(c1.isReleaseCommit, isTrue);

      final c2 = ConventionalCommit(
        hash: 'abc1234',
        subject: 'feat: add filter [skip release]',
        body: '',
      );
      expect(c2.isReleaseCommit, isTrue);

      final c3 = ConventionalCommit(
        hash: 'abc1234',
        subject: 'fix: handle memory',
        body: 'Details here [release-skip]',
      );
      expect(c3.isReleaseCommit, isTrue);
    });

    test('detects breaking changes via subject exclamation mark', () {
      final c1 = ConventionalCommit(
        hash: '1111111',
        subject: 'feat!: overhaul storage architecture',
        body: '',
      );
      expect(c1.isBreakingChange, isTrue);

      final c2 = ConventionalCommit(
        hash: '2222222',
        subject: 'fix(core)!: change return type of scanner',
        body: '',
      );
      expect(c2.isBreakingChange, isTrue);

      final c3 = ConventionalCommit(
        hash: '3333333',
        subject: 'refactor!: migrate platform interface',
        body: '',
      );
      expect(c3.isBreakingChange, isTrue);
    });

    test('detects breaking changes via body footer', () {
      final c1 = ConventionalCommit(
        hash: '4444444',
        subject: 'feat: update channel names',
        body: 'BREAKING CHANGE: channel constants have changed.',
      );
      expect(c1.isBreakingChange, isTrue);

      final c2 = ConventionalCommit(
        hash: '5555555',
        subject: 'chore: modify gradle configuration',
        body: 'BREAKING-CHANGE: requires minimum api 26.',
      );
      expect(c2.isBreakingChange, isTrue);
    });

    test('detects feat (minor) commits', () {
      final c1 = ConventionalCommit(
        hash: '6666666',
        subject: 'feat: support video duration display',
        body: '',
      );
      expect(c1.isFeat, isTrue);
      expect(c1.isBreakingChange, isFalse);

      final c2 = ConventionalCommit(
        hash: '7777777',
        subject: 'feat(viewer): implement pinch to zoom',
        body: '',
      );
      expect(c2.isFeat, isTrue);
    });

    test('detects fix (patch) commits', () {
      final c1 = ConventionalCommit(
        hash: '8888888',
        subject: 'fix: resolve video controller leak on pop',
        body: '',
      );
      expect(c1.isFix, isTrue);
      expect(c1.isBreakingChange, isFalse);
      expect(c1.isFeat, isFalse);

      final c2 = ConventionalCommit(
        hash: '9999999',
        subject: 'fix(saf): handle uri permission revocation',
        body: '',
      );
      expect(c2.isFix, isTrue);
    });

    test('non-releasing commits are not feat, fix, or breaking', () {
      final commits = [
        ConventionalCommit(hash: 'a', subject: 'docs: update readme', body: ''),
        ConventionalCommit(
          hash: 'b',
          subject: 'chore: bump dependencies',
          body: '',
        ),
        ConventionalCommit(
          hash: 'c',
          subject: 'ci: optimize gradle cache',
          body: '',
        ),
        ConventionalCommit(
          hash: 'd',
          subject: 'test: add unit tests',
          body: '',
        ),
        ConventionalCommit(
          hash: 'e',
          subject: 'style: format imports',
          body: '',
        ),
        ConventionalCommit(
          hash: 'f',
          subject: 'refactor: simplify notifier',
          body: '',
        ),
      ];

      for (final c in commits) {
        expect(c.isFeat, isFalse);
        expect(c.isFix, isFalse);
        expect(c.isBreakingChange, isFalse);
      }

      final bump = determineBumpFromCommits(commits);
      expect(bump, equals(ReleaseType.none));
    });
  });

  group('determineBumpFromCommits Precedence', () {
    test('breaking change takes precedence over feat and fix (MAJOR)', () {
      final commits = [
        ConventionalCommit(hash: '1', subject: 'fix: patch bug', body: ''),
        ConventionalCommit(hash: '2', subject: 'feat: new feature', body: ''),
        ConventionalCommit(
          hash: '3',
          subject: 'feat!: breaking change',
          body: '',
        ),
      ];

      expect(determineBumpFromCommits(commits), equals(ReleaseType.major));
    });

    test('feat takes precedence over fix (MINOR)', () {
      final commits = [
        ConventionalCommit(hash: '1', subject: 'fix: patch bug 1', body: ''),
        ConventionalCommit(hash: '2', subject: 'feat: new feature', body: ''),
        ConventionalCommit(hash: '3', subject: 'fix: patch bug 2', body: ''),
      ];

      expect(determineBumpFromCommits(commits), equals(ReleaseType.minor));
    });

    test('fix only produces PATCH', () {
      final commits = [
        ConventionalCommit(hash: '1', subject: 'fix: patch bug 1', body: ''),
        ConventionalCommit(hash: '2', subject: 'docs: update guide', body: ''),
        ConventionalCommit(
          hash: '3',
          subject: 'fix(viewer): fix orientation',
          body: '',
        ),
      ];

      expect(determineBumpFromCommits(commits), equals(ReleaseType.patch));
    });

    test('empty or release-only commits produce NONE', () {
      expect(determineBumpFromCommits([]), equals(ReleaseType.none));
    });
  });

  group('Release Notes & Pubspec File Update', () {
    test('generateReleaseNotes formats expected sections accurately', () {
      final notes = generateReleaseNotes(
        tag: 'v1.2.0',
        releaseType: 'Minor',
        commits: [
          '- feat: add kept media vault (a1b2c3d)',
          '- fix: resolve thumbnail aspect ratio (e5f6g7h)',
        ],
        checksums: 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855  Keeva-v1.2.0-Android.apk',
      );

      expect(notes, contains('# Keeva v1.2.0'));
      expect(notes, contains('## Release type'));
      expect(notes, contains('Minor'));
      expect(notes, contains('## Changes'));
      expect(notes, contains('- feat: add kept media vault (a1b2c3d)'));
      expect(notes, contains('## Downloads'));
      expect(notes, contains('Keeva-v1.2.0-Android.apk'));
      expect(notes, contains('Keeva-v1.2.0-Android.aab'));
      expect(notes, contains('## Verification'));
      expect(notes, contains('### SHA-256 Checksums'));
      expect(
        notes,
        contains(
          'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',
        ),
      );
      expect(notes, contains('## License'));
      expect(notes, contains('Apache-2.0'));
    });

    test('updatePubspecFile updates version and preserves other content', () {
      final tempDir = Directory.systemTemp.createTempSync(
        'keeva_release_test_',
      );
      try {
        final testPubspec = File('${tempDir.path}/pubspec.yaml');
        testPubspec.writeAsStringSync('''
name: keeva
description: WhatsApp Status Saver
publish_to: 'none'

version: 1.0.0+1

environment:
  sdk: ^3.13.2

dependencies:
  flutter:
    sdk: flutter
''');

        updatePubspecFile(
          pubspecPath: testPubspec.path,
          newVersion: '1.1.0',
          newBuild: 2,
        );

        final updatedContent = testPubspec.readAsStringSync();
        expect(updatedContent, contains('version: 1.1.0+2'));
        expect(updatedContent, contains('name: keeva'));
        expect(updatedContent, contains('sdk: ^3.13.2'));
      } finally {
        tempDir.deleteSync(recursive: true);
      }
    });
  });
}
