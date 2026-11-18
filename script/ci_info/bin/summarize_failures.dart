// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:ci_info/ci_lib.dart' as ci_lib;
import 'package:ci_info/failure_analysis.dart';

const String _maxLinesOption = 'max-lines';
const String _jsonFlag = 'json';
const String _helpFlag = 'help';

Future<Map<String, dynamic>> _summarize(String buildId, int maxLines) async {
  final Map<String, dynamic> build = await ci_lib.getBuild(buildId, buildFields);
  final Map<String, dynamic> builder =
      build['builder'] as Map<String, dynamic>? ?? <String, dynamic>{};

  return <String, dynamic>{
    'id': buildId,
    'number': build['number'],
    'status': build['status'],
    'builder': ci_lib.stringField(builder, 'builder'),
    'url': ci_lib.miloBuildUrl(
      ci_lib.stringField(builder, 'project', defaultValue: 'flutter'),
      ci_lib.stringField(builder, 'bucket', defaultValue: 'prod'),
      ci_lib.stringField(builder, 'builder'),
      build['number'] as int?,
      buildId,
    ),
    'summary': ci_lib
        .stringField(build, 'summaryMarkdown', defaultValue: '')
        .replaceAll(RegExp(r'[\r\n]+'), ' ')
        .trim(),
    'minutes': buildMinutes(build)?.round(),
    'steps': await analyzeSteps(buildId, build, maxLines),
  };
}

void _render(Map<String, dynamic> result) {
  final header = StringBuffer('BUILD ${result['id']}  ${result['status']}  ${result['builder']}');
  if (result['number'] != null) {
    header.write(' #${result['number']}');
  }
  if (result['minutes'] != null) {
    header.write('  (${result['minutes']} min)');
  }
  print(header);
  print('  ${result['url']}');
  if ((result['summary'] as String).isNotEmpty) {
    print('  summary: ${result['summary']}');
  }

  final List<Map<String, dynamic>> steps = (result['steps'] as List<dynamic>)
      .cast<Map<String, dynamic>>();
  if (steps.isEmpty) {
    print(
      '  (no failing step with logs -- likely an infra failure; see summary '
      'above)',
    );
  }

  if (steps.any((Map<String, dynamic> step) => step['kind'] == 'hung')) {
    print(
      '  NOTE: a step was CANCELED mid-run, so this build most likely hit its '
      'execution timeout.',
    );
    if (steps.any((Map<String, dynamic> step) => step['kind'] == 'failed')) {
      print(
        '        The failed step below is probably just cleanup; the HUNG step '
        'is the real failure.',
      );
    }
  }

  for (final step in steps) {
    final hung = step['kind'] == 'hung';
    final title = hung ? 'HUNG STEP (cancelled at timeout)' : 'FAILED STEP';
    print('\n  $title: ${step['step']}');

    if (step.containsKey('error')) {
      print('    ${step['error']}');
      continue;
    }

    final List<String> errorPackages = (step['error_packages'] as List<dynamic>).cast<String>();
    if (errorPackages.isNotEmpty) {
      print('    packages with errors:');
      for (final package in errorPackages) {
        print('      - $package');
      }
    }

    final String label;
    if (hung) {
      label = 'where it stopped';
    } else if (step['signature_is_fallback'] == true) {
      label = 'log tail (no known pattern matched)';
    } else {
      label = 'signature';
    }

    print('    $label (${step['log_lines']} line log):');
    for (final String line in (step['signature'] as List<dynamic>).cast<String>()) {
      print('      $line');
    }

    print('    cached log: ${step['cached_log']}');
  }
  print('');
}

Future<void> main(List<String> args) async {
  final parser = ArgParser()
    ..addOption(_maxLinesOption, defaultsTo: '12', help: 'Signature lines per step.')
    ..addFlag(_jsonFlag, help: 'Output as JSON.')
    ..addFlag(_helpFlag, abbr: 'h', negatable: false, help: 'Print usage information.');

  final ArgResults parsedArgs;
  final int maxLines;
  try {
    parsedArgs = parser.parse(args);
    if (parsedArgs[_helpFlag] as bool) {
      print('Usage: summarize_failures <build_id> [<build_id> ...] [options]\n');
      print(parser.usage);
      return;
    }
    if (parsedArgs.rest.isEmpty) {
      throw const FormatException('Must specify at least one build ID.');
    }
    maxLines = int.parse(parsedArgs[_maxLinesOption] as String);
    if (maxLines < 1) {
      throw const FormatException('--$_maxLinesOption must be at least 1.');
    }
  } on FormatException catch (e) {
    stderr.writeln('Error: ${e.message}');
    stderr.writeln(parser.usage);
    exit(1);
  }

  final results = <Map<String, dynamic>>[];
  for (final String buildId in parsedArgs.rest) {
    try {
      results.add(await _summarize(buildId, maxLines));
    } on Exception catch (e) {
      stderr.writeln('BUILD $buildId: failed to summarize: $e');
      // Keep going so the other builds are still summarized, but report the
      // failure to callers.
      exitCode = 1;
    }
  }

  if (parsedArgs[_jsonFlag] as bool) {
    print(jsonEncode(results));
  } else {
    results.forEach(_render);
  }
}
