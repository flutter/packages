// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// TODO(a14n): remove this import once Flutter 3.1 or later reaches stable (including flutter/flutter#104231)
// ignore: unnecessary_import
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'generated.dart';

/// Possible host languages that test can target.
enum TargetGenerator {
  /// The Windows C++ generator.
  cpp,

  /// The Android Java generator.
  java,

  /// The Android Kotlin generator.
  kotlin,

  /// The iOS Objective-C generator.
  objc,

  /// The iOS or macOS Objective-C generator.
  swift,
}

/// Sets up and runs the integration tests.
void runPigeonIntegrationTests(TargetGenerator targetGenerator) {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Host sync API tests', () {
    testWidgets('basic void->void call works', (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      expect(api.noop(), completes);
    });

    testWidgets('all datatypes serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final AllTypes sentObject = AllTypes(
        aBool: true,
        anInt: 42,
        aDouble: 3.14159,
        aString: 'Hello host!',
        aByteArray: Uint8List.fromList(<int>[1, 2, 3]),
        a4ByteArray: Int32List.fromList(<int>[4, 5, 6]),
        a8ByteArray: Int64List.fromList(<int>[7, 8, 9]),
        aFloatArray: Float64List.fromList(<double>[2.71828, 3.14159]),
        aList: <Object?>['Thing 1', 2],
        aMap: <Object?, Object?>{'a': 1, 'b': 2.0},
        nestedList: <List<bool>>[
          <bool>[true, false],
          <bool>[false, true]
        ],
      );

      final AllTypes echoObject = await api.echoAllTypes(sentObject);
      expect(echoObject.aBool, sentObject.aBool);
      expect(echoObject.anInt, sentObject.anInt);
      expect(echoObject.aDouble, sentObject.aDouble);
      expect(echoObject.aString, sentObject.aString);
      // TODO(stuartmorgan): Enable these once they work for all generators;
      // currently at least Swift is broken.
      // See https://github.com/flutter/flutter/issues/115906
      //expect(echoObject.aByteArray, sentObject.aByteArray);
      //expect(echoObject.a4ByteArray, sentObject.a4ByteArray);
      //expect(echoObject.a8ByteArray, sentObject.a8ByteArray);
      //expect(echoObject.aFloatArray, sentObject.aFloatArray);
      expect(listEquals(echoObject.aList, sentObject.aList), true);
      expect(mapEquals(echoObject.aMap, sentObject.aMap), true);
      expect(echoObject.nestedList?.length, sentObject.nestedList?.length);
      // TODO(stuartmorgan): Enable this once the Dart types are fixed; see
      // https://github.com/flutter/flutter/issues/116117
      //for (int i = 0; i < echoObject.nestedList!.length; i++) {
      //  expect(listEquals(echoObject.nestedList![i], sentObject.nestedList![i]),
      //      true);
      //}
      expect(
          mapEquals(
              echoObject.mapWithAnnotations, sentObject.mapWithAnnotations),
          true);
      expect(
          mapEquals(echoObject.mapWithObject, sentObject.mapWithObject), true);
    });

    testWidgets('errors are returned correctly', (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      expect(() async {
        await api.throwError();
      }, throwsA(isA<PlatformException>()));
    },
        // Currently unimplementable for Swift:
        // https://github.com/flutter/flutter/issues/112483
        skip: targetGenerator == TargetGenerator.swift);

    testWidgets('nested objects can be sent correctly', (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      const String sentString = 'Some string';
      final AllTypesWrapper sentObject =
          AllTypesWrapper(values: AllTypes(aString: sentString));

      final String? receivedString = await api.extractNestedString(sentObject);
      expect(receivedString, sentString);
    });

    testWidgets('nested objects can be received correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      const String sentString = 'Some string';
      final AllTypesWrapper receivedObject =
          await api.createNestedString(sentString);
      expect(receivedObject.values.aString, sentString);
    });
  });

  group('Host async API tests', () {
    testWidgets('basic void->void call works', (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      expect(api.noopAsync(), completes);
    });

    testWidgets('strings serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      const String sentObject = 'Hello, asyncronously!';

      final String echoObject = await api.echoAsyncString(sentObject);
      expect(echoObject, sentObject);
    });
  });

  // These tests rely on the ansync Dart->host calls to work correctly, since
  // the host->Dart call is wrapped in a driving Dart->host call, so any test
  // added to this group should have coverage of the relevant arguments and
  // return value in the "Host async API tests" group.
  group('Flutter API tests', () {
    setUp(() {
      FlutterIntegrationCoreApi.setup(_FlutterApiTestImplementation());
    });

    testWidgets('basic void->void call works', (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      expect(api.callFlutterNoop(), completes);
    });

    testWidgets('strings serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      const String sentObject = 'Hello Dart!';

      final String echoObject = await api.callFlutterEchoString(sentObject);
      expect(echoObject, sentObject);
    });
  },
      // TODO(stuartmorgan): Enable when FlutterApi generation is fixed for
      // C++. See https://github.com/flutter/flutter/issues/108682.
      skip: targetGenerator == TargetGenerator.cpp);
}

class _FlutterApiTestImplementation implements FlutterIntegrationCoreApi {
  @override
  AllTypes echoAllTypes(AllTypes everything) {
    return everything;
  }

  @override
  String echoString(String aString) {
    return aString;
  }

  @override
  void noop() {}
}
