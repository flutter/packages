// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:file/file.dart';
import 'package:io/io.dart' as io;
import 'package:path/path.dart' as p;

import 'common/file_filters.dart';
import 'common/package_looping_command.dart';
import 'common/repository_package.dart';

/// A command to run dart fix tests for packages that have a test_fixes
/// directory.
class TestDartFixesCommand extends PackageLoopingCommand {
  /// Creates an instance of the test dart fixes command.
  TestDartFixesCommand(super.packagesDir, {super.processRunner, super.platform, super.gitDir});

  @override
  final String name = 'test-dart-fixes';

  @override
  List<String> get aliases => <String>[];

  @override
  final String description =
      'Runs the Dart fix tests for all packages.\n\n'
      'This command requires "flutter" to be in your path.';

  @override
  PackageLoopingType get packageLoopingType => PackageLoopingType.includeAllSubpackages;

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

    late final PackageResult result;
    try {
      final int statusCode = await _runDartFixTests(package, testDirectory);
      if (statusCode != 0) {
        throw Exception('Status code $statusCode');
      }
      result = PackageResult.success();
    } catch (error) {
      result = PackageResult.fail(['Dart fix tests failed: $error']);
    }
    if (testDirectory.existsSync()) {
      await testDirectory.delete(recursive: true);
    }
    return result;
  }

  /// Create and prepare a temporary directory in which to run the dart fix
  /// tests.
  ///
  /// It is the responsibility of the caller to delete this directory and its
  /// contents when done.
  static Future<Directory> _createTestDirectory(RepositoryPackage package) async {
    final FileSystem fileSystem = package.directory.fileSystem;
    final Directory testTempDirectory = await fileSystem.systemTempDirectory.createTemp();

    // Copy from `test_fixes/` to the temp directory.
    await io.copyPath(package.dartFixTestDirectory.path, testTempDirectory.path);

    // The pubspec.yaml file to create.
    final File targetPubspecFile = fileSystem.file(p.join(testTempDirectory.path, 'pubspec.yaml'));

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
    return testTempDirectory;
  }

  /// Run the dart fix tests for the package in the given temporary directory.
  ///
  /// Resolves with the status code of the command.
  Future<int> _runDartFixTests(RepositoryPackage package, Directory testDirectory) async {
    // Run flutter pub get in the temp directory to set it up.
    final int pubGetStatusCode = await _runProcess('flutter', <String>[
      'pub',
      'get',
    ], workingDirectory: testDirectory);

    if (pubGetStatusCode != 0) {
      return pubGetStatusCode;
    }

    // Run dart fix --compare-to-golden in the temp directory.
    return _runProcess('dart', <String>[
      'fix',
      '--compare-to-golden',
    ], workingDirectory: testDirectory);
  }

  Future<int> _runProcess(
    String command,
    List<String> arguments, {
    Directory? workingDirectory,
  }) async {
    final Process process = await _streamOutput(
      processRunner.start(command, arguments, workingDirectory: workingDirectory),
    );
    return process.exitCode;
  }

  static Future<Process> _streamOutput(Future<Process> processFuture) async {
    final Process process = await processFuture;
    unawaited(stdout.addStream(process.stdout));
    unawaited(stderr.addStream(process.stderr));
    return process;
  }
}
