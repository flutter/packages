// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
// ignore_for_file: avoid_print

import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:jni/jni.dart';

import 'integration_tests.dart' show FlutterApiTestImplementation;
import 'ni_integration_tests.dart';
import 'ni_test_types.dart' as ni_types;
import 'src/generated/core_tests.gen.dart' as core;
import 'src/generated/ni_tests.gen.dart' as ni;
import 'test_types.dart' as core_types;

/// Runs benchmarks comparing MethodChannel to Native Interop.
void runComparisonBenchmarks(TargetGenerator targetGenerator) {
  group('Comparison Benchmarks (MethodChannel vs Native Interop)', () {
    final mcApi = core.HostIntegrationCoreApi();
    final ni.NIHostIntegrationCoreApiForNativeInterop? niApi =
        ni.NIHostIntegrationCoreApiForNativeInterop.getInstance();

    core.FlutterIntegrationCoreApi.setUp(FlutterApiTestImplementation());
    final niRegistrar = ni.NIFlutterIntegrationCoreApiRegistrar();
    niRegistrar.register(NIFlutterIntegrationCoreApiImpl());

    testWidgets('Uint8List Echo 1MB Comparison', (WidgetTester _) async {
      const int size = 1024 * 1024;
      final data = Uint8List(size);
      for (var i = 0; i < size; i++) {
        data[i] = i % 256;
      }

      // MethodChannel
      final mcStopwatch = Stopwatch()..start();
      await mcApi.echoUint8List(data);
      mcStopwatch.stop();
      print('MC_BENCHMARK: 1MB Uint8List Echo took ${mcStopwatch.elapsedMilliseconds}ms');

      // Native Interop
      if (niApi != null) {
        final niStopwatch = Stopwatch()..start();
        niApi.echoUint8List(data);
        niStopwatch.stop();
        print('NI_BENCHMARK: 1MB Uint8List Echo took ${niStopwatch.elapsedMilliseconds}ms');
      } else {
        print('NI_BENCHMARK: Native Interop API not available');
      }
    });

    testWidgets('Large Object List 15 Comparison', (WidgetTester _) async {
      final coreList = List<core.AllNullableTypes?>.generate(
        15,
        (_) => core_types.genericAllNullableTypes,
      );
      final niList = List<ni.NIAllNullableTypes?>.generate(
        15,
        (_) => ni_types.recursiveNIAllNullableTypes,
      );

      // MethodChannel
      final mcStopwatch = Stopwatch()..start();
      await mcApi.echoClassList(coreList);
      mcStopwatch.stop();
      print('MC_BENCHMARK: 15 Objects List Echo took ${mcStopwatch.elapsedMilliseconds}ms');

      // Native Interop
      if (niApi != null) {
        final niStopwatch = Stopwatch()..start();
        niApi.echoClassList(niList);
        niStopwatch.stop();
        print('NI_BENCHMARK: 15 Objects List Echo took ${niStopwatch.elapsedMilliseconds}ms');
      }
    });

    testWidgets('Large Int List 200 Comparison', (WidgetTester _) async {
      final list = List<int?>.generate(200, (i) => i);

      // MethodChannel
      final mcStopwatch = Stopwatch()..start();
      await mcApi.echoList(list);
      mcStopwatch.stop();
      print('MC_BENCHMARK: 200 Ints List Echo took ${mcStopwatch.elapsedMilliseconds}ms');

      // Native Interop
      if (niApi != null) {
        final niStopwatch = Stopwatch()..start();
        niApi.echoIntList(list);
        niStopwatch.stop();
        print('NI_BENCHMARK: 200 Ints List Echo took ${niStopwatch.elapsedMilliseconds}ms');
      }
    });

    testWidgets('Large Int Map 200 Comparison', (WidgetTester _) async {
      final map = <int?, int?>{for (var i = 0; i < 200; i++) i: i};

      // MethodChannel
      final mcStopwatch = Stopwatch()..start();
      await mcApi.echoIntMap(map);
      mcStopwatch.stop();
      print('MC_BENCHMARK: 200 Ints Map Echo took ${mcStopwatch.elapsedMilliseconds}ms');

      // Native Interop
      if (niApi != null) {
        final niStopwatch = Stopwatch()..start();
        niApi.echoIntMap(map);
        niStopwatch.stop();
        print('NI_BENCHMARK: 200 Ints Map Echo took ${niStopwatch.elapsedMilliseconds}ms');
      }
    });

    testWidgets('Small String Echo Comparison (x200)', (WidgetTester _) async {
      const text = 'Hello Pigeon Benchmark!';

      // MethodChannel
      final mcStopwatch = Stopwatch()..start();
      for (var i = 0; i < 200; i++) {
        await mcApi.echoString(text);
      }
      mcStopwatch.stop();
      print('MC_BENCHMARK: 200 Strings Echo took ${mcStopwatch.elapsedMilliseconds}ms');

      // Native Interop
      if (niApi != null) {
        final niStopwatch = Stopwatch()..start();
        for (var i = 0; i < 200; i++) {
          niApi.echoString(text);
        }
        niStopwatch.stop();
        print('NI_BENCHMARK: 200 Strings Echo took ${niStopwatch.elapsedMilliseconds}ms');
      }
    });

    testWidgets('Small Int Echo Comparison (x200)', (WidgetTester _) async {
      const value = 42;

      // MethodChannel
      final mcStopwatch = Stopwatch()..start();
      for (var i = 0; i < 200; i++) {
        await mcApi.echoInt(value);
      }
      mcStopwatch.stop();
      print('MC_BENCHMARK: 200 Ints Echo took ${mcStopwatch.elapsedMilliseconds}ms');

      // Native Interop
      if (niApi != null) {
        final niStopwatch = Stopwatch()..start();
        for (var i = 0; i < 200; i++) {
          niApi.echoInt(value);
        }
        niStopwatch.stop();
        print('NI_BENCHMARK: 200 Ints Echo took ${niStopwatch.elapsedMilliseconds}ms');
      }
    });

    testWidgets('Flutter String Echo Comparison (x200)', (WidgetTester _) async {
      const text = 'Hello Pigeon Benchmark!';

      // MethodChannel
      final mcStopwatch = Stopwatch()..start();
      for (var i = 0; i < 200; i++) {
        await mcApi.callFlutterEchoString(text);
      }
      mcStopwatch.stop();
      print('MC_BENCHMARK: 200 Flutter Strings Echo took ${mcStopwatch.elapsedMilliseconds}ms');

      // Native Interop
      final niStopwatch = Stopwatch()..start();
      for (var i = 0; i < 200; i++) {
        niApi!.callFlutterEchoString(text);
      }
      niStopwatch.stop();
      print('NI_BENCHMARK: 200 Flutter Strings Echo took ${niStopwatch.elapsedMilliseconds}ms');
    });

    testWidgets('Flutter Int Echo Comparison (x200)', (WidgetTester _) async {
      const value = 42;

      // MethodChannel
      final mcStopwatch = Stopwatch()..start();
      for (var i = 0; i < 200; i++) {
        await mcApi.callFlutterEchoInt(value);
      }
      mcStopwatch.stop();
      print('MC_BENCHMARK: 200 Flutter Ints Echo took ${mcStopwatch.elapsedMilliseconds}ms');

      // Native Interop
      final niStopwatch = Stopwatch()..start();
      for (var i = 0; i < 200; i++) {
        niApi!.callFlutterEchoInt(value);
      }
      niStopwatch.stop();
      print('NI_BENCHMARK: 200 Flutter Ints Echo took ${niStopwatch.elapsedMilliseconds}ms');
    });

    testWidgets('Flutter Uint8List Echo 1MB Comparison', (WidgetTester _) async {
      const int size = 1024 * 1024;
      final data = Uint8List(size);
      for (var i = 0; i < size; i++) {
        data[i] = i % 256;
      }

      // MethodChannel
      final mcStopwatch = Stopwatch()..start();
      await mcApi.callFlutterEchoUint8List(data);
      mcStopwatch.stop();
      print('MC_BENCHMARK: 1MB Flutter Uint8List Echo took ${mcStopwatch.elapsedMilliseconds}ms');

      // Native Interop
      final niStopwatch = Stopwatch()..start();
      niApi!.callFlutterEchoUint8List(data);
      niStopwatch.stop();
      print('NI_BENCHMARK: 1MB Flutter Uint8List Echo took ${niStopwatch.elapsedMilliseconds}ms');
    });

    testWidgets('Flutter Large Object List 15 Comparison', (WidgetTester _) async {
      final coreList = List<core.AllNullableTypes?>.generate(
        15,
        (_) => core_types.genericAllNullableTypes,
      );
      final niList = List<ni.NIAllNullableTypes?>.generate(
        15,
        (_) => ni_types.recursiveNIAllNullableTypes,
      );

      // MethodChannel
      final mcStopwatch = Stopwatch()..start();
      await mcApi.callFlutterEchoClassList(coreList);
      mcStopwatch.stop();
      print('MC_BENCHMARK: 15 Flutter Objects List Echo took ${mcStopwatch.elapsedMilliseconds}ms');

      // Native Interop
      final niStopwatch = Stopwatch()..start();
      niApi!.callFlutterEchoClassList(niList);
      niStopwatch.stop();
      print('NI_BENCHMARK: 15 Flutter Objects List Echo took ${niStopwatch.elapsedMilliseconds}ms');
    });

    testWidgets('Flutter Large Int List 200 Comparison', (WidgetTester _) async {
      final list = List<int?>.generate(200, (i) => i);

      // MethodChannel
      final mcStopwatch = Stopwatch()..start();
      await mcApi.callFlutterEchoList(list);
      mcStopwatch.stop();
      print('MC_BENCHMARK: 200 Flutter Ints List Echo took ${mcStopwatch.elapsedMilliseconds}ms');

      // Native Interop
      final niStopwatch = Stopwatch()..start();
      niApi!.callFlutterEchoList(list);
      niStopwatch.stop();
      print('NI_BENCHMARK: 200 Flutter Ints List Echo took ${niStopwatch.elapsedMilliseconds}ms');
    });

    testWidgets('Flutter Large Int Map 200 Comparison', (WidgetTester _) async {
      final map = <int?, int?>{for (var i = 0; i < 200; i++) i: i};

      // MethodChannel
      final mcStopwatch = Stopwatch()..start();
      await mcApi.callFlutterEchoIntMap(map);
      mcStopwatch.stop();
      print('MC_BENCHMARK: 200 Flutter Ints Map Echo took ${mcStopwatch.elapsedMilliseconds}ms');

      // Native Interop
      final niStopwatch = Stopwatch()..start();
      niApi!.callFlutterEchoIntMap(map);
      niStopwatch.stop();
      print('NI_BENCHMARK: 200 Flutter Ints Map Echo took ${niStopwatch.elapsedMilliseconds}ms');
    });

    if (targetGenerator == TargetGenerator.kotlin) {
      testWidgets('JList iteration overhead micro-benchmark: asDart vs raw', (
        WidgetTester _,
      ) async {
        if (niApi == null) {
          return;
        }

        // Simulate generating a mock JList
        final List<JString> dartList = List.generate(200, (i) => 'Item $i'.toJString());
        final JList<JString> jList = dartList.toJList();

        const iters = 100;

        // 1. Without asDart(), uncached size()
        final sw1 = Stopwatch()..start();
        for (var iter = 0; iter < iters; iter++) {
          for (var i = 0; i < JList$$Methods(jList).size(); i++) {
            final JString? _ = JList$$Methods(jList).get(i);
          }
        }
        sw1.stop();
        print('JLIST_BENCHMARK (without asDart, uncached .size()): ${sw1.elapsedMilliseconds}ms');

        // 2. Without asDart(), cached size()
        final sw2 = Stopwatch()..start();
        for (var iter = 0; iter < iters; iter++) {
          final int len = JList$$Methods(jList).size();
          for (var i = 0; i < len; i++) {
            final JString? _ = JList$$Methods(jList).get(i);
          }
        }
        sw2.stop();
        print('JLIST_BENCHMARK (without asDart, cached .size()): ${sw2.elapsedMilliseconds}ms');

        // 3. With asDart(), uncached length
        final sw3 = Stopwatch()..start();
        for (var iter = 0; iter < iters; iter++) {
          final List<JString> asDartList = jList.asDart();
          for (var i = 0; i < asDartList.length; i++) {
            final JString _ = asDartList[i];
          }
        }
        sw3.stop();
        print('JLIST_BENCHMARK (with asDart, uncached .length): ${sw3.elapsedMilliseconds}ms');

        // 4. With asDart(), cached length (current Pigeon code)
        final sw4 = Stopwatch()..start();
        for (var iter = 0; iter < iters; iter++) {
          final List<JString> asDartList = jList.asDart();
          final int len = asDartList.length;
          for (var i = 0; i < len; i++) {
            final JString _ = asDartList[i];
          }
        }
        sw4.stop();
        print('JLIST_BENCHMARK (with asDart, cached .length): ${sw4.elapsedMilliseconds}ms');

        // Check difference
        print('JLIST_BENCHMARK differences confirmed via benchmark.');
      });
    }

    if (targetGenerator == TargetGenerator.swift) {
      testWidgets('FFI list casting overhead micro-benchmark: cast() vs List.from() vs map()', (
        WidgetTester _,
      ) async {
        if (niApi == null) {
          return;
        }

        // Simulate a decoded FFI NSArray which arrives as List<Object?> via StandardMessageCodec
        final ffiList = List<Object?>.generate(200, (i) => 'Item $i');

        const iters = 100;

        // 1. .cast<String>() iteration (What Pigeon currently uses for FFI)
        final sw1 = Stopwatch()..start();
        for (var iter = 0; iter < iters; iter++) {
          final List<String> castList = ffiList.cast<String>();
          final int len = castList.length;
          for (var i = 0; i < len; i++) {
            final String _ = castList[i];
          }
        }
        sw1.stop();
        print('FFI_BENCHMARK (cast<T>() iteration): ${sw1.elapsedMilliseconds}ms');

        // 2. List.from() iteration
        final sw2 = Stopwatch()..start();
        for (var iter = 0; iter < iters; iter++) {
          final fromList = List<String>.from(ffiList);
          final int len = fromList.length;
          for (var i = 0; i < len; i++) {
            final String _ = fromList[i];
          }
        }
        sw2.stop();
        print('FFI_BENCHMARK (List.from() iteration): ${sw2.elapsedMilliseconds}ms');

        // 3. .map().toList() iteration
        final sw3 = Stopwatch()..start();
        for (var iter = 0; iter < iters; iter++) {
          final List<String> mapList = ffiList.map((e) => e! as String).toList();
          final int len = mapList.length;
          for (var i = 0; i < len; i++) {
            final String _ = mapList[i];
          }
        }
        sw3.stop();
        print('FFI_BENCHMARK (.map().toList() iteration): ${sw3.elapsedMilliseconds}ms');
      });
    }
  });
}
