// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:devtools_app_shared/service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences_tool/src/shared_preferences_tool_eval.dart';
import 'package:vm_service/vm_service.dart';

@GenerateNiceMocks(<MockSpec<dynamic>>[
  MockSpec<EvalOnDartLibrary>(),
  MockSpec<InstanceRef>(),
  MockSpec<Instance>(),
])
import 'shared_preferences_tool_eval_test.mocks.dart';

void main() {
  group('SharedPreferencesToolEval', () {
    Future<void> testFetchKeys({required bool isWeb}) async {
      final MockEvalOnDartLibrary asyncEval = MockEvalOnDartLibrary();
      final MockEvalOnDartLibrary legacyEval = MockEvalOnDartLibrary();
      final SharedPreferencesToolEval sharedPreferencesToolEval =
          SharedPreferencesToolEval(
        asyncEval,
        legacyEval,
        isWeb,
      );
      addTearDown(sharedPreferencesToolEval.dispose);
      final MockInstance keysInstance = MockInstance();
      final List<String> legacyKeys = <String>['key1', 'key2'];
      final List<String> asyncKeys = <String>['key3', 'key4'];
      final MockInstance legacyKeysInstance = MockInstance();

      asyncEval.stubPrefsGetInstance('getKeys()', isWeb, keysInstance);
      keysInstance.stubElements(asyncEval, asyncKeys);
      legacyEval.stubLegacyPrefsGetInstance(
        'getKeys()',
        isWeb,
        legacyKeysInstance,
      );
      legacyKeysInstance.stubElements(legacyEval, legacyKeys);
      final KeysResult allKeys = await sharedPreferencesToolEval.fetchAllKeys();

      expect(allKeys.asyncKeys, equals(asyncKeys));
      expect(allKeys.legacyKeys, equals(legacyKeys));
    }

    test('should fetch legacy and async keys', () async {
      await testFetchKeys(isWeb: false);
    });

    test('should fetch legacy and async keys on web', () async {
      await testFetchKeys(isWeb: true);
    });
  });
}

extension on MockEvalOnDartLibrary {
  void stubSafeGetInstance(InstanceRef ref, Instance instance) {
    when(safeGetInstance(ref, any)).thenAnswer((_) async => instance);
  }

  void stubAsyncEval(String expression, bool isWeb, InstanceRef ref) {
    if (!isWeb) {
      when(asyncEval(
        'await $expression',
        isAlive: anyNamed('isAlive'),
      )).thenAnswer((_) async => ref);
      return;
    }

    // Web stubbing
    final InstanceRef valueHolderRef = MockInstanceRef();
    final Instance holderInstance = MockInstance();
    when(valueHolderRef.id).thenReturn('fakeId');
    stubSafeGetInstance(valueHolderRef, holderInstance);
    when(safeEval('[]', isAlive: anyNamed('isAlive')))
        .thenAnswer((_) async => valueHolderRef);
    when(holderInstance.elements).thenReturn(<InstanceRef>[ref]);
    when(safeEval(
      '$expression.then(valueHolder.add);',
      isAlive: anyNamed('isAlive'),
      scope: anyNamed('scope'),
    )).thenAnswer((_) async => MockInstanceRef());
  }

  void stubLegacyMethodCall(String method, bool isWeb, InstanceRef ref) {
    stubAsyncEval(
      'SharedPreferences.getInstance().then((prefs) => prefs.$method)',
      isWeb,
      ref,
    );
  }

  void stubMethodCall(String method, bool isWeb, InstanceRef ref) {
    stubAsyncEval(
      'SharedPreferencesAsync().$method',
      isWeb,
      ref,
    );
  }

  void stubPrefsGetInstance(String method, bool isWeb, Instance instance) {
    final MockInstanceRef instanceRef = MockInstanceRef();
    stubSafeGetInstance(instanceRef, instance);

    stubMethodCall(
      method,
      isWeb,
      instanceRef,
    );
  }

  void stubLegacyPrefsGetInstance(
      String method, bool isWeb, Instance instance) {
    final MockInstanceRef instanceRef = MockInstanceRef();
    stubSafeGetInstance(instanceRef, instance);

    stubLegacyMethodCall(
      method,
      isWeb,
      instanceRef,
    );
  }
}

extension on Instance {
  void stubElements(MockEvalOnDartLibrary eval, List<String> valuesAsString) {
    when(elements).thenAnswer(
      (_) => valuesAsString.map(
        (String key) {
          final MockInstanceRef valueInstanceRef = MockInstanceRef();
          final MockInstance valueInstance = MockInstance();

          eval.stubSafeGetInstance(valueInstanceRef, valueInstance);

          when(valueInstance.valueAsString).thenReturn(key);

          return valueInstanceRef;
        },
      ).toList(),
    );
  }
}
