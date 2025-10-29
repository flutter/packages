// Copyright 2013 The Flutter Authors. All rights reserved.
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

const int _kExitPackageMalformed = 2;
const int _kGitFailedToPush = 3;

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
      help: 'The branch to push the release PR to.',
    );
  }

  @override
  final String name = 'branch-for-batch-release';

  @override
  final String description = 'Creates a release PR for a single package.';

  @override
  Future<void> run() async {
    final String branchName = argResults!['branch'] as String;

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
    final PendingChangelogs pendingChangelogs =
        await _getPendingChangelogs(package);
    if (pendingChangelogs.entries.isEmpty) {
      print('No pending changelogs found for ${package.displayName}.');
      return;
    }

    final Pubspec pubspec =
        Pubspec.parse(package.pubspecFile.readAsStringSync());
    final ReleaseInfo releaseInfo =
        _getReleaseInfo(pendingChangelogs.entries, pubspec.version!);

    if (releaseInfo.newVersion == null) {
      print('No version change specified in pending changelogs for '
          '${package.displayName}.');
      return;
    }

    print('Creating and pushing release branch...');
    await _pushBranch(
      git: repository,
      package: package,
      branchName: branchName,
      pendingChangelogFiles: pendingChangelogs.files,
      releaseInfo: releaseInfo,
    );
  }

  Future<PendingChangelogs> _getPendingChangelogs(
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
      final List<PendingChangelogEntry> entries = pendingChangelogFiles
          .map<PendingChangelogEntry>(
              (File f) => PendingChangelogEntry.parse(f.readAsStringSync()))
          .toList();
      return PendingChangelogs(entries, pendingChangelogFiles);
    } on FormatException catch (e) {
      printError('Malformed pending changelog file: $e');
      throw ToolExit(_kExitPackageMalformed);
    }
  }

  ReleaseInfo _getReleaseInfo(
      List<PendingChangelogEntry> pendingChangelogEntries, Version oldVersion) {
    final List<String> changelogs = <String>[];
    int versionIndex = VersionChange.skip.index;
    for (final PendingChangelogEntry entry in pendingChangelogEntries) {
      changelogs.add(entry.changelog);
      versionIndex = math.min(versionIndex, entry.version.index);
    }
    final VersionChange effectiveVersionChange =
        VersionChange.values[versionIndex];

    Version? newVersion;
    switch (effectiveVersionChange) {
      case VersionChange.skip:
        break;
      case VersionChange.major:
        newVersion = Version(
          oldVersion.major + 1,
          0,
          0,
        );
      case VersionChange.minor:
        newVersion = Version(
          oldVersion.major,
          oldVersion.minor + 1,
          0,
        );
      case VersionChange.patch:
        newVersion = Version(
          oldVersion.major,
          oldVersion.minor,
          oldVersion.patch + 1,
        );
    }
    return ReleaseInfo(newVersion, changelogs);
  }

  Future<void> _pushBranch({
    required GitDir git,
    required RepositoryPackage package,
    required String branchName,
    required List<File> pendingChangelogFiles,
    required ReleaseInfo releaseInfo,
  }) async {
    print('  Creating new branch "$branchName"...');
    final io.ProcessResult checkoutResult =
        await git.runCommand(<String>['checkout', '-b', branchName]);
    if (checkoutResult.exitCode != 0) {
      printError(
          'Failed to create branch $branchName: ${checkoutResult.stderr}');
      throw ToolExit(_kGitFailedToPush);
    }

    print('  Updating pubspec.yaml to version ${releaseInfo.newVersion}...');
    // Update pubspec.yaml.
    final YamlEditor editablePubspec =
        YamlEditor(package.pubspecFile.readAsStringSync());
    editablePubspec
        .update(<String>['version'], releaseInfo.newVersion.toString());
    package.pubspecFile.writeAsStringSync(editablePubspec.toString());

    print('  Updating CHANGELOG.md...');
    // Update CHANGELOG.md.
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

    print('  Removing pending changelog files...');
    for (final File file in pendingChangelogFiles) {
      final io.ProcessResult rmResult =
          await git.runCommand(<String>['rm', file.path]);
      if (rmResult.exitCode != 0) {
        printError('Failed to rm ${file.path}: ${rmResult.stderr}');
        throw ToolExit(_kGitFailedToPush);
      }
    }

    print('  Staging changes...');
    final io.ProcessResult addResult = await git.runCommand(
        <String>['add', package.pubspecFile.path, package.changelogFile.path]);
    if (addResult.exitCode != 0) {
      printError('Failed to git add: ${addResult.stderr}');
      throw ToolExit(_kGitFailedToPush);
    }

    print('  Committing changes...');
    final io.ProcessResult commitResult = await git.runCommand(<String>[
      'commit',
      '-m',
      '${package.displayName}: Prepare for release'
    ]);
    if (commitResult.exitCode != 0) {
      printError('Failed to commit: ${commitResult.stderr}');
      throw ToolExit(_kGitFailedToPush);
    }

    print('  Pushing to remote...');
    final io.ProcessResult pushResult =
        await git.runCommand(<String>['push', 'origin', branchName]);
    if (pushResult.exitCode != 0) {
      printError('Failed to push to $branchName: ${pushResult.stderr}');
      throw ToolExit(_kGitFailedToPush);
    }
  }
}

/// A data class for pending changelogs.
class PendingChangelogs {
  /// Creates a new instance.
  PendingChangelogs(this.entries, this.files);

  /// The parsed pending changelog entries.
  final List<PendingChangelogEntry> entries;

  /// The files that the pending changelog entries were parsed from.
  final List<File> files;
}

/// A data class for processed release information.
class ReleaseInfo {
  /// Creates a new instance.
  ReleaseInfo(this.newVersion, this.changelogs);

  /// The new version for the release, or null if there is no version change.
  final Version? newVersion;

  /// The combined changelog entries.
  final List<String> changelogs;
}

/// The type of version change for a release.
enum VersionChange {
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
class PendingChangelogEntry {
  /// Creates a new pending changelog entry.
  PendingChangelogEntry({required this.changelog, required this.version});

  /// Creates a PendingChangelogEntry from a YAML string.
  factory PendingChangelogEntry.parse(String yamlContent) {
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
    final VersionChange version = VersionChange.values.firstWhere(
      (VersionChange e) => e.name == versionString,
      orElse: () =>
          throw FormatException('Invalid version type: $versionString'),
    );

    return PendingChangelogEntry(changelog: changelog, version: version);
  }

  /// The changelog messages for this entry.
  final String changelog;

  /// The type of version change for this entry.
  final VersionChange version;
}
