// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Log parsing and failing-step analysis used by `summarize_failures.dart`.
library;

import 'dart:convert';

import 'package:http/http.dart' as http;

import 'ci_lib.dart' as ci_lib;

/// Buildbucket fields needed to analyze a build's failing steps.
const String buildFields =
    'id,number,status,builder,summaryMarkdown,startTime,endTime,'
    'steps.*.name,steps.*.status,steps.*.logs';

/// ANSI escape codes. Gradle/JUnit colourize their output, and the escape
/// codes break word boundaries (e.g. "\x1b[31mFAILED"), so they are stripped
/// before matching.
final RegExp _ansi = RegExp(r'\x1b\[[0-9;]*[A-Za-z]');

/// A `flutter test` progress line for a failed test: "00:05 +12 -1: name [E]".
/// The skip (~) and failure (-) counters are optional, and minutes can exceed
/// two digits on very long runs.
final RegExp _dartFailed = RegExp(r'^\d{2,}:\d{2} \+\d+(?: ~\d+)?(?: -\d+)?: (.*) \[E\]$');

/// A class of log line that identifies a failure.
class _SignalPattern {
  /// Creates a pattern. Lower [priority] values are more informative.
  _SignalPattern(this.priority, this.label, this.pattern, this.maxHits);

  /// Lower is more informative; used to pick which lines to keep.
  final int priority;

  /// Human-readable category.
  final String label;

  /// The regex a stripped log line must match.
  final RegExp pattern;

  /// Maximum number of lines this pattern may contribute.
  final int maxHits;
}

/// Known failure line patterns, most specific first.
final List<_SignalPattern> _signalPatterns = <_SignalPattern>[
  // JUnit / AndroidX test runner: "pkg.SomeTest > someMethod[device] FAILED".
  _SignalPattern(0, 'junit', RegExp(r'^\S+ > \w+.*\bFAILED\b'), 5),
  _SignalPattern(1, 'junit', RegExp(r'^Execute \S+: FAILED'), 3),
  // Dart / flutter test: "00:05 +12 -1: some test [E]".
  _SignalPattern(1, 'dart', _dartFailed, 5),
  // Entries of the "Failing tests:" block printed at the end of a run.
  _SignalPattern(2, 'dart', RegExp(r'^/\S+\.dart: .+'), 5),
  // Matcher output. Kept for context, but ranked below exception headers
  // because on its own (e.g. "Actual: <null>") it doesn't identify the failure.
  _SignalPattern(4, 'dart', RegExp('^(?:Expected|Actual|Which): '), 4),
  // Flutter framework error blocks ("══╡ EXCEPTION CAUGHT BY ... ╞══") put
  // the actual error on the line after "The following X was thrown ...".
  _SignalPattern(2, 'dart', RegExp('EXCEPTION CAUGHT BY [A-Z ]+'), 2),
  _SignalPattern(
    3,
    'dart',
    RegExp(
      r'^(?:Bad state|Invalid argument\(s\)|Null check operator|'
      r'Unsupported operation|Concurrent modification)\b',
    ),
    3,
  ),
  // flutter_plugin_tools per-package verdicts.
  _SignalPattern(2, 'tool', RegExp(r'^(?:packages|third_party)/\S+ .*failed\.?$'), 5),
  _SignalPattern(2, 'tool', RegExp(r'^(?:ERROR|Error): \S'), 3),
  // Xcode.
  _SignalPattern(2, 'xcode', RegExp(r'\*\* (?:TEST|BUILD) FAILED \*\*'), 2),
  _SignalPattern(2, 'xcode', RegExp('^.*: error: .+'), 3),
  // Gradle task-level failure.
  _SignalPattern(3, 'task', RegExp(r'^> Task \S+ FAILED'), 3),
  // Exception headers and timeouts (not stack frames).
  _SignalPattern(
    3,
    'exception',
    RegExp(r'^(?:Caused by: )?[\w.$]+(?:Exception|Error)(?::|\b after )'),
    3,
  ),
  _SignalPattern(3, 'exception', RegExp(r'Timeout while executing \w+'), 2),
  // flutter_plugin_tools repo-policy checks (validate / version-check).
  _SignalPattern(3, 'policy', RegExp('^No (?:version|CHANGELOG) change found'), 2),
  _SignalPattern(3, 'policy', RegExp('^Missing (?:version|CHANGELOG) change'), 2),
  _SignalPattern(3, 'policy', RegExp('^Unresolved combo PR'), 2),
  // Only stack frames pointing at a test source file are worth keeping; the
  // rest of the trace is framework/infra noise.
  _SignalPattern(4, 'frame', RegExp(r'^at .*\(\w*Test\.(?:java|kt):\d+\)'), 3),
  _SignalPattern(5, 'gradle', RegExp(r'^FAILURE: Build failed with an exception\.'), 1),
];

/// Lines that show what a step was doing, used to find where a hung step
/// stopped.
final RegExp _activity = RegExp(
  r'^\d{2,}:\d{2} \+\d+|^Launching benchmark|^Running command:|'
  r'^Test is taking a long time|^# Running |^\|\| Running for|'
  r'^\[\d+:\d+\] Running for',
);

/// Lines that look like failures but carry no information.
final RegExp _noise = RegExp(
  r'Run with --stacktrace|Run with --info|Run with --scan|Get more help at|'
  r'Problems report is available|[Dd]eprecated|^\s*\.\.\. \d+ (?:more|trimmed)|'
  r'^See above for full details|^If this (?:is|PR)|^Otherwise, please|'
  r'^For more details|^See here for an example',
);

/// flutter_plugin_tools uses two per-package header styles depending on
/// command.
final RegExp _packageContext = RegExp(
  r'^(?:\|\| Running for|\[\d+:\d+\] Running for) '
  r'((?:packages|third_party)/[^\s.]+)',
);

final RegExp _errorsHeader = RegExp('^The following packages had errors:');

String _withReasons(String package, List<String> reasons) =>
    reasons.isEmpty ? package : '$package (${reasons.join('; ')})';

/// Parses flutter_plugin_tools' "The following packages had errors:" block.
List<String> extractErrorPackages(List<String> lines) {
  final entries = <String>[];
  for (var i = 0; i < lines.length; i++) {
    if (!_errorsHeader.hasMatch(lines[i].replaceAll(_ansi, ''))) {
      continue;
    }
    String? current;
    final reasons = <String>[];
    for (int j = i + 1; j < lines.length; j++) {
      final String candidate = lines[j].replaceAll(_ansi, '').trimRight();
      final String stripped = candidate.trim();
      if (stripped.isEmpty || stripped.startsWith('See above')) {
        break;
      }
      final int indent = candidate.length - candidate.trimLeft().length;
      if (indent >= 4 && current != null) {
        reasons.add(stripped);
        continue;
      }
      if (current != null) {
        entries.add(_withReasons(current, reasons));
      }
      current = stripped.endsWith(':') ? stripped.substring(0, stripped.length - 1) : stripped;
      reasons.clear();
    }
    if (current != null) {
      entries.add(_withReasons(current, reasons));
    }
  }
  return entries.toSet().toList();
}

class _Hit {
  _Hit(this.order, this.priority, this.text, this.package);

  final int order;
  final int priority;
  final String text;
  final String? package;
}

/// Picks up to [maxLines] of the most informative failure lines out of a step
/// log, in log order. A line is prefixed with `[package]` whenever the owning
/// package differs from the line before.
List<String> extractSignature(List<String> lines, int maxLines) {
  final hits = <_Hit>[];
  final counts = <int, int>{};
  final seen = <String>{};
  String? currentPackage;

  for (var order = 0; order < lines.length; order++) {
    final String line = lines[order].replaceAll(_ansi, '').trimRight();
    final RegExpMatch? context = _packageContext.firstMatch(line);
    if (context != null) {
      currentPackage = context.group(1);
      continue;
    }
    final String stripped = line.trim();
    if (stripped.isEmpty || _noise.hasMatch(stripped)) {
      continue;
    }

    for (var index = 0; index < _signalPatterns.length; index++) {
      final _SignalPattern signal = _signalPatterns[index];
      if (!signal.pattern.hasMatch(stripped)) {
        continue;
      }
      if ((counts[index] ?? 0) >= signal.maxHits) {
        break;
      }

      // Digits vary between runs (line numbers, timings, device ids), so
      // normalize them away when deduplicating near-identical lines.
      final String key = ci_lib.truncate(stripped.replaceAll(RegExp(r'\d+'), '#'), 120);
      if (!seen.add(key)) {
        break;
      }
      counts[index] = (counts[index] ?? 0) + 1;

      final String text = ci_lib.truncate(stripped, 220);
      hits.add(_Hit(order, signal.priority, text, currentPackage));
      break;
    }
  }

  hits.sort((_Hit a, _Hit b) {
    final int cmp = a.priority.compareTo(b.priority);
    return cmp != 0 ? cmp : a.order.compareTo(b.order);
  });

  final List<_Hit> kept = hits.take(maxLines).toList()
    ..sort((_Hit a, _Hit b) => a.order.compareTo(b.order));

  final rendered = <String>[];
  String? previousPackage;
  for (final hit in kept) {
    final String? package = hit.package;
    if (package != null && package != previousPackage) {
      rendered.add('[$package] ${hit.text}');
    } else {
      rendered.add(hit.text);
    }
    previousPackage = package;
  }

  return rendered;
}

List<Map<String, dynamic>> _steps(Map<String, dynamic> build) =>
    (build['steps'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? <Map<String, dynamic>>[];

List<Map<String, dynamic>> _logs(Map<String, dynamic> step) =>
    (step['logs'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? <Map<String, dynamic>>[];

/// Filters [steps] down to those with no child step also in [steps].
List<Map<String, dynamic>> _leaves(List<Map<String, dynamic>> steps) {
  return steps.where((Map<String, dynamic> step) {
    final stepName = step['name'] as String;
    return !steps.any(
      (Map<String, dynamic> other) =>
          other != step && (other['name'] as String).startsWith('$stepName|'),
    );
  }).toList();
}

const Set<String> _badStatus = <String>{'FAILURE', 'INFRA_FAILURE'};

/// The innermost steps that failed.
List<Map<String, dynamic>> failedLeafSteps(Map<String, dynamic> build) {
  return _leaves(
    _steps(build).where((Map<String, dynamic> s) => _badStatus.contains(s['status'])).toList(),
  );
}

bool _hasStdout(Map<String, dynamic> step) =>
    _logs(step).any((Map<String, dynamic> entry) => entry['name'] == 'stdout');

/// The innermost steps that were cancelled mid-run (i.e. hit the build
/// timeout) in a failed build.
List<Map<String, dynamic>> hungLeafSteps(Map<String, dynamic> build) {
  if (!_badStatus.contains(build['status'])) {
    return <Map<String, dynamic>>[];
  }
  final List<Map<String, dynamic>> cancelled = _steps(
    build,
  ).where((Map<String, dynamic> s) => s['status'] == 'CANCELED').toList();
  return _leaves(cancelled).where(_hasStdout).toList();
}

/// Wall-clock duration of [build] in minutes, if known.
double? buildMinutes(Map<String, dynamic> build) {
  final DateTime? start = ci_lib.parseBuildTime(build['startTime'] as String?);
  final DateTime? end = ci_lib.parseBuildTime(build['endTime'] as String?);
  if (start == null || end == null) {
    return null;
  }
  return end.difference(start).inSeconds / 60.0;
}

/// Describes where a cancelled step's log stopped, in at most [maxLines]
/// lines: the last package, then the most recent activity and the end of the
/// log. When lines must be dropped, the oldest go first, because the newest
/// show where the step hung.
List<String> extractHang(List<String> lines, int maxLines) {
  final List<String> clean = lines.map((String line) => line.replaceAll(_ansi, '').trim()).toList();
  String? package;
  for (final line in clean) {
    final RegExpMatch? context = _packageContext.firstMatch(line);
    if (context != null) {
      package = context.group(1);
    }
  }

  final List<String> activities = clean.where(_activity.hasMatch).toList();
  final List<String> nonEmpty = clean.where((String l) => l.isNotEmpty).toList();
  final Iterable<String> tail = nonEmpty
      .skip(nonEmpty.length > 3 ? nonEmpty.length - 3 : 0)
      .map((String l) => ci_lib.truncate(l, 200));
  final List<String> recentActivity = activities
      .skip(activities.length > 4 ? activities.length - 4 : 0)
      .map((String l) => ci_lib.truncate(l, 200))
      .toList();

  final details = <String>[
    for (final String line in recentActivity) 'last activity: $line',
    for (final String line in tail)
      if (!recentActivity.contains(line)) 'log ends: $line',
  ];
  final int keep = maxLines - 1;

  return <String>[
    'last package: ${package ?? '?'}',
    ...details.skip(details.length > keep ? details.length - keep : 0),
  ];
}

String? _stdoutUrl(String buildId, Map<String, dynamic> step) {
  final List<Map<String, dynamic>> logs = _logs(step);
  for (final entry in logs) {
    if (entry['name'] == 'stdout' && entry['viewUrl'] != null) {
      return entry['viewUrl'] as String;
    }
  }
  // Steps that list logs but no stdout are recipe/cleanup steps.
  if (logs.isNotEmpty) {
    return null;
  }
  return ci_lib.stepLogUrl(buildId, step['name'] as String);
}

/// Fetches and analyzes the log of every failed or hung leaf step of [build].
///
/// [client] is used to fetch logs if given, otherwise a default client is
/// used.
Future<List<Map<String, dynamic>>> analyzeSteps(
  String buildId,
  Map<String, dynamic> build,
  int maxLines, {
  http.Client? client,
}) async {
  final entries = <Map<String, dynamic>>[];
  final targets = <(Map<String, dynamic>, String)>[
    for (final Map<String, dynamic> step in failedLeafSteps(build)) (step, 'failed'),
    for (final Map<String, dynamic> step in hungLeafSteps(build)) (step, 'hung'),
  ];

  for (final (Map<String, dynamic> step, String kind) in targets) {
    final stepName = step['name'] as String;
    final String? url = _stdoutUrl(buildId, step);
    final entry = <String, dynamic>{'step': stepName, 'kind': kind, 'log_url': url};
    entries.add(entry);

    if (url == null) {
      entry['error'] = 'no stdout log (a recipe/cleanup step; see any hung step below)';
      continue;
    }

    final String text = await ci_lib.fetchLog(url, client: client);
    if (text == ci_lib.logMissing) {
      entry['error'] = 'log purged or unavailable (LogDog keeps ~6 months)';
      continue;
    }
    if (text == ci_lib.logInaccessible) {
      entry['error'] =
          'log inaccessible (HTTP 403 from LogDog; the build may be private, '
          'or requests are being rate limited)';
      continue;
    }

    final List<String> lines = LineSplitter.split(text).toList();
    entry['error_packages'] = extractErrorPackages(lines);

    if (kind == 'hung') {
      entry['signature'] = extractHang(lines, maxLines);
    } else {
      final List<String> signature = extractSignature(lines, maxLines);
      entry['signature'] = signature;

      if (signature.isEmpty) {
        final List<String> nonEmpty = lines
            .map((String l) => l.replaceAll(_ansi, '').trim())
            .where((String l) => l.isNotEmpty)
            .toList();
        entry['signature'] = nonEmpty
            .skip(nonEmpty.length > maxLines ? nonEmpty.length - maxLines : 0)
            .map((String l) => ci_lib.truncate(l, 220))
            .toList();
        entry['signature_is_fallback'] = true;
      }
    }

    entry['cached_log'] = ci_lib.logCachePath(url);
    entry['log_lines'] = lines.length;
  }

  return entries;
}
