import 'dart:io';

/// Release CLI tool for Keeva.
///
/// Implements:
/// - Semantic version determination via Conventional Commits
/// - Build number monotonicity enforcement
/// - Release loop prevention
/// - Pubspec version manipulation
/// - Release notes generation
void main(List<String> args) async {
  if (args.isEmpty) {
    _printUsage();
    exit(1);
  }

  final command = args[0];
  final commandArgs = args.sublist(1);

  try {
    switch (command) {
      case 'calculate':
        await _handleCalculate(commandArgs);
        break;
      case 'update-pubspec':
        await _handleUpdatePubspec(commandArgs);
        break;
      case 'notes':
        await _handleNotes(commandArgs);
        break;
      case 'help':
      case '--help':
      case '-h':
        _printUsage();
        break;
      default:
        stderr.writeln('Unknown command: $command');
        _printUsage();
        exit(1);
    }
  } catch (e, stack) {
    stderr.writeln('Error executing release tool: $e');
    stderr.writeln(stack);
    exit(1);
  }
}

void _printUsage() {
  stdout.writeln('''
Keeva Release Automation Tool

Usage:
  dart run tool/release.dart <command> [options]

Commands:
  calculate         Evaluate git history and calculate next release version.
    --override      <auto|patch|minor|major> (default: auto)
    --dry-run       Calculate without executing release actions
    --pubspec       Path to pubspec.yaml (default: pubspec.yaml)
    --github-output Path to GITHUB_OUTPUT file (optional)

  update-pubspec    Update version in pubspec.yaml.
    --version       New semantic version (e.g. 1.0.0)
    --build         New build number (e.g. 2)
    --pubspec       Path to pubspec.yaml (default: pubspec.yaml)

  notes             Generate release notes markdown.
    --tag           Release tag (e.g. v1.0.0)
    --prev-tag      Previous tag (e.g. v0.9.0 or empty)
    --type          Release type (Initial, Patch, Minor, Major)
    --output        Output file path (default: stdout)
    --checksums     Path to SHA256SUMS.txt to embed (optional)
''');
}

class PubspecVersion {
  final int major;
  final int minor;
  final int patch;
  final int build;

  PubspecVersion({
    required this.major,
    required this.minor,
    required this.patch,
    required this.build,
  });

  String get semVer => '$major.$minor.$patch';
  String get full => '$semVer+$build';

  @override
  String toString() => full;

  static PubspecVersion parse(String content) {
    final versionLine = content
        .split('\n')
        .firstWhere(
          (line) => line.trim().startsWith('version:'),
          orElse: () =>
              throw FormatException('No version line found in pubspec.yaml'),
        );

    final parts = versionLine.split(':').last.trim();
    return parseString(parts);
  }

  static PubspecVersion parseString(String value) {
    final match = RegExp(r'^(\d+)\.(\d+)\.(\d+)\+(\d+)$')
        .firstMatch(value.trim());
    if (match == null) {
      throw FormatException(
        'Invalid version string format: "$value" (expected X.Y.Z+B)',
      );
    }

    return PubspecVersion(
      major: int.parse(match.group(1)!),
      minor: int.parse(match.group(2)!),
      patch: int.parse(match.group(3)!),
      build: int.parse(match.group(4)!),
    );
  }
}

enum ReleaseType { none, initial, patch, minor, major }

extension ReleaseTypeExtension on ReleaseType {
  String get label {
    switch (this) {
      case ReleaseType.none:
        return 'None';
      case ReleaseType.initial:
        return 'Initial';
      case ReleaseType.patch:
        return 'Patch';
      case ReleaseType.minor:
        return 'Minor';
      case ReleaseType.major:
        return 'Major';
    }
  }
}

class ReleaseDecision {
  final bool shouldRelease;
  final ReleaseType releaseType;
  final String currentVersion;
  final int currentBuild;
  final String nextVersion;
  final int nextBuild;
  final String tagName;
  final String reason;
  final List<String> commitSummaries;

  ReleaseDecision({
    required this.shouldRelease,
    required this.releaseType,
    required this.currentVersion,
    required this.currentBuild,
    required this.nextVersion,
    required this.nextBuild,
    required this.tagName,
    required this.reason,
    required this.commitSummaries,
  });
}

class ConventionalCommit {
  final String hash;
  final String subject;
  final String body;

  ConventionalCommit({
    required this.hash,
    required this.subject,
    required this.body,
  });

  bool get isReleaseCommit =>
      subject.startsWith('chore(release):') ||
      subject.contains('[skip release]') ||
      body.contains('[skip release]') ||
      subject.contains('[release-skip]') ||
      body.contains('[release-skip]');

  bool get isBreakingChange {
    final subjectHasBreaking = RegExp(r'^[a-zA-Z]+(\([^)]+\))?!:')
        .hasMatch(subject);
    final bodyHasBreaking =
        body.contains('BREAKING CHANGE:') || body.contains('BREAKING-CHANGE:');
    return subjectHasBreaking || bodyHasBreaking;
  }

  bool get isFeat => RegExp(r'^feat(\([^)]+\))?:').hasMatch(subject);

  bool get isFix => RegExp(r'^fix(\([^)]+\))?:').hasMatch(subject);
}

Future<void> _handleCalculate(List<String> args) async {
  String override = 'auto';
  bool dryRun = false;
  String pubspecPath = 'pubspec.yaml';
  String? githubOutput;

  for (int i = 0; i < args.length; i++) {
    if (args[i] == '--override' && i + 1 < args.length) {
      override = args[++i].toLowerCase();
    } else if (args[i] == '--dry-run') {
      dryRun = true;
    } else if (args[i] == '--pubspec' && i + 1 < args.length) {
      pubspecPath = args[++i];
    } else if (args[i] == '--github-output' && i + 1 < args.length) {
      githubOutput = args[++i];
    }
  }

  final decision = await calculateReleaseDecision(
    pubspecPath: pubspecPath,
    override: override,
  );

  stdout.writeln('=== Release Calculation Result ===');
  stdout.writeln('Should Release:  ${decision.shouldRelease}');
  stdout.writeln('Release Type:    ${decision.releaseType.label}');
  stdout.writeln(
    'Current Version: ${decision.currentVersion}+${decision.currentBuild}',
  );
  stdout.writeln(
    'Next Version:    ${decision.nextVersion}+${decision.nextBuild}',
  );
  stdout.writeln('Target Tag:      ${decision.tagName}');
  stdout.writeln('Reason:          ${decision.reason}');
  stdout.writeln('Qualifying commits: ${decision.commitSummaries.length}');
  for (final c in decision.commitSummaries) {
    stdout.writeln('  - $c');
  }

  if (dryRun) {
    stdout.writeln(
      '\n[DRY RUN] No commits, tags, or publishing actions will be performed.',
    );
  }

  if (githubOutput != null) {
    final file = File(githubOutput);
    final buffer = StringBuffer();
    buffer.writeln('should_release=${decision.shouldRelease}');
    buffer.writeln('release_type=${decision.releaseType.label}');
    buffer.writeln('current_version=${decision.currentVersion}');
    buffer.writeln('current_build=${decision.currentBuild}');
    buffer.writeln('next_version=${decision.nextVersion}');
    buffer.writeln('next_build=${decision.nextBuild}');
    buffer.writeln(
      'version_full=${decision.nextVersion}+${decision.nextBuild}',
    );
    buffer.writeln('tag_name=${decision.tagName}');
    buffer.writeln('dry_run=$dryRun');
    await file.writeAsString(buffer.toString(), mode: FileMode.append);
  }
}

Future<ReleaseDecision> calculateReleaseDecision({
  required String pubspecPath,
  String override = 'auto',
}) async {
  final pubspecFile = File(pubspecPath);
  if (!pubspecFile.existsSync()) {
    throw FileSystemException('Pubspec file not found at $pubspecPath');
  }

  final currentPubspec = PubspecVersion.parse(pubspecFile.readAsStringSync());

  // Check latest release tag in repository
  final tagsResult = await Process.run('git', [
    'tag',
    '-l',
    'v*.*.*',
    '--sort=-v:refname',
  ]);
  final rawTags = (tagsResult.stdout as String)
      .split('\n')
      .map((t) => t.trim())
      .where((t) => t.isNotEmpty && RegExp(r'^v\d+\.\d+\.\d+$').hasMatch(t))
      .toList();

  final latestTag = rawTags.isNotEmpty ? rawTags.first : null;

  // Check HEAD commit for release loops
  final headCommitResult = await Process.run('git', [
    'log',
    '-1',
    '--format=%B',
  ]);
  final headCommitMsg = (headCommitResult.stdout as String).trim();
  if (headCommitMsg.startsWith('chore(release):') ||
      headCommitMsg.contains('[skip release]') ||
      headCommitMsg.contains('[release-skip]')) {
    return ReleaseDecision(
      shouldRelease: false,
      releaseType: ReleaseType.none,
      currentVersion: currentPubspec.semVer,
      currentBuild: currentPubspec.build,
      nextVersion: currentPubspec.semVer,
      nextBuild: currentPubspec.build,
      tagName: latestTag ?? 'v${currentPubspec.semVer}',
      reason: 'Release loop prevention: HEAD commit is a release commit or contains release skip flag.',
      commitSummaries: [],
    );
  }

  // Handle case where NO prior release tags exist
  if (latestTag == null) {
    if (override == 'auto') {
      // Per Section 28: Initial release uses current pubspec version baseline (e.g. v1.0.0+1)
      final initialTag = 'v${currentPubspec.semVer}';
      final tagExistsResult = await Process.run('git', [
        'rev-parse',
        '-q',
        '--verify',
        'refs/tags/$initialTag',
      ]);
      if (tagExistsResult.exitCode == 0) {
        throw StateError(
          'Tag $initialTag already exists. Refusing to overwrite existing release.',
        );
      }

      // Collect commit log
      final logResult = await Process.run('git', [
        'log',
        '--format=%h %s',
        '-n',
        '20',
      ]);
      final summaries = (logResult.stdout as String)
          .split('\n')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();

      return ReleaseDecision(
        shouldRelease: true,
        releaseType: ReleaseType.initial,
        currentVersion: currentPubspec.semVer,
        currentBuild: currentPubspec.build,
        nextVersion: currentPubspec.semVer,
        nextBuild: currentPubspec.build,
        tagName: initialTag,
        reason:
            'Initial release baseline established from pubspec.yaml ($initialTag).',
        commitSummaries: summaries,
      );
    } else {
      // Explicit manual override without existing tag
      final bumpType = _parseOverrideType(override);
      final (nextVer, nextBld) = _applyBump(currentPubspec, bumpType);
      _validateMonotonicBuild(nextBld, currentPubspec.build);

      final nextTag = 'v$nextVer';
      final tagExistsResult = await Process.run('git', [
        'rev-parse',
        '-q',
        '--verify',
        'refs/tags/$nextTag',
      ]);
      if (tagExistsResult.exitCode == 0) {
        throw StateError(
          'Tag $nextTag already exists. Refusing to overwrite existing release.',
        );
      }

      return ReleaseDecision(
        shouldRelease: true,
        releaseType: bumpType,
        currentVersion: currentPubspec.semVer,
        currentBuild: currentPubspec.build,
        nextVersion: nextVer,
        nextBuild: nextBld,
        tagName: nextTag,
        reason: 'Manual override ($override) from initial baseline.',
        commitSummaries: ['Manual override triggered: $override'],
      );
    }
  }

  // Tags exist: determine commits since latestTag
  final gitLogResult = await Process.run('git', [
    'log',
    '$latestTag..HEAD',
    '--format=%H%x1f%s%x1f%b%x1e',
  ]);

  final rawLog = gitLogResult.stdout as String;
  final commits = parseGitCommits(rawLog);

  // Evaluate bump type
  ReleaseType evaluatedBump = ReleaseType.none;
  if (override != 'auto') {
    evaluatedBump = _parseOverrideType(override);
  } else {
    evaluatedBump = determineBumpFromCommits(commits);
  }

  if (evaluatedBump == ReleaseType.none) {
    return ReleaseDecision(
      shouldRelease: false,
      releaseType: ReleaseType.none,
      currentVersion: currentPubspec.semVer,
      currentBuild: currentPubspec.build,
      nextVersion: currentPubspec.semVer,
      nextBuild: currentPubspec.build,
      tagName: latestTag,
      reason:
          'No qualifying Conventional Commits (fix, feat, breaking change) found since $latestTag.',
      commitSummaries: commits
          .map((c) => '${c.hash.substring(0, 7)} ${c.subject}')
          .toList(),
    );
  }

  // Parse baseline version from latest tag to ensure continuity
  final tagVersionStr = latestTag.substring(1); // remove 'v'
  final tagParts = tagVersionStr.split('.').map(int.parse).toList();
  final baseVersionForMath = PubspecVersion(
    major: tagParts[0],
    minor: tagParts[1],
    patch: tagParts[2],
    build: currentPubspec.build,
  );

  final (nextVer, nextBld) = _applyBump(baseVersionForMath, evaluatedBump);
  _validateMonotonicBuild(nextBld, currentPubspec.build);

  final nextTag = 'v$nextVer';

  // Check if tag already exists
  final tagExistsResult = await Process.run('git', [
    'rev-parse',
    '-q',
    '--verify',
    'refs/tags/$nextTag',
  ]);
  if (tagExistsResult.exitCode == 0) {
    throw StateError(
      'Calculated tag $nextTag already exists in git! Aborting to prevent overwriting releases.',
    );
  }

  return ReleaseDecision(
    shouldRelease: true,
    releaseType: evaluatedBump,
    currentVersion: currentPubspec.semVer,
    currentBuild: currentPubspec.build,
    nextVersion: nextVer,
    nextBuild: nextBld,
    tagName: nextTag,
    reason: override != 'auto'
        ? 'Manual override: $override'
        : 'Conventional Commits detected qualifying changes (${evaluatedBump.label}).',
    commitSummaries: commits
        .map((c) => '${c.hash.substring(0, 7)} ${c.subject}')
        .toList(),
  );
}

List<ConventionalCommit> parseGitCommits(String rawLog) {
  if (rawLog.trim().isEmpty) return [];

  final entries = rawLog.split('\x1e');
  final commits = <ConventionalCommit>[];

  for (final entry in entries) {
    if (entry.trim().isEmpty) continue;
    final parts = entry.split('\x1f');
    if (parts.length >= 2) {
      final hash = parts[0].trim();
      final subject = parts[1].trim();
      final body = parts.length >= 3 ? parts[2].trim() : '';

      final commit = ConventionalCommit(
        hash: hash,
        subject: subject,
        body: body,
      );
      if (!commit.isReleaseCommit) {
        commits.add(commit);
      }
    }
  }

  return commits;
}

ReleaseType determineBumpFromCommits(List<ConventionalCommit> commits) {
  bool hasMajor = false;
  bool hasMinor = false;
  bool hasPatch = false;

  for (final commit in commits) {
    if (commit.isBreakingChange) {
      hasMajor = true;
      break; // Major is highest precedence
    } else if (commit.isFeat) {
      hasMinor = true;
    } else if (commit.isFix) {
      hasPatch = true;
    }
  }

  if (hasMajor) return ReleaseType.major;
  if (hasMinor) return ReleaseType.minor;
  if (hasPatch) return ReleaseType.patch;
  return ReleaseType.none;
}

ReleaseType _parseOverrideType(String override) {
  switch (override) {
    case 'patch':
      return ReleaseType.patch;
    case 'minor':
      return ReleaseType.minor;
    case 'major':
      return ReleaseType.major;
    default:
      throw ArgumentError(
        'Invalid override release type: $override (allowed: patch, minor, major, auto)',
      );
  }
}

(String, int) _applyBump(PubspecVersion current, ReleaseType bump) {
  int nextMajor = current.major;
  int nextMinor = current.minor;
  int nextPatch = current.patch;
  final nextBuild = current.build + 1;

  switch (bump) {
    case ReleaseType.major:
      nextMajor += 1;
      nextMinor = 0;
      nextPatch = 0;
      break;
    case ReleaseType.minor:
      nextMinor += 1;
      nextPatch = 0;
      break;
    case ReleaseType.patch:
      nextPatch += 1;
      break;
    case ReleaseType.initial:
    case ReleaseType.none:
      break;
  }

  return ('$nextMajor.$nextMinor.$nextPatch', nextBuild);
}

void _validateMonotonicBuild(int nextBuild, int currentBuild) {
  if (nextBuild <= currentBuild) {
    throw StateError(
      'FAIL RELEASE: Build number must strictly increase! nextBuild ($nextBuild) <= currentBuild ($currentBuild)',
    );
  }
}

Future<void> _handleUpdatePubspec(List<String> args) async {
  String? newVersion;
  int? newBuild;
  String pubspecPath = 'pubspec.yaml';

  for (int i = 0; i < args.length; i++) {
    if (args[i] == '--version' && i + 1 < args.length) {
      newVersion = args[++i];
    } else if (args[i] == '--build' && i + 1 < args.length) {
      newBuild = int.parse(args[++i]);
    } else if (args[i] == '--pubspec' && i + 1 < args.length) {
      pubspecPath = args[++i];
    }
  }

  if (newVersion == null || newBuild == null) {
    throw ArgumentError(
      'Both --version and --build are required for update-pubspec',
    );
  }

  updatePubspecFile(
    pubspecPath: pubspecPath,
    newVersion: newVersion,
    newBuild: newBuild,
  );
  stdout.writeln(
    'Successfully updated $pubspecPath to version: $newVersion+$newBuild',
  );
}

void updatePubspecFile({
  required String pubspecPath,
  required String newVersion,
  required int newBuild,
}) {
  final file = File(pubspecPath);
  if (!file.existsSync()) {
    throw FileSystemException('File not found: $pubspecPath');
  }

  final content = file.readAsStringSync();
  final versionRegex = RegExp(
    r'^version:\s*([0-9]+\.[0-9]+\.[0-9]+\+[0-9]+)',
    multiLine: true,
  );

  if (!versionRegex.hasMatch(content)) {
    throw FormatException(
      'Could not locate standard "version: X.Y.Z+B" in $pubspecPath',
    );
  }

  final updatedContent = content.replaceFirst(
    versionRegex,
    'version: $newVersion+$newBuild',
  );

  file.writeAsStringSync(updatedContent);

  // Validate written file
  final verified = PubspecVersion.parse(file.readAsStringSync());
  if (verified.semVer != newVersion || verified.build != newBuild) {
    throw StateError(
      'Verification failed: pubspec version mismatch after write.',
    );
  }
}

Future<void> _handleNotes(List<String> args) async {
  String? tag;
  String? prevTag;
  String type = 'Patch';
  String? outputPath;
  String? checksumsPath;

  for (int i = 0; i < args.length; i++) {
    if (args[i] == '--tag' && i + 1 < args.length) {
      tag = args[++i];
    } else if (args[i] == '--prev-tag' && i + 1 < args.length) {
      prevTag = args[++i];
    } else if (args[i] == '--type' && i + 1 < args.length) {
      type = args[++i];
    } else if (args[i] == '--output' && i + 1 < args.length) {
      outputPath = args[++i];
    } else if (args[i] == '--checksums' && i + 1 < args.length) {
      checksumsPath = args[++i];
    }
  }

  if (tag == null) {
    throw ArgumentError('--tag is required for notes');
  }

  String checksumsContent = '';
  if (checksumsPath != null && File(checksumsPath).existsSync()) {
    checksumsContent = File(checksumsPath).readAsStringSync().trim();
  }

  // Fetch commits
  List<String> commitList = [];
  if (prevTag != null && prevTag.isNotEmpty) {
    final result = await Process.run('git', [
      'log',
      '$prevTag..HEAD',
      '--format=- %s (%h)',
    ]);
    commitList = (result.stdout as String)
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty && !l.contains('chore(release):'))
        .toList();
  } else {
    final result = await Process.run('git', [
      'log',
      '-n',
      '15',
      '--format=- %s (%h)',
    ]);
    commitList = (result.stdout as String)
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty && !l.contains('chore(release):'))
        .toList();
  }

  final notes = generateReleaseNotes(
    tag: tag,
    releaseType: type,
    commits: commitList,
    checksums: checksumsContent,
  );

  if (outputPath != null) {
    File(outputPath).writeAsStringSync(notes);
    stdout.writeln('Release notes written to $outputPath');
  } else {
    stdout.write(notes);
  }
}

String generateReleaseNotes({
  required String tag,
  required String releaseType,
  required List<String> commits,
  required String checksums,
  bool iosAvailable = false,
}) {
  final buffer = StringBuffer();
  buffer.writeln('# Keeva $tag');
  buffer.writeln();
  buffer.writeln('## Release type');
  buffer.writeln(releaseType);
  buffer.writeln();
  buffer.writeln('## Changes');
  if (commits.isEmpty) {
    buffer.writeln('- Automated release build for $tag.');
  } else {
    for (final commit in commits) {
      buffer.writeln(commit);
    }
  }
  buffer.writeln();
  buffer.writeln('## Downloads');
  buffer.writeln('- Android APK: `Keeva-$tag-Android.apk`');
  buffer.writeln('- Android AAB: `Keeva-$tag-Android.aab`');
  if (iosAvailable) {
    buffer.writeln('- iOS IPA: `Keeva-$tag-iOS.ipa`');
  } else {
    buffer.writeln(
      '- iOS: Not distributed via direct IPA (signing configuration pending / distributed via TestFlight).',
    );
  }
  buffer.writeln();
  buffer.writeln('## Verification');
  buffer.writeln('### SHA-256 Checksums');
  if (checksums.isNotEmpty) {
    buffer.writeln('```');
    buffer.writeln(checksums);
    buffer.writeln('```');
  } else {
    buffer.writeln(
      'Refer to attached `SHA256SUMS.txt` for cryptographic verification.',
    );
  }
  buffer.writeln();
  buffer.writeln('## License');
  buffer.writeln('Apache-2.0');
  buffer.writeln();

  return buffer.toString();
}
