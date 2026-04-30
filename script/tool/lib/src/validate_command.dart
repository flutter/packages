// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file/file.dart';
import 'package:meta/meta.dart';

import 'common/package_looping_command.dart';
import 'common/repository_package.dart';
import 'validators/dependabot_validator.dart';
import 'validators/gradle_validator.dart';
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
enum Validator { dependabot, repoInfo, gradle }

/// A command to validate that packages follow various team conventions,
/// guidelines, and best practices.
///
/// This includes:
/// - repository-level metadata about packages, such as repo README and
///   auto-label entries
/// - dependabot configuration coverage
/// - gradle configurations
class ValidateCommand extends PackageLoopingCommand {
  /// Creates Dependabot check command instance.
  ValidateCommand(super.packagesDir, {this.targetedValidators, super.gitDir});

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

  // The set of directories covered by the repo's Dependabot configuration.
  late DependabotCoverage _dependabotCoverage;

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
    if (_shouldRun(Validator.dependabot)) {
      _dependabotCoverage = DependabotValidator.loadConfig(repoRoot: _repoRoot);
    }
  }

  @override
  Future<PackageResult> runForPackage(RepositoryPackage package) async {
    final List<String> errors = [
      if (_shouldRun(Validator.repoInfo)) ...await _validateRepoInfo(package),
      if (_shouldRun(Validator.dependabot))
        ...await _validateDependabot(package),
      if (_shouldRun(Validator.gradle)) ...await _validateGradle(package),
    ];

    return errors.isEmpty
        ? PackageResult.success()
        : PackageResult.fail(errors);
  }

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

  bool _shouldRun(Validator validator) =>
      targetedValidators?.contains(validator) ?? true;
}
