// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:io/io.dart' as io;
import 'package:path/path.dart' as p;

import 'common/file_filters.dart';
import 'common/package_looping_command.dart';
import 'common/repository_package.dart';

/// A command to run dart fix tests for packages that have a test_fixes
/// directory.
class TestDartFixes extends PackageLoopingCommand {
  /// Creates an instance of the test dart fixes command.
  TestDartFixes(super.packagesDir, {super.processRunner, super.platform, super.gitDir});

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

    // Create a temporary directory to run the tests in.
    const fileSystem = LocalFileSystem();
    final Directory testTempDir = await fileSystem.systemTempDirectory.createTemp();

    late final PackageResult result;
    try {
      final int statusCode = await _runDartFixTests(package, testTempDir);
      if (statusCode != 0) {
        throw Exception('Status code $statusCode');
      }
      result = PackageResult.success();
    } catch (error) {
      result = PackageResult.fail(['Dart fix tests failed: $error}']);
    }
    if (testTempDir.existsSync()) {
      await testTempDir.delete(recursive: true);
    }
    return result;
  }

  /// Run the dart fix tests for the package in the given temporary directory.
  ///
  /// Resolves with the status code of the command.
  Future<int> _runDartFixTests(RepositoryPackage package, Directory testTempDir) async {
    // Copy the test_fixes folder to the temporary testTempDir.
    //
    // This also creates the proper pubspec.yaml in the temp directory.
    await _prepareTemplate(package: package, testTempDir: testTempDir);

    // Run dart pub get in the temp directory to set it up.
    final int pubGetStatusCode = await _runProcess('dart', <String>[
      'pub',
      'get',
    ], workingDirectory: testTempDir.path);

    if (pubGetStatusCode != 0) {
      await testTempDir.delete(recursive: true);
      return pubGetStatusCode;
    }

    // Run dart fix --compare-to-golden in the temp directory.
    final int dartFixStatusCode = await _runProcess('dart', <String>[
      'fix',
      '--compare-to-golden',
    ], workingDirectory: testTempDir.path);

    await testTempDir.delete(recursive: true);
    return dartFixStatusCode;
  }

  Future<void> _prepareTemplate({
    required RepositoryPackage package,
    required Directory testTempDir,
  }) async {
    // Copy from src `test_fixes/` to the temp directory.
    await io.copyPath(package.dartFixTestDirectory.path, testTempDir.path);

    // The pubspec.yaml file to create.
    const fileSystem = LocalFileSystem();
    final File targetPubspecFile = fileSystem.file(p.join(testTempDir.path, 'pubspec.yaml'));

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
  }

  Future<int> _runProcess(
    String command,
    List<String> arguments, {
    String? workingDirectory,
  }) async {
    final Process process = await _streamOutput(
      Process.start(command, arguments, workingDirectory: workingDirectory),
    );
    return process.exitCode;
  }

  Future<Process> _streamOutput(Future<Process> processFuture) async {
    final Process process = await processFuture;
    unawaited(stdout.addStream(process.stdout));
    unawaited(stderr.addStream(process.stderr));
    return process;
  }
}
