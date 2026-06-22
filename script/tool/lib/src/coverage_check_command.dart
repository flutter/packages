// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io' as io;

import 'package:file/file.dart';
import 'package:yaml/yaml.dart';

import 'common/package_looping_command.dart';
import 'common/repository_package.dart';

/// A command to run coverage checks on changed packages.
class CoverageCheckCommand extends PackageLoopingCommand {
  /// Creates an instance of the coverage check command.
  CoverageCheckCommand(super.packagesDir, {super.processRunner, super.platform, super.gitDir});

  @override
  final String name = 'coverage-check';

  @override
  final String description =
      'Checks that code coverage meets the specified minimums '
      'for opted-in packages.';

  @override
  PackageLoopingType get packageLoopingType => PackageLoopingType.includeAllSubpackages;

  final Map<String, double> _customMinimums = <String, double>{};

  @override
  Future<void> initializeRun() async {
    final File minimumsFile = packagesDir.parent
        .childDirectory('script')
        .childDirectory('configs')
        .childFile('custom_coverage_minimums.yaml');
    if (minimumsFile.existsSync()) {
      final minimumsConfig = loadYaml(minimumsFile.readAsStringSync()) as YamlMap;
      final packageMap = minimumsConfig['custom_coverage_minimums'] as YamlMap?;
      if (packageMap != null) {
        for (final MapEntry<dynamic, dynamic> entry in packageMap.entries) {
          _customMinimums[entry.key as String] = (entry.value as num).toDouble();
        }
      }
    }
  }

  @override
  Future<PackageResult> runForPackage(RepositoryPackage package) async {
    // Only run for first-party packages.
    if (!package.directory.path.contains(
          '${packagesDir.fileSystem.path.separator}packages${packagesDir.fileSystem.path.separator}',
        ) &&
        !package.directory.path.endsWith('${packagesDir.fileSystem.path.separator}packages')) {
      return PackageResult.skip('Not a first-party package.');
    }

    if (!package.testDirectory.existsSync()) {
      return PackageResult.skip('No test/ directory.');
    }

    final String packageName = package.directory.basename;

    if (!_customMinimums.containsKey(packageName)) {
      return PackageResult.skip('Package not opted into coverage checks.');
    }

    // Run tests on current branch.
    final double? currentCoverage = await _runCoverageAndParse(package);
    if (currentCoverage == null) {
      return PackageResult.fail(<String>['Failed to run tests or parse coverage on HEAD']);
    }

    final double requiredCoverage = _customMinimums[packageName]!;

    final errors = <String>[];

    if (currentCoverage < requiredCoverage) {
      errors.add(
        'Code coverage for $packageName is ${currentCoverage.toStringAsFixed(1)}%, '
        'which is below the required ${requiredCoverage.toStringAsFixed(1)}%.',
      );
    }

    final Directory coverageDir = package.directory.childDirectory('coverage');
    if (coverageDir.existsSync()) {
      coverageDir.deleteSync(recursive: true);
    }

    if (errors.isNotEmpty) {
      return PackageResult.fail(errors);
    }

    return PackageResult.success();
  }

  Future<double?> _runCoverageAndParse(RepositoryPackage package) async {
    final args = <String>['test', '--coverage'];

    final io.ProcessResult result = await processRunner.run(
      'flutter',
      args,
      workingDir: package.directory,
    );

    if (result.exitCode != 0) {
      print('Test failed for ${package.directory.basename}:\n${result.stdout}\n${result.stderr}');
      return null;
    }

    final File lcovFile = package.directory.childDirectory('coverage').childFile('lcov.info');
    if (!lcovFile.existsSync()) {
      return null;
    }

    return _calculateCoverage(lcovFile);
  }

  double _calculateCoverage(File lcovFile) {
    var linesHit = 0;
    var linesFound = 0;
    var skipCurrentFile = false;

    final List<String> lines = lcovFile.readAsLinesSync();
    for (final line in lines) {
      if (line.startsWith('SF:')) {
        final String fileName = line.substring(3);
        // Skip checking coverage of generated files.
        skipCurrentFile =
            fileName.endsWith('.g.dart') ||
            fileName.endsWith('.pb.dart') ||
            fileName.endsWith('.pigeon.dart') ||
            fileName.endsWith('.mocks.dart') ||
            fileName.endsWith('.freezed.dart');
      } else if (!skipCurrentFile) {
        if (line.startsWith('LH:')) {
          linesHit += int.parse(line.substring(3));
        } else if (line.startsWith('LF:')) {
          linesFound += int.parse(line.substring(3));
        }
      }
    }

    if (linesFound == 0) {
      return 100.0;
    }
    return (linesHit / linesFound) * 100.0;
  }
}
