// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file/file.dart';

import 'common/package_looping_command.dart';
import 'common/repository_package.dart';
import 'validators/repo_info_validator.dart';

/// A command to validate that packages follow various team conventions,
/// guidelines, and best practices.
///
/// This includes:
/// - repository-level metadata about packages, such as repo README and
///   auto-label entries.
class ValidateCommand extends PackageLoopingCommand {
  /// Creates Dependabot check command instance.
  ValidateCommand(super.packagesDir, {super.gitDir});

  late Directory _repoRoot;

  /// Data from the root README.md table of packages.
  final Map<String, List<String>> _readmeTableEntries =
      <String, List<String>>{};

  /// Packages with entries in labeler.yml.
  final Set<String> _autoLabeledPackages = <String>{};

  @override
  final String name = 'validate';

  @override
  final String description = 'Checks that packages follow team guidelines.';

  @override
  final bool hasLongOutput = false;

  @override
  Future<void> initializeRun() async {
    _repoRoot = packagesDir.fileSystem.directory((await gitDir).path);

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

  @override
  Future<PackageResult> runForPackage(RepositoryPackage package) async {
    final validator = RepoInfoValidator(
      readmeTableEntries: _readmeTableEntries,
      autoLabeledPackages: _autoLabeledPackages,
      gitDir: await gitDir,
      indentation: indentation,
    );
    final List<String> errors = await validator.validatePackage(package);

    return errors.isEmpty
        ? PackageResult.success()
        : PackageResult.fail(errors);
  }
}
