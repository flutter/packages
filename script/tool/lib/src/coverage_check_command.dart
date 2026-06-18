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
      'Checks that code coverage does not decrease and stays above 60% '
      'for modified packages.';

  @override
  PackageLoopingType get packageLoopingType => PackageLoopingType.includeAllSubpackages;

  final Set<String> _exceptions = <String>{};

  @override
  Future<void> initializeRun() async {
    final File exceptionsFile = packagesDir.parent
        .childDirectory('script')
        .childDirectory('configs')
        .childFile('coverage_exceptions.yaml');
    if (exceptionsFile.existsSync()) {
      final exceptionsConfig = loadYaml(exceptionsFile.readAsStringSync()) as YamlMap;
      final packageList = exceptionsConfig['coverage_exceptions'] as YamlList?;
      if (packageList != null) {
        _exceptions.addAll(packageList.map((dynamic item) => item as String));
      }
    }
  }

  @override
  Future<PackageResult> runForPackage(RepositoryPackage package) async {
    // Only run for first-party packages (in the 'packages/' directory).
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

    // Run tests on current branch.
    final double? currentCoverage = await _runCoverageAndParse(package);
    if (currentCoverage == null) {
      return PackageResult.fail(<String>['Failed to run tests or parse coverage on HEAD']);
    }

    // Checkout baseSha and run tests.
    final io.ProcessResult stashResult = await processRunner.run('git', <String>[
      'stash',
    ], workingDir: packagesDir.parent);
    final io.ProcessResult checkoutBaseResult = await processRunner.run('git', <String>[
      'checkout',
      baseSha,
    ], workingDir: packagesDir.parent);

    if (checkoutBaseResult.exitCode != 0) {
      return PackageResult.fail(<String>['Failed to checkout base SHA ($baseSha).']);
    }

    final double? baseCoverage = await _runCoverageAndParse(package);

    // Revert checkout
    await processRunner.run('git', <String>['checkout', '-'], workingDir: packagesDir.parent);
    if (stashResult.stdout.toString().contains('Saved working directory')) {
      await processRunner.run('git', <String>['stash', 'pop'], workingDir: packagesDir.parent);
    }

    if (baseCoverage == null) {
      print(
        'Warning: Failed to run tests or parse coverage on base branch for $packageName. Assuming 0% base coverage.',
      );
    }

    final double effectiveBaseCoverage = baseCoverage ?? 0.0;

    final errors = <String>[];

    if (currentCoverage < effectiveBaseCoverage) {
      errors.add(
        'Code coverage decreased from ${effectiveBaseCoverage.toStringAsFixed(1)}% '
        'to ${currentCoverage.toStringAsFixed(1)}%.',
      );
    }

    if (currentCoverage < 60.0) {
      if (_exceptions.contains(packageName)) {
        print(
          'Warning: Code coverage for $packageName is ${currentCoverage.toStringAsFixed(1)}%, '
          'which is below the 60.0% threshold. Allowed by exceptions list.',
        );
      } else {
        errors.add(
          'Code coverage for $packageName is ${currentCoverage.toStringAsFixed(1)}%, '
          'which is below the 60.0% threshold.',
        );
      }
    }

    if (errors.isNotEmpty) {
      return PackageResult.fail(errors);
    }

    return PackageResult.success();
  }

  Future<double?> _runCoverageAndParse(RepositoryPackage package) async {
    final bool isFlutter = package.requiresFlutter();
    final executable = isFlutter ? 'flutter' : 'dart';

    final args = <String>['test', '--coverage'];

    final io.ProcessResult result = await processRunner.run(
      executable,
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

    final List<String> lines = lcovFile.readAsLinesSync();
    for (final line in lines) {
      if (line.startsWith('LH:')) {
        linesHit += int.parse(line.substring(3));
      } else if (line.startsWith('LF:')) {
        linesFound += int.parse(line.substring(3));
      }
    }

    if (linesFound == 0) {
      return 100.0;
    }
    return (linesHit / linesFound) * 100.0;
  }
}
