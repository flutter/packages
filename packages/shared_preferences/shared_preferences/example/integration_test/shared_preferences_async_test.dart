// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preference_async.dart';
import 'package:shared_preferences_platform_interface/types.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

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
    late SharedPreferencesAsync preferences;

    setUp(() async {
      preferences =
          SharedPreferencesAsync(options: const SharedPreferencesOptions());
    });

    tearDown(() async {
      await preferences.clear(
          const ClearPreferencesParameters(filter: PreferencesFilters()));
    });

    test('set and get', () async {
      await Future.wait(<Future<bool>>[
        preferences.setString(stringKey, testString),
        preferences.setBool(boolKey, testBool),
        preferences.setInt(intKey, testInt),
        preferences.setDouble(doubleKey, testDouble),
        preferences.setStringList(listKey, testList)
      ]);

      expect(await preferences.getString(stringKey), testString);
      expect(await preferences.getBool(boolKey), testBool);
      expect(await preferences.getInt(intKey), testInt);
      expect(await preferences.getDouble(doubleKey), testDouble);
      expect(await preferences.getStringList(listKey), testList);
    });

    test('getAll', () async {
      await Future.wait(<Future<bool>>[
        preferences.setString(stringKey, testString),
        preferences.setBool(boolKey, testBool),
        preferences.setInt(intKey, testInt),
        preferences.setDouble(doubleKey, testDouble),
        preferences.setStringList(listKey, testList)
      ]);

      final Map<String, Object?> gotAll = await preferences
          .getAll(const GetPreferencesParameters(filter: PreferencesFilters()));

      expect(gotAll.length, 5);
      expect(gotAll[stringKey], testString);
      expect(gotAll[boolKey], testBool);
      expect(gotAll[intKey], testInt);
      expect(gotAll[doubleKey], testDouble);
      expect(gotAll[listKey], testList);
    });

    test('getAll with filter', () async {
      await Future.wait(<Future<bool>>[
        preferences.setString(stringKey, testString),
        preferences.setBool(boolKey, testBool),
        preferences.setInt(intKey, testInt),
        preferences.setDouble(doubleKey, testDouble),
        preferences.setStringList(listKey, testList)
      ]);

      final Map<String, Object?> gotAll = await preferences.getAll(
        const GetPreferencesParameters(
          filter: PreferencesFilters(allowList: <String>{stringKey, boolKey}),
        ),
      );

      expect(gotAll.length, 2);
      expect(gotAll[stringKey], testString);
      expect(gotAll[boolKey], testBool);
    });

    test('getKeys', () async {
      await Future.wait(<Future<bool>>[
        preferences.setString(stringKey, testString),
        preferences.setBool(boolKey, testBool),
        preferences.setInt(intKey, testInt),
        preferences.setDouble(doubleKey, testDouble),
        preferences.setStringList(listKey, testList)
      ]);

      final Set<String?> keys = await preferences.getKeys(
          const GetPreferencesParameters(filter: PreferencesFilters()));

      expect(keys.length, 5);
      expect(keys, contains(stringKey));
      expect(keys, contains(boolKey));
      expect(keys, contains(intKey));
      expect(keys, contains(doubleKey));
      expect(keys, contains(listKey));
    });

    test('getKeys with filter', () async {
      await Future.wait(<Future<bool>>[
        preferences.setString(stringKey, testString),
        preferences.setBool(boolKey, testBool),
        preferences.setInt(intKey, testInt),
        preferences.setDouble(doubleKey, testDouble),
        preferences.setStringList(listKey, testList)
      ]);

      final Set<String?> keys = await preferences.getKeys(
        const GetPreferencesParameters(
          filter: PreferencesFilters(allowList: <String>{stringKey, boolKey}),
        ),
      );

      expect(keys.length, 2);
      expect(keys, contains(stringKey));
      expect(keys, contains(boolKey));
    });

    test('containsKey', () async {
      const String key = 'testKey';

      expect(false, await preferences.containsKey(key));

      await preferences.setString(key, 'test');
      expect(true, await preferences.containsKey(key));
    });

    test('clear', () async {
      await Future.wait(<Future<bool>>[
        preferences.setString(stringKey, testString),
        preferences.setBool(boolKey, testBool),
        preferences.setInt(intKey, testInt),
        preferences.setDouble(doubleKey, testDouble),
        preferences.setStringList(listKey, testList)
      ]);
      await preferences.clear(
          const ClearPreferencesParameters(filter: PreferencesFilters()));
      expect(await preferences.getString(stringKey), null);
      expect(await preferences.getBool(boolKey), null);
      expect(await preferences.getInt(intKey), null);
      expect(await preferences.getDouble(doubleKey), null);
      expect(await preferences.getStringList(listKey), null);
    });

    test('clear with filter', () async {
      await Future.wait(<Future<bool>>[
        preferences.setString(stringKey, testString),
        preferences.setBool(boolKey, testBool),
        preferences.setInt(intKey, testInt),
        preferences.setDouble(doubleKey, testDouble),
        preferences.setStringList(listKey, testList)
      ]);
      await preferences.clear(
        const ClearPreferencesParameters(
          filter: PreferencesFilters(allowList: <String>{stringKey, boolKey}),
        ),
      );
      expect(await preferences.getString(stringKey), null);
      expect(await preferences.getBool(boolKey), null);
      expect(await preferences.getInt(intKey), testInt);
      expect(await preferences.getDouble(doubleKey), testDouble);
      expect(await preferences.getStringList(listKey), testList);
    });
  });

  group('withCache', () {
    late SharedPreferencesWithCache preferences;
    late Map<String, Object?> cache;

    setUp(() async {
      cache = <String, Object?>{};
      preferences = SharedPreferencesWithCache(
        cache: cache,
        sharedPreferencesOptions: const SharedPreferencesOptions(),
        cacheOptions: SharedPreferencesWithCacheOptions(
          filter: const PreferencesFilters(),
        ),
      );
    });

    test('set and get', () async {
      await Future.wait(<Future<bool>>[
        preferences.setString(stringKey, testString),
        preferences.setBool(boolKey, testBool),
        preferences.setInt(intKey, testInt),
        preferences.setDouble(doubleKey, testDouble),
        preferences.setStringList(listKey, testList)
      ]);

      expect(preferences.getString(stringKey), testString);
      expect(preferences.getBool(boolKey), testBool);
      expect(preferences.getInt(intKey), testInt);
      expect(preferences.getDouble(doubleKey), testDouble);
      expect(preferences.getStringList(listKey), testList);
    });

    test('reloading', () async {
      await preferences.clear();
      await preferences.setString(stringKey, testString);
      expect(preferences.getString(stringKey), testString);

      cache.clear();
      expect(preferences.getString(stringKey), null);

      await preferences.reloadCache();
      expect(preferences.getString(stringKey), testString);
    });

    test('containsKey', () async {
      const String key = 'testKey';

      expect(false, preferences.containsKey(key));

      await preferences.setString(key, 'test');
      expect(true, preferences.containsKey(key));
    });

    test('getKeys', () async {
      await Future.wait(<Future<bool>>[
        preferences.setString(stringKey, testString),
        preferences.setBool(boolKey, testBool),
        preferences.setInt(intKey, testInt),
        preferences.setDouble(doubleKey, testDouble),
        preferences.setStringList(listKey, testList)
      ]);

      final Set<String> keys = preferences.getKeys();

      expect(keys.length, 5);
      expect(keys, contains(stringKey));
      expect(keys, contains(boolKey));
      expect(keys, contains(intKey));
      expect(keys, contains(doubleKey));
      expect(keys, contains(listKey));
    });

    test('clear', () async {
      await Future.wait(<Future<bool>>[
        preferences.setString(stringKey, testString),
        preferences.setBool(boolKey, testBool),
        preferences.setInt(intKey, testInt),
        preferences.setDouble(doubleKey, testDouble),
        preferences.setStringList(listKey, testList)
      ]);
      await preferences.clear();
      expect(preferences.getString(stringKey), null);
      expect(preferences.getBool(boolKey), null);
      expect(preferences.getInt(intKey), null);
      expect(preferences.getDouble(doubleKey), null);
      expect(preferences.getStringList(listKey), null);
    });
  });

  group('withCache with filter', () {
    late SharedPreferencesWithCache preferences;
    late Map<String, Object?> cache;

    setUp(() async {
      cache = <String, Object?>{};
      preferences = SharedPreferencesWithCache(
        cache: cache,
        sharedPreferencesOptions: const SharedPreferencesOptions(),
        cacheOptions: SharedPreferencesWithCacheOptions(
          filter:
              const PreferencesFilters(allowList: <String>{stringKey, boolKey}),
        ),
      );
    });

    test('set and get', () async {
      await Future.wait(<Future<bool>>[
        preferences.setString(stringKey, testString),
        preferences.setBool(boolKey, testBool),
        preferences.setInt(intKey, testInt),
        preferences.setDouble(doubleKey, testDouble),
        preferences.setStringList(listKey, testList)
      ]);

      expect(preferences.getString(stringKey), testString);
      expect(preferences.getBool(boolKey), testBool);
      expect(preferences.getInt(intKey), testInt);
      expect(preferences.getDouble(doubleKey), testDouble);
      expect(preferences.getStringList(listKey), testList);
    });

    test('reloading', () async {
      await preferences.clear();
      await preferences.setString(stringKey, testString);
      expect(preferences.getString(stringKey), testString);

      cache.clear();
      expect(preferences.getString(stringKey), null);

      await preferences.reloadCache();
      expect(preferences.getString(stringKey), testString);
    });

    test('containsKey', () async {
      const String key = 'testKey';

      expect(false, preferences.containsKey(key));

      await preferences.setString(key, 'test');
      expect(true, preferences.containsKey(key));
    });

    test('getKeys', () async {
      await Future.wait(<Future<bool>>[
        preferences.setString(stringKey, testString),
        preferences.setBool(boolKey, testBool),
        preferences.setInt(intKey, testInt),
        preferences.setDouble(doubleKey, testDouble),
        preferences.setStringList(listKey, testList)
      ]);

      final Set<String> keys = preferences.getKeys();

      expect(keys.length, 2);
      expect(keys, contains(stringKey));
      expect(keys, contains(boolKey));
    });

    test('clear', () async {
      await Future.wait(<Future<bool>>[
        preferences.setString(stringKey, testString),
        preferences.setBool(boolKey, testBool),
        preferences.setInt(intKey, testInt),
        preferences.setDouble(doubleKey, testDouble),
        preferences.setStringList(listKey, testList)
      ]);
      await preferences.clear();

      expect(preferences.getString(stringKey), null);
      expect(preferences.getBool(boolKey), null);
      expect(preferences.getInt(intKey), testInt);
      expect(preferences.getDouble(doubleKey), testDouble);
      expect(preferences.getStringList(listKey), testList);
    });
  });
}
