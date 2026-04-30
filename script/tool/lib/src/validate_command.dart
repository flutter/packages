// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file/file.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

import 'common/core.dart';
import 'common/file_utils.dart';
import 'common/output_utils.dart';
import 'common/package_looping_command.dart';
import 'common/repository_package.dart';
import 'validators/dependabot_validator.dart';
import 'validators/gradle_validator.dart';
import 'validators/pubspec_validator.dart';
import 'validators/repo_info_validator.dart';

/// The set of possible validators.
///
/// Exposed for testing so that unit tests can target a single validator's
/// behavior via the command without having to set everything required for
/// every other validator to pass.
///
/// This is done instead of testing validators directly to ensure that testing
/// includes things like command line parsing and run initialization.
@visibleForTesting
// ignore: public_member_api_docs
enum Validator { dependabot, repoInfo, gradle, pubspec }

// Config file names.
const String _versionConfigFileName = 'min_version.yaml';
const String _allowedPinnedDependenciesFileName =
    'allowed_pinned_dependencies.yaml';
const String _allowedUnpinnedDependenciesFileName =
    'allowed_unpinned_dependencies.yaml';

const int _exitCodeVersionConfigIssue = 3;

/// A command to validate that packages follow various team conventions,
/// guidelines, and best practices.
///
/// This includes:
/// - repository-level metadata about packages, such as repo README and
///   auto-label entries
/// - pubspec format and contents
/// - dependabot configuration coverage
/// - gradle configurations
class ValidateCommand extends PackageLoopingCommand {
  /// Creates Dependabot check command instance.
  ValidateCommand(
    super.packagesDir, {
    this.targetedValidators,
    super.processRunner,
    super.platform,
    super.gitDir,
  });

  /// The validators to run.
  ///
  /// If null, all validators are run.
  final Set<Validator>? targetedValidators;

  late Directory _repoRoot;

  /// Data from the root README.md table of packages.
  final Map<String, List<String>> _readmeTableEntries =
      <String, List<String>>{};

  /// Packages with entries in labeler.yml.
  final Set<String> _autoLabeledPackages = <String>{};

  /// The set of directories covered by the repo's Dependabot configuration.
  late DependabotCoverage _dependabotCoverage;

  /// The set of packages that are allowed as dependencies.
  final AllowPackageLists _allowedPackages = (
    local: <String>{},
    pinned: <String>{},
    unpinned: <String>{},
  );

  /// The minimum version of Flutter that is allowed for any package.
  late final String _minMinFlutterVersion;

  @override
  final String name = 'validate';

  @override
  final String description = 'Checks that packages follow team guidelines.';

  @override
  final PackageLoopingType packageLoopingType =
      PackageLoopingType.includeAllSubpackages;

  @override
  final bool hasLongOutput = false;

  @override
  Future<void> initializeRun() async {
    _repoRoot = packagesDir.fileSystem.directory((await gitDir).path);

    if (_shouldRun(Validator.repoInfo)) {
      // Extract all of the repo-level README.md table entries.
      _readmeTableEntries.addAll(
        RepoInfoValidator.loadReadmeTableEntries(
          repoRoot: _repoRoot,
          packagesDir: packagesDir,
          thirdPartyPackagesDir: thirdPartyPackagesDir,
        ),
      );
      // Extract all of the labeler.yml package entries.
      _autoLabeledPackages.addAll(
        RepoInfoValidator.loadAutoLabeledPackages(repoRoot: _repoRoot),
      );
    }
    if (_shouldRun(Validator.pubspec)) {
      await _loadAllowedDependencies();
      _minMinFlutterVersion = await _loadMinMinFlutterVersion();
    }
    if (_shouldRun(Validator.dependabot)) {
      _dependabotCoverage = DependabotValidator.loadConfig(repoRoot: _repoRoot);
    }
  }

  @override
  Future<PackageResult> runForPackage(RepositoryPackage package) async {
    final List<String> errors = [
      if (_shouldRun(Validator.repoInfo)) ...await _validateRepoInfo(package),
      if (_shouldRun(Validator.pubspec)) ...await _validatePubspec(package),
      if (_shouldRun(Validator.dependabot))
        ...await _validateDependabot(package),
      if (_shouldRun(Validator.gradle)) ...await _validateGradle(package),
    ];

    return errors.isEmpty
        ? PackageResult.success()
        : PackageResult.fail(errors);
  }

  bool _shouldRun(Validator validator) =>
      targetedValidators?.contains(validator) ?? true;

  /// Runs repo-level checks.
  Future<List<String>> _validateRepoInfo(RepositoryPackage package) async {
    // Repo-level checks only apply to top-level packages.
    if (!package.isTopLevel) {
      return <String>[];
    }
    final validator = RepoInfoValidator(
      readmeTableEntries: _readmeTableEntries,
      autoLabeledPackages: _autoLabeledPackages,
      gitDir: await gitDir,
      indentation: indentation,
    );
    return validator.validatePackage(package);
  }

  Future<List<String>> _validateDependabot(RepositoryPackage package) async {
    final validator = DependabotValidator(
      coverage: _dependabotCoverage,
      path: path,
      repoRoot: _repoRoot,
      indentation: indentation,
    );
    return validator.validateDependabotCoverage(package);
  }

  Future<List<String>> _validateGradle(RepositoryPackage package) async {
    if (!package.platformDirectory(FlutterPlatform.android).existsSync()) {
      return [];
    }

    final validator = GradleValidator(path: path, indentation: indentation);
    return validator.validateGradle(package);
  }

  Future<List<String>> _validatePubspec(RepositoryPackage package) async {
    final validator = PubspecValidator(
      path: path,
      indentation: indentation,
      warningLogger: printWarning,
      allowedPackages: _allowedPackages,
      repoRoot: packagesDir.parent,
      minMinFlutterVersion: _minMinFlutterVersion,
    );
    return validator.validatePubspec(package);
  }

  Stream<String> _findAllPublishedPackages() async* {
    for (final File pubspecFile
        in (await _repoRoot.list(recursive: true, followLinks: false).toList())
            .whereType<File>()
            .where(
              (File entity) => p.basename(entity.path) == 'pubspec.yaml',
            )) {
      final Pubspec? pubspec = _tryParsePubspec(pubspecFile.readAsStringSync());
      if (pubspec != null && pubspec.publishTo != 'none') {
        yield pubspec.name;
      }
    }
  }

  Future<void> _loadAllowedDependencies() async {
    final Directory toolConfigDir = toolConfigDirectory(_repoRoot);

    // Find all local, published packages.
    _allowedPackages.local.addAll(await _findAllPublishedPackages().toList());
    // Load explicitly allowed packages.
    _allowedPackages.unpinned.addAll(
      loadYamlList(
            toolConfigDir.childFile(_allowedUnpinnedDependenciesFileName),
          ) ??
          <String>[],
    );
    _allowedPackages.pinned.addAll(
      loadYamlList(
            toolConfigDir.childFile(_allowedPinnedDependenciesFileName),
          ) ??
          <String>[],
    );
  }

  Future<String> _loadMinMinFlutterVersion() async {
    final File versionConfig = toolConfigDirectory(
      _repoRoot,
    ).childFile(_versionConfigFileName);
    if (!versionConfig.existsSync()) {
      printError(
        'Minimum version configuration file not found at $_versionConfigFileName',
      );
      return '';
    }
    const minFlutterKey = 'min_flutter';
    final config = loadYaml(versionConfig.readAsStringSync()) as YamlMap?;
    if (config == null || config[minFlutterKey] == null) {
      printError(
        '$_versionConfigFileName must be a map containing a "$minFlutterKey" entry',
      );
      throw ToolExit(_exitCodeVersionConfigIssue);
    }
    return (config[minFlutterKey] as String).trim();
  }

  Pubspec? _tryParsePubspec(String pubspecContents) {
    try {
      return Pubspec.parse(pubspecContents);
    } on Exception catch (exception) {
      print('  Cannot parse pubspec.yaml: $exception');
    }
    return null;
  }
}
