// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      testWidgets('set and get String', (WidgetTester _) async {
        expect(preferences.get('String'), isNull);
        await preferences.setString('String', testString2);
        expect(preferences.getString('String'), testString2);
      });

      testWidgets('set and get Bool', (WidgetTester _) async {
        expect(preferences.get('Bool'), isNull);
        await preferences.setBool('Bool', testBool2);
        expect(preferences.getBool('Bool'), testBool2);
      });

      testWidgets('set and get Int', (WidgetTester _) async {
        expect(preferences.get('Int'), isNull);
        await preferences.setInt('Int', testInt2);
        expect(preferences.getInt('Int'), testInt2);
      });

      testWidgets('set and get Double', (WidgetTester _) async {
        expect(preferences.get('Double'), isNull);
        await preferences.setDouble('Double', testDouble2);
        expect(preferences.getDouble('Double'), testDouble2);
      });

      testWidgets('set and get StringList', (WidgetTester _) async {
        expect(preferences.get('StringList'), isNull);
        await preferences.setStringList('StringList', testList2);
        expect(preferences.getStringList('StringList'), testList2);
      });

      testWidgets('removing', (WidgetTester _) async {
        const String key = 'testKey';
        await preferences.setString(key, testString);
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
      Future<SharedPreferencesAsync> getPreferences() async {
        final SharedPreferencesAsync preferences = SharedPreferencesAsync();
        await preferences.clear();
        return preferences;
      }

      testWidgets('set and get String', (WidgetTester _) async {
        final SharedPreferencesAsync preferences = await getPreferences();

        await preferences.setString(stringKey, testString);
        expect(await preferences.getString(stringKey), testString);
      });

      testWidgets('set and get bool', (WidgetTester _) async {
        final SharedPreferencesAsync preferences = await getPreferences();

        await preferences.setBool(boolKey, testBool);
        expect(await preferences.getBool(boolKey), testBool);
      });

      testWidgets('set and get int', (WidgetTester _) async {
        final SharedPreferencesAsync preferences = await getPreferences();

        await preferences.setInt(intKey, testInt);
        expect(await preferences.getInt(intKey), testInt);
      });

      testWidgets('set and get double', (WidgetTester _) async {
        final SharedPreferencesAsync preferences = await getPreferences();

        await preferences.setDouble(doubleKey, testDouble);
        expect(await preferences.getDouble(doubleKey), testDouble);
      });

      testWidgets('set and get StringList', (WidgetTester _) async {
        final SharedPreferencesAsync preferences = await getPreferences();

        await preferences.setStringList(listKey, testList);
        expect(await preferences.getStringList(listKey), testList);
      });

      testWidgets('getStringList returns mutable list', (WidgetTester _) async {
        final SharedPreferencesAsync preferences = await getPreferences();

        await preferences.setStringList(listKey, testList);
        final List<String>? list = await preferences.getStringList(listKey);
        list?.add('value');
        expect(list?.length, testList.length + 1);
      });

      testWidgets('getAll', (WidgetTester _) async {
        final SharedPreferencesAsync preferences = await getPreferences();
        await Future.wait(<Future<void>>[
          preferences.setString(stringKey, testString),
          preferences.setBool(boolKey, testBool),
          preferences.setInt(intKey, testInt),
          preferences.setDouble(doubleKey, testDouble),
          preferences.setStringList(listKey, testList)
        ]);

        final Map<String, Object?> gotAll = await preferences.getAll();

        expect(gotAll.length, 5);
        expect(gotAll[stringKey], testString);
        expect(gotAll[boolKey], testBool);
        expect(gotAll[intKey], testInt);
        expect(gotAll[doubleKey], testDouble);
        expect(gotAll[listKey], testList);
      });

      testWidgets('getAll with filter', (WidgetTester _) async {
        final SharedPreferencesAsync preferences = await getPreferences();
        await Future.wait(<Future<void>>[
          preferences.setString(stringKey, testString),
          preferences.setBool(boolKey, testBool),
          preferences.setInt(intKey, testInt),
          preferences.setDouble(doubleKey, testDouble),
          preferences.setStringList(listKey, testList)
        ]);

        final Map<String, Object?> gotAll =
            await preferences.getAll(allowList: <String>{stringKey, boolKey});

        expect(gotAll.length, 2);
        expect(gotAll[stringKey], testString);
        expect(gotAll[boolKey], testBool);
      });

      testWidgets('getKeys', (WidgetTester _) async {
        final SharedPreferencesAsync preferences = await getPreferences();
        await Future.wait(<Future<void>>[
          preferences.setString(stringKey, testString),
          preferences.setBool(boolKey, testBool),
          preferences.setInt(intKey, testInt),
          preferences.setDouble(doubleKey, testDouble),
          preferences.setStringList(listKey, testList)
        ]);

        final Set<String?> keys = await preferences.getKeys();

        expect(keys.length, 5);
        expect(keys, contains(stringKey));
        expect(keys, contains(boolKey));
        expect(keys, contains(intKey));
        expect(keys, contains(doubleKey));
        expect(keys, contains(listKey));
      });

      testWidgets('getKeys with filter', (WidgetTester _) async {
        final SharedPreferencesAsync preferences = await getPreferences();
        await Future.wait(<Future<void>>[
          preferences.setString(stringKey, testString),
          preferences.setBool(boolKey, testBool),
          preferences.setInt(intKey, testInt),
          preferences.setDouble(doubleKey, testDouble),
          preferences.setStringList(listKey, testList)
        ]);

        final Set<String?> keys =
            await preferences.getKeys(allowList: <String>{stringKey, boolKey});

        expect(keys.length, 2);
        expect(keys, contains(stringKey));
        expect(keys, contains(boolKey));
      });

      testWidgets('containsKey', (WidgetTester _) async {
        final SharedPreferencesAsync preferences = await getPreferences();
        const String key = 'testKey';

        expect(false, await preferences.containsKey(key));

        await preferences.setString(key, 'test');
        expect(true, await preferences.containsKey(key));
      });

      testWidgets('clear', (WidgetTester _) async {
        final SharedPreferencesAsync preferences = await getPreferences();
        await Future.wait(<Future<void>>[
          preferences.setString(stringKey, testString),
          preferences.setBool(boolKey, testBool),
          preferences.setInt(intKey, testInt),
          preferences.setDouble(doubleKey, testDouble),
          preferences.setStringList(listKey, testList)
        ]);
        await preferences.clear();
        expect(await preferences.getString(stringKey), null);
        expect(await preferences.getBool(boolKey), null);
        expect(await preferences.getInt(intKey), null);
        expect(await preferences.getDouble(doubleKey), null);
        expect(await preferences.getStringList(listKey), null);
      });

      testWidgets('clear with filter', (WidgetTester _) async {
        final SharedPreferencesAsync preferences = await getPreferences();
        await Future.wait(<Future<void>>[
          preferences.setString(stringKey, testString),
          preferences.setBool(boolKey, testBool),
          preferences.setInt(intKey, testInt),
          preferences.setDouble(doubleKey, testDouble),
          preferences.setStringList(listKey, testList)
        ]);
        await preferences.clear(allowList: <String>{stringKey, boolKey});
        expect(await preferences.getString(stringKey), null);
        expect(await preferences.getBool(boolKey), null);
        expect(await preferences.getInt(intKey), testInt);
        expect(await preferences.getDouble(doubleKey), testDouble);
        expect(await preferences.getStringList(listKey), testList);
      });

      testWidgets('throws TypeError when returned getBool type is incorrect',
          (WidgetTester _) async {
        final SharedPreferencesAsync preferences = await getPreferences();
        await preferences.setString(stringKey, testString);

        expect(() async {
          await preferences.getBool(stringKey);
        }, throwsA(isA<TypeError>()));
      });

      testWidgets('throws TypeError when returned getString type is incorrect',
          (WidgetTester _) async {
        final SharedPreferencesAsync preferences = await getPreferences();
        await preferences.setInt(stringKey, testInt);

        expect(() async {
          await preferences.getString(stringKey);
        }, throwsA(isA<TypeError>()));
      });

      testWidgets('throws TypeError when returned getInt type is incorrect',
          (WidgetTester _) async {
        final SharedPreferencesAsync preferences = await getPreferences();
        await preferences.setString(stringKey, testString);

        expect(() async {
          await preferences.getInt(stringKey);
        }, throwsA(isA<TypeError>()));
      });

      testWidgets('throws TypeError when returned getDouble type is incorrect',
          (WidgetTester _) async {
        final SharedPreferencesAsync preferences = await getPreferences();
        await preferences.setString(stringKey, testString);

        expect(() async {
          await preferences.getDouble(stringKey);
        }, throwsA(isA<TypeError>()));
      });

      testWidgets(
          'throws TypeError when returned getStringList type is incorrect',
          (WidgetTester _) async {
        final SharedPreferencesAsync preferences = await getPreferences();
        await preferences.setString(stringKey, testString);

        expect(() async {
          await preferences.getStringList(stringKey);
        }, throwsA(isA<TypeError>()));
      });
    });

    group('withCache', () {
      Future<
          (
            SharedPreferencesWithCache,
            Map<String, Object?>,
          )> getPreferences() async {
        final Map<String, Object?> cache = <String, Object?>{};
        final SharedPreferencesWithCache preferences =
            await SharedPreferencesWithCache.create(
          cache: cache,
          cacheOptions: const SharedPreferencesWithCacheOptions(),
        );
        await preferences.clear();
        return (preferences, cache);
      }

      testWidgets('set and get String', (WidgetTester _) async {
        final (SharedPreferencesWithCache preferences, _) =
            await getPreferences();

        await preferences.setString(stringKey, testString);
        expect(preferences.getString(stringKey), testString);
      });

      testWidgets('set and get bool', (WidgetTester _) async {
        final (SharedPreferencesWithCache preferences, _) =
            await getPreferences();

        await preferences.setBool(boolKey, testBool);
        expect(preferences.getBool(boolKey), testBool);
      });

      testWidgets('set and get int', (WidgetTester _) async {
        final (SharedPreferencesWithCache preferences, _) =
            await getPreferences();

        await preferences.setInt(intKey, testInt);
        expect(preferences.getInt(intKey), testInt);
      });

      testWidgets('set and get double', (WidgetTester _) async {
        final (SharedPreferencesWithCache preferences, _) =
            await getPreferences();

        await preferences.setDouble(doubleKey, testDouble);
        expect(preferences.getDouble(doubleKey), testDouble);
      });

      testWidgets('set and get StringList', (WidgetTester _) async {
        final (SharedPreferencesWithCache preferences, _) =
            await getPreferences();

        await preferences.setStringList(listKey, testList);
        expect(preferences.getStringList(listKey), testList);
      });

      testWidgets('reloading', (WidgetTester _) async {
        final (
          SharedPreferencesWithCache preferences,
          Map<String, Object?> cache
        ) = await getPreferences();
        await preferences.clear();
        await preferences.setString(stringKey, testString);
        expect(preferences.getString(stringKey), testString);

        cache.clear();
        expect(preferences.getString(stringKey), null);

        await preferences.reloadCache();
        expect(preferences.getString(stringKey), testString);
      });

      testWidgets('containsKey', (WidgetTester _) async {
        final (SharedPreferencesWithCache preferences, _) =
            await getPreferences();
        const String key = 'testKey';

        expect(false, preferences.containsKey(key));

        await preferences.setString(key, 'test');
        expect(true, preferences.containsKey(key));
      });

      testWidgets('getKeys', (WidgetTester _) async {
        final (SharedPreferencesWithCache preferences, _) =
            await getPreferences();
        await Future.wait(<Future<void>>[
          preferences.setString(stringKey, testString),
          preferences.setBool(boolKey, testBool),
          preferences.setInt(intKey, testInt),
          preferences.setDouble(doubleKey, testDouble),
          preferences.setStringList(listKey, testList)
        ]);

        final Set<String> keys = preferences.keys;

        expect(keys.length, 5);
        expect(keys, contains(stringKey));
        expect(keys, contains(boolKey));
        expect(keys, contains(intKey));
        expect(keys, contains(doubleKey));
        expect(keys, contains(listKey));
      });

      testWidgets('clear', (WidgetTester _) async {
        final (SharedPreferencesWithCache preferences, _) =
            await getPreferences();
        await Future.wait(<Future<void>>[
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
      Future<
          (
            SharedPreferencesWithCache,
            Map<String, Object?>,
          )> getPreferences() async {
        final Map<String, Object?> cache = <String, Object?>{};
        final SharedPreferencesWithCache preferences =
            await SharedPreferencesWithCache.create(
          cache: cache,
          cacheOptions: const SharedPreferencesWithCacheOptions(
            allowList: <String>{
              stringKey,
              boolKey,
              intKey,
              doubleKey,
              listKey,
            },
          ),
        );
        await preferences.clear();
        return (preferences, cache);
      }

      testWidgets('throws ArgumentError if key is not included in filter',
          (WidgetTester _) async {
        final (SharedPreferencesWithCache preferences, _) =
            await getPreferences();
        const String key = 'testKey';

        expect(() async => preferences.setString(key, 'test'),
            throwsArgumentError);
      });

      testWidgets('set and get String', (WidgetTester _) async {
        final (SharedPreferencesWithCache preferences, _) =
            await getPreferences();

        await preferences.setString(stringKey, testString);
        expect(preferences.getString(stringKey), testString);
      });

      testWidgets('set and get bool', (WidgetTester _) async {
        final (SharedPreferencesWithCache preferences, _) =
            await getPreferences();

        await preferences.setBool(boolKey, testBool);
        expect(preferences.getBool(boolKey), testBool);
      });

      testWidgets('set and get int', (WidgetTester _) async {
        final (SharedPreferencesWithCache preferences, _) =
            await getPreferences();

        await preferences.setInt(intKey, testInt);
        expect(preferences.getInt(intKey), testInt);
      });

      testWidgets('set and get double', (WidgetTester _) async {
        final (SharedPreferencesWithCache preferences, _) =
            await getPreferences();

        await preferences.setDouble(doubleKey, testDouble);
        expect(preferences.getDouble(doubleKey), testDouble);
      });

      testWidgets('set and get StringList', (WidgetTester _) async {
        final (SharedPreferencesWithCache preferences, _) =
            await getPreferences();

        await preferences.setStringList(listKey, testList);
        expect(preferences.getStringList(listKey), testList);
      });

      testWidgets('get StringList handles List<Object?>',
          (WidgetTester _) async {
        final (
          SharedPreferencesWithCache preferences,
          Map<String, Object?> cache
        ) = await getPreferences();
        final List<Object?> listObject = <Object?>['one', 'two'];
        cache[listKey] = listObject;
        expect(preferences.getStringList(listKey), listObject);
      });

      testWidgets('reloading', (WidgetTester _) async {
        final (
          SharedPreferencesWithCache preferences,
          Map<String, Object?> cache
        ) = await getPreferences();
        await preferences.clear();
        await preferences.setString(stringKey, testString);
        expect(preferences.getString(stringKey), testString);

        cache.clear();
        expect(preferences.getString(stringKey), null);

        await preferences.reloadCache();
        expect(preferences.getString(stringKey), testString);
      });

      testWidgets('containsKey', (WidgetTester _) async {
        final (SharedPreferencesWithCache preferences, _) =
            await getPreferences();

        expect(false, preferences.containsKey(stringKey));

        await preferences.setString(stringKey, 'test');
        expect(true, preferences.containsKey(stringKey));
      });

      testWidgets('getKeys', (WidgetTester _) async {
        final (SharedPreferencesWithCache preferences, _) =
            await getPreferences();
        await Future.wait(<Future<void>>[
          preferences.setString(stringKey, testString),
          preferences.setBool(boolKey, testBool),
          preferences.setInt(intKey, testInt),
          preferences.setDouble(doubleKey, testDouble),
          preferences.setStringList(listKey, testList)
        ]);

        final Set<String> keys = preferences.keys;

        expect(keys.length, 5);
        expect(keys, contains(stringKey));
        expect(keys, contains(boolKey));
        expect(keys, contains(intKey));
        expect(keys, contains(doubleKey));
        expect(keys, contains(listKey));
      });

      testWidgets('clear', (WidgetTester _) async {
        final (SharedPreferencesWithCache preferences, _) =
            await getPreferences();
        await Future.wait(<Future<void>>[
          preferences.setString(stringKey, testString),
          preferences.setBool(boolKey, testBool),
          preferences.setInt(intKey, testInt),
          preferences.setDouble(doubleKey, testDouble),
          preferences.setStringList(listKey, testList)
        ]);
        await preferences.clear();

        expect(preferences.getString(stringKey), null);
        expect(preferences.getBool(boolKey), null);
        // The data for the next few tests is still stored on the platform, but not in the cache.
        // This will cause the results to be null.
        expect(preferences.getInt(intKey), null);
        expect(preferences.getDouble(doubleKey), null);
        expect(preferences.getStringList(listKey), null);
      });
    });
  });
}
