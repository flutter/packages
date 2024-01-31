// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preference_async.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/types.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const String testString = 'hello world';
  const bool testBool = true;
  const int testInt = 42;
  const double testDouble = 3.14159;
  const List<String> testList = <String>['foo', 'bar'];

  const String testString2 = 'goodbye world';
  const bool testBool2 = false;
  const int testInt2 = 1337;
  const double testDouble2 = 2.71828;
  const List<String> testList2 = <String>['baz', 'qux'];

  group('shared_preferences', () {
    late SharedPreferences preferences;

    void runAllTests() {
      testWidgets('reading', (WidgetTester _) async {
        expect(preferences.get('String'), isNull);
        expect(preferences.get('bool'), isNull);
        expect(preferences.get('int'), isNull);
        expect(preferences.get('double'), isNull);
        expect(preferences.get('List'), isNull);
        expect(preferences.getString('String'), isNull);
        expect(preferences.getBool('bool'), isNull);
        expect(preferences.getInt('int'), isNull);
        expect(preferences.getDouble('double'), isNull);
        expect(preferences.getStringList('List'), isNull);
      });

      testWidgets('writing', (WidgetTester _) async {
        await Future.wait(<Future<bool>>[
          preferences.setString('String', testString2),
          preferences.setBool('bool', testBool2),
          preferences.setInt('int', testInt2),
          preferences.setDouble('double', testDouble2),
          preferences.setStringList('List', testList2)
        ]);
        expect(preferences.getString('String'), testString2);
        expect(preferences.getBool('bool'), testBool2);
        expect(preferences.getInt('int'), testInt2);
        expect(preferences.getDouble('double'), testDouble2);
        expect(preferences.getStringList('List'), testList2);
      });

      testWidgets('removing', (WidgetTester _) async {
        const String key = 'testKey';
        await preferences.setString(key, testString);
        await preferences.setBool(key, testBool);
        await preferences.setInt(key, testInt);
        await preferences.setDouble(key, testDouble);
        await preferences.setStringList(key, testList);
        await preferences.remove(key);
        expect(preferences.get('testKey'), isNull);
      });

      testWidgets('clearing', (WidgetTester _) async {
        await preferences.setString('String', testString);
        await preferences.setBool('bool', testBool);
        await preferences.setInt('int', testInt);
        await preferences.setDouble('double', testDouble);
        await preferences.setStringList('List', testList);
        await preferences.clear();
        expect(preferences.getString('String'), null);
        expect(preferences.getBool('bool'), null);
        expect(preferences.getInt('int'), null);
        expect(preferences.getDouble('double'), null);
        expect(preferences.getStringList('List'), null);
      });

      testWidgets('simultaneous writes', (WidgetTester _) async {
        final List<Future<bool>> writes = <Future<bool>>[];
        const int writeCount = 100;
        for (int i = 1; i <= writeCount; i++) {
          writes.add(preferences.setInt('int', i));
        }
        final List<bool> result = await Future.wait(writes, eagerError: true);
        // All writes should succeed.
        expect(result.where((bool element) => !element), isEmpty);
        // The last write should win.
        expect(preferences.getInt('int'), writeCount);
      });
    }

    group('SharedPreferences', () {
      setUp(() async {
        preferences = await SharedPreferences.getInstance();
      });

      tearDown(() async {
        await preferences.clear();
        SharedPreferences.resetStatic();
      });

      runAllTests();
    });

    group('setPrefix', () {
      setUp(() async {
        SharedPreferences.resetStatic();
        SharedPreferences.setPrefix('prefix.');
        preferences = await SharedPreferences.getInstance();
      });

      tearDown(() async {
        await preferences.clear();
        SharedPreferences.resetStatic();
      });

      runAllTests();
    });

    group('setNoPrefix', () {
      setUp(() async {
        SharedPreferences.resetStatic();
        SharedPreferences.setPrefix('');
        preferences = await SharedPreferences.getInstance();
      });

      tearDown(() async {
        await preferences.clear();
        SharedPreferences.resetStatic();
      });

      runAllTests();
    });

    testWidgets('allowList only gets allowed items', (WidgetTester _) async {
      const String allowedString = 'stringKey';
      const String allowedBool = 'boolKey';
      const String notAllowedDouble = 'doubleKey';
      const String resultString = 'resultString';

      const Set<String> allowList = <String>{allowedString, allowedBool};

      SharedPreferences.resetStatic();
      SharedPreferences.setPrefix('', allowList: allowList);

      final SharedPreferences prefs = await SharedPreferences.getInstance();

      await prefs.setString(allowedString, resultString);
      await prefs.setBool(allowedBool, true);
      await prefs.setDouble(notAllowedDouble, 3.14);

      await prefs.reload();

      final String? testString = prefs.getString(allowedString);
      expect(testString, resultString);

      final bool? testBool = prefs.getBool(allowedBool);
      expect(testBool, true);

      final double? testDouble = prefs.getDouble(notAllowedDouble);
      expect(testDouble, null);
    });
  });

  group('shared_preferences_async', () {
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

        final Map<String, Object?> gotAll = await preferences.getAll(
            const GetPreferencesParameters(filter: PreferencesFilters()));

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
            filter: const PreferencesFilters(
                allowList: <String>{stringKey, boolKey}),
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
  });
}
