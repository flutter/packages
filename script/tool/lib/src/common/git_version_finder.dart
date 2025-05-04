// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io' as io;

import 'package:git/git.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:yaml/yaml.dart';

/// Finding diffs based on `baseGitDir` and `baseSha`.
class GitVersionFinder {
  /// Constructor
  GitVersionFinder(this.baseGitDir, {String? baseSha, String? baseBranch})
      : assert(baseSha == null || baseBranch == null,
            'At most one of baseSha and baseBranch can be provided'),
        _baseSha = baseSha,
        _baseBranch = baseBranch ?? 'FETCH_HEAD';

  /// The top level directory of the git repo.
  ///
  /// That is where the .git/ folder exists.
  final GitDir baseGitDir;

  /// The base sha used to get diff.
  String? _baseSha;

  /// The base branche used to find a merge point if baseSha is not provided.
  final String _baseBranch;

  /// Get a list of all the changed files.
  Future<List<String>> getChangedFiles(
      {bool includeUncommitted = false}) async {
    final String baseSha = await getBaseSha();
    final io.ProcessResult changedFilesCommand = await baseGitDir
        .runCommand(<String>[
      'diff',
      '--name-only',
      baseSha,
      if (!includeUncommitted) 'HEAD'
    ]);
    final String changedFilesStdout = changedFilesCommand.stdout.toString();
    if (changedFilesStdout.isEmpty) {
      return <String>[];
    }
    final List<String> changedFiles = changedFilesStdout.split('\n')
      ..removeWhere((String element) => element.isEmpty);
    return changedFiles.toList();
  }

  /// Get a list of all the changed files.
  Future<List<String>> getDiffContents({
    String? targetPath,
    bool includeUncommitted = false,
  }) async {
    final String baseSha = await getBaseSha();
    final io.ProcessResult diffCommand = await baseGitDir.runCommand(<String>[
      'diff',
      baseSha,
      if (!includeUncommitted) 'HEAD',
      if (targetPath != null) ...<String>['--', targetPath],
    ]);
    final String diffStdout = diffCommand.stdout.toString();
    if (diffStdout.isEmpty) {
      return <String>[];
    }
    final List<String> changedFiles = diffStdout.split('\n')
      ..removeWhere((String element) => element.isEmpty);
    return changedFiles.toList();
  }

  /// Get the package version specified in the pubspec file in `pubspecPath` and
  /// at the revision of `gitRef` (defaulting to the base if not provided).
  Future<Version?> getPackageVersion(String pubspecPath,
      {String? gitRef}) async {
    final String ref = gitRef ?? (await getBaseSha());

    io.ProcessResult gitShow;
    try {
      gitShow =
          await baseGitDir.runCommand(<String>['show', '$ref:$pubspecPath']);
    } on io.ProcessException {
      return null;
    }
    final String fileContent = gitShow.stdout as String;
    if (fileContent.trim().isEmpty) {
      return null;
    }
    final YamlMap fileYaml = loadYaml(fileContent) as YamlMap;
    final String? versionString = fileYaml['version'] as String?;
    return versionString == null ? null : Version.parse(versionString);
  }

  /// Returns the base used to diff against.
  Future<String> getBaseSha() async {
    String? baseSha = _baseSha;
    if (baseSha != null && baseSha.isNotEmpty) {
      return baseSha;
    }

    io.ProcessResult baseShaFromMergeBase = await baseGitDir.runCommand(
        <String>['merge-base', '--fork-point', _baseBranch, 'HEAD'],
        throwOnError: false);
    final String stdout = (baseShaFromMergeBase.stdout as String? ?? '').trim();
    final String stderr = (baseShaFromMergeBase.stderr as String? ?? '').trim();
    if (stderr.isNotEmpty || stdout.isEmpty) {
      baseShaFromMergeBase = await baseGitDir
          .runCommand(<String>['merge-base', _baseBranch, 'HEAD']);
    }
    baseSha = (baseShaFromMergeBase.stdout as String).trim();
    _baseSha = baseSha;
    return baseSha;
  }
}
