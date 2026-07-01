// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io' as io;

import 'package:file/file.dart';
import 'package:meta/meta.dart';
import 'package:yaml/yaml.dart';

import 'common/core.dart';
import 'common/output_utils.dart';
import 'common/package_looping_command.dart';
import 'common/repository_package.dart';

/// A command to run code coverage checks on changed packages.
class CoverageCheckCommand extends PackageLoopingCommand {
  /// Creates a coverage check command instance.
  CoverageCheckCommand(super.packagesDir, {super.processRunner, super.platform, super.gitDir});

  @override
  final String name = 'coverage-check';

  @override
  final String description =
      'Checks that code coverage meets the specified minimums '
      'for opted-in packages as specified in `script/configs/custom_coverage_minimums.yaml`.';

  @override
  PackageLoopingType get packageLoopingType => PackageLoopingType.includeAllSubpackages;

  final Map<String, double> _customMinimums = <String, double>{};

  @override
  Future<void> initializeRun() async {
    final File minimumsFile = packagesDir.parent
        .childDirectory('script')
        .childDirectory('configs')
        .childFile('custom_coverage_minimums.yaml');
    if (!minimumsFile.existsSync()) {
      printError('The custom_coverage_minimums.yaml file is missing.');
      throw ToolExit(1);
    }

    final Object? yaml = loadYaml(minimumsFile.readAsStringSync());
    if (yaml is YamlMap) {
      final Object? packageMap = yaml['custom_coverage_minimums'];
      if (packageMap is YamlMap) {
        for (final MapEntry<dynamic, dynamic> entry in packageMap.entries) {
          final Object? key = entry.key;
          final Object? value = entry.value;
          if (key is String && value is num) {
            _customMinimums[key] = value.toDouble();
          }
        }
      }
    }
  }

  @override
  Future<PackageResult> runForPackage(RepositoryPackage package) async {
    // Only run for first-party packages.
    final List<String> pathComponents = package.directory.fileSystem.path.split(package.path);
    if (pathComponents.contains('third_party')) {
      return PackageResult.skip('Not a first-party package.');
    }

    if (!package.testDirectory.existsSync()) {
      return PackageResult.skip('No test/ directory.');
    }

    final String packageName = package.directory.basename;

    if (!_customMinimums.containsKey(packageName)) {
      return PackageResult.skip('Package not opted into coverage checks.');
    }

    // Collect code coverage for the package.
    double? currentCoverage;
    try {
      currentCoverage = await _runCoverageAndParse(package);
    } on NoLinesFoundException {
      return PackageResult.fail(<String>[
        'No instrumented Dart lines were found in the coverage report for $packageName.',
        'If this package contains no code to cover, please remove it from ',
            'script/configs/custom_coverage_minimums.yaml.',
      ]);
    }

    if (currentCoverage == null) {
      return PackageResult.fail(<String>['Failed to run tests or parse coverage']);
    }
    final double requiredCoverage = _customMinimums[packageName]!;

    if (currentCoverage < requiredCoverage) {
      return PackageResult.fail(<String>[
        'Code coverage for $packageName is ${currentCoverage.toStringAsFixed(1)}%, which is below the required ${requiredCoverage.toStringAsFixed(1)}%.',
      ]);
    }

    return PackageResult.success();
  }

  Future<double?> _runCoverageAndParse(RepositoryPackage package) async {
    final Directory coverageDir = package.directory.childDirectory('coverage');
    try {
      final io.ProcessResult result = await processRunner.run('flutter', <String>[
        'test',
        '--coverage',
      ], workingDir: package.directory);

      if (result.exitCode != 0) {
        print('Test failed for ${package.directory.basename}:\n${result.stdout}\n${result.stderr}');
        return null;
      }

      final File lcovFile = coverageDir.childFile('lcov.info');
      if (!lcovFile.existsSync()) {
        print('Coverage file not found at ${lcovFile.path}.');
        return null;
      }

      return calculateCoverage(lcovFile);
    } finally {
      if (coverageDir.existsSync()) {
        coverageDir.deleteSync(recursive: true);
      }
    }
  }

  /// Calculates code coverage for non-generated code files by finding
  /// the percentage of covered lines of code over the total lines of code.
  @visibleForTesting
  double calculateCoverage(File lcovFile) {
    var linesHit = 0;
    var linesFound = 0;
    var skipCurrentFile = false;

    final List<String> lines = lcovFile.readAsLinesSync();
    for (final line in lines) {
      if (line.startsWith('SF:')) {
        final String fileName = line.substring(3);
        skipCurrentFile = _isGeneratedFile(fileName);
      }
      if (!skipCurrentFile) {
        if (line.startsWith('LH:')) {
          linesHit += int.parse(line.substring(3));
        } else if (line.startsWith('LF:')) {
          linesFound += int.parse(line.substring(3));
        }
      }
    }

    if (linesFound == 0) {
      throw const NoLinesFoundException();
    }
    return (linesHit / linesFound) * 100.0;
  }
}

/// Exception thrown when no instrumented lines are found in the coverage report.
class NoLinesFoundException implements Exception {
  /// Creates a new [NoLinesFoundException].
  const NoLinesFoundException();
}

bool _isGeneratedFile(String fileName) {
  return fileName.endsWith('.g.dart') ||
      fileName.endsWith('.pb.dart') ||
      fileName.endsWith('.mocks.dart');
}
