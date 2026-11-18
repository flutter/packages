// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Log parsing and failing-step analysis shared by `summarize_failures.dart`
/// and `flake_history.dart`.
library;

import 'build_info.dart';
import 'ci_lib.dart' as ci_lib;

/// Buildbucket fields needed to analyze a build's failing steps.
const String buildFields =
    'id,number,status,builder,summaryMarkdown,startTime,endTime,'
    'steps.*.name,steps.*.status,steps.*.logs';

/// ANSI escape codes. Gradle/JUnit colourize their output, and the escape
/// codes break word boundaries (e.g. "\x1b[31mFAILED"), so they are stripped
/// before matching.
final RegExp ansi = RegExp(r'\x1b\[[0-9;]*[A-Za-z]');

/// `flutter test` progress line: "00:05 +669 ~2 -1: some test name". The skip
/// (~) and failure (-) counters are optional and attach directly to the colon.
/// Minutes can exceed two digits on very long runs.
final RegExp dartProgress = RegExp(r'^\d{2,}:\d{2} \+\d+(?: ~\d+)?(?: -\d+)?: (.*)$');

/// A `flutter test` progress line for a failed test.
final RegExp dartFailed = RegExp(r'^\d{2,}:\d{2} \+\d+(?: ~\d+)?(?: -\d+)?: (.*) \[E\]$');

/// A class of log line that identifies a failure.
class SignalPattern {
  /// Creates a pattern. Lower [priority] values are more informative.
  SignalPattern(this.priority, this.label, this.pattern, this.maxHits);

  /// Lower is more informative; used to pick the best line for `--match`.
  final int priority;

  /// Human-readable category.
  final String label;

  /// The regex a stripped log line must match.
  final RegExp pattern;

  /// Maximum number of lines this pattern may contribute.
  final int maxHits;
}

/// Known failure line patterns, most specific first.
final List<SignalPattern> signalPatterns = <SignalPattern>[
  // JUnit / AndroidX test runner: "pkg.SomeTest > someMethod[device] FAILED".
  SignalPattern(0, 'junit', RegExp(r'^\S+ > \w+.*\bFAILED\b'), 5),
  SignalPattern(1, 'junit', RegExp(r'^Execute \S+: FAILED'), 3),
  // Dart / flutter test: "00:05 +12 -1: some test [E]".
  SignalPattern(1, 'dart', dartFailed, 5),
  // Entries of the "Failing tests:" block printed at the end of a run.
  SignalPattern(2, 'dart', RegExp(r'^/\S+\.dart: .+'), 5),
  // Matcher output. Kept for context, but ranked below exception headers
  // because on its own (e.g. "Actual: <null>") it doesn't identify the failure.
  SignalPattern(4, 'dart', RegExp('^(?:Expected|Actual|Which): '), 4),
  // Flutter framework error blocks ("══╡ EXCEPTION CAUGHT BY ... ╞══") put
  // the actual error on the line after "The following X was thrown ...".
  SignalPattern(2, 'dart', RegExp('EXCEPTION CAUGHT BY [A-Z ]+'), 2),
  SignalPattern(
    3,
    'dart',
    RegExp(
      r'^(?:Bad state|Invalid argument\(s\)|Null check operator|'
      r'Unsupported operation|Concurrent modification)\b',
    ),
    3,
  ),
  // flutter_plugin_tools per-package verdicts.
  SignalPattern(2, 'tool', RegExp(r'^(?:packages|third_party)/\S+ .*failed\.?$'), 5),
  SignalPattern(2, 'tool', RegExp(r'^(?:ERROR|Error): \S'), 3),
  // Xcode.
  SignalPattern(2, 'xcode', RegExp(r'\*\* (?:TEST|BUILD) FAILED \*\*'), 2),
  SignalPattern(2, 'xcode', RegExp('^.*: error: .+'), 3),
  // Gradle task-level failure.
  SignalPattern(3, 'task', RegExp(r'^> Task \S+ FAILED'), 3),
  // Exception headers and timeouts (not stack frames).
  SignalPattern(
    3,
    'exception',
    RegExp(r'^(?:Caused by: )?[\w.$]+(?:Exception|Error)(?::|\b after )'),
    3,
  ),
  SignalPattern(3, 'exception', RegExp(r'Timeout while executing \w+'), 2),
  // flutter_plugin_tools repo-policy checks (validate / version-check).
  SignalPattern(3, 'policy', RegExp('^No (?:version|CHANGELOG) change found'), 2),
  SignalPattern(3, 'policy', RegExp('^Missing (?:version|CHANGELOG) change'), 2),
  SignalPattern(3, 'policy', RegExp('^Unresolved combo PR'), 2),
  // Only stack frames pointing at a test source file are worth keeping; the
  // rest of the trace is framework/infra noise.
  SignalPattern(4, 'frame', RegExp(r'^at .*\(\w*Test\.(?:java|kt):\d+\)'), 3),
  SignalPattern(5, 'gradle', RegExp(r'^FAILURE: Build failed with an exception\.'), 1),
];

/// Lines that show what a step was doing, used to find where a hung step
/// stopped.
final RegExp activity = RegExp(
  r'^\d{2,}:\d{2} \+\d+|^Launching benchmark|^Running command:|'
  r'^Test is taking a long time|^# Running |^\|\| Running for|'
  r'^\[\d+:\d+\] Running for',
);

/// A hung step's signature is judged only against the end of its log, because
/// the test that hung also appears (and passes) earlier in other builds' logs.
const int hangTailLines = 40;

/// Lines that look like failures but carry no information.
final RegExp noise = RegExp(
  r'Run with --stacktrace|Run with --info|Run with --scan|Get more help at|'
  r'Problems report is available|[Dd]eprecated|^\s*\.\.\. \d+ (?:more|trimmed)|'
  r'^See above for full details|^If this (?:is|PR)|^Otherwise, please|'
  r'^For more details|^See here for an example',
);

/// flutter_plugin_tools uses two per-package header styles depending on
/// command.
final RegExp packageContext = RegExp(
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
    if (!_errorsHeader.hasMatch(lines[i])) {
      continue;
    }
    String? current;
    final reasons = <String>[];
    for (int j = i + 1; j < lines.length; j++) {
      final String candidate = lines[j];
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

/// The identifying lines of a failed step's log.
class Signature {
  /// Creates a signature.
  Signature(this.lines, this.best);

  /// Up to `maxLines` signal lines, in log order.
  final List<String> lines;

  /// The single most informative line, used to suggest a `--match` regex.
  final String? best;
}

/// Picks the most informative failure lines out of a step log.
Signature extractSignature(List<String> lines, int maxLines) {
  final hits = <_Hit>[];
  final counts = <int, int>{};
  final seen = <String>{};
  String? bestLine;
  int? bestPriority;
  String? currentPackage;

  for (var order = 0; order < lines.length; order++) {
    final String line = lines[order].replaceAll(ansi, '').trimRight();
    final RegExpMatch? context = packageContext.firstMatch(line);
    if (context != null) {
      currentPackage = context.group(1);
      continue;
    }
    final String stripped = line.trim();
    if (stripped.isEmpty || noise.hasMatch(stripped)) {
      continue;
    }

    for (var index = 0; index < signalPatterns.length; index++) {
      final SignalPattern signal = signalPatterns[index];
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

      if (bestPriority == null || signal.priority < bestPriority) {
        bestPriority = signal.priority;
        // Untruncated: the part worth matching on may be past the display
        // limit, e.g. the message after a long XCTest file path.
        bestLine = stripped;
      }
      break;
    }
  }

  hits.sort((_Hit a, _Hit b) {
    final int cmp = a.priority.compareTo(b.priority);
    return cmp != 0 ? cmp : a.order.compareTo(b.order);
  });

  final List<_Hit> kept = hits.take(maxLines).toList()
    ..sort((_Hit a, _Hit b) => a.order.compareTo(b.order));

  final List<String> rendered = kept.map((_Hit h) => h.text).toList();
  if (kept.isNotEmpty && kept.first.package != null) {
    rendered[0] = '[${kept.first.package}] ${rendered[0]}';
  }

  return Signature(rendered, bestLine);
}

/// Escapes [text] for use in a regex, leaving spaces readable.
String _escape(String text) => RegExp.escape(text).replaceAll(r'\ ', ' ');

/// Suggests a `--match` regex for `flake_history.dart` from a signature's
/// best line.
String? suggestMatch(String? bestLine) {
  if (bestLine == null) {
    return null;
  }

  // XCTest: ".../FooTests.swift:628: error: -[RunnerTests.FooTests testBar] :
  // Asynchronous wait failed: Exceeded timeout ..." ->
  // "FooTests test\w+\] : Asynchronous wait failed". Line numbers change
  // whenever the file is edited, and a flaky environment usually fails a
  // different subset of a class's tests each run, so match any test in the
  // class that failed for the same reason.
  final RegExpMatch? xctest = _xctestFailure.firstMatch(bestLine);
  if (xctest != null) {
    final String message = xctest.group(2)!;
    final int colon = message.indexOf(':');
    final (String reason, _) = _toPattern(
      colon > 0 ? message.substring(0, colon) : message,
      maxLength: 50,
    );
    return '${_escape(xctest.group(1)!)} test\\w+\\] : $reason';
  }

  // "pkg.ClassName > methodName[device] FAILED" -> "ClassName > methodName",
  // which is stable across devices, shards and reruns.
  final RegExpMatch? junit = RegExp(r'([\w$]+) > (\w+)').firstMatch(bestLine);
  if (junit != null) {
    return '${_escape(junit.group(1)!)} > ${_escape(junit.group(2)!)}';
  }

  // "Execute pkg.ClassName.methodName: FAILED" -> "ClassName.methodName".
  final RegExpMatch? execute = RegExp(r'^Execute \S*?([\w$]+)\.(\w+): FAILED').firstMatch(bestLine);
  if (execute != null) {
    return _escape('${execute.group(1)}.${execute.group(2)}');
  }

  final RegExpMatch? dart = dartFailed.firstMatch(bestLine);
  if (dart != null) {
    // Keep the [E] marker: the bare test name is also printed when the
    // test *passes*, which would turn every red build into a false match.
    final (String name, bool truncated) = _toPattern(dart.group(1)!);
    return '$name${truncated ? '.*' : ''} \\[E\\]';
  }

  return _toPattern(bestLine).$1;
}

/// `error: -[Module.Class testMethod] : message`, capturing the class and the
/// message.
final RegExp _xctestFailure = RegExp(r'error: -\[(?:\w+\.)?(\w+) test\w*\] : (.+)$');

/// Parts of a log line that differ between bots or commits: absolute
/// directories (e.g. `/Volumes/Work/s/w/` or `C:\b\s\w\`), and the line and
/// column numbers of source locations (e.g. the `:12:4` in `foo.dart:12:4`).
final RegExp _variablePart = RegExp(r'(?<!\S)(?:[A-Za-z]:\\|/)\S*[/\\]|(?<=\w):\d+(?=[:)\s]|$)');

/// Converts log text into a regex that matches it on any bot and commit.
///
/// Absolute directories become `.*` (keeping the file name), line numbers
/// become `:\d+`, and the literal text is cut to about [maxLength] characters,
/// on a word boundary where possible. Also returns whether it was cut, since a
/// cut pattern can't be followed by text that must be adjacent.
(String, bool) _toPattern(String text, {int maxLength = 70}) {
  final pattern = StringBuffer();
  var remaining = maxLength;
  var truncated = false;

  void addLiteral(String literal) {
    if (literal.length <= remaining) {
      pattern.write(_escape(literal));
      remaining -= literal.length;
      return;
    }
    String cut = literal.substring(0, remaining);
    final int space = cut.lastIndexOf(' ');
    if (space > cut.length ~/ 2) {
      cut = cut.substring(0, space);
    }
    pattern.write(_escape(cut.trimRight()));
    remaining = 0;
    truncated = true;
  }

  var position = 0;
  for (final RegExpMatch variable in _variablePart.allMatches(text)) {
    addLiteral(text.substring(position, variable.start));
    if (truncated) {
      break;
    }
    pattern.write(variable.group(0)!.startsWith(':') ? r':\d+' : '.*');
    position = variable.end;
  }
  if (!truncated) {
    addLiteral(text.substring(position));
  }
  return (pattern.toString(), truncated);
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
  final DateTime? start = parseBuildTime(build['startTime'] as String?);
  final DateTime? end = parseBuildTime(build['endTime'] as String?);
  if (start == null || end == null) {
    return null;
  }
  return end.difference(start).inSeconds / 60.0;
}

/// Where a hung step stopped.
class Hang {
  /// Creates a hang description.
  Hang(this.lines, this.match);

  /// Human-readable description of where the step stopped.
  final List<String> lines;

  /// A `--match` regex for the last test/benchmark that was running.
  final String? match;
}

/// Describes where a cancelled step's log stopped.
Hang extractHang(List<String> lines, int maxLines) {
  final List<String> clean = lines.map((String line) => line.replaceAll(ansi, '').trim()).toList();
  String? package;
  for (final line in clean) {
    final RegExpMatch? context = packageContext.firstMatch(line);
    if (context != null) {
      package = context.group(1);
    }
  }

  final List<String> activities = clean.where(activity.hasMatch).toList();
  final List<String> nonEmpty = clean.where((String l) => l.isNotEmpty).toList();
  final Iterable<String> tail = nonEmpty.skip(nonEmpty.length > 3 ? nonEmpty.length - 3 : 0);
  final List<String> recentActivity = activities
      .skip(activities.length > 4 ? activities.length - 4 : 0)
      .map((String l) => ci_lib.truncate(l, 200))
      .toList();

  final rendered = <String>[
    'last package: ${package ?? '?'}',
    for (final String line in recentActivity.take(maxLines)) 'last activity: $line',
    for (final String line in tail)
      if (!recentActivity.contains(ci_lib.truncate(line, 200))) 'log ends: $line',
  ];

  String? match;
  for (final String line in activities.reversed) {
    final RegExpMatch? progress = dartProgress.firstMatch(line);
    if (progress != null) {
      match = _toPattern(progress.group(1)!).$1;
      break;
    }
    if (line.startsWith('Launching benchmark')) {
      match = _toPattern(line).$1;
      break;
    }
  }

  return Hang(rendered, match);
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
/// Each entry includes a `match_text` field holding the text that
/// `flake_history.dart` matches against: the whole log for failed steps, and
/// only the last [hangTailLines] lines for hung steps.
Future<List<Map<String, dynamic>>> analyzeSteps(
  String buildId,
  Map<String, dynamic> build,
  int maxLines,
) async {
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

    final String text = await ci_lib.fetchLog(url);
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

    final List<String> lines = text.split('\n');
    entry['error_packages'] = extractErrorPackages(lines);

    if (kind == 'hung') {
      final Hang hang = extractHang(lines, maxLines);
      entry['signature'] = hang.lines;
      entry['suggested_match'] = hang.match;
      entry['match_text'] = lines
          .skip(lines.length > hangTailLines ? lines.length - hangTailLines : 0)
          .map((String line) => line.replaceAll(ansi, ''))
          .join('\n');
    } else {
      final Signature signature = extractSignature(lines, maxLines);
      entry['signature'] = signature.lines;
      entry['suggested_match'] = suggestMatch(signature.best);
      entry['match_text'] = text;

      if (signature.lines.isEmpty) {
        final List<String> nonEmpty = lines
            .map((String l) => l.trim())
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
