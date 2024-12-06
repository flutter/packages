// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences/src/shared_preferences_devtools_extension_data.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import 'shared_preferences_async_test.dart';

typedef _Event = (String eventKind, Map<String, Object?> eventData);

class _FakePostEvent {
  final List<_Event> eventLog = <_Event>[];

  void call(
    String eventKind,
    Map<String, Object?> eventData,
  ) {
    eventLog.add((eventKind, eventData));
  }
}

void main() {
  group('DevtoolsExtension', () {
    late SharedPreferencesAsync asyncPreferences;
    late _FakePostEvent fakePostEvent;
    late SharedPreferencesDevToolsExtensionData extension;

    setUp(() {
      SharedPreferencesAsyncPlatform.instance = FakeSharedPreferencesAsync();
      asyncPreferences = SharedPreferencesAsync();
      fakePostEvent = _FakePostEvent();
      extension = SharedPreferencesDevToolsExtensionData(fakePostEvent.call);
    });

    test('should request all keys', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'key1': 1,
        'key2': true,
      });
      await asyncPreferences.setBool('key3', true);
      await asyncPreferences.setInt('key4', 1);

      await extension.requestAllKeys();

      expect(fakePostEvent.eventLog.length, equals(1));
      final (
        String eventKind,
        Map<String, Object?> eventData,
      ) = fakePostEvent.eventLog.first;
      expect(
        eventKind,
        equals('shared_preferences.all_keys'),
      );
      expect(
        eventData,
        equals(<String, List<String>>{
          'asyncKeys': <String>['key3', 'key4'],
          'legacyKeys': <String>['key1', 'key2'],
        }),
      );
    });

    group('async api', () {
      Future<void> testAsyncApiRequestValue(
        String key, {
        required Map<String, Object?> expectedData,
      }) async {
        const bool legacy = false;

        await extension.requestValue(
          key,
          legacy,
        );

        expect(fakePostEvent.eventLog.length, equals(1));
        final (
          String eventKind,
          Map<String, Object?> eventData,
        ) = fakePostEvent.eventLog.first;
        expect(
          eventKind,
          equals('shared_preferences.value'),
        );
        expect(
          eventData,
          equals(expectedData),
        );
      }

      test('should request bool value from async api', () async {
        const String key = 'key';
        const bool expectedValue = true;
        await asyncPreferences.setBool(key, expectedValue);

        await testAsyncApiRequestValue(
          key,
          expectedData: <String, Object?>{
            'value': expectedValue,
            'kind': 'bool',
          },
        );
      });

      test('should request int value from async api', () async {
        const String key = 'key';
        const int expectedValue = 42;
        await asyncPreferences.setInt(key, expectedValue);

        await testAsyncApiRequestValue(
          key,
          expectedData: <String, Object?>{
            'value': expectedValue,
            'kind': 'int',
          },
        );
      });

      test('should request double value from async api', () async {
        const String key = 'key';
        const double expectedValue = 42.2;
        await asyncPreferences.setDouble(key, expectedValue);

        await testAsyncApiRequestValue(
          key,
          expectedData: <String, Object?>{
            'value': expectedValue,
            'kind': 'double',
          },
        );
      });

      test('should request string value from async api', () async {
        const String key = 'key';
        const String expectedValue = 'value';
        await asyncPreferences.setString(key, expectedValue);

        await testAsyncApiRequestValue(
          key,
          expectedData: <String, Object?>{
            'value': expectedValue,
            'kind': 'String',
          },
        );
      });

      test('should request string list value from async api', () async {
        const String key = 'key';
        const List<String> expectedValue = <String>['string1', 'string2'];
        await asyncPreferences.setStringList(key, expectedValue);

        await testAsyncApiRequestValue(
          key,
          expectedData: <String, Object?>{
            'value': expectedValue,
            'kind': 'List<String>',
          },
        );
      });

      Future<void> testAsyncApiValueChange(
        String key,
        Object expectedValue,
      ) async {
        const bool legacy = false;

        await extension.requestValueChange(
          key,
          jsonEncode(expectedValue),
          expectedValue.runtimeType.toString(),
          legacy,
        );

        expect(fakePostEvent.eventLog.length, equals(1));
        final (
          String eventKind,
          Map<String, Object?> eventData,
        ) = fakePostEvent.eventLog.first;
        expect(
          eventKind,
          equals('shared_preferences.change_value'),
        );
        expect(
          eventData,
          equals(<String, Object?>{}),
        );
      }

      test('should request int value change on async api', () async {
        const String key = 'key';
        const int expectedValue = 42;
        await asyncPreferences.setInt(key, 24);

        await testAsyncApiValueChange(key, expectedValue);

        expect(
          await asyncPreferences.getInt(key),
          equals(expectedValue),
        );
      });

      test('should request bool value change on async api', () async {
        const String key = 'key';
        const bool expectedValue = false;
        await asyncPreferences.setBool(key, true);

        await testAsyncApiValueChange(key, expectedValue);

        expect(
          await asyncPreferences.getBool(key),
          equals(expectedValue),
        );
      });

      test('should request double value change on async api', () async {
        const String key = 'key';
        const double expectedValue = 22.22;
        await asyncPreferences.setDouble(key, 11.1);

        await testAsyncApiValueChange(key, expectedValue);

        expect(
          await asyncPreferences.getDouble(key),
          equals(expectedValue),
        );
      });

      test('should request string value change on async api', () async {
        const String key = 'key';
        const String expectedValue = 'new value';
        await asyncPreferences.setString(key, 'old value');

        await testAsyncApiValueChange(key, expectedValue);

        expect(
          await asyncPreferences.getString(key),
          equals(expectedValue),
        );
      });

      test('should request string list value change on async api', () async {
        const String key = 'key';
        const List<String> expectedValue = <String>['string1', 'string2'];
        await asyncPreferences.setStringList(key, <String>['old1', 'old2']);

        await testAsyncApiValueChange(key, expectedValue);

        expect(
          await asyncPreferences.getStringList(key),
          equals(expectedValue),
        );
      });
    });

    group('legacy api', () {
      Future<void> testLegacyApiRequestValue(
        String key, {
        required Map<String, Object?> expectedData,
      }) async {
        const bool legacy = true;

        await extension.requestValue(
          key,
          legacy,
        );

        expect(fakePostEvent.eventLog.length, equals(1));
        final (
          String eventKind,
          Map<String, Object?> eventData,
        ) = fakePostEvent.eventLog.first;
        expect(
          eventKind,
          equals('shared_preferences.value'),
        );
        expect(eventData, equals(expectedData));
      }

      test('should request bool value from legacy api', () async {
        const String key = 'key';
        const bool expectedValue = false;
        SharedPreferences.setMockInitialValues(<String, Object>{
          key: expectedValue,
        });

        await testLegacyApiRequestValue(key, expectedData: <String, Object?>{
          'value': expectedValue,
          'kind': 'bool',
        });
      });

      test('should request int value from legacy api', () async {
        const String key = 'key';
        const int expectedValue = 42;
        SharedPreferences.setMockInitialValues(<String, Object>{
          key: expectedValue,
        });

        await testLegacyApiRequestValue(key, expectedData: <String, Object?>{
          'value': expectedValue,
          'kind': 'int',
        });
      });

      test('should request double value from legacy api', () async {
        const String key = 'key';
        const double expectedValue = 42.2;
        SharedPreferences.setMockInitialValues(<String, Object>{
          key: expectedValue,
        });

        await testLegacyApiRequestValue(key, expectedData: <String, Object?>{
          'value': expectedValue,
          'kind': 'double',
        });
      });

      test('should request string value from legacy api', () async {
        const String key = 'key';
        const String expectedValue = 'value';
        SharedPreferences.setMockInitialValues(<String, Object>{
          key: expectedValue,
        });

        await testLegacyApiRequestValue(key, expectedData: <String, Object?>{
          'value': expectedValue,
          'kind': 'String',
        });
      });

      test('should request string list value from legacy api', () async {
        const String key = 'key';
        const List<String> expectedValue = <String>['string1', 'string2'];
        SharedPreferences.setMockInitialValues(<String, Object>{
          key: expectedValue,
        });

        await testLegacyApiRequestValue(key, expectedData: <String, Object?>{
          'value': expectedValue,
          'kind': 'List<String>',
        });
      });

      Future<void> testLegacyApiValueChange(
        String key,
        Object expectedValue,
      ) async {
        const bool legacy = true;

        await extension.requestValueChange(
          key,
          jsonEncode(expectedValue),
          expectedValue.runtimeType.toString(),
          legacy,
        );

        expect(fakePostEvent.eventLog.length, equals(1));
        final (
          String eventKind,
          Map<String, Object?> eventData,
        ) = fakePostEvent.eventLog.first;
        expect(
          eventKind,
          equals('shared_preferences.change_value'),
        );
        expect(
          eventData,
          equals(<String, Object?>{}),
        );
      }

      test('should request int value change on legacy api', () async {
        const String key = 'key';
        const int expectedValue = 42;
        SharedPreferences.setMockInitialValues(<String, Object>{
          key: 24,
        });

        await testLegacyApiValueChange(key, expectedValue);

        expect(
          (await SharedPreferences.getInstance()).getInt(key),
          equals(expectedValue),
        );
      });

      test('should request bool value change on legacy api', () async {
        const String key = 'key';
        const bool expectedValue = false;
        SharedPreferences.setMockInitialValues(<String, Object>{
          key: true,
        });

        await testLegacyApiValueChange(key, expectedValue);

        expect(
          (await SharedPreferences.getInstance()).getBool(key),
          equals(expectedValue),
        );
      });

      test('should request double value change on legacy api', () async {
        const String key = 'key';
        const double expectedValue = 1.11;
        SharedPreferences.setMockInitialValues(<String, Object>{
          key: 2.22,
        });

        await testLegacyApiValueChange(key, expectedValue);

        expect(
          (await SharedPreferences.getInstance()).getDouble(key),
          equals(expectedValue),
        );
      });

      test('should request string value change on legacy api', () async {
        const String key = 'key';
        const String expectedValue = 'new value';
        SharedPreferences.setMockInitialValues(<String, Object>{
          key: 'old value',
        });

        await testLegacyApiValueChange(key, expectedValue);

        expect(
          (await SharedPreferences.getInstance()).getString(key),
          equals(expectedValue),
        );
      });

      test('should request string list value change on legacy api', () async {
        const String key = 'key';
        const List<String> expectedValue = <String>['string1', 'string2'];
        SharedPreferences.setMockInitialValues(<String, Object>{
          key: <String>['old1', 'old2'],
        });

        await testLegacyApiValueChange(key, expectedValue);

        expect(
          (await SharedPreferences.getInstance()).getStringList(key),
          equals(expectedValue),
        );
      });
    });
  });
}
