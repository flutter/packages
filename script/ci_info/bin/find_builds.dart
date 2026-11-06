// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:ci_info/ci_lib.dart' as ci_lib;

const String _prOption = 'pr';
const String _commitOption = 'commit';
const String _repoOption = 'repo';
const String _projectOption = 'project';
const String _limitOption = 'limit';
const String _failedOnlyFlag = 'failed-only';
const String _jsonFlag = 'json';
const String _helpFlag = 'help';

const String _fields =
    'builds.*.id,builds.*.number,builds.*.status,builds.*.builder,'
    'builds.*.endTime,builds.*.summaryMarkdown';

const Set<String> _terminalBad = <String>{'FAILURE', 'INFRA_FAILURE', 'CANCELED'};
const Set<String> _terminalFailed = <String>{'FAILURE', 'INFRA_FAILURE'};

/// Default for `--limit`.
///
/// Each push to a PR starts about 77 builds, and each landed commit about 94,
/// so this covers several pushes. Buildbucket returns the newest builds first,
/// so when the limit is reached the builds from the oldest pushes are dropped.
const int _defaultLimit = 400;

Future<List<Map<String, dynamic>>> _collect({
  required String repo,
  required String project,
  required int limit,
  int? pr,
  String? commit,
}) {
  final Map<String, dynamic> predicate;
  if (pr != null) {
    predicate = <String, dynamic>{
      'builder': <String, String>{'project': project, 'bucket': 'try'},
      'tags': <Map<String, String>>[
        <String, String>{'key': 'github_link', 'value': ci_lib.githubLink(pr, repo: repo)},
      ],
    };
  } else {
    predicate = <String, dynamic>{
      'builder': <String, String>{'project': project, 'bucket': 'prod'},
      'tags': <Map<String, String>>[
        <String, String>{'key': 'buildset', 'value': ci_lib.commitBuildset(commit!, repo: repo)},
      ],
    };
  }
  return ci_lib.searchBuilds(predicate, fields: _fields, limit: limit);
}

Future<void> main(List<String> args) async {
  final parser = ArgParser()
    ..addOption(_prOption, help: 'GitHub PR number (presubmit tryjobs).')
    ..addOption(_commitOption, help: 'Full commit SHA (postsubmit builds).')
    ..addOption(
      _repoOption,
      defaultsTo: ci_lib.defaultRepo,
      help: 'owner/name, default flutter/packages.',
    )
    ..addOption(_projectOption, defaultsTo: 'flutter', help: "LUCI project, default 'flutter'.")
    ..addOption(_limitOption, defaultsTo: '$_defaultLimit', help: 'Max builds to retrieve.')
    ..addFlag(_failedOnlyFlag, help: 'Only show non-successful builds.')
    ..addFlag(_jsonFlag, help: 'Output as JSON.')
    ..addFlag(_helpFlag, abbr: 'h', negatable: false, help: 'Print usage information.');

  final ArgResults parsedArgs;
  final int? pr;
  final int limit;
  try {
    parsedArgs = parser.parse(args);
    if (parsedArgs[_helpFlag] as bool) {
      print(parser.usage);
      return;
    }
    if (parsedArgs[_prOption] == null && parsedArgs[_commitOption] == null) {
      throw const FormatException('Must specify either --$_prOption or --$_commitOption');
    }
    if (parsedArgs[_prOption] != null && parsedArgs[_commitOption] != null) {
      throw const FormatException('Cannot specify both --$_prOption and --$_commitOption');
    }
    final prValue = parsedArgs[_prOption] as String?;
    pr = prValue == null ? null : int.parse(prValue);
    limit = int.parse(parsedArgs[_limitOption] as String);
  } on FormatException catch (e) {
    stderr.writeln('Error: ${e.message}');
    stderr.writeln(parser.usage);
    exit(1);
  }

  final repo = parsedArgs[_repoOption] as String;
  final defaultProject = parsedArgs[_projectOption] as String;
  final List<Map<String, dynamic>> builds = await _collect(
    repo: repo,
    project: defaultProject,
    limit: limit,
    pr: pr,
    commit: parsedArgs[_commitOption] as String?,
  );
  if (builds.isEmpty) {
    final target = pr != null ? 'PR $pr' : 'commit ${parsedArgs[_commitOption]}';
    stderr.writeln('No builds found for $target in $repo.');
    stderr.writeln(
      'Check that the PR/SHA is correct and that CI has started. For a '
      'commit, the SHA must be the full 40-character hash of a commit that '
      'landed on a CI-enabled branch.',
    );
    exit(1);
  }

  final failedOnly = parsedArgs[_failedOnlyFlag] as bool;
  final rows = <Map<String, dynamic>>[];
  for (final build in builds) {
    final String status = ci_lib.stringField(build, 'status');
    if (failedOnly && !_terminalBad.contains(status)) {
      continue;
    }
    final Map<String, dynamic> builder =
        build['builder'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final String builderName = ci_lib.stringField(builder, 'builder');
    final String bucket = ci_lib.stringField(builder, 'bucket');
    final String project = ci_lib.stringField(builder, 'project', defaultValue: defaultProject);
    final number = build['number'] as int?;
    final id = build['id'] as String;
    final String summary = ci_lib
        .stringField(build, 'summaryMarkdown', defaultValue: '')
        .replaceAll('\n', ' ')
        .trim();

    rows.add(<String, dynamic>{
      'status': status,
      'builder': builderName,
      'bucket': bucket,
      'project': project,
      'number': number,
      'id': id,
      'endTime': ci_lib.truncate(ci_lib.stringField(build, 'endTime', defaultValue: ''), 10),
      'summary': ci_lib.truncate(summary, 120),
      'url': ci_lib.miloBuildUrl(project, bucket, builderName, number, id),
    });
  }

  if (parsedArgs[_jsonFlag] as bool) {
    print(jsonEncode(rows));
    return;
  }

  final int failed = builds
      .where((Map<String, dynamic> b) => _terminalFailed.contains(b['status']))
      .length;
  final int canceled = builds.where((Map<String, dynamic> b) => b['status'] == 'CANCELED').length;
  final int running = builds
      .where(
        (Map<String, dynamic> b) => const <String>{'STARTED', 'SCHEDULED'}.contains(b['status']),
      )
      .length;

  final canceledSummary = canceled > 0 ? ' | $canceled canceled' : '';
  print('${builds.length} builds | $failed failed$canceledSummary | $running still running\n');

  if (rows.isEmpty) {
    print('(no failing builds)');
    return;
  }

  final int width = rows
      .map((Map<String, dynamic> row) => (row['builder'] as String).length)
      .reduce((int a, int b) => a > b ? a : b);
  final String indent = ' ' * (13 + 1 + width + 2);

  for (final row in rows) {
    print(
      '${(row['status'] as String).padRight(13)} '
      '${(row['builder'] as String).padRight(width)}  '
      '${row['endTime']}  ${row['id']}',
    );
    if ((row['summary'] as String).isNotEmpty) {
      print('$indent-> ${row['summary']}');
    }
    print('$indent${row['url']}');
  }
}
