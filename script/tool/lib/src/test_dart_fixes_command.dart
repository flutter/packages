// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:file/file.dart';
import 'package:meta/meta.dart';

import 'common/file_filters.dart';
import 'common/package_looping_command.dart';
import 'common/pub_utils.dart';
import 'common/repository_package.dart';

/// A command to run dart fix tests for packages that have a test_fixes
/// directory.
class TestDartFixesCommand extends PackageLoopingCommand {
  /// Creates an instance of the test dart fixes command.
  TestDartFixesCommand(super.packagesDir, {super.processRunner, super.platform, super.gitDir});

  /// A map of the test directory used for each package passed to runForPackage.
  @visibleForTesting
  final testDirectories = <String, Directory>{};

  @override
  final String name = 'test-dart-fixes';

  @override
  List<String> get aliases => <String>[];

  @override
  final String description =
      'Runs the Dart fix tests for all packages.\n\n'
      'This command requires "flutter" to be in your path.';

  @override
  PackageLoopingType get packageLoopingType => PackageLoopingType.topLevelOnly;

  @override
  bool shouldIgnoreFile(String path) {
    return isRepoLevelNonCodeImpactingFile(path) ||
        isNativeCodeFile(path) ||
        isPackageSupportFile(path);
  }

  @override
  Future<PackageResult> runForPackage(RepositoryPackage package) async {
    // Only run for packages that have a fix_tests directory.
    if (!package.dartFixTestDirectory.existsSync()) {
      return PackageResult.skip('No ${package.dartFixTestDirectory} directory.');
    }

    final Directory testDirectory;
    try {
      testDirectory = await _createTestDirectory(package);
    } catch (error) {
      return PackageResult.fail(['Failed to create temporary test directory: $error']);
    }

    PackageResult result;
    try {
      final bool success = await _runDartFixTests(testDirectory);
      if (!success) {
        throw Exception('Failed to run dart fix tests.');
      }
      result = PackageResult.success();
    } catch (error) {
      result = PackageResult.fail(['Dart fix tests failed: $error']);
    }
    if (testDirectory.existsSync()) {
      await testDirectory.delete(recursive: true);
    }
    testDirectories[package.displayName] = testDirectory;
    return result;
  }

  /// Create and prepare a temporary directory in which to run the dart fix
  /// tests.
  ///
  /// It is the responsibility of the caller to delete this directory and its
  /// contents when done.
  static Future<Directory> _createTestDirectory(RepositoryPackage package) async {
    final FileSystem fileSystem = package.directory.fileSystem;
    final Directory testDirectory = await fileSystem.systemTempDirectory.createTemp();

    // Copy from `test_fixes/` to the temp directory.
    for (final FileSystemEntity entity in package.dartFixTestDirectory.listSync(recursive: true)) {
      final String relativePath = fileSystem.path.relative(
        entity.path,
        from: package.dartFixTestDirectory.path,
      );
      final String destPath = fileSystem.path.join(testDirectory.path, relativePath);
      if (entity is Directory) {
        fileSystem.directory(destPath).createSync(recursive: true);
      } else if (entity is File) {
        fileSystem.file(destPath).parent.createSync(recursive: true);
        entity.copySync(destPath);
      }
    }

    // The pubspec.yaml file to create.
    final File targetPubspecFile = fileSystem.file(
      fileSystem.path.join(testDirectory.path, 'pubspec.yaml'),
    );

    final targetYaml =
        '''
name: test_fixes
publish_to: "none"
version: 1.0.0

environment:
  sdk: ">=2.18.0 <4.0.0"
  flutter: ">=3.3.0"

dependencies:
  flutter:
    sdk: flutter
  ${package.directory.basename}:
    path: ${package.directory.path}
''';

    await targetPubspecFile.writeAsString(targetYaml);
    return testDirectory;
  }

  /// Run the dart fix tests for the package in the given temporary directory.
  ///
  /// Resolves with the status code of the command.
  Future<bool> _runDartFixTests(Directory testDirectory) async {
    // Run flutter pub get in the temp directory to set it up.
    final bool success = await runPubGet(RepositoryPackage(testDirectory), processRunner, platform);

    if (!success) {
      return success;
    }

    // Run dart fix --compare-to-golden in the temp directory.
    final int exitCode = await processRunner.runAndStream('dart', <String>[
      'fix',
      '--compare-to-golden',
    ], workingDir: testDirectory);

    return exitCode == 0;
  }
}
