// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Helpers for reading Buildbucket build metadata.
library;

import 'ci_lib.dart' as ci_lib;

/// Parses a Buildbucket timestamp.
///
/// Buildbucket emits nanosecond precision; DateTime.parse accepts at most
/// microseconds.
DateTime? parseBuildTime(String? value) {
  if (value == null) {
    return null;
  }
  return DateTime.tryParse(
    value.replaceAllMapped(RegExp(r'(\.\d{6})\d+'), (Match m) => m.group(1)!),
  );
}

/// The date (YYYY-MM-DD) a build finished, or started if it is still running.
String buildDate(Map<String, dynamic> build) {
  final value = (build['endTime'] ?? build['startTime'] ?? build['createTime']) as String?;
  return ci_lib.truncate(value ?? '', 10);
}

/// The change a build tested: a PR for presubmit, a commit for postsubmit.
class BuildChange {
  /// Creates a change description.
  const BuildChange({required this.repo, this.pr, this.commit});

  /// GitHub `owner/name` of the repository.
  final String repo;

  /// PR number, for presubmit builds.
  final int? pr;

  /// The commit tested. For presubmit builds, this is the PR's head commit.
  final String? commit;

  /// Short human-readable description, e.g. `PR #123` or `commit 0123abcde`.
  String get label {
    if (pr != null) {
      return 'PR #$pr';
    }
    if (commit != null) {
      return 'commit ${ci_lib.truncate(commit!, 9)}';
    }
    return '?';
  }

  /// GitHub URL for the PR or commit, if known.
  String? get url {
    if (pr != null) {
      return ci_lib.githubLink(pr!, repo: repo);
    }
    if (commit != null) {
      return 'https://github.com/$repo/commit/$commit';
    }
    return null;
  }

  /// JSON-friendly representation.
  Map<String, dynamic> toJson() => <String, dynamic>{
    'repo': repo,
    'pr': pr,
    'commit': commit,
    'url': url,
    'label': label,
  };
}

final RegExp _githubPull = RegExp(r'github\.com/([^/]+/[^/]+)/pull/(\d+)');
final RegExp _gitilesCommit = RegExp(r'^commit/gitiles/([^/]+)/(.+)/\+/(\w+)$');
final RegExp _gitCommit = RegExp(r'^(?:commit|sha)/git/(\w+)$');

/// Determines which PR or commit [build] tested, from its `github_link` and
/// `buildset` tags. Requires the `tags` field to have been requested.
BuildChange buildChange(Map<String, dynamic> build) {
  final List<Map<String, dynamic>> tags =
      (build['tags'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? <Map<String, dynamic>>[];
  String repo = ci_lib.defaultRepo;
  int? pr;
  String? commit;
  for (final tag in tags) {
    final String value = tag['value'] as String? ?? '';
    switch (tag['key']) {
      case 'github_link':
        final RegExpMatch? match = _githubPull.firstMatch(value);
        if (match != null) {
          repo = match.group(1)!;
          pr = int.parse(match.group(2)!);
        }
      case 'buildset':
        final RegExpMatch? gitiles = _gitilesCommit.firstMatch(value);
        if (gitiles != null) {
          commit = gitiles.group(3);
          for (final MapEntry<String, List<String>> mirror in ci_lib.gitilesMirrors.entries) {
            if (mirror.value[0] == gitiles.group(1) && mirror.value[1] == gitiles.group(2)) {
              repo = mirror.key;
            }
          }
        } else {
          commit ??= _gitCommit.firstMatch(value)?.group(1);
        }
    }
  }
  return BuildChange(repo: repo, pr: pr, commit: commit);
}

/// Returns a warning if [newestBuild], the most recent build of a builder, is
/// older than [maxAge]. That usually means the builder was renamed or retired,
/// so its history says nothing about current CI.
String? staleBuilderWarning(
  Map<String, dynamic> newestBuild, {
  required DateTime now,
  Duration maxAge = const Duration(days: 14),
}) {
  final DateTime? newest = parseBuildTime(newestBuild['createTime'] as String?);
  if (newest == null) {
    return null;
  }
  final Duration age = now.difference(newest);
  if (age <= maxAge) {
    return null;
  }
  return 'WARNING: the newest build of this builder is ${age.inDays} days old '
      '(${buildDate(newestBuild)}). It has probably been renamed or retired, '
      'so this history may not reflect current CI.';
}
