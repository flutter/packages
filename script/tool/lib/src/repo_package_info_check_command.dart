// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file/file.dart';

import 'common/package_looping_command.dart';
import 'common/repository_package.dart';
import 'validators/repo_info_validator.dart';

/// A command to verify repository-level metadata about packages, such as
/// repo README and auto-label entries.
class RepoPackageInfoCheckCommand extends PackageLoopingCommand {
  /// Creates Dependabot check command instance.
  RepoPackageInfoCheckCommand(super.packagesDir, {super.gitDir});

  late Directory _repoRoot;

  /// Data from the root README.md table of packages.
  final Map<String, List<String>> _readmeTableEntries =
      <String, List<String>>{};

  /// Packages with entries in labeler.yml.
  final Set<String> _autoLabeledPackages = <String>{};

  @override
  final String name = 'repo-package-info-check';

  @override
  List<String> get aliases => <String>['check-repo-package-info'];

  @override
  final String description =
      'Checks that all packages are listed correctly in repo metadata.';

  @override
  final bool hasLongOutput = false;

  @override
  Future<void> initializeRun() async {
    _repoRoot = packagesDir.fileSystem.directory((await gitDir).path);

    // Extract all of the README.md table entries.
    _readmeTableEntries.addAll(
      RepoInfoValidator.loadReadmeTableEntries(
        repoRoot: _repoRoot,
        packagesDir: packagesDir,
        thirdPartyPackagesDir: thirdPartyPackagesDir,
      ),
    );
    // Extract all of the lebeler.yml package entries.
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
