// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file/file.dart';
import 'package:yaml/yaml.dart';

import 'common/output_utils.dart';
import 'common/package_looping_command.dart';
import 'common/repository_package.dart';

/// A command to verify Dependabot configuration coverage of packages.
class DependabotCheckCommand extends PackageLoopingCommand {
  /// Creates Dependabot check command instance.
  DependabotCheckCommand(super.packagesDir, {super.gitDir}) {
    argParser.addOption(_configPathFlag,
        help: 'Path to the Dependabot configuration file',
        defaultsTo: '.github/dependabot.yml');
  }

  static const String _configPathFlag = 'config';

  late Directory _repoRoot;

  // The set of directories covered by "gradle" entries in the config.
  Set<String> _gradleDirs = const <String>{};

  @override
  final String name = 'dependabot-check';

  @override
  List<String> get aliases => <String>['check-dependabot'];

  @override
  final String description =
      'Checks that all packages have Dependabot coverage.';

  @override
  final PackageLoopingType packageLoopingType =
      PackageLoopingType.includeAllSubpackages;

  @override
  final bool hasLongOutput = false;

  @override
  Future<void> initializeRun() async {
    _repoRoot = packagesDir.fileSystem.directory((await gitDir).path);

    final YamlMap config = loadYaml(_repoRoot
        .childFile(getStringArg(_configPathFlag))
        .readAsStringSync()) as YamlMap;
    final dynamic entries = config['updates'];
    if (entries is! YamlList) {
      return;
    }

    const String typeKey = 'package-ecosystem';
    const String dirKey = 'directory';
    const String dirsKey = 'directories';
    final Iterable<YamlMap> gradleEntries = entries
        .cast<YamlMap>()
        .where((YamlMap entry) => entry[typeKey] == 'gradle');
    final Iterable<String?> directoryEntries =
        gradleEntries.map((YamlMap entry) => entry[dirKey] as String?);
    final Iterable<String?> directoriesEntries = gradleEntries
        .map((YamlMap entry) => entry[dirsKey] as YamlList?)
        .expand((YamlList? list) => list?.nodes ?? <String>[])
        .cast<YamlScalar>()
        .map((YamlScalar entry) => entry.value as String);
    _gradleDirs = directoryEntries
        .followedBy(directoriesEntries)
        .whereType<String>()
        .toSet();
  }

  @override
  Future<PackageResult> runForPackage(RepositoryPackage package) async {
    bool skipped = true;
    final List<String> errors = <String>[];

    final _GradleCoverageResult gradleResult =
        _validateDependabotGradleCoverage(package);
    skipped = skipped && gradleResult.runState == RunState.skipped;
    if (gradleResult.runState == RunState.failed) {
      printError('${indentation}Missing Gradle coverage.');
      print('${indentation}Add a "gradle" entry to '
          '${getStringArg(_configPathFlag)} for ${gradleResult.missingPath}');
      errors.add('Missing Gradle coverage');
    }

    // TODO(stuartmorgan): Add other ecosystem checks here as more are enabled.

    if (skipped) {
      return PackageResult.skip('No supported package ecosystems');
    }
    return errors.isEmpty
        ? PackageResult.success()
        : PackageResult.fail(errors);
  }

  /// Returns the state for the Dependabot coverage of the Gradle ecosystem for
  /// [package]:
  /// - succeeded if it includes gradle and is covered.
  /// - failed if it includes gradle and is not covered.
  /// - skipped if it doesn't include gradle.
  _GradleCoverageResult _validateDependabotGradleCoverage(
      RepositoryPackage package) {
    final Directory androidDir =
        package.platformDirectory(FlutterPlatform.android);
    final Directory appDir = androidDir.childDirectory('app');
    if (appDir.existsSync()) {
      // It's an app, so only check for the app directory to be covered.
      final String dependabotPath =
          '/${getRelativePosixPath(appDir, from: _repoRoot)}';
      return _gradleDirs.contains(dependabotPath)
          ? _GradleCoverageResult(RunState.succeeded)
          : _GradleCoverageResult(RunState.failed, missingPath: dependabotPath);
    } else if (androidDir.existsSync()) {
      // It's a library, so only check for the android directory to be covered.
      final String dependabotPath =
          '/${getRelativePosixPath(androidDir, from: _repoRoot)}';
      return _gradleDirs.contains(dependabotPath)
          ? _GradleCoverageResult(RunState.succeeded)
          : _GradleCoverageResult(RunState.failed, missingPath: dependabotPath);
    }
    return _GradleCoverageResult(RunState.skipped);
  }
}

class _GradleCoverageResult {
  _GradleCoverageResult(this.runState, {this.missingPath});

  final RunState runState;
  final String? missingPath;
}
