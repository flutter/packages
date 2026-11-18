// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:ci_info/failure_analysis.dart';
import 'package:test/test.dart';

void main() {
  group('extractSignature', () {
    test('handles short lines containing multi-digit numbers', () {
      // Regression test: dedup keys were truncated using the length of the
      // un-normalized line, which threw a RangeError for exactly these lines.
      final Signature signature = extractSignature(<String>[
        '00:05 +12 -1: my widget test [E]',
        'pkg.FooTest > bar[emulator-5554] FAILED',
      ], 12);

      expect(signature.lines, <String>[
        '00:05 +12 -1: my widget test [E]',
        'pkg.FooTest > bar[emulator-5554] FAILED',
      ]);
      expect(signature.best, 'pkg.FooTest > bar[emulator-5554] FAILED');
    });

    test('strips ANSI codes and prefixes the owning package', () {
      final Signature signature = extractSignature(<String>[
        '|| Running for packages/camera/camera_android',
        '\x1b[31mcom.example.CameraTest > takePicture FAILED\x1b[0m',
      ], 12);

      expect(signature.lines, <String>[
        '[packages/camera/camera_android] com.example.CameraTest > takePicture FAILED',
      ]);
    });

    test('dedups lines that differ only in digits', () {
      final Signature signature = extractSignature(<String>[
        'Error: timed out after 100ms',
        'Error: timed out after 250ms',
      ], 12);

      expect(signature.lines, <String>['Error: timed out after 100ms']);
    });

    test('ignores noise and respects maxLines', () {
      final Signature signature = extractSignature(<String>[
        'Run with --stacktrace option to get the stack trace.',
        '00:01 +1 -1: a [E]',
        '00:02 +1 -2: b [E]',
        '00:03 +1 -3: c [E]',
      ], 2);

      expect(signature.lines, <String>['00:01 +1 -1: a [E]', '00:02 +1 -2: b [E]']);
    });

    test('returns no lines when nothing matches', () {
      final Signature signature = extractSignature(<String>['all good'], 12);

      expect(signature.lines, isEmpty);
      expect(signature.best, isNull);
    });
  });

  group('suggestMatch', () {
    test('reduces JUnit lines to Class > method', () {
      expect(suggestMatch('io.flutter.FooTest > bar[device] FAILED'), 'FooTest > bar');
    });

    test('reduces Gradle Execute lines to Class.method', () {
      expect(suggestMatch('Execute io.flutter.FooTest.bar: FAILED'), r'FooTest\.bar');
    });

    test('keeps the [E] marker for Dart tests', () {
      expect(suggestMatch('00:05 +12 -1: my test (x) [E]'), r'my test \(x\) \[E\]');
    });

    test('escapes and truncates other lines', () {
      final String? match = suggestMatch('Bad state: ${'x' * 100}');
      expect(match, startsWith('Bad state: '));
      expect(match!.length, 70);
    });

    test('returns null without a best line', () {
      expect(suggestMatch(null), isNull);
    });

    test('escapes JUnit inner class names', () {
      const line = r'io.flutter.Foo$Bar > baz FAILED';
      final String match = suggestMatch(line)!;
      expect(match, r'Foo\$Bar > baz');
      expect(RegExp(match).hasMatch(line), isTrue);
    });

    group('always matches its own line', () {
      const segments = <String>[
        'packages',
        'packages',
        'webview_flutter',
        'webview_flutter',
        'example',
        'integration_test',
        'webview_flutter_test.dart',
      ];
      final macPath = '/Volumes/Work/s/w/ir/x/w/${segments.join('/')}';
      final String windowsPath = r'C:\b\s\w\ir\x\w\' + segments.join(r'\');
      final macLine = '00:00 +0 -1: loading $macPath [E]';
      final windowsLine = '00:00 +0 -1: loading $windowsPath [E]';
      final passingLine = '00:00 +1: loading $macPath';
      final String longName = 'a very long test name ' * 5;

      test('with an absolute path, on any bot', () {
        // Regression test: the name used to be cut mid-path and then had
        // ` \[E\]` appended, which matched nothing, not even its own build.
        final String match = suggestMatch(macLine)!;
        expect(match, r'loading .*webview_flutter_test\.dart \[E\]');
        expect(RegExp(match).hasMatch(macLine), isTrue);
        expect(RegExp(match).hasMatch(windowsLine), isTrue);
        expect(RegExp(match).hasMatch(passingLine), isFalse);
      });

      test('when the test name is truncated', () {
        final line = '00:05 +12 -1: $longName [E]';
        final String match = suggestMatch(line)!;
        expect(match, endsWith(r'.* \[E\]'));
        expect(RegExp(match).hasMatch(line), isTrue);
      });

      test('for fallback lines', () {
        final line = 'Bad state: $longName';
        expect(RegExp(suggestMatch(line)!).hasMatch(line), isTrue);
      });
    });

    test('reduces XCTest failures to class and message', () {
      String xctestLine(String test) =>
          '/Volumes/Work/s/w/ir/x/w/packages/packages/in_app_purchase/'
          'in_app_purchase_storekit/example/shared/RunnerTests/'
          'InAppPurchaseStoreKit2PluginTests.swift:628: error: '
          '-[RunnerTests.InAppPurchase2PluginTests $test] : '
          'Asynchronous wait failed: Exceeded timeout of 5 seconds, with '
          'unfulfilled expectations: "completed".';
      final String line = xctestLine('testDuplicatePurchaseFails');

      // Real lines are long; the message must survive signature extraction.
      final String match = suggestMatch(extractSignature(<String>[line], 12).best)!;

      expect(match, r'InAppPurchase2PluginTests test\w+\] : Asynchronous wait failed');
      expect(RegExp(match).hasMatch(line), isTrue);
      // Other tests in the class failing the same way should also match.
      expect(RegExp(match).hasMatch(xctestLine('testRestorePurchases')), isTrue);
    });

    test('replaces line numbers with wildcards', () {
      const line = 'Bad state: at foo.dart:123:45';

      final String match = suggestMatch(line)!;

      expect(match, contains(r':\d+:\d+'));
      expect(RegExp(match).hasMatch(line), isTrue);
      expect(RegExp(match).hasMatch('Bad state: at foo.dart:9:1'), isTrue);
    });
  });

  test('prefers the error over matcher output', () {
    const driverError =
        'DriverError: Error while reading FlutterDriver result for command: '
        r'''window.$flutterDriver('{"command":"request_data","timeout":"1200000"}')''';
    final Signature signature = extractSignature(<String>[
      driverError,
      'Original error: Expected: not null',
      '  Actual: <null>',
    ], 12);

    expect(signature.best, driverError);
    final String match = suggestMatch(signature.best)!;
    expect(match, 'DriverError: Error while reading FlutterDriver result for command:');
    expect(RegExp(match).hasMatch(driverError), isTrue);
  });

  group('extractErrorPackages', () {
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
    test('reports last package, activity, and a match for the last test', () {
      final Hang hang = extractHang(<String>[
        '[1:02] Running for packages/video_player/video_player',
        '00:10 +3: plays video',
        '100:10 +4: seeks video',
        'still waiting...',
      ], 12);

      expect(hang.lines, <String>[
        'last package: packages/video_player/video_player',
        'last activity: [1:02] Running for packages/video_player/video_player',
        'last activity: 00:10 +3: plays video',
        'last activity: 100:10 +4: seeks video',
        'log ends: still waiting...',
      ]);
      expect(hang.match, 'seeks video');
    });

    test('matches the last benchmark', () {
      final Hang hang = extractHang(<String>['Launching benchmark "scroll"'], 12);

      expect(hang.match, 'Launching benchmark "scroll"');
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
}
