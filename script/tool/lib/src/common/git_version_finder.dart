// Copyright 2013 The Flutter Authors
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
    : assert(
        baseSha == null || baseBranch == null,
        'At most one of baseSha and baseBranch can be provided',
      ),
      _baseSha = baseSha,
      _baseBranch = baseBranch ?? 'main';

  /// The top level directory of the git repo.
  ///
  /// That is where the .git/ folder exists.
  final GitDir baseGitDir;

  /// The base sha used to get diff.
  String? _baseSha;

  /// The base branche used to find a merge point if baseSha is not provided.
  final String _baseBranch;

  /// Get a list of all the changed files.
  Future<List<String>> getChangedFiles({bool includeUncommitted = false}) async {
    final String baseSha = await getBaseSha();
    final io.ProcessResult changedFilesCommand = await baseGitDir.runCommand(<String>[
      'diff',
      '-z',
      '--name-only',
      baseSha,
      if (!includeUncommitted) 'HEAD',
    ]);
    return _splitDiffOutputs(changedFilesCommand.stdout.toString());
  }

  /// Get a list of all the staged files.
  Future<List<String>> getStagedFiles() async {
    final io.ProcessResult changedFilesCommand = await baseGitDir.runCommand(const <String>[
      'diff',
      '--cached',
      '-z',
      '--name-only',
      '--diff-filter=ACM',
    ]);
    return _splitDiffOutputs(changedFilesCommand.stdout.toString());
  }

  /// Splits the stdout of a `git diff` command into a list of file paths.
  ///
  /// When `git diff` is run with the `-z` flag, it outputs file paths separated
  /// by a null byte (`\u0000`, ASCII 0). This is the safest way to parse filenames
  /// because:
  /// 1. Filenames can contain spaces, quotes, and newlines, but they can never
  ///    contain null bytes.
  /// 2. Git does not quote or escape "unusual" characters in filenames when
  ///    using `-z`, giving us the raw path.
  ///
  /// For backward compatibility with legacy unit tests that mock `git diff`
  /// using newline-terminated strings, this helper falls back to splitting
  /// by `\n` if no null bytes are detected in the output.
  List<String> _splitDiffOutputs(String stdout) {
    if (stdout.isEmpty) {
      return <String>[];
    }
    final List<String> files;
    if (stdout.contains('\u0000')) {
      files = stdout.split('\u0000');
    } else {
      files = stdout.split('\n');
    }
    return files.where((String file) => file.isNotEmpty).toList();
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
    final diffStdout = diffCommand.stdout.toString();
    if (diffStdout.isEmpty) {
      return <String>[];
    }
    final List<String> changedFiles = diffStdout.split('\n')
      ..removeWhere((String element) => element.isEmpty);
    return changedFiles.toList();
  }

  /// Get the package version specified in the pubspec file in `pubspecPath` and
  /// at the revision of `gitRef` (defaulting to the base if not provided).
  Future<Version?> getPackageVersion(String pubspecPath, {String? gitRef}) async {
    final String ref = gitRef ?? (await getBaseSha());

    io.ProcessResult gitShow;
    try {
      gitShow = await baseGitDir.runCommand(<String>['show', '$ref:$pubspecPath']);
    } on io.ProcessException {
      return null;
    }
    final fileContent = gitShow.stdout as String;
    if (fileContent.trim().isEmpty) {
      return null;
    }
    final fileYaml = loadYaml(fileContent) as YamlMap;
    final versionString = fileYaml['version'] as String?;
    return versionString == null ? null : Version.parse(versionString);
  }

  /// Returns the base used to diff against.
  Future<String> getBaseSha() async {
    String? baseSha = _baseSha;
    if (baseSha != null && baseSha.isNotEmpty) {
      return baseSha;
    }

    io.ProcessResult baseShaFromMergeBase = await baseGitDir.runCommand(<String>[
      'merge-base',
      '--fork-point',
      _baseBranch,
      'HEAD',
    ], throwOnError: false);
    final String stdout = (baseShaFromMergeBase.stdout as String? ?? '').trim();
    final String stderr = (baseShaFromMergeBase.stderr as String? ?? '').trim();
    if (stderr.isNotEmpty || stdout.isEmpty) {
      baseShaFromMergeBase = await baseGitDir.runCommand(<String>[
        'merge-base',
        _baseBranch,
        'HEAD',
      ]);
    }
    baseSha = (baseShaFromMergeBase.stdout as String).trim();
    _baseSha = baseSha;
    return baseSha;
  }
}
