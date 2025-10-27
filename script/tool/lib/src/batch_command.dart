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

/// A command to create a pull request for a single package release.
class BatchCommand extends PackageCommand {
  /// Creates a new `batch` command.
  BatchCommand(
    super.packagesDir, {
    super.processRunner,
    super.platform,
    super.gitDir,
  }) {
    argParser.addOption(
      'package',
      mandatory: true,
      abbr: 'p',
      help: 'The package to create a release PR for.',
    );
    argParser.addOption(
      'branch',
      mandatory: true,
      abbr: 'b',
      help: 'The branch to push the release PR to.',
    );
  }

  @override
  final String name = 'batch';

  @override
  final String description = 'Creates a release PR for a single package.';

  @override
  Future<void> run() async {
    final String packageName = argResults!['package'] as String;
    final String branchName = argResults!['branch'] as String;

    final GitDir repository = await gitDir;

    final RepositoryPackage package = await _getPackage(packageName);

    final UnreleasedChanges unreleasedChanges =
        await _getUnreleasedChanges(package);
    if (unreleasedChanges.entries.isEmpty) {
      printError('No unreleased changes found for $packageName.');
      return;
    }

    final Pubspec pubspec =
        Pubspec.parse(package.pubspecFile.readAsStringSync());
    final ReleaseInfo releaseInfo =
        _getReleaseInfo(unreleasedChanges.entries, pubspec.version!);

    if (releaseInfo.newVersion == null) {
      printError('No version change specified in unreleased changelog for '
          '$packageName.');
      return;
    }

    await _pushBranch(
      repository: repository,
      package: package,
      branchName: branchName,
      unreleasedFiles: unreleasedChanges.files,
      releaseInfo: releaseInfo,
    );
  }

  Future<RepositoryPackage> _getPackage(String packageName) async {
    return getTargetPackages()
        .map<RepositoryPackage>(
            (PackageEnumerationEntry entry) => entry.package)
        .firstWhere((RepositoryPackage p) => p.displayName.split('/').last == packageName);
  }

  Future<UnreleasedChanges> _getUnreleasedChanges(
      RepositoryPackage package) async {
    final Directory unreleasedDir =
        package.directory.childDirectory('unreleased');
    if (!unreleasedDir.existsSync()) {
      printError('No unreleased folder found for ${package.displayName}.');
      throw ToolExit(_kExitPackageMalformed);
    }
    final List<File> unreleasedFiles = unreleasedDir
        .listSync()
        .whereType<File>()
        .where((File f) => f.basename.endsWith('.yaml') && f.basename != _kTemplateFileName)
        .toList();
    try {
      final List<UnreleasedEntry> entries = unreleasedFiles
          .map<UnreleasedEntry>(
              (File f) => UnreleasedEntry.parse(f.readAsStringSync()))
          .toList();
      return UnreleasedChanges(entries, unreleasedFiles);
    } on FormatException catch (e) {
      printError('Malformed unreleased changelog file: $e');
      throw ToolExit(_kExitPackageMalformed);
    }
  }

  ReleaseInfo _getReleaseInfo(
      List<UnreleasedEntry> unreleasedEntries, Version oldVersion) {
    final List<String> changelogs = <String>[];
    int versionIndex = VersionChange.skip.index;
    for (final UnreleasedEntry entry in unreleasedEntries) {
      changelogs.addAll(entry.changelog);
      versionIndex = math.min(versionIndex, entry.version.index);
    }
    final VersionChange effectiveVersionChange =
        VersionChange.values[versionIndex];

    Version? newVersion;
    printError('Effective version change: $effectiveVersionChange');
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
    required GitDir repository,
    required RepositoryPackage package,
    required String branchName,
    required List<File> unreleasedFiles,
    required ReleaseInfo releaseInfo,
  }) async {
    final io.ProcessResult deleteBranchResult =
        await repository.runCommand(<String>['branch', '-D', branchName]);
    if (deleteBranchResult.exitCode != 0) {
      printError(
          'Failed to delete branch $branchName: ${deleteBranchResult.stderr}');
      throw ToolExit(_kGitFailedToPush);
    }

    final io.ProcessResult checkoutResult = await repository.runCommand(
        <String>['checkout', '-b', branchName]);
    if (checkoutResult.exitCode != 0) {
      printError(
          'Failed to checkout branch $branchName: ${checkoutResult.stderr}');
      throw ToolExit(_kGitFailedToPush);
    }

    // Update pubspec.yaml.
    final YamlEditor editablePubspec =
        YamlEditor(package.pubspecFile.readAsStringSync());
    editablePubspec.update(<String>['version'], releaseInfo.newVersion.toString());
    package.pubspecFile.writeAsStringSync(editablePubspec.toString());

    // Update CHANGELOG.md.
    final String newHeader = '## ${releaseInfo.newVersion}';
    final List<String> newEntries = releaseInfo.changelogs
        .map((String line) => '- $line')
        .toList();

    final List<String> changelogLines = package.changelogFile.readAsLinesSync();
    final StringBuffer newChangelog = StringBuffer();

    bool inserted = false;
    for (final String line in changelogLines) {
      if (!inserted && line.startsWith('## ')) {
        newChangelog.writeln(newHeader);
        newChangelog.writeln();
        newChangelog.writeln(newEntries.join('\n'));
        newChangelog.writeln();
        inserted = true;
      }
      newChangelog.writeln(line);
    }

    if (!inserted) {
      printError("Can't parse existing CHANGELOG.md.");
      throw ToolExit(_kExitPackageMalformed);
    }

    package.changelogFile.writeAsStringSync(newChangelog.toString());

    for (final File file in unreleasedFiles) {
      final io.ProcessResult rmResult =
          await repository.runCommand(<String>['rm', file.path]);
      if (rmResult.exitCode != 0) {
        printError('Failed to rm ${file.path}: ${rmResult.stderr}');
        throw ToolExit(_kGitFailedToPush);
      }
    }

    final io.ProcessResult addResult = await repository
        .runCommand(<String>['add', package.pubspecFile.path, package.changelogFile.path]);
    if (addResult.exitCode != 0) {
      printError('Failed to git add: ${addResult.stderr}');
      throw ToolExit(_kGitFailedToPush);
    }

    final io.ProcessResult commitResult = await repository.runCommand(<String>[
      'commit',
      '-m',
      '${package.displayName}: Prepare for release'
    ]);
    if (commitResult.exitCode != 0) {
      printError('Failed to commit: ${commitResult.stderr}');
      throw ToolExit(_kGitFailedToPush);
    }

    final io.ProcessResult pushResult =
        await repository.runCommand(<String>['push', 'origin', branchName]);
    if (pushResult.exitCode != 0) {
      printError('Failed to push to $branchName: ${pushResult.stderr}');
      throw ToolExit(_kGitFailedToPush);
    }
  }
}

/// A data class for unreleased changes.
class UnreleasedChanges {
  /// Creates a new instance.
  UnreleasedChanges(this.entries, this.files);

  /// The parsed unreleased entries.
  final List<UnreleasedEntry> entries;

  /// The files that the unreleased entries were parsed from.
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

/// Represents a single entry in the unreleased changelog.
class UnreleasedEntry {
  /// Creates a new unreleased entry.
  UnreleasedEntry({required this.changelog, required this.version});

  /// Creates an UnreleasedEntry from a YAML string.
  factory UnreleasedEntry.parse(String yamlContent) {
    final dynamic yaml = loadYaml(yamlContent);
    if (yaml is! YamlMap) {
      throw FormatException('Expected a YAML map, but found ${yaml.runtimeType}.');
    }

    final dynamic changelogYaml = yaml['changelog'];
    if (changelogYaml is! YamlList) {
      throw FormatException('Expected "changelog" to be a list, but found ${changelogYaml.runtimeType}.');
    }
    final List<String> changelog = changelogYaml.nodes
        .map((YamlNode node) => node.value as String)
        .toList();

    final String? versionString = yaml['version'] as String?;
    if (versionString == null) {
      throw const FormatException('Missing "version" key.');
    }
    final VersionChange version = VersionChange.values.firstWhere(
      (VersionChange e) => e.name == versionString,
      orElse: () =>
          throw FormatException('Invalid version type: $versionString'),
    );

    return UnreleasedEntry(changelog: changelog, version: version);
  }

  /// The changelog messages for this entry.
  final List<String> changelog;

  /// The type of version change for this entry.
  final VersionChange version;
}
