// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: avoid_print

////////////////////////////////////////////////////////////////////////////////
/// Script for running the native interop benchmarks.
///
/// usage: `dart run tool/benchmark.dart --platform <android|ios|macos>`
///
/// Writes a temporary benchmark target to the test plugin's example app, runs
/// it in release mode, and prints a comparison table of the results. Benchmarks
/// compare platform channels with native interop on the same payloads, so run
/// them on each platform that you change.
////////////////////////////////////////////////////////////////////////////////
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:meta/meta.dart';

import 'shared/flutter_utils.dart';

const String _platformOption = 'platform';
const String _deviceOption = 'device';

/// Prefix for benchmark output lines printed by the test app.
///
/// Each line has the form `PIGEON_BENCHMARK|<json>`.
const String _resultPrefix = 'PIGEON_BENCHMARK|';
const String _examplePath = 'platform_tests/test_plugin/example';
const String _target = 'integration_test/_native_interop_benchmarks.dart';

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

  final List<BenchmarkResult> results = await _run(device);
  if (results.isEmpty) {
    print('The benchmarks did not report any results.');
    exit(1);
  }
  _printTable(results);
}

/// Summary statistics for a single benchmark case and transport.
@visibleForTesting
class BenchmarkResult {
  /// Creates a [BenchmarkResult].
  BenchmarkResult(this.name, this.transport, this.median, this.p90, this.samples);

  /// The name of the benchmark case (for example, `large_class_roundtrip`).
  final String name;

  /// The transport mechanism used (`channel` or `native_interop`).
  final String transport;

  /// The median round-trip duration in microseconds.
  final double median;

  /// The 90th-percentile round-trip duration in microseconds.
  final double p90;

  /// The number of timed iterations recorded for this benchmark case.
  final int samples;
}

/// Parses a single stdout/stderr [line] from the benchmark runner, returning a
/// [BenchmarkResult] if the line contains a JSON benchmark record.
@visibleForTesting
BenchmarkResult? parseBenchmarkLine(String line) {
  if (!line.contains(_resultPrefix)) {
    return null;
  }
  final int start = line.indexOf(_resultPrefix);
  final json = jsonDecode(line.substring(start + _resultPrefix.length)) as Map<String, Object?>;
  return BenchmarkResult(
    json['name']! as String,
    json['transport']! as String,
    (json['median']! as num).toDouble(),
    (json['p90']! as num).toDouble(),
    (json['samples']! as num).toInt(),
  );
}

/// Runs the benchmarks on [device] in release mode and returns the results.
///
/// Neither `flutter test` nor `flutter drive` supports release mode on mobile
/// devices, so this writes a temporary target file to the test plugin's example
/// app, runs it as the app's entrypoint with `flutter run --release`, and waits
/// for `flutter_test` to print its summary.
Future<List<BenchmarkResult>> _run(String device) async {
  final targetFile = File('$_examplePath/$_target')..writeAsStringSync(_benchmarkTargetSource);
  try {
    final Process process = await Process.start(getFlutterCommand(), <String>[
      'run',
      '--release',
      '--target',
      _target,
      '--device-id',
      device,
    ], workingDirectory: _examplePath);

    final results = <BenchmarkResult>[];
    final done = Completer<void>();
    void handleLine(String line) {
      if (line.contains(_resultPrefix)) {
        final int start = line.indexOf(_resultPrefix);
        final BenchmarkResult result = parseBenchmarkLine(line)!;
        if (result.samples > 0) {
          results.add(result);
        }
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
  } finally {
    if (targetFile.existsSync()) {
      targetFile.deleteSync();
    }
  }
}

/// Formats [results] as Markdown table lines comparing `channel` and
/// `native_interop` transports.
@visibleForTesting
List<String> formatBenchmarkTable(List<BenchmarkResult> results) {
  String format(double microseconds) => microseconds >= 1000
      ? '${(microseconds / 1000).toStringAsFixed(2)} ms'
      : '${microseconds.toStringAsFixed(2)} µs';

  final resultsByCase = <String, Map<String, BenchmarkResult>>{};
  for (final result in results) {
    (resultsByCase[result.name] ??= <String, BenchmarkResult>{})[result.transport] = result;
  }
  final lines = <String>[
    '| Case | Channel median | Native interop median | Native interop p90 | Ratio |',
    '| :--- | ---: | ---: | ---: | ---: |',
  ];
  for (final String name in resultsByCase.keys) {
    final Map<String, BenchmarkResult> byTransport = resultsByCase[name]!;
    final BenchmarkResult? channel = byTransport['channel'];
    final BenchmarkResult? interop = byTransport['native_interop'];
    final ratio = channel == null || interop == null
        ? ''
        : '${(channel.median / interop.median).toStringAsFixed(2)}x';
    lines.add(
      '| $name | ${channel == null ? '' : format(channel.median)} | '
      '${interop == null ? '' : format(interop.median)} | '
      '${interop == null ? '' : format(interop.p90)} | $ratio |',
    );
  }
  return lines;
}

void _printTable(List<BenchmarkResult> results) {
  print('');
  formatBenchmarkTable(results).forEach(print);
}

const String _benchmarkTargetSource =
    '''
// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: avoid_print, implementation_imports

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_test_plugin_code/generated.dart' as core;
import 'package:shared_test_plugin_code/integration_tests.dart'
    show FlutterApiTestImplementation;
import 'package:shared_test_plugin_code/native_interop_integration_tests.dart'
    show NativeInteropFlutterIntegrationCoreApiImpl;
import 'package:shared_test_plugin_code/native_interop_test_types.dart'
    as native_interop_types;
import 'package:shared_test_plugin_code/src/generated/native_interop_tests.gen.dart'
    as native_interop;
import 'package:shared_test_plugin_code/test_types.dart' as core_types;

/// The longest that warm-up runs for each case.
const Duration _maxWarmUp = Duration(milliseconds: 500);

/// The longest that sampling runs for each case, after the minimum number of
/// samples.
const Duration _maxSampling = Duration(seconds: 5);

const int _maxWarmUpIterations = 20;
const int _minSamples = 5;
const int _maxSamples = 201;

/// Each sample batches enough calls to take at least this long, so that
/// timer resolution doesn't dominate fast calls.
const int _minSampleMicroseconds = 200;

class _Result {
  _Result(this.medianMicroseconds, this.p90Microseconds, this.samples);

  final double medianMicroseconds;
  final double p90Microseconds;
  final int samples;
}

_Result _summarize(List<double> samples) {
  samples.sort();
  double percentile(double p) =>
      samples[min(samples.length - 1, (samples.length * p).floor())];
  return _Result(percentile(0.5), percentile(0.9), samples.length);
}

/// Measures [call], which completes synchronously.
_Result _measureSync(void Function() call) {
  final warmUp = Stopwatch()..start();
  for (var i = 0; i < _maxWarmUpIterations && warmUp.elapsed < _maxWarmUp; i++) {
    call();
  }
  final probe = Stopwatch()..start();
  call();
  final int batch =
      max(1, (_minSampleMicroseconds / max(1, probe.elapsedMicroseconds)).ceil());
  final samples = <double>[];
  final sampling = Stopwatch()..start();
  final sample = Stopwatch();
  while (samples.length < _maxSamples &&
      (samples.length < _minSamples || sampling.elapsed < _maxSampling)) {
    sample
      ..reset()
      ..start();
    for (var i = 0; i < batch; i++) {
      call();
    }
    sample.stop();
    samples.add(sample.elapsedMicroseconds / batch);
  }
  return _summarize(samples);
}

/// Measures [call], which completes asynchronously.
Future<_Result> _measureAsync(Future<void> Function() call) async {
  final warmUp = Stopwatch()..start();
  for (var i = 0; i < _maxWarmUpIterations && warmUp.elapsed < _maxWarmUp; i++) {
    await call();
  }
  final probe = Stopwatch()..start();
  await call();
  final int batch =
      max(1, (_minSampleMicroseconds / max(1, probe.elapsedMicroseconds)).ceil());
  final samples = <double>[];
  final sampling = Stopwatch()..start();
  final sample = Stopwatch();
  while (samples.length < _maxSamples &&
      (samples.length < _minSamples || sampling.elapsed < _maxSampling)) {
    sample
      ..reset()
      ..start();
    for (var i = 0; i < batch; i++) {
      await call();
    }
    sample.stop();
    samples.add(sample.elapsedMicroseconds / batch);
  }
  return _summarize(samples);
}

void _report(String name, String transport, _Result result) {
  final String payload = jsonEncode(<String, Object>{
    'name': name,
    'transport': transport,
    'median': result.medianMicroseconds,
    'p90': result.p90Microseconds,
    'samples': result.samples,
  });
  print('$_resultPrefix\$payload');
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('native interop benchmarks', (WidgetTester _) async {
    final channelApi = core.HostIntegrationCoreApi();
    final native_interop.NativeInteropHostIntegrationCoreApiForNativeInterop
        interopApi = native_interop
            .NativeInteropHostIntegrationCoreApiForNativeInterop.getInstance()!;
    core.FlutterIntegrationCoreApi.setUp(FlutterApiTestImplementation());
    native_interop.NativeInteropFlutterIntegrationCoreApiRegistrar().register(
      NativeInteropFlutterIntegrationCoreApiImpl(),
    );

    Future<void> both(
      String name,
      Future<void> Function() channel,
      void Function() interop,
    ) async {
      _report(name, 'channel', await _measureAsync(channel));
      _report(name, 'native_interop', _measureSync(interop));
    }

    await both('noop', channelApi.noop, interopApi.noop);
    await both(
      'echoInt',
      () => channelApi.echoInt(42),
      () => interopApi.echoInt(42),
    );
    await both(
      'echoString',
      () => channelApi.echoString('Hello Pigeon!'),
      () => interopApi.echoString('Hello Pigeon!'),
    );

    final bytes = Uint8List(1024 * 1024);
    for (var i = 0; i < bytes.length; i++) {
      bytes[i] = i % 256;
    }
    await both(
      'echoUint8List 1MB',
      () => channelApi.echoUint8List(bytes),
      () => interopApi.echoUint8List(bytes),
    );

    await both(
      'echoAllTypes',
      () => channelApi.echoAllTypes(core_types.genericAllTypes),
      () => interopApi.echoAllTypes(
        native_interop_types.genericNativeInteropAllTypes,
      ),
    );

    for (final count in <int>[1, 10, 100, 1000]) {
      final channelList = List<core.AllNullableTypes?>.filled(
        count,
        core_types.genericAllNullableTypes,
      );
      final interopList =
          List<native_interop.NativeInteropAllNullableTypes?>.filled(
            count,
            native_interop_types.genericNativeInteropAllNullableTypes,
          );
      await both(
        'echoClassList AllNullableTypes x\$count',
        () => channelApi.echoClassList(channelList),
        () => interopApi.echoClassList(interopList),
      );
    }

    for (final count in <int>[10, 100, 1000, 10000]) {
      final ints = List<int?>.generate(count, (int i) => i);
      await both(
        'echoIntList x\$count',
        () => channelApi.echoIntList(ints),
        () => interopApi.echoIntList(ints),
      );
    }

    final intMap = <int?, int?>{for (var i = 0; i < 1000; i++) i: i};
    await both(
      'echoIntMap x1000',
      () => channelApi.echoIntMap(intMap),
      () => interopApi.echoIntMap(intMap),
    );

    final channelFlutterList = List<core.AllNullableTypes?>.filled(
      100,
      core_types.genericAllNullableTypes,
    );
    final interopFlutterList =
        List<native_interop.NativeInteropAllNullableTypes?>.filled(
          100,
          native_interop_types.genericNativeInteropAllNullableTypes,
        );
    await both(
      'callFlutterEchoClassList AllNullableTypes x100',
      () => channelApi.callFlutterEchoClassList(channelFlutterList),
      () => interopApi.callFlutterEchoClassList(interopFlutterList),
    );
  }, timeout: const Timeout(Duration(minutes: 30)));
}
''';
