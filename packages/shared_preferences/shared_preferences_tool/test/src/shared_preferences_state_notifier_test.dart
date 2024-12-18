// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:devtools_app_shared/service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences_tool/src/async_state.dart';
import 'package:shared_preferences_tool/src/shared_preferences_state.dart';
import 'package:shared_preferences_tool/src/shared_preferences_state_notifier.dart';
import 'package:shared_preferences_tool/src/shared_preferences_tool_eval.dart';

@GenerateNiceMocks(<MockSpec<dynamic>>[
  MockSpec<SharedPreferencesToolEval>(),
  MockSpec<ConnectedApp>()
])
import 'shared_preferences_state_notifier_test.mocks.dart';

void main() {
  group('SharedPreferencesStateNotifier', () {
    late MockSharedPreferencesToolEval evalMock;
    late SharedPreferencesStateNotifier notifier;

    setUpAll(() {
      provideDummy(const SharedPreferencesData.int(value: 42));
    });

    setUp(() {
      evalMock = MockSharedPreferencesToolEval();
      notifier = SharedPreferencesStateNotifier(evalMock);
    });

    test('should start with the default state', () {
      expect(
        notifier.value,
        const SharedPreferencesState(),
      );
    });

    test('should fetch all keys', () async {
      const List<String> asyncKeys = <String>['key1', 'key2'];
      const List<String> legacyKeys = <String>['key11', 'key22'];
      when(evalMock.fetchAllKeys()).thenAnswer(
        (_) async => (
          asyncKeys: asyncKeys,
          legacyKeys: legacyKeys,
        ),
      );

      await notifier.fetchAllKeys();

      expect(notifier.value.allKeys.dataOrNull, asyncKeys);
    });

    test('should filter out keys with "flutter." prefix async keys', () async {
      const List<String> asyncKeys = <String>['flutter.key1', 'key2'];
      const List<String> legacyKeys = <String>['key1', 'key3'];
      when(evalMock.fetchAllKeys()).thenAnswer(
        (_) async => (
          asyncKeys: asyncKeys,
          legacyKeys: legacyKeys,
        ),
      );

      await notifier.fetchAllKeys();

      expect(
        notifier.value.allKeys.dataOrNull,
        equals(<String>['key2']),
      );
    });

    test('should select key', () async {
      const List<String> keys = <String>['key1', 'key2'];
      const SharedPreferencesData keyValue =
          SharedPreferencesData.string(value: 'value');
      when(evalMock.fetchAllKeys()).thenAnswer(
        (_) async => (
          asyncKeys: keys,
          legacyKeys: const <String>[],
        ),
      );
      when(evalMock.fetchValue('key1', false)).thenAnswer(
        (_) async => keyValue,
      );
      await notifier.fetchAllKeys();

      await notifier.selectKey('key1');

      expect(
        notifier.value.selectedKey,
        equals(
          const SelectedSharedPreferencesKey(
            key: 'key1',
            value: AsyncState<SharedPreferencesData>.data(keyValue),
          ),
        ),
      );
    });

    test('should select key for legacy api', () async {
      const List<String> keys = <String>['key1', 'key2'];
      const SharedPreferencesData keyValue =
          SharedPreferencesData.string(value: 'value');
      when(evalMock.fetchAllKeys()).thenAnswer(
        (_) async => (
          asyncKeys: const <String>[],
          legacyKeys: keys,
        ),
      );
      when(evalMock.fetchValue('key1', true)).thenAnswer(
        (_) async => keyValue,
      );
      await notifier.fetchAllKeys();
      notifier.selectApi(legacyApi: true);

      await notifier.selectKey('key1');

      expect(
        notifier.value,
        equals(
          const SharedPreferencesState(
            allKeys: AsyncState<List<String>>.data(keys),
            selectedKey: SelectedSharedPreferencesKey(
              key: 'key1',
              value: AsyncState<SharedPreferencesData>.data(keyValue),
            ),
            legacyApi: true,
          ),
        ),
      );
    });

    test('should filter keys and clear filter', () async {
      const List<String> asyncKeys = <String>['key1', 'key2'];
      const List<String> legacyKeys = <String>['key11', 'key22'];
      when(evalMock.fetchAllKeys()).thenAnswer(
        (_) async => (
          asyncKeys: asyncKeys,
          legacyKeys: legacyKeys,
        ),
      );
      await notifier.fetchAllKeys();

      notifier.filter('key1');

      expect(notifier.value.allKeys.dataOrNull, equals(<String>['key1']));

      notifier.filter('');

      expect(notifier.value.allKeys.dataOrNull, equals(asyncKeys));
    });

    test('should start/stop editing', () async {
      const List<String> asyncKeys = <String>['key1', 'key2'];
      const List<String> legacyKeys = <String>['key11', 'key22'];
      when(evalMock.fetchAllKeys()).thenAnswer(
        (_) async => (
          asyncKeys: asyncKeys,
          legacyKeys: legacyKeys,
        ),
      );
      await notifier.fetchAllKeys();
      notifier.startEditing();

      expect(notifier.value.editing, equals(true));

      notifier.stopEditing();

      expect(notifier.value.editing, equals(false));
    });

    test('should change value', () async {
      const List<String> asyncKeys = <String>['key1', 'key2'];
      const List<String> legacyKeys = <String>['key11', 'key22'];
      when(evalMock.fetchAllKeys()).thenAnswer(
        (_) async => (
          asyncKeys: asyncKeys,
          legacyKeys: legacyKeys,
        ),
      );
      const SharedPreferencesData keyValue = SharedPreferencesData.string(
        value: 'value',
      );
      when(evalMock.fetchValue('key1', false)).thenAnswer(
        (_) async => keyValue,
      );
      await notifier.fetchAllKeys();
      await notifier.selectKey('key1');

      await notifier.deleteSelectedKey();

      verify(evalMock.deleteKey('key1', false)).called(1);
    });

    test('should change value', () async {
      const List<String> asyncKeys = <String>['key1', 'key2'];
      const List<String> legacyKeys = <String>['key11', 'key22'];
      when(evalMock.fetchAllKeys()).thenAnswer(
        (_) async => (
          asyncKeys: asyncKeys,
          legacyKeys: legacyKeys,
        ),
      );
      const SharedPreferencesData keyValue =
          SharedPreferencesData.string(value: 'value');
      when(evalMock.fetchValue('key1', false))
          .thenAnswer((_) async => keyValue);
      await notifier.fetchAllKeys();
      await notifier.selectKey('key1');

      await notifier.changeValue(
        const SharedPreferencesData.string(value: 'newValue'),
      );

      verify(
        evalMock.changeValue(
          'key1',
          const SharedPreferencesData.string(value: 'newValue'),
          false,
        ),
      ).called(1);
    });

    test('should change select legacy api and async api', () async {
      const List<String> asyncKeys = <String>['key1', 'key2'];
      const List<String> legacyKeys = <String>['key11', 'key22'];
      when(evalMock.fetchAllKeys()).thenAnswer(
        (_) async => (
          asyncKeys: asyncKeys,
          legacyKeys: legacyKeys,
        ),
      );
      await notifier.fetchAllKeys();

      notifier.selectApi(legacyApi: true);

      expect(notifier.value.legacyApi, equals(true));

      notifier.selectApi(legacyApi: false);

      expect(notifier.value.legacyApi, equals(false));
    });
  });
}
