// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io' as io;
import 'dart:math' as math;

import 'package:file/file.dart';
import 'package:git/git.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:yaml_edit/yaml_edit.dart';

import 'common/core.dart';
import 'common/output_utils.dart';
import 'common/package_command.dart';
import 'common/repository_package.dart';

const int _kExitPackageMalformed = 3;
const int _kGitFailedToPush = 4;

/// A command to create a remote branch with release changes for a single package.
class BranchForBatchReleaseCommand extends PackageCommand {
  /// Creates a new `branch-for-batch-release` command.
  BranchForBatchReleaseCommand(
    super.packagesDir, {
    super.processRunner,
    super.platform,
    super.gitDir,
  }) {
    argParser.addOption(
      'branch',
      mandatory: true,
      abbr: 'b',
      help: 'The branch name to contain the release commit',
    );
    argParser.addOption(
      'remote',
      mandatory: true,
      abbr: 'r',
      help: 'The remote to push the branch to.',
    );
  }

  @override
  final String name = 'branch-for-batch-release';

  @override
  final String description = 'Creates a release PR for a single package.';

  @override
  Future<void> run() async {
    final String branchName = getStringArg('branch');
    final String remoteName = getStringArg('remote');

    final List<RepositoryPackage> packages = await getTargetPackages()
        .map((PackageEnumerationEntry e) => e.package)
        .toList();
    if (packages.length != 1) {
      printError('Exactly one package must be specified.');
      throw ToolExit(2);
    }
    final RepositoryPackage package = packages.single;

    final GitDir repository = await gitDir;

    print('Parsing package "${package.displayName}"...');
    final List<PendingChangelogEntry> pendingChangelogs;
    try {
      pendingChangelogs = package.getPendingChangelogs();
    } on FormatException catch (e) {
      printError('Failed to parse pending changelogs: ${e.message}');
      throw ToolExit(_kExitPackageMalformed);
    }

    if (pendingChangelogs.isEmpty) {
      print('No pending changelogs found for ${package.displayName}.');
      return;
    }

    final pubspec = Pubspec.parse(package.pubspecFile.readAsStringSync());
    if (pubspec.version == null || pubspec.version!.major < 1) {
      printError(
        'This script only supports packages with version >= 1.0.0. Current version: ${pubspec.version}.',
      );
      throw ToolExit(_kExitPackageMalformed);
    }
    final _ReleaseInfo releaseInfo = _getReleaseInfo(
      pendingChangelogs,
      pubspec.version!,
    );

    if (releaseInfo.newVersion == null) {
      print(
        'No version change specified in pending changelogs for '
        '${package.displayName}.',
      );
      return;
    }

    await _generateCommitAndBranch(
      git: repository,
      package: package,
      branchName: branchName,
      pendingChangelogFiles: pendingChangelogs
          .map<File>((PendingChangelogEntry e) => e.file)
          .toList(),
      releaseInfo: releaseInfo,
      remoteName: remoteName,
    );
  }

  /// Returns the release info for the given package.
  ///
  /// This method read through the parsed changelog entries decide the new version
  /// by following the version change rules. See [_VersionChange] for more details.
  _ReleaseInfo _getReleaseInfo(
    List<PendingChangelogEntry> pendingChangelogEntries,
    Version oldVersion,
  ) {
    final List<String> changelogs = <String>[];
    int versionIndex = VersionChange.skip.index;
    for (final PendingChangelogEntry entry in pendingChangelogEntries) {
      changelogs.add(entry.changelog);
      versionIndex = math.min(versionIndex, entry.version.index);
    }
    final VersionChange effectiveVersionChange =
        VersionChange.values[versionIndex];

    final Version? newVersion = switch (effectiveVersionChange) {
      VersionChange.skip => null,
      VersionChange.major => Version(oldVersion.major + 1, 0, 0),
      VersionChange.minor => Version(oldVersion.major, oldVersion.minor + 1, 0),
      VersionChange.patch => Version(
        oldVersion.major,
        oldVersion.minor,
        oldVersion.patch + 1,
      ),
    };
    return _ReleaseInfo(newVersion, changelogs);
  }

  /// Creates a branch with a commit contains the changes for the release.
  ///
  /// This method will create a new branch, update the pubspec.yaml, update the changelog,
  /// remove the pending changelog files, stage the changes, and commit them.
  ///
  /// Throws a [ToolExit] if any of the steps fail.
  Future<void> _generateCommitAndBranch({
    required GitDir git,
    required RepositoryPackage package,
    required String branchName,
    required List<File> pendingChangelogFiles,
    required _ReleaseInfo releaseInfo,
    required String remoteName,
  }) async {
    print('  Creating new branch "$branchName"...');
    final io.ProcessResult checkoutResult = await git.runCommand(<String>[
      'checkout',
      '-b',
      branchName,
    ]);
    if (checkoutResult.exitCode != 0) {
      printError(
        'Failed to create branch $branchName: ${checkoutResult.stderr}',
      );
      throw ToolExit(_kGitFailedToPush);
    }

    _updatePubspec(package, releaseInfo.newVersion!);
    _updateChangelog(package, releaseInfo);
    await _stageAndCommitChanges(git, package, pendingChangelogFiles);
    await _pushBranch(git, remoteName, branchName);
  }

  void _updatePubspec(RepositoryPackage package, Version newVersion) {
    final editablePubspec = YamlEditor(package.pubspecFile.readAsStringSync());
    editablePubspec.update(<String>['version'], newVersion.toString());
    package.pubspecFile.writeAsStringSync(editablePubspec.toString());
  }

  void _updateChangelog(RepositoryPackage package, _ReleaseInfo releaseInfo) {
    final newHeader = '## ${releaseInfo.newVersion}';
    final List<String> newEntries = releaseInfo.changelogs;

    String oldChangelogContent = package.changelogFile.readAsStringSync();
    final newChangelog = StringBuffer();

    // If the changelog starts with ## NEXT, replace it with the new version
    // and append the new entries.
    final nextSection = RegExp(r'^\s*## NEXT[ \t]*(\r?\n)*');
    final Match? match = nextSection.firstMatch(oldChangelogContent);
    if (match != null) {
      final replacement = '$newHeader\n\n${newEntries.join('\n')}\n';
      oldChangelogContent = oldChangelogContent.replaceRange(
        match.start,
        match.end,
        replacement,
      );
      newChangelog.write(oldChangelogContent);
    } else {
      newChangelog.writeln(newHeader);
      newChangelog.writeln();
      newChangelog.writeln(newEntries.join('\n'));
      newChangelog.writeln();
      newChangelog.write(oldChangelogContent);
    }

    package.changelogFile.writeAsStringSync(newChangelog.toString());
  }

  Future<void> _stageAndCommitChanges(
    GitDir git,
    RepositoryPackage package,
    List<File> pendingChangelogFiles,
  ) async {
    final List<String> paths = pendingChangelogFiles
        .map((File f) => f.path)
        .toList();
    final io.ProcessResult rmResult = await git.runCommand(<String>[
      'rm',
      ...paths,
    ]);
    if (rmResult.exitCode != 0) {
      printError('Failed to rm ${paths.join(' ')}: ${rmResult.stderr}');
      throw ToolExit(_kGitFailedToPush);
    }

    final io.ProcessResult addResult = await git.runCommand(<String>[
      'add',
      package.pubspecFile.path,
      package.changelogFile.path,
    ]);
    if (addResult.exitCode != 0) {
      printError('Failed to git add: ${addResult.stderr}');
      throw ToolExit(_kGitFailedToPush);
    }

    final io.ProcessResult commitResult = await git.runCommand(<String>[
      'commit',
      '-m',
      '[${package.displayName}] Prepare for batch release',
    ]);
    if (commitResult.exitCode != 0) {
      printError('Failed to commit: ${commitResult.stderr}');
      throw ToolExit(_kGitFailedToPush);
    }
  }

  Future<void> _pushBranch(
    GitDir git,
    String remoteName,
    String branchName,
  ) async {
    print('  Pushing branch $branchName to remote $remoteName...');
    final io.ProcessResult pushResult = await git.runCommand(<String>[
      'push',
      remoteName,
      branchName,
    ]);
    if (pushResult.exitCode != 0) {
      printError('Failed to push to $branchName: ${pushResult.stderr}');
      throw ToolExit(_kGitFailedToPush);
    }
  }
}

/// A data class for processed release information.
class _ReleaseInfo {
  /// Creates a new instance.
  _ReleaseInfo(this.newVersion, this.changelogs);

  /// The new version for the release, or null if there is no version change.
  final Version? newVersion;

  /// The combined changelog entries.
  final List<String> changelogs;
}
