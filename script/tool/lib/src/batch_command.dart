// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io' as io;

import 'package:args/command_runner.dart';
import 'package:file/file.dart';
import 'package:github/github.dart';
import 'package:yaml/yaml.dart';

import 'common/core.dart';
import 'common/process_runner.dart';
import 'common/repository_package.dart';

const String _baseBranch = 'release';
const String _headBranch = 'main';

/// A command to create a pull request for a batch release.
class BatchCommand extends Command<void> {
  /// Creates a new `batch` command.
  BatchCommand(this.packagesDir);

  /// The directory containing the packages.
  final Directory packagesDir;

  @override
  final String name = 'batch';

  @override
  final String description =
      'Creates a batch release PR based on unreleased changes.';

  @override
  Future<void> run() async {
    final String? githubToken = io.Platform.environment['GITHUB_TOKEN'];
    if (githubToken == null) {
      print('This command requires a GITHUB_TOKEN environment variable.');
      throw ToolExit(1);
    }

    final ProcessRunner processRunner = ProcessRunner();
    final String remote = await processRunner.runAndExitOnError(
        'git', <String>['remote', 'get-url', 'origin'],
        workingDir: packagesDir.parent.parent); // run git from root
    final RepositorySlug slug = RepositorySlug.fromUrl(remote);

    final ReleaseInfo releaseInfo = await _getReleaseInfo();

    if (releaseInfo.packagesToRelease.isEmpty) {
      print(
          'No packages with unreleased changes are configured for batch releases.');
      return;
    }

    final String prTitle =
        'chore: Batch release for ${releaseInfo.packagesToRelease.length} packages';

    final GitHub github = GitHub(auth: Authentication.withToken(githubToken));

    try {
      final PullRequest pr = await github.pullRequests.create(
        slug,
        CreatePullRequest(
          prTitle,
          _headBranch,
          _baseBranch,
          body: releaseInfo.prBody,
        ),
      );
      print('Successfully created pull request: ${pr.htmlUrl}');
    } on GitHubError catch (e) {
      if (e.toString().contains('A pull request already exists')) {
        print('A pull request already exists for these branches. Nothing to do.');
      } else {
        print('Failed to create pull request: $e');
        throw ToolExit(1);
      }
    } catch (e) {
      print('An unexpected error occurred: $e');
      throw ToolExit(1);
    } finally {
      github.dispose();
    }
  }

  Future<ReleaseInfo> _getReleaseInfo() async {
    final List<RepositoryPackage> packages = 
        await getPackages(packagesDir).toList();
    final List<RepositoryPackage> packagesToRelease = <RepositoryPackage>[];
    final StringBuffer prBody = StringBuffer();

    prBody.writeln('The following packages are included in this batch release:');
    prBody.writeln();

    for (final RepositoryPackage package in packages) {
      final File ciConfig = package.directory.childFile('ci_config.yaml');
      if (!ciConfig.existsSync()) {
        continue;
      }

      try {
        final dynamic yaml = loadYaml(ciConfig.readAsStringSync());
        if (yaml['release']?['batch'] != true) {
          continue;
        }
      } on YamlException catch (e) {
        print('Error parsing ${ciConfig.path}: $e');
        continue;
      }

      final Directory unreleasedDir = 
          package.directory.childDirectory('unreleased');
      if (!unreleasedDir.existsSync()) {
        continue;
      }

      final List<FileSystemEntity> unreleasedFiles = unreleasedDir.listSync() 
        ..removeWhere((FileSystemEntity entity) => entity.basename == '.gitkeep');
      if (unreleasedFiles.isEmpty) {
        continue;
      }

      packagesToRelease.add(package);
      prBody.writeln('### ${package.displayName}');
      for (final FileSystemEntity file in unreleasedFiles) {
        if (file is File) {
          prBody.writeln(file.readAsStringSync());
        }
      }
      prBody.writeln();
    }

    return ReleaseInfo(packagesToRelease, prBody.toString());
  }
}

/// A data class to hold information about a pending release.
class ReleaseInfo {
  /// Creates a new ReleaseInfo.
  const ReleaseInfo(this.packagesToRelease, this.prBody);

  /// The packages that are part of this release.
  final List<RepositoryPackage> packagesToRelease;

  /// The generated pull request body.
  final String prBody;
}


/// Extension to get a [RepositorySlug] from a git remote URL.
extension on RepositorySlug {
  /// Creates a [RepositorySlug] from a git remote URL.
  static RepositorySlug fromUrl(String remoteUrl) {
    final Uri remoteUri = Uri.parse(remoteUrl.trim());
    final List<String> pathSegments = remoteUri.pathSegments;
    // The path for https is e.g., /flutter/packages.git, and for git is
    // e.g., flutter/packages.git.
    final String owner = pathSegments[pathSegments.length - 2];
    final String name = pathSegments.last.replaceAll('.git', '');
    return RepositorySlug(owner, name);
  }
}