// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: avoid_print

////////////////////////////////////////////////////////////////////////////////
/// Script for running the native interop benchmarks.
///
/// usage: `dart run tool/benchmark.dart --platform <android|ios|macos>`
///
/// Runs `platform_tests/shared_test_plugin_code/lib/native_interop_benchmarks.dart`
/// in a release build of the test plugin's example app, then prints a table
/// of the results. Benchmarks compare platform channels with native interop on
/// the same payloads, so run them on each platform that you change.
////////////////////////////////////////////////////////////////////////////////
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';

import 'shared/flutter_utils.dart';

const String _platformOption = 'platform';
const String _deviceOption = 'device';
const String _resultPrefix = 'PIGEON_BENCHMARK|';
const String _examplePath = 'platform_tests/test_plugin/example';
const String _target = 'integration_test/native_interop_benchmarks.dart';

Future<void> main(List<String> args) async {
  final parser = ArgParser()
    ..addOption(
      _platformOption,
      allowed: <String>['android', 'ios', 'macos'],
      defaultsTo: Platform.isMacOS ? 'macos' : 'android',
      help: 'The platform to benchmark.',
    )
    ..addOption(_deviceOption, help: 'The device ID. Defaults to the first device of the platform.')
    ..addFlag('help', negatable: false, abbr: 'h', help: 'Print this reference.');
  final ArgResults argResults = parser.parse(args);
  if (argResults.flag('help')) {
    print('usage: dart run tool/benchmark.dart [options]\n\n${parser.usage}');
    exit(0);
  }

  final platform = argResults[_platformOption] as String;
  final String? device =
      argResults[_deviceOption] as String? ??
      (platform == 'macos' ? 'macos' : await getDeviceForPlatform(platform));
  if (device == null) {
    print('No $platform device is available.');
    exit(1);
  }

  final List<_Result> results = await _run(device);
  if (results.isEmpty) {
    print('The benchmarks did not report any results.');
    exit(1);
  }
  _printTable(results);
}

class _Result {
  _Result(this.name, this.transport, this.median, this.p90, this.samples);

  final String name;
  final String transport;
  final double median;
  final double p90;
  final int samples;
}

/// Runs the benchmarks on [device] in release mode and returns the results.
///
/// Neither `flutter test` nor `flutter drive` supports release mode on mobile
/// devices, so this runs the benchmarks as the app's entrypoint with
/// `flutter run` and waits for `flutter_test` to print its summary.
Future<List<_Result>> _run(String device) async {
  final Process process = await Process.start(getFlutterCommand(), <String>[
    'run',
    '--release',
    '--target',
    _target,
    '--device-id',
    device,
  ], workingDirectory: _examplePath);

  final results = <_Result>[];
  final done = Completer<void>();
  void handleLine(String line) {
    final int start = line.indexOf(_resultPrefix);
    if (start >= 0) {
      final List<String> fields = line.substring(start + _resultPrefix.length).split('|');
      results.add(
        _Result(
          fields[0],
          fields[1],
          double.parse(fields[2]),
          double.parse(fields[3]),
          int.parse(fields[4]),
        ),
      );
      print(line.substring(start));
    } else if (line.contains('All tests passed!') || line.contains('Some tests failed.')) {
      if (!done.isCompleted) {
        done.complete();
      }
    } else if (line.contains('Error') || line.contains('Exception')) {
      print(line);
    }
  }

  final List<StreamSubscription<String>> subscriptions =
      <Stream<List<int>>>[process.stdout, process.stderr].map((Stream<List<int>> output) {
        return output.transform(utf8.decoder).transform(const LineSplitter()).listen(handleLine);
      }).toList();
  unawaited(
    process.exitCode.then((int _) {
      if (!done.isCompleted) {
        done.complete();
      }
    }),
  );

  try {
    await done.future.timeout(const Duration(minutes: 30));
  } finally {
    process.kill();
    await process.exitCode.timeout(
      const Duration(minutes: 1),
      onTimeout: () {
        process.kill(ProcessSignal.sigkill);
        return process.exitCode;
      },
    );
    await Future.wait(subscriptions.map((StreamSubscription<String> s) => s.cancel()));
  }
  return results;
}

void _printTable(List<_Result> results) {
  String format(double microseconds) => microseconds >= 1000
      ? '${(microseconds / 1000).toStringAsFixed(2)} ms'
      : '${microseconds.toStringAsFixed(2)} µs';

  final names = <String>[];
  final byName = <String, Map<String, _Result>>{};
  for (final result in results) {
    if (!byName.containsKey(result.name)) {
      names.add(result.name);
    }
    (byName[result.name] ??= <String, _Result>{})[result.transport] = result;
  }
  print('');
  print('| Case | Channel median | Native interop median | Native interop p90 | Ratio |');
  print('| :--- | ---: | ---: | ---: | ---: |');
  for (final name in names) {
    final _Result? channel = byName[name]!['channel'];
    final _Result? interop = byName[name]!['native_interop'];
    final ratio = channel == null || interop == null
        ? ''
        : '${(channel.median / interop.median).toStringAsFixed(2)}x';
    print(
      '| $name | ${channel == null ? '' : format(channel.median)} | '
      '${interop == null ? '' : format(interop.median)} | '
      '${interop == null ? '' : format(interop.p90)} | $ratio |',
    );
  }
}
