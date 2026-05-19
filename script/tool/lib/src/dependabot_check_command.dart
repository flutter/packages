// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file/file.dart';

import 'common/package_looping_command.dart';
import 'common/repository_package.dart';
import 'validators/dependabot_validator.dart';

/// A command to verify Dependabot configuration coverage of packages.
class DependabotCheckCommand extends PackageLoopingCommand {
  /// Creates Dependabot check command instance.
  DependabotCheckCommand(super.packagesDir, {super.gitDir});

  late Directory _repoRoot;

  // The set of directories covered by the repo's Dependabot configuration.
  late DependabotCoverage _coverage;

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

    _coverage = DependabotValidator.loadConfig(repoRoot: _repoRoot);
  }

  @override
  Future<PackageResult> runForPackage(RepositoryPackage package) async {
    final validator = DependabotValidator(
      coverage: _coverage,
      path: path,
      repoRoot: _repoRoot,
      indentation: indentation,
    );

    final errors = <String>[];

    errors.addAll(validator.validateDependabotCoverage(package));

    // TODO(stuartmorgan): Add other ecosystem checks here as more are enabled.

    return errors.isEmpty
        ? PackageResult.success()
        : PackageResult.fail(errors);
  }
}
