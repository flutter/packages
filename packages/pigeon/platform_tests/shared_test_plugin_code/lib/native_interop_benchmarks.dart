// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: avoid_print

import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'integration_tests.dart' show FlutterApiTestImplementation;
import 'native_interop_integration_tests.dart';
import 'native_interop_test_types.dart' as native_interop_types;
import 'src/generated/core_tests.gen.dart' as core;
import 'src/generated/native_interop_tests.gen.dart' as native_interop;
import 'test_types.dart' as core_types;

/// The prefix of the lines that report benchmark results.
///
/// Each line has the form
/// `PIGEON_BENCHMARK|<case>|<transport>|<median µs>|<p90 µs>|<samples>`, so
/// that `tool/benchmark.dart` can collect them.
const String benchmarkResultPrefix = 'PIGEON_BENCHMARK';

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
  double percentile(double p) => samples[min(samples.length - 1, (samples.length * p).floor())];
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
  final int batch = max(1, (_minSampleMicroseconds / max(1, probe.elapsedMicroseconds)).ceil());
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
  final int batch = max(1, (_minSampleMicroseconds / max(1, probe.elapsedMicroseconds)).ceil());
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
  print(
    '$benchmarkResultPrefix|$name|$transport|${result.medianMicroseconds.toStringAsFixed(2)}|'
    '${result.p90Microseconds.toStringAsFixed(2)}|${result.samples}',
  );
}

/// Runs benchmarks that compare platform channels with native interop on the
/// same payloads.
///
/// Run these in release mode with `tool/benchmark.dart`, since debug builds
/// exaggerate every cost.
void runNativeInteropBenchmarks(TargetGenerator targetGenerator) {
  testWidgets('native interop benchmarks', (WidgetTester _) async {
    final channelApi = core.HostIntegrationCoreApi();
    final native_interop.NativeInteropHostIntegrationCoreApiForNativeInterop interopApi =
        native_interop.NativeInteropHostIntegrationCoreApiForNativeInterop.getInstance()!;
    core.FlutterIntegrationCoreApi.setUp(FlutterApiTestImplementation());
    native_interop.NativeInteropFlutterIntegrationCoreApiRegistrar().register(
      NativeInteropFlutterIntegrationCoreApiImpl(),
    );

    Future<void> both(String name, Future<void> Function() channel, void Function() interop) async {
      _report(name, 'channel', await _measureAsync(channel));
      _report(name, 'native_interop', _measureSync(interop));
    }

    await both('noop', channelApi.noop, interopApi.noop);
    await both('echoInt', () => channelApi.echoInt(42), () => interopApi.echoInt(42));
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
      () => interopApi.echoAllTypes(native_interop_types.genericNativeInteropAllTypes),
    );

    for (final count in <int>[1, 10, 100, 1000]) {
      final channelList = List<core.AllNullableTypes?>.filled(
        count,
        core_types.genericAllNullableTypes,
      );
      final interopList = List<native_interop.NativeInteropAllNullableTypes?>.filled(
        count,
        native_interop_types.genericNativeInteropAllNullableTypes,
      );
      await both(
        'echoClassList AllNullableTypes x$count',
        () => channelApi.echoClassList(channelList),
        () => interopApi.echoClassList(interopList),
      );
    }

    for (final count in <int>[10, 100, 1000, 10000]) {
      final ints = List<int?>.generate(count, (int i) => i);
      await both(
        'echoIntList x$count',
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
    final interopFlutterList = List<native_interop.NativeInteropAllNullableTypes?>.filled(
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
