// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:ci_info/ci_lib.dart' as ci_lib;
import 'package:ci_info/failure_analysis.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

void main() {
  group('extractSignature', () {
    test('handles short lines containing multi-digit numbers', () {
      // Regression test: dedup keys were truncated using the length of the
      // un-normalized line, which threw a RangeError for exactly these lines.
      final List<String> signature = extractSignature(<String>[
        '00:05 +12 -1: my widget test [E]',
        'pkg.FooTest > bar[emulator-5554] FAILED',
      ], 12);

      expect(signature, <String>[
        '00:05 +12 -1: my widget test [E]',
        'pkg.FooTest > bar[emulator-5554] FAILED',
      ]);
    });

    test('strips ANSI codes and prefixes the owning package', () {
      final List<String> signature = extractSignature(<String>[
        '|| Running for packages/camera/camera_android',
        '\x1b[31mcom.example.CameraTest > takePicture FAILED\x1b[0m',
      ], 12);

      expect(signature, <String>[
        '[packages/camera/camera_android] com.example.CameraTest > takePicture FAILED',
      ]);
    });

    test('prefixes a line whenever the owning package changes', () {
      final List<String> signature = extractSignature(<String>[
        '|| Running for packages/foo',
        'Error: foo broke',
        'Error: foo broke again',
        '|| Running for packages/bar',
        'Error: bar broke',
      ], 12);

      expect(signature, <String>[
        '[packages/foo] Error: foo broke',
        'Error: foo broke again',
        '[packages/bar] Error: bar broke',
      ]);
    });

    test('prefers the error over matcher output when trimming to maxLines', () {
      final List<String> signature = extractSignature(<String>[
        'DriverError: Error while reading FlutterDriver result',
        '  Actual: <null>',
      ], 1);

      expect(signature, <String>['DriverError: Error while reading FlutterDriver result']);
    });

    test('dedups lines that differ only in digits', () {
      final List<String> signature = extractSignature(<String>[
        'Error: timed out after 100ms',
        'Error: timed out after 250ms',
      ], 12);

      expect(signature, <String>['Error: timed out after 100ms']);
    });

    test('ignores noise and respects maxLines', () {
      final List<String> signature = extractSignature(<String>[
        'Run with --stacktrace option to get the stack trace.',
        '00:01 +1 -1: a [E]',
        '00:02 +1 -2: b [E]',
        '00:03 +1 -3: c [E]',
      ], 2);

      expect(signature, <String>['00:01 +1 -1: a [E]', '00:02 +1 -2: b [E]']);
    });

    test('returns no lines when nothing matches', () {
      final List<String> signature = extractSignature(<String>['all good'], 12);

      expect(signature, isEmpty);
    });
  });

  group('extractErrorPackages', () {
    test('ignores ANSI color codes', () {
      expect(
        extractErrorPackages(<String>[
          '\x1b[31mThe following packages had errors:\x1b[0m',
          '\x1b[31m  packages/foo:\x1b[0m',
          '\x1b[31m      Missing CHANGELOG change\x1b[0m',
          '',
        ]),
        <String>['packages/foo (Missing CHANGELOG change)'],
      );
    });

    test('parses packages and indented reasons', () {
      expect(
        extractErrorPackages(<String>[
          'noise',
          'The following packages had errors:',
          '  packages/foo:',
          '      Missing CHANGELOG change',
          '  packages/bar',
          '',
          'packages/ignored',
        ]),
        <String>['packages/foo (Missing CHANGELOG change)', 'packages/bar'],
      );
    });
  });

  group('extractHang', () {
    test('reports the last package and activity', () {
      final List<String> hang = extractHang(<String>[
        '[1:02] Running for packages/video_player/video_player',
        '00:10 +3: plays video',
        '100:10 +4: seeks video',
        'still waiting...',
      ], 12);

      expect(hang, <String>[
        'last package: packages/video_player/video_player',
        'last activity: [1:02] Running for packages/video_player/video_player',
        'last activity: 00:10 +3: plays video',
        'last activity: 100:10 +4: seeks video',
        'log ends: still waiting...',
      ]);
    });

    test('truncates long final lines', () {
      final List<String> hang = extractHang(<String>['x' * 500], 12);

      expect(hang.last, 'log ends: ${'x' * 200}');
    });

    test('keeps the newest lines when trimming to maxLines', () {
      final List<String> hang = extractHang(<String>[
        '00:01 +1: a',
        '00:02 +2: b',
        '00:03 +3: c',
        'tail 1',
        'tail 2',
      ], 2);

      expect(hang, <String>['last package: ?', 'log ends: tail 2']);
    });
  });

  group('step selection', () {
    final build = <String, dynamic>{
      'status': 'INFRA_FAILURE',
      'steps': <Map<String, dynamic>>[
        <String, dynamic>{'name': 'run tests', 'status': 'FAILURE'},
        <String, dynamic>{'name': 'run tests|shard 1', 'status': 'FAILURE'},
        <String, dynamic>{'name': 'run tests|shard 2', 'status': 'SUCCESS'},
        <String, dynamic>{
          'name': 'native tests',
          'status': 'CANCELED',
          'logs': <Map<String, dynamic>>[
            <String, dynamic>{'name': 'stdout'},
          ],
        },
        <String, dynamic>{
          'name': 'reset XCode',
          'status': 'CANCELED',
          'logs': <Map<String, dynamic>>[],
        },
      ],
    };

    test('failedLeafSteps skips parents of failed steps', () {
      expect(failedLeafSteps(build).map((Map<String, dynamic> s) => s['name']), <String>[
        'run tests|shard 1',
      ]);
    });

    test('hungLeafSteps only returns cancelled steps with stdout', () {
      expect(hungLeafSteps(build).map((Map<String, dynamic> s) => s['name']), <String>[
        'native tests',
      ]);
    });

    test('hungLeafSteps ignores successful builds', () {
      expect(hungLeafSteps(<String, dynamic>{...build, 'status': 'SUCCESS'}), isEmpty);
    });
  });

  group('buildMinutes', () {
    test('handles nanosecond timestamps', () {
      expect(
        buildMinutes(<String, dynamic>{
          'startTime': '2026-09-24T18:00:00.123456789Z',
          'endTime': '2026-09-24T18:30:00.987654321Z',
        }),
        30,
      );
    });

    test('returns null when a time is missing or invalid', () {
      expect(buildMinutes(<String, dynamic>{'startTime': 'x'}), isNull);
      expect(buildMinutes(<String, dynamic>{'startTime': 'x', 'endTime': 'y'}), isNull);
    });
  });

  group('analyzeSteps', () {
    late Directory tempCache;

    setUp(() {
      tempCache = Directory.systemTemp.createTempSync('ci_info_test_');
      ci_lib.cacheDirOverride = tempCache.path;
    });

    tearDown(() {
      ci_lib.cacheDirOverride = null;
      tempCache.deleteSync(recursive: true);
    });

    Map<String, dynamic> stdoutLog(String name) => <String, dynamic>{
      'name': 'stdout',
      'viewUrl': 'https://logs.chromium.org/logs/$name/stdout',
    };

    /// Serves each log by the name in its URL, or a 404 for unknown names.
    MockClient logServer(Map<String, (int, String)> logs) {
      return MockClient((http.Request request) async {
        final String name = request.url.pathSegments[1];
        final (int status, String body) = logs[name] ?? (404, '');
        return http.Response(body, status);
      });
    }

    test('summarizes failed and hung steps', () async {
      final build = <String, dynamic>{
        'status': 'INFRA_FAILURE',
        'steps': <Map<String, dynamic>>[
          <String, dynamic>{
            'name': 'unit tests',
            'status': 'FAILURE',
            'logs': <Map<String, dynamic>>[stdoutLog('unit')],
          },
          <String, dynamic>{
            'name': 'native tests',
            'status': 'CANCELED',
            'logs': <Map<String, dynamic>>[stdoutLog('native')],
          },
        ],
      };

      final List<Map<String, dynamic>> steps = await analyzeSteps(
        '1',
        build,
        12,
        client: logServer(<String, (int, String)>{
          'unit': (
            200,
            '00:05 +1 -1: my test [E]\r\nThe following packages had errors:\r\n  packages/foo\r\n',
          ),
          'native': (200, '|| Running for packages/bar\n00:01 +1: still going'),
        }),
      );

      expect(steps, hasLength(2));
      expect(steps[0]['kind'], 'failed');
      expect(steps[0]['signature'], <String>['00:05 +1 -1: my test [E]']);
      expect(steps[0]['error_packages'], <String>['packages/foo']);
      expect(steps[1]['kind'], 'hung');
      expect(steps[1]['signature'], contains('last package: packages/bar'));
    });

    test('reports missing and inaccessible logs', () async {
      final build = <String, dynamic>{
        'status': 'FAILURE',
        'steps': <Map<String, dynamic>>[
          <String, dynamic>{
            'name': 'purged',
            'status': 'FAILURE',
            'logs': <Map<String, dynamic>>[stdoutLog('purged')],
          },
          <String, dynamic>{
            'name': 'private',
            'status': 'FAILURE',
            'logs': <Map<String, dynamic>>[stdoutLog('private')],
          },
          <String, dynamic>{
            'name': 'cleanup',
            'status': 'FAILURE',
            'logs': <Map<String, dynamic>>[
              <String, dynamic>{'name': 'json.output'},
            ],
          },
        ],
      };

      final List<Map<String, dynamic>> steps = await analyzeSteps(
        '1',
        build,
        12,
        client: logServer(<String, (int, String)>{'private': (403, '')}),
      );

      expect(steps.map((Map<String, dynamic> s) => s['error']), <Object>[
        contains('purged'),
        contains('inaccessible'),
        contains('no stdout log'),
      ]);
    });

    test('falls back to the log tail without ANSI codes', () async {
      final build = <String, dynamic>{
        'status': 'FAILURE',
        'steps': <Map<String, dynamic>>[
          <String, dynamic>{
            'name': 'mystery',
            'status': 'FAILURE',
            'logs': <Map<String, dynamic>>[stdoutLog('mystery')],
          },
        ],
      };

      final List<Map<String, dynamic>> steps = await analyzeSteps(
        '1',
        build,
        2,
        client: logServer(<String, (int, String)>{
          'mystery': (200, 'one\n\x1b[33mtwo\x1b[0m\nthree'),
        }),
      );

      expect(steps.single['signature'], <String>['two', 'three']);
      expect(steps.single['signature_is_fallback'], isTrue);
    });
  });
}
