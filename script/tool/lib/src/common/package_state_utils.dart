// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file/file.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;

import 'git_version_finder.dart';
import 'repository_package.dart';

/// The state of a package on disk relative to git state.
@immutable
class PackageChangeState {
  /// Creates a new immutable state instance.
  const PackageChangeState({
    required this.hasChanges,
    required this.hasChangelogChange,
    required this.needsChangelogChange,
    required this.needsVersionChange,
  });

  /// True if there are any changes to files in the package.
  final bool hasChanges;

  /// True if the package's CHANGELOG.md has been changed.
  final bool hasChangelogChange;

  /// True if any changes in the package require a version change according
  /// to repository policy.
  final bool needsVersionChange;

  /// True if any changes in the package require a CHANGELOG change according
  /// to repository policy.
  final bool needsChangelogChange;
}

/// Checks [package] against [changedPaths] to determine what changes it has
/// and how those changes relate to repository policy about CHANGELOG and
/// version updates.
///
/// [changedPaths] should be a list of POSIX-style paths from a common root,
/// and [relativePackagePath] should be the path to [package] from that same
/// root. Commonly these will come from `gitVersionFinder.getChangedFiles()`
/// and `getRelativePosixPath(package.directory, gitDir.path)` respectively;
/// they are arguments mainly to allow for caching the changed paths for an
/// entire command run.
///
/// If [git] is provided, [changedPaths] must be repository-relative
/// paths, and change type detection can use file diffs in addition to paths.
Future<PackageChangeState> checkPackageChangeState(
  RepositoryPackage package, {
  required List<String> changedPaths,
  required String relativePackagePath,
  GitVersionFinder? git,
}) async {
  final String packagePrefix = relativePackagePath.endsWith('/')
      ? relativePackagePath
      : '$relativePackagePath/';

  bool hasChanges = false;
  bool hasChangelogChange = false;
  bool needsVersionChange = false;
  bool needsChangelogChange = false;
  for (final String path in changedPaths) {
    // Only consider files within the package.
    if (!path.startsWith(packagePrefix)) {
      continue;
    }
    final String packageRelativePath = path.substring(packagePrefix.length);
    hasChanges = true;

    final List<String> components = p.posix.split(packageRelativePath);
    if (components.isEmpty) {
      continue;
    }

    if (components.first == 'CHANGELOG.md') {
      hasChangelogChange = true;
      continue;
    }

    if (!needsVersionChange) {
      // Developer-only changes don't need version changes or changelog changes.
      if (await _isDevChange(components, git: git, repoPath: path)) {
        continue;
      }

      final bool isUnpublishedExampleChange =
          _isUnpublishedExampleChange(components, package);

      // Since examples of federated plugin implementations are only intended
      // for testing purposes, any unpublished example change in one of them is
      // effectively a developer-only change.
      if (package.isFederated &&
          package.isPlatformImplementation &&
          isUnpublishedExampleChange) {
        continue;
      }

      // Anything that is not developer-only might benefit from changelog
      // changes. This errs on the side of flagging, so that someone checks to
      // see if it should be mentioned there or not.
      needsChangelogChange = true;

      // Most changes that aren't developer-only need version changes.
      if (
          // One of a few special files example will be shown on pub.dev, but
          // for anything else in the example, publishing isn't necessary (even
          // if it is relevant to mention in the CHANGELOG for the future).
          !isUnpublishedExampleChange) {
        needsVersionChange = true;
      }
    }
  }

  return PackageChangeState(
      hasChanges: hasChanges,
      hasChangelogChange: hasChangelogChange,
      needsChangelogChange: needsChangelogChange,
      needsVersionChange: needsVersionChange);
}

bool _isTestChange(List<String> pathComponents) {
  return pathComponents.contains('test') ||
      pathComponents.contains('integration_test') ||
      pathComponents.contains('androidTest') ||
      pathComponents.contains('RunnerTests') ||
      pathComponents.contains('RunnerUITests') ||
      pathComponents.contains('Tests') ||
      pathComponents.last == 'dart_test.yaml' ||
      // Pigeon's custom platform tests.
      pathComponents.first == 'platform_tests';
}

// True if the given file is an example file other than the one that will be
// published according to https://dart.dev/tools/pub/package-layout#examples.
//
// This is not exhastive; it currently only handles variations we actually have
// in our repositories.
bool _isUnpublishedExampleChange(
    List<String> pathComponents, RepositoryPackage package) {
  if (pathComponents.first != 'example') {
    return false;
  }
  final List<String> exampleComponents = pathComponents.sublist(1);
  if (exampleComponents.isEmpty) {
    return false;
  }

  final Directory exampleDirectory =
      package.directory.childDirectory('example');

  // Check for example.md/EXAMPLE.md first, as that has priority. If it's
  // present, any other example file is unpublished.
  final bool hasExampleMd =
      exampleDirectory.childFile('example.md').existsSync() ||
          exampleDirectory.childFile('EXAMPLE.md').existsSync();
  if (hasExampleMd) {
    return !(exampleComponents.length == 1 &&
        exampleComponents.first.toLowerCase() == 'example.md');
  }

  // Most packages have an example/lib/main.dart (or occasionally
  // example/main.dart), so check for that. The other naming variations aren't
  // currently used.
  const String mainName = 'main.dart';
  final bool hasExampleCode =
      exampleDirectory.childDirectory('lib').childFile(mainName).existsSync() ||
          exampleDirectory.childFile(mainName).existsSync();
  if (hasExampleCode) {
    // If there is an example main, only that example file is published.
    return !((exampleComponents.length == 1 &&
            exampleComponents.first == mainName) ||
        (exampleComponents.length == 2 &&
            exampleComponents.first == 'lib' &&
            exampleComponents[1] == mainName));
  }

  // If there's no example code either, the example README.md, if any, is the
  // file that will be published.
  return exampleComponents.first.toLowerCase() != 'readme.md';
}

// True if the change is only relevant to people working on the package.
Future<bool> _isDevChange(List<String> pathComponents,
    {GitVersionFinder? git, String? repoPath}) async {
  return _isTestChange(pathComponents) ||
      // The top-level "tool" directory is for non-client-facing utility
      // code, such as test scripts.
      pathComponents.first == 'tool' ||
      // The top-level "pigeons" directory is the repo convention for storing
      // pigeon input files.
      pathComponents.first == 'pigeons' ||
      // Entry point for the 'custom-test' command, which is only for CI and
      // local testing.
      pathComponents.first == 'run_tests.sh' ||
      // CONTRIBUTING.md is dev-facing.
      pathComponents.last == 'CONTRIBUTING.md' ||
      // Lints don't affect clients.
      pathComponents.contains('analysis_options.yaml') ||
      pathComponents.contains('lint-baseline.xml') ||
      // Example build files are very unlikely to be interesting to clients.
      _isExampleBuildFile(pathComponents) ||
      // Test-only gradle depenedencies don't affect clients.
      await _isGradleTestDependencyChange(pathComponents,
          git: git, repoPath: repoPath) ||
      // Implementation comments don't affect clients.
      // This check is currently Dart-only since that's the only place
      // this has come up in practice; it could be generalized to other
      // languages if needed.
      await _isDartImplementationCommentChange(pathComponents,
          git: git, repoPath: repoPath);
}

bool _isExampleBuildFile(List<String> pathComponents) {
  if (!pathComponents.contains('example')) {
    return false;
  }
  return pathComponents.contains('gradle-wrapper.properties') ||
      pathComponents.contains('gradle.properties') ||
      pathComponents.contains('build.gradle') ||
      pathComponents.contains('Runner.xcodeproj') ||
      pathComponents.contains('Runner.xcscheme') ||
      pathComponents.contains('Runner.xcworkspace') ||
      pathComponents.contains('Podfile') ||
      pathComponents.contains('CMakeLists.txt') ||
      pathComponents.contains('.pluginToolsConfig.yaml') ||
      pathComponents.contains('settings.gradle') ||
      pathComponents.contains('pubspec.yaml');
}

Future<bool> _isGradleTestDependencyChange(List<String> pathComponents,
    {GitVersionFinder? git, String? repoPath}) async {
  if (git == null) {
    return false;
  }
  if (pathComponents.last != 'build.gradle') {
    return false;
  }
  final List<String> diff = await git.getDiffContents(targetPath: repoPath);
  final RegExp changeLine = RegExp(r'^[+-] ');
  final RegExp testDependencyLine =
      RegExp(r'^[+-]\s*(?:androidT|t)estImplementation\s');
  bool foundTestDependencyChange = false;
  for (final String line in diff) {
    if (!changeLine.hasMatch(line) ||
        line.startsWith('--- ') ||
        line.startsWith('+++ ')) {
      continue;
    }
    if (!testDependencyLine.hasMatch(line)) {
      return false;
    }
    foundTestDependencyChange = true;
  }
  // Only return true if a test dependency change was found, as a failsafe
  // against having the wrong (e.g., incorrectly empty) diff output.
  return foundTestDependencyChange;
}

// Returns true if the given file is a Dart file whose only changes are
// implementation comments (i.e., not doc comments).
Future<bool> _isDartImplementationCommentChange(List<String> pathComponents,
    {GitVersionFinder? git, String? repoPath}) async {
  if (git == null) {
    return false;
  }
  if (!pathComponents.last.endsWith('.dart')) {
    return false;
  }
  final List<String> diff = await git.getDiffContents(targetPath: repoPath);
  final RegExp changeLine = RegExp(r'^[+-] ');
  final RegExp whitespaceLine = RegExp(r'^[+-]\s*$');
  final RegExp nonDocCommentLine = RegExp(r'^[+-]\s*//\s');
  bool foundIgnoredChange = false;
  for (final String line in diff) {
    if (!changeLine.hasMatch(line) ||
        line.startsWith('--- ') ||
        line.startsWith('+++ ')) {
      continue;
    }
    if (!nonDocCommentLine.hasMatch(line) && !whitespaceLine.hasMatch(line)) {
      return false;
    }
    foundIgnoredChange = true;
  }
  // Only return true if an ignored change was found, as a failsafe against
  // having the wrong (e.g., incorrectly empty) diff output.
  return foundIgnoredChange;
}
