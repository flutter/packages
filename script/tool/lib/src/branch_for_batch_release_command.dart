// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io' as io;
import 'dart:math' as math;

import 'package:file/file.dart';
import 'package:git/git.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:yaml/yaml.dart';
import 'package:yaml_edit/yaml_edit.dart';

import 'common/core.dart';
import 'common/output_utils.dart';
import 'common/package_command.dart';
import 'common/repository_package.dart';

const int _kExitPackageMalformed = 3;
const int _kGitFailedToPush = 4;

// The template file name used to draft a pending changelog file.
// This file will not be picked up by the batch release process.
const String _kTemplateFileName = 'template.yaml';

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
    final _PendingChangelogs pendingChangelogs =
        await _getPendingChangelogs(package);
    if (pendingChangelogs.entries.isEmpty) {
      print('No pending changelogs found for ${package.displayName}.');
      return;
    }

    final Pubspec pubspec =
        Pubspec.parse(package.pubspecFile.readAsStringSync());
    if (pubspec.version == null || pubspec.version!.major < 1) {
      printError(
          'This script only supports packages with version >= 1.0.0. Current version: ${pubspec.version}. Package: ${package.displayName}.');
      throw ToolExit(_kExitPackageMalformed);
    }
    final _ReleaseInfo releaseInfo =
        _getReleaseInfo(pendingChangelogs.entries, pubspec.version!);

    if (releaseInfo.newVersion == null) {
      print('No version change specified in pending changelogs for '
          '${package.displayName}.');
      return;
    }

    await _generateCommitAndBranch(
      git: repository,
      package: package,
      branchName: branchName,
      pendingChangelogFiles: pendingChangelogs.files,
      releaseInfo: releaseInfo,
      remoteName: remoteName,
    );
  }

  Future<_PendingChangelogs> _getPendingChangelogs(
      RepositoryPackage package) async {
    final Directory pendingChangelogsDir =
        package.directory.childDirectory('pending_changelogs');
    if (!pendingChangelogsDir.existsSync()) {
      printError(
          'No pending_changelogs folder found for ${package.displayName}.');
      throw ToolExit(_kExitPackageMalformed);
    }
    final List<File> pendingChangelogFiles = pendingChangelogsDir
        .listSync()
        .whereType<File>()
        .where((File f) =>
            f.basename.endsWith('.yaml') && f.basename != _kTemplateFileName)
        .toList();
    try {
      final List<_PendingChangelogEntry> entries = pendingChangelogFiles
          .map<_PendingChangelogEntry>(
              (File f) => _PendingChangelogEntry.parse(f.readAsStringSync()))
          .toList();
      return _PendingChangelogs(entries, pendingChangelogFiles);
    } on FormatException catch (e) {
      printError('Malformed pending changelog file: $e');
      throw ToolExit(_kExitPackageMalformed);
    }
  }

  _ReleaseInfo _getReleaseInfo(
      List<_PendingChangelogEntry> pendingChangelogEntries,
      Version oldVersion) {
    final List<String> changelogs = <String>[];
    int versionIndex = _VersionChange.skip.index;
    for (final _PendingChangelogEntry entry in pendingChangelogEntries) {
      changelogs.add(entry.changelog);
      versionIndex = math.min(versionIndex, entry.version.index);
    }
    final _VersionChange effectiveVersionChange =
        _VersionChange.values[versionIndex];

    final Version? newVersion = switch (effectiveVersionChange) {
      _VersionChange.skip => null,
      _VersionChange.major => Version(oldVersion.major + 1, 0, 0),
      _VersionChange.minor =>
        Version(oldVersion.major, oldVersion.minor + 1, 0),
      _VersionChange.patch =>
        Version(oldVersion.major, oldVersion.minor, oldVersion.patch + 1),
    };
    return _ReleaseInfo(newVersion, changelogs);
  }

  Future<void> _generateCommitAndBranch({
    required GitDir git,
    required RepositoryPackage package,
    required String branchName,
    required List<File> pendingChangelogFiles,
    required _ReleaseInfo releaseInfo,
    required String remoteName,
  }) async {
    print('  Creating new branch "$branchName"...');
    final io.ProcessResult checkoutResult =
        await git.runCommand(<String>['checkout', '-b', branchName]);
    if (checkoutResult.exitCode != 0) {
      printError(
          'Failed to create branch $branchName: ${checkoutResult.stderr}');
      throw ToolExit(_kGitFailedToPush);
    }

    _updatePubspec(package, releaseInfo.newVersion!);
    _updateChangelog(package, releaseInfo);
    await _removePendingChangelogs(git, pendingChangelogFiles);
    await _stageAndCommitChanges(git, package);
    await _pushBranch(git, remoteName, branchName);
  }

  void _updatePubspec(RepositoryPackage package, Version newVersion) {
    final YamlEditor editablePubspec =
        YamlEditor(package.pubspecFile.readAsStringSync());
    editablePubspec.update(<String>['version'], newVersion.toString());
    package.pubspecFile.writeAsStringSync(editablePubspec.toString());
  }

  void _updateChangelog(RepositoryPackage package, _ReleaseInfo releaseInfo) {
    final String newHeader = '## ${releaseInfo.newVersion}';
    final List<String> newEntries = releaseInfo.changelogs;

    final String oldChangelogContent = package.changelogFile.readAsStringSync();
    final StringBuffer newChangelog = StringBuffer();

    newChangelog.writeln(newHeader);
    newChangelog.writeln();
    newChangelog.writeln(newEntries.join('\n'));
    newChangelog.writeln();
    newChangelog.write(oldChangelogContent);

    package.changelogFile.writeAsStringSync(newChangelog.toString());
  }

  Future<void> _removePendingChangelogs(
      GitDir git, List<File> pendingChangelogFiles) async {
    for (final File file in pendingChangelogFiles) {
      final io.ProcessResult rmResult =
          await git.runCommand(<String>['rm', file.path]);
      if (rmResult.exitCode != 0) {
        printError('Failed to rm ${file.path}: ${rmResult.stderr}');
        throw ToolExit(_kGitFailedToPush);
      }
    }
  }

  Future<void> _stageAndCommitChanges(
      GitDir git, RepositoryPackage package) async {
    final io.ProcessResult addResult = await git.runCommand(
        <String>['add', package.pubspecFile.path, package.changelogFile.path]);
    if (addResult.exitCode != 0) {
      printError('Failed to git add: ${addResult.stderr}');
      throw ToolExit(_kGitFailedToPush);
    }

    final io.ProcessResult commitResult = await git.runCommand(<String>[
      'commit',
      '-m',
      '[${package.displayName}] Prepares for batch release'
    ]);
    if (commitResult.exitCode != 0) {
      printError('Failed to commit: ${commitResult.stderr}');
      throw ToolExit(_kGitFailedToPush);
    }
  }

  Future<void> _pushBranch(
      GitDir git, String remoteName, String branchName) async {
    print('  Pushing branch ${branchName} to remote ${remoteName}...');
    final io.ProcessResult pushResult =
        await git.runCommand(<String>['push', remoteName, branchName]);
    if (pushResult.exitCode != 0) {
      printError('Failed to push to $branchName: ${pushResult.stderr}');
      throw ToolExit(_kGitFailedToPush);
    }
  }
}

/// A data class for pending changelogs.
class _PendingChangelogs {
  /// Creates a new instance.
  _PendingChangelogs(this.entries, this.files);

  /// The parsed pending changelog entries.
  final List<_PendingChangelogEntry> entries;

  /// The files that the pending changelog entries were parsed from.
  final List<File> files;
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

/// The type of version change for a release.
enum _VersionChange {
  /// A major version change (e.g., 1.2.3 -> 2.0.0).
  major,

  /// A minor version change (e.g., 1.2.3 -> 1.3.0).
  minor,

  /// A patch version change (e.g., 1.2.3 -> 1.2.4).
  patch,

  /// No version change.
  skip,
}

/// Represents a single entry in the pending changelog.
class _PendingChangelogEntry {
  /// Creates a new pending changelog entry.
  _PendingChangelogEntry({required this.changelog, required this.version});

  /// Creates a PendingChangelogEntry from a YAML string.
  factory _PendingChangelogEntry.parse(String yamlContent) {
    final dynamic yaml = loadYaml(yamlContent);
    if (yaml is! YamlMap) {
      throw FormatException(
          'Expected a YAML map, but found ${yaml.runtimeType}.');
    }

    final dynamic changelogYaml = yaml['changelog'];
    if (changelogYaml is! String) {
      throw FormatException(
          'Expected "changelog" to be a string, but found ${changelogYaml.runtimeType}.');
    }
    final String changelog = changelogYaml.trim();

    final String? versionString = yaml['version'] as String?;
    if (versionString == null) {
      throw const FormatException('Missing "version" key.');
    }
    final _VersionChange version = _VersionChange.values.firstWhere(
      (_VersionChange e) => e.name == versionString,
      orElse: () =>
          throw FormatException('Invalid version type: $versionString'),
    );

    return _PendingChangelogEntry(changelog: changelog, version: version);
  }

  /// The changelog messages for this entry.
  final String changelog;

  /// The type of version change for this entry.
  final _VersionChange version;
}
