// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:devtools_app_shared/service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences_tool/src/shared_preferences_state.dart';
import 'package:shared_preferences_tool/src/shared_preferences_tool_eval.dart';
import 'package:vm_service/vm_service.dart';

@GenerateNiceMocks(<MockSpec<dynamic>>[
  MockSpec<EvalOnDartLibrary>(),
])
import 'shared_preferences_tool_eval_test.mocks.dart';

void main() {
  group('SharedPreferencesToolEval', () {
    late MockEvalOnDartLibrary eval;
    late _FakeVmService vmService;
    late SharedPreferencesToolEval sharedPreferencesToolEval;

    void stubEvalMethod({
      required String eventKind,
      required String method,
      required Map<String, Object?> response,
    }) {
      final StreamController<Event> eventStream = StreamController<Event>();
      vmService.onExtensionEvent = eventStream.stream;
      when(
        eval.eval(
          'SharedPreferencesDevToolsExtensionData().$method',
          isAlive: anyNamed('isAlive'),
        ),
      ).thenAnswer((_) async {
        eventStream.add(
          Event(
            extensionKind: 'shared_preferences.$eventKind',
            extensionData: ExtensionData.parse(response),
          ),
        );
        return null;
      });
    }

    setUp(() {
      eval = MockEvalOnDartLibrary();
      vmService = _FakeVmService();
      sharedPreferencesToolEval = SharedPreferencesToolEval(vmService, eval);
    });

    test('should fetch all keys', () async {
      final List<String> expectedAsyncKeys = <String>['key1', 'key2'];
      const List<String> expectedLegacyKeys = <String>['key3', 'key4'];
      stubEvalMethod(
        eventKind: 'all_keys',
        method: 'requestAllKeys()',
        response: <String, Object?>{
          'asyncKeys': expectedAsyncKeys,
          'legacyKeys': expectedLegacyKeys,
        },
      );

      final KeysResult allKeys = await sharedPreferencesToolEval.fetchAllKeys();

      expect(
        allKeys.asyncKeys,
        equals(expectedAsyncKeys),
      );
      expect(
        allKeys.legacyKeys,
        equals(expectedLegacyKeys),
      );
    });

    test('should fetch int value', () async {
      const String key = 'testKey';
      const int expectedValue = 42;
      stubEvalMethod(
        eventKind: 'value',
        method: "requestValue('$key', false)",
        response: <String, Object?>{
          'value': expectedValue,
          'kind': 'int',
        },
      );

      final SharedPreferencesData data =
          await sharedPreferencesToolEval.fetchValue(key, false);

      expect(
        data,
        equals(
          const SharedPreferencesData.int(
            value: expectedValue,
          ),
        ),
      );
    });

    test('should fetch bool value', () async {
      const String key = 'testKey';
      const bool expectedValue = true;
      stubEvalMethod(
        eventKind: 'value',
        method: "requestValue('$key', false)",
        response: <String, Object?>{
          'value': expectedValue,
          'kind': 'bool',
        },
      );

      final SharedPreferencesData data =
          await sharedPreferencesToolEval.fetchValue(key, false);

      expect(
        data,
        equals(
          const SharedPreferencesData.bool(
            value: expectedValue,
          ),
        ),
      );
    });

    test('should fetch double value', () async {
      const String key = 'testKey';
      const double expectedValue = 11.1;
      stubEvalMethod(
        eventKind: 'value',
        method: "requestValue('$key', false)",
        response: <String, Object?>{
          'value': expectedValue,
          'kind': 'double',
        },
      );

      final SharedPreferencesData data =
          await sharedPreferencesToolEval.fetchValue(key, false);

      expect(
        data,
        equals(
          const SharedPreferencesData.double(
            value: expectedValue,
          ),
        ),
      );
    });

    test('should fetch string value', () async {
      const String key = 'testKey';
      const String expectedValue = 'value';
      stubEvalMethod(
        eventKind: 'value',
        method: "requestValue('$key', false)",
        response: <String, Object?>{
          'value': expectedValue,
          'kind': 'String',
        },
      );

      final SharedPreferencesData data =
          await sharedPreferencesToolEval.fetchValue(key, false);

      expect(
        data,
        equals(
          const SharedPreferencesData.string(
            value: expectedValue,
          ),
        ),
      );
    });

    test('should fetch string list value', () async {
      const String key = 'testKey';
      const List<String> expectedValue = <String>['value1', 'value2'];
      stubEvalMethod(
        eventKind: 'value',
        method: "requestValue('$key', true)",
        response: <String, Object?>{
          'value': expectedValue,
          'kind': 'List<String>',
        },
      );

      final SharedPreferencesData data =
          await sharedPreferencesToolEval.fetchValue(key, true);

      expect(
        data,
        equals(
          const SharedPreferencesData.stringList(
            value: expectedValue,
          ),
        ),
      );
    });

    test('should throw error on unsupported value', () {
      const String key = 'testKey';
      stubEvalMethod(
        eventKind: 'value',
        method: "requestValue('$key', true)",
        response: <String, Object?>{
          'value': 'error',
          'kind': 'SomeClass',
        },
      );

      expect(
        () => sharedPreferencesToolEval.fetchValue(key, true),
        throwsUnsupportedError,
      );
    });

    test('should change value', () async {
      const String key = 'testKey';
      const String method = "requestValueChange('$key', 'true', 'bool', false)";
      stubEvalMethod(
        eventKind: 'change_value',
        method: method,
        response: <String, Object?>{},
      );

      await sharedPreferencesToolEval.changeValue(
        key,
        const SharedPreferencesData.bool(value: true),
        false,
      );

      verify(
        eval.eval(
          'SharedPreferencesDevToolsExtensionData().$method',
          isAlive: anyNamed('isAlive'),
        ),
      ).called(1);
    });

    test('should delete key', () async {
      const String key = 'testKey';
      const String method = "requestRemoveKey('$key', false)";
      stubEvalMethod(
        eventKind: 'remove',
        method: method,
        response: <String, Object?>{},
      );

      await sharedPreferencesToolEval.deleteKey(
        key,
        false,
      );

      verify(
        eval.eval(
          'SharedPreferencesDevToolsExtensionData().$method',
          isAlive: anyNamed('isAlive'),
        ),
      ).called(1);
    });
  });
}

class _FakeVmService extends VmService {
  _FakeVmService() : super(const Stream<Object?>.empty(), (String _) {});

  @override
  late Stream<Event> onExtensionEvent;
}
