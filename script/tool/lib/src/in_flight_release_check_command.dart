// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:io' as io;

import 'package:git/git.dart';
import 'package:pub_semver/pub_semver.dart';

import 'common/core.dart';
import 'common/output_utils.dart';
import 'common/package_command.dart';
import 'common/repository_package.dart';

const int _kExitPackageMalformed = 3;

const int _kGitFailedToQueryRemote = 6;

/// A command to check whether a new batch release can be cut for a package.
class InFlightReleaseCheckCommand extends PackageCommand {
  /// Creates a new `in-flight-release-check` command.
  InFlightReleaseCheckCommand(
    super.packagesDir, {
    super.processRunner,
    super.platform,
    super.gitDir,
  }) {
    argParser.addOption(
      'remote',
      mandatory: true,
      abbr: 'r',
      help: 'The remote to check for release branches.',
    );
  }

  @override
  final String name = 'in-flight-release-check';

  @override
  final String description =
      'Reports whether an earlier batch release for a package has not been merged back yet.\n\n'
      'A remote `release-<package>-<version>` branch whose version is higher than the version in '
      'the current checkout means an earlier release is still in flight: either its release PR '
      'has not landed, or its sync-back PR has not. Cutting a new release in that state would '
      'branch from history that predates the earlier release, and would re-release pending '
      'changelog entries that have already shipped.\n\n'
      'The blocking branch, if any, is reported as a `blocking_branch` GitHub Actions output. '
      'Finding one is not an error, so that CI can create or nudge the sync-back PR for it; only '
      'a failure to run the check itself is.';

  @override
  Future<void> run() async {
    final String remoteName = getStringArg('remote');

    final List<RepositoryPackage> packages = await getTargetPackages()
        .map((PackageEnumerationEntry e) => e.package)
        .toList();
    if (packages.length != 1) {
      printError('Exactly one package must be specified.');
      throw ToolExit(2);
    }
    final RepositoryPackage package = packages.single;

    final pubspec = Pubspec.parse(package.pubspecFile.readAsStringSync());
    final Version? currentVersion = pubspec.version;
    if (currentVersion == null) {
      printError('The package has no version specified.');
      throw ToolExit(_kExitPackageMalformed);
    }

    final String? blockingBranch = await _findUnmergedReleaseBranch(
      git: await gitDir,
      package: package,
      currentVersion: currentVersion,
      remoteName: remoteName,
    );

    if (blockingBranch == null) {
      print('No in-flight release for ${package.displayName}.');
      return;
    }

    writeGitHubActionsOutput('blocking_branch', blockingBranch);
    printWarning(
      'A new batch release cannot be cut for ${package.displayName}.\n'
      'The remote branch "$blockingBranch" is ahead of the $currentVersion in this checkout, so '
      'an earlier release has not been merged back yet.\n'
      'Releasing now would cut a branch from outdated history, and would re-release changelog '
      'entries that have already shipped.\n'
      'To unblock, land that release and its sync-back PR. If the sync-back PR cannot be landed '
      'as-is, apply its version bump and changelog by hand instead; the release is already '
      'published at that point, so those changes cannot be dropped. Only delete '
      '"$blockingBranch" if its release was never published.',
    );
  }

  /// Returns the highest-versioned release branch for [package] on [remoteName]
  /// that is newer than [currentVersion], or null if there is none.
  Future<String?> _findUnmergedReleaseBranch({
    required GitDir git,
    required RepositoryPackage package,
    required Version currentVersion,
    required String remoteName,
  }) async {
    final branchPrefix = 'release-${package.directory.basename}-';
    final io.ProcessResult result = await git.runCommand(<String>[
      'ls-remote',
      '--heads',
      remoteName,
      'refs/heads/$branchPrefix*',
    ], throwOnError: false);
    if (result.exitCode != 0) {
      printError('Failed to list release branches on $remoteName: ${result.stderr}');
      throw ToolExit(_kGitFailedToQueryRemote);
    }

    String? blockingBranch;
    Version? blockingVersion;
    for (final String line in const LineSplitter().convert(result.stdout as String)) {
      // Each line is "<sha>\t<ref>", e.g. "0123abc\trefs/heads/release-foo-1.0.0".
      final List<String> parts = line.split('\t');
      if (parts.length != 2) {
        continue;
      }
      final String branch = parts[1].trim().replaceFirst('refs/heads/', '');
      if (!branch.startsWith(branchPrefix)) {
        continue;
      }
      final Version version;
      try {
        version = Version.parse(branch.substring(branchPrefix.length));
      } on FormatException {
        // Branches that don't end in a version aren't release branches.
        continue;
      }
      if (version > currentVersion && (blockingVersion == null || version > blockingVersion)) {
        blockingVersion = version;
        blockingBranch = branch;
      }
    }
    return blockingBranch;
  }
}
