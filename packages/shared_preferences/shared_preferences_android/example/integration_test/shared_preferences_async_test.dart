// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences_android/shared_preferences_async_android.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:shared_preferences_platform_interface/types.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final SharedPreferencesAndroidOptions emptyOptions =
      SharedPreferencesAndroidOptions();

  const String stringKey = 'testString';
  const String boolKey = 'testBool';
  const String intKey = 'testInt';
  const String doubleKey = 'testDouble';
  const String listKey = 'testList';

  const String testString = 'hello world';
  const bool testBool = true;
  const int testInt = 42;
  const double testDouble = 3.14159;
  const List<String> testList = <String>['foo', 'bar'];

  group('Async', () {
    late SharedPreferencesAsyncPlatform preferences;

    setUp(() async {
      preferences = SharedPreferencesAsyncAndroid();
    });

    test('set and get', () async {
      await Future.wait(<Future<bool>>[
        preferences.setString(stringKey, testString, emptyOptions),
        preferences.setBool(boolKey, testBool, emptyOptions),
        preferences.setInt(intKey, testInt, emptyOptions),
        preferences.setDouble(doubleKey, testDouble, emptyOptions),
        preferences.setStringList(listKey, testList, emptyOptions)
      ]);

      expect(await preferences.getString(stringKey, emptyOptions), testString);
      expect(await preferences.getBool(boolKey, emptyOptions), testBool);
      expect(await preferences.getInt(intKey, emptyOptions), testInt);
      expect(await preferences.getDouble(doubleKey, emptyOptions), testDouble);
      expect(await preferences.getStringList(listKey, emptyOptions), testList);
    });

    test('getAll', () async {
      await Future.wait(<Future<bool>>[
        preferences.setString(stringKey, testString, emptyOptions),
        preferences.setBool(boolKey, testBool, emptyOptions),
        preferences.setInt(intKey, testInt, emptyOptions),
        preferences.setDouble(doubleKey, testDouble, emptyOptions),
        preferences.setStringList(listKey, testList, emptyOptions)
      ]);

      final Map<String, Object?> gotAll = await preferences.getPreferences(
          const GetPreferencesParameters(filter: PreferencesFilters()),
          emptyOptions);

      expect(gotAll.length, 5);
      expect(gotAll[stringKey], testString);
      expect(gotAll[boolKey], testBool);
      expect(gotAll[intKey], testInt);
      expect(gotAll[doubleKey], testDouble);
      expect(gotAll[listKey], testList);
    });

    test('getAll with filter', () async {
      await Future.wait(<Future<bool>>[
        preferences.setString(stringKey, testString, emptyOptions),
        preferences.setBool(boolKey, testBool, emptyOptions),
        preferences.setInt(intKey, testInt, emptyOptions),
        preferences.setDouble(doubleKey, testDouble, emptyOptions),
        preferences.setStringList(listKey, testList, emptyOptions)
      ]);

      final Map<String, Object?> gotAll = await preferences.getPreferences(
        const GetPreferencesParameters(
          filter: PreferencesFilters(allowList: <String>{stringKey, boolKey}),
        ),
        emptyOptions,
      );

      expect(gotAll.length, 2);
      expect(gotAll[stringKey], testString);
      expect(gotAll[boolKey], testBool);
    });

    test('getKeys', () async {
      await Future.wait(<Future<bool>>[
        preferences.setString(stringKey, testString, emptyOptions),
        preferences.setBool(boolKey, testBool, emptyOptions),
        preferences.setInt(intKey, testInt, emptyOptions),
        preferences.setDouble(doubleKey, testDouble, emptyOptions),
        preferences.setStringList(listKey, testList, emptyOptions)
      ]);

      final Set<String?> keys = await preferences.getKeys(
        const GetPreferencesParameters(filter: PreferencesFilters()),
        emptyOptions,
      );

      expect(keys.length, 5);
      expect(keys, contains(stringKey));
      expect(keys, contains(boolKey));
      expect(keys, contains(intKey));
      expect(keys, contains(doubleKey));
      expect(keys, contains(listKey));
    });

    test('getKeys with filter', () async {
      await Future.wait(<Future<bool>>[
        preferences.setString(stringKey, testString, emptyOptions),
        preferences.setBool(boolKey, testBool, emptyOptions),
        preferences.setInt(intKey, testInt, emptyOptions),
        preferences.setDouble(doubleKey, testDouble, emptyOptions),
        preferences.setStringList(listKey, testList, emptyOptions)
      ]);

      final Set<String?> keys = await preferences.getKeys(
        const GetPreferencesParameters(
          filter: PreferencesFilters(allowList: <String>{stringKey, boolKey}),
        ),
        emptyOptions,
      );

      expect(keys.length, 2);
      expect(keys, contains(stringKey));
      expect(keys, contains(boolKey));
    });

    test('clear', () async {
      await Future.wait(<Future<bool>>[
        preferences.setString(stringKey, testString, emptyOptions),
        preferences.setBool(boolKey, testBool, emptyOptions),
        preferences.setInt(intKey, testInt, emptyOptions),
        preferences.setDouble(doubleKey, testDouble, emptyOptions),
        preferences.setStringList(listKey, testList, emptyOptions)
      ]);
      await preferences.clear(
          const ClearPreferencesParameters(filter: PreferencesFilters()),
          emptyOptions);
      expect(await preferences.getString(stringKey, emptyOptions), null);
      expect(await preferences.getBool(boolKey, emptyOptions), null);
      expect(await preferences.getInt(intKey, emptyOptions), null);
      expect(await preferences.getDouble(doubleKey, emptyOptions), null);
      expect(await preferences.getStringList(listKey, emptyOptions), null);
    });

    test('clear with filter', () async {
      await Future.wait(<Future<bool>>[
        preferences.setString(stringKey, testString, emptyOptions),
        preferences.setBool(boolKey, testBool, emptyOptions),
        preferences.setInt(intKey, testInt, emptyOptions),
        preferences.setDouble(doubleKey, testDouble, emptyOptions),
        preferences.setStringList(listKey, testList, emptyOptions)
      ]);
      await preferences.clear(
        const ClearPreferencesParameters(
          filter: PreferencesFilters(allowList: <String>{stringKey, boolKey}),
        ),
        emptyOptions,
      );
      expect(await preferences.getString(stringKey, emptyOptions), null);
      expect(await preferences.getBool(boolKey, emptyOptions), null);
      expect(await preferences.getInt(intKey, emptyOptions), testInt);
      expect(await preferences.getDouble(doubleKey, emptyOptions), testDouble);
      expect(await preferences.getStringList(listKey, emptyOptions), testList);
    });
  });
}
