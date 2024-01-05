// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file/file.dart';

import 'common/core.dart';
import 'common/output_utils.dart';
import 'common/package_looping_command.dart';
import 'common/repository_package.dart';

const int _exitBadTableEntry = 3;
const int _exitUknownPackageEntry = 4;

/// A command to verify repository-level metadata about packages, such as
/// repo README and CODEOWNERS entries.
class RepoPackageInfoCheckCommand extends PackageLoopingCommand {
  /// Creates Dependabot check command instance.
  RepoPackageInfoCheckCommand(super.packagesDir, {super.gitDir});

  late Directory _repoRoot;

  final Map<String, List<String>> _readmeTableEntries =
      <String, List<String>>{};

  @override
  final String name = 'repo-package-info-check';

  @override
  List<String> get aliases => <String>['check-repo-package-info'];

  @override
  final String description =
      'Checks that all packages are listed correctly in the repo README.';

  @override
  final bool hasLongOutput = false;

  @override
  Future<void> initializeRun() async {
    _repoRoot = packagesDir.fileSystem.directory((await gitDir).path);

    final RegExp namePattern = RegExp(r'\[(.*?)\]\(');
    for (final String line
        in _repoRoot.childFile('README.md').readAsLinesSync()) {
      // Find all the table entries, skipping the header.
      if (line.startsWith('|') &&
          !line.startsWith('| Package') &&
          !line.startsWith('|-')) {
        final List<String> cells = line
            .split('|')
            .map((String s) => s.trim())
            .where((String s) => s.isNotEmpty)
            .toList();
        // Extract the name, removing any markdown escaping.
        final String? name =
            namePattern.firstMatch(cells[0])?.group(1)?.replaceAll(r'\_', '_');
        if (name == null) {
          printError('Unexpected README table line:\n  $line');
          throw ToolExit(_exitBadTableEntry);
        }
        _readmeTableEntries[name] = cells;

        if (!(packagesDir.childDirectory(name).existsSync() ||
            thirdPartyPackagesDir.childDirectory(name).existsSync())) {
          printError('Uknown package "$name" in README table.');
          throw ToolExit(_exitUknownPackageEntry);
        }
      }
    }
  }

  @override
  Future<PackageResult> runForPackage(RepositoryPackage package) async {
    final List<String> errors = <String>[];

    // All packages should have

    // Any published package should be in the README table.
    // For federated plugins, only the app-facing package is listed.
    if (package.isPublishable() &&
        (!package.isFederated || package.isAppFacing)) {
      if (!_readmeTableEntries.containsKey(package.directory.basename)) {
        printError('${indentation}Missing table entry');
        errors.add('Missing table entry');
      }
    }

    return errors.isEmpty
        ? PackageResult.success()
        : PackageResult.fail(errors);
  }
}
