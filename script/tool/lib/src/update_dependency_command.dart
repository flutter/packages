// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file/file.dart';
import 'package:http/http.dart' as http;
import 'package:pub_semver/pub_semver.dart';
import 'package:pubspec_parse/pubspec_parse.dart';
import 'package:yaml_edit/yaml_edit.dart';

import 'common/core.dart';
import 'common/package_looping_command.dart';
import 'common/pub_version_finder.dart';
import 'common/repository_package.dart';

const int _exitIncorrectTargetDependency = 3;
const int _exitNoTargetVersion = 4;

/// A command to update a dependency in packages.
///
/// This is intended to expand over time to support any sort of dependency that
/// packages use, including pub packages and native dependencies, and should
/// include any tasks related to the dependency (e.g., regenerating files when
/// updating a dependency that is responsible for code generation).
class UpdateDependencyCommand extends PackageLoopingCommand {
  /// Creates an instance of the version check command.
  UpdateDependencyCommand(
    Directory packagesDir, {
    http.Client? httpClient,
  })  : _pubVersionFinder =
            PubVersionFinder(httpClient: httpClient ?? http.Client()),
        super(packagesDir) {
    argParser.addOption(
      _pubPackageFlag,
      help: 'A pub package to update.',
    );
    argParser.addOption(
      _versionFlag,
      help: 'The version to update to.\n\n'
          '- For pub, defaults to the latest published version if not '
          'provided. This can be any constraint that pubspec.yaml allows; a '
          'specific version will be treated as the exact version for '
          'dependencies that are alread pinned, or a ^ range for those that '
          'are unpinned.',
    );
  }

  static const String _pubPackageFlag = 'pub-package';
  static const String _versionFlag = 'version';

  final PubVersionFinder _pubVersionFinder;

  late final String? _targetPubPackage;
  late final String _targetVersion;

  @override
  final String name = 'update-dependency';

  @override
  final String description = 'Updates a dependency in a package.';

  @override
  bool get hasLongOutput => false;

  @override
  PackageLoopingType get packageLoopingType =>
      PackageLoopingType.includeAllSubpackages;

  @override
  Future<void> initializeRun() async {
    const Set<String> targetFlags = <String>{_pubPackageFlag};
    final Set<String> passedTargetFlags =
        targetFlags.where((String flag) => argResults![flag] != null).toSet();
    if (passedTargetFlags.length != 1) {
      printError(
          'Exactly one of the target flags must be provided: (${targetFlags.join(', ')})');
      throw ToolExit(_exitIncorrectTargetDependency);
    }
    _targetPubPackage = getNullableStringArg(_pubPackageFlag);
    if (_targetPubPackage != null) {
      final String? version = getNullableStringArg(_versionFlag);
      if (version == null) {
        final PubVersionFinderResponse response = await _pubVersionFinder
            .getPackageVersion(packageName: _targetPubPackage!);
        switch (response.result) {
          case PubVersionFinderResult.success:
            _targetVersion = response.versions.first.toString();
            break;
          case PubVersionFinderResult.fail:
            printError('''
Error fetching $_targetPubPackage version from pub: ${response.httpResponse.statusCode}:
${response.httpResponse.body}
''');
            throw ToolExit(_exitNoTargetVersion);
          case PubVersionFinderResult.noPackageFound:
            printError('$_targetPubPackage does not exist on pub');
            throw ToolExit(_exitNoTargetVersion);
        }
      } else {
        _targetVersion = version;
      }
    }
  }

  @override
  Future<void> completeRun() async {
    _pubVersionFinder.httpClient.close();
  }

  @override
  Future<PackageResult> runForPackage(RepositoryPackage package) async {
    if (_targetPubPackage != null) {
      return _runForPubDependency(package, _targetPubPackage!);
    }
    // TODO(stuartmorgan): Add othe dependency types here (e.g., maven).

    return PackageResult.fail();
  }

  /// Handles all of the updates for [package] when the target dependency is
  /// a pub dependency.
  Future<PackageResult> _runForPubDependency(
      RepositoryPackage package, String dependency) async {
    final _PubDependencyInfo? dependencyInfo =
        _getPubDependencyInfo(package, dependency);
    if (dependencyInfo == null) {
      return PackageResult.skip('Does not depend on $dependency');
    } else if (!dependencyInfo.hosted) {
      return PackageResult.skip('$dependency in not a hosted dependency');
    }

    final String sectionKey = dependencyInfo.type == _PubDependencyType.dev
        ? 'dev_dependencies'
        : 'dependencies';
    final String versionString;
    final VersionConstraint parsedConstraint =
        VersionConstraint.parse(_targetVersion);
    // If the provided string was a constraint, or if it's a specific
    // version but the package has a pinned dependency, use it as-is.
    if (dependencyInfo.pinned ||
        parsedConstraint is! VersionRange ||
        parsedConstraint.min != parsedConstraint.max) {
      versionString = _targetVersion;
    } else {
      // Otherwise, it's a specific version; treat it as '^version'.
      final Version minVersion = parsedConstraint.min!;
      versionString = '^$minVersion';
    }

    print('${indentation}Updating to "$versionString"');
    if (versionString == dependencyInfo.constraintString) {
      return PackageResult.skip('Already depends on $versionString');
    }
    final YamlEditor editablePubspec =
        YamlEditor(package.pubspecFile.readAsStringSync());
    editablePubspec.update(
      <String>[sectionKey, dependency],
      versionString,
    );
    package.pubspecFile.writeAsStringSync(editablePubspec.toString());

    // TODO(stuartmorgan): Add additionally handling of known packages that
    // do file generation (mockito, pigeon, etc.).

    return PackageResult.success();
  }

  /// Returns information about the current dependency of [package] on
  /// the package named [dependencyName], or null if there is no dependency.
  _PubDependencyInfo? _getPubDependencyInfo(
      RepositoryPackage package, String dependencyName) {
    final Pubspec pubspec = package.parsePubspec();

    Dependency? dependency;
    final _PubDependencyType type;
    if (pubspec.dependencies.containsKey(dependencyName)) {
      dependency = pubspec.dependencies[dependencyName];
      type = _PubDependencyType.normal;
    } else if (pubspec.devDependencies.containsKey(dependencyName)) {
      dependency = pubspec.devDependencies[dependencyName];
      type = _PubDependencyType.dev;
    } else {
      return null;
    }
    if (dependency != null && dependency is HostedDependency) {
      final VersionConstraint version = dependency.version;
      return _PubDependencyInfo(
        type,
        pinned: version is VersionRange && version.min == version.max,
        hosted: true,
        constraintString: version.toString(),
      );
    }
    return _PubDependencyInfo(type, pinned: false, hosted: false);
  }
}

class _PubDependencyInfo {
  const _PubDependencyInfo(this.type,
      {required this.pinned, required this.hosted, this.constraintString});
  final _PubDependencyType type;
  final bool pinned;
  final bool hosted;
  final String? constraintString;
}

enum _PubDependencyType { normal, dev }
