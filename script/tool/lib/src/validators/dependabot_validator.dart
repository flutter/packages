// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file/file.dart';
import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart';

import '../common/file_utils.dart';
import '../common/output_utils.dart';
import '../common/repository_package.dart';

/// Directories covered by Dependabot, for various ecosystems.
// TODO(stuartmorgan): Add coverage for other ecosystems.
typedef DependabotCoverage = ({Set<String> gradleDirs});

/// A validator that checks that the Dependabot configuration for a package is
/// correct.
class DependabotValidator {
  /// Creates a new instance of the validator.
  DependabotValidator({
    required DependabotCoverage coverage,
    required path.Context path,
    required Directory repoRoot,
    required String indentation,
  }) : _coverage = coverage,
       _path = path,
       _repoRoot = repoRoot,
       _indentation = indentation;

  final DependabotCoverage _coverage;
  final String _indentation;
  final path.Context _path;
  final Directory _repoRoot;

  /// The path to the Dependabot config file, relative to the repository root.
  static const String _configFilePath = '.github/dependabot.yml';

  /// Loads Dependabot coverage from the repository's configuration file.
  static DependabotCoverage loadConfig({required Directory repoRoot}) {
    final DependabotCoverage coverage = (gradleDirs: <String>{});
    final config =
        loadYaml(repoRoot.childFile(_configFilePath).readAsStringSync())
            as YamlMap;
    final dynamic entries = config['updates'];
    if (entries is YamlList) {
      const typeKey = 'package-ecosystem';
      const dirKey = 'directory';
      const dirsKey = 'directories';
      final Iterable<YamlMap> gradleEntries = entries.cast<YamlMap>().where(
        (YamlMap entry) => entry[typeKey] == 'gradle',
      );
      final Iterable<String?> directoryEntries = gradleEntries.map(
        (YamlMap entry) => entry[dirKey] as String?,
      );
      final Iterable<String?> directoriesEntries = gradleEntries
          .map((YamlMap entry) => entry[dirsKey] as YamlList?)
          .expand((YamlList? list) => list?.nodes ?? <String>[])
          .cast<YamlScalar>()
          .map((YamlScalar entry) => entry.value as String);
      coverage.gradleDirs.addAll(
        directoryEntries.followedBy(directoriesEntries).whereType<String>(),
      );
    }
    return coverage;
  }

  /// Validates that the Dependabot coverage for a package is correct, returning
  /// a list of resulting error strings.
  ///
  /// If no errors are found, an empty list is returned.
  List<String> validateDependabotCoverage(RepositoryPackage package) {
    final errors = <String>[];

    final String? missingGradlePath = _validateDependabotGradleCoverage(
      package,
    );
    if (missingGradlePath != null) {
      printError('${_indentation}Missing Gradle coverage.');
      print(
        '${_indentation}Add a "gradle" entry to $_configFilePath for '
        '$missingGradlePath',
      );
      errors.add('Missing Gradle coverage');
    }

    // TODO(stuartmorgan): Add other ecosystem checks here as more are enabled.

    return errors;
  }

  /// Returns the path of a file that is missing dependabot coverage, if any.
  String? _validateDependabotGradleCoverage(RepositoryPackage package) {
    final Directory androidDir = package.platformDirectory(
      FlutterPlatform.android,
    );
    final Directory appDir = androidDir.childDirectory('app');
    if (appDir.existsSync()) {
      // It's an app, so only check for the app directory to be covered.
      final dependabotPath =
          '/${relativePosixPath(appDir, from: _repoRoot, platformContext: _path)}';
      return _coverage.gradleDirs.contains(dependabotPath)
          ? null
          : dependabotPath;
    } else if (androidDir.existsSync()) {
      // It's a library, so only check for the android directory to be covered.
      final dependabotPath =
          '/${relativePosixPath(androidDir, from: _repoRoot, platformContext: _path)}';
      return _coverage.gradleDirs.contains(dependabotPath)
          ? null
          : dependabotPath;
    }
    return null;
  }
}
