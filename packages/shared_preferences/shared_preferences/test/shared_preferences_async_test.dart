// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preference_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:shared_preferences_platform_interface/types.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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
    late FakeSharedPreferencesAsync store;
    late SharedPreferencesAsync preferences;

    setUp(() async {
      store = FakeSharedPreferencesAsync();
      SharedPreferencesAsyncPlatform.instance = store;
      preferences =
          SharedPreferencesAsync(options: const SharedPreferencesOptions());
      store.log.clear();
    });

    test('set and get', () async {
      await Future.wait(<Future<bool>>[
        preferences.setString(stringKey, testString),
        preferences.setBool(boolKey, testBool),
        preferences.setInt(intKey, testInt),
        preferences.setDouble(doubleKey, testDouble),
        preferences.setStringList(listKey, testList)
      ]);
      expect(
        store.log,
        <Matcher>[
          isMethodCall('setString', arguments: <dynamic>[
            stringKey,
            testString,
          ]),
          isMethodCall('setBool', arguments: <dynamic>[
            boolKey,
            testBool,
          ]),
          isMethodCall('setInt', arguments: <dynamic>[
            intKey,
            testInt,
          ]),
          isMethodCall('setDouble', arguments: <dynamic>[
            doubleKey,
            testDouble,
          ]),
          isMethodCall('setStringList', arguments: <dynamic>[
            listKey,
            testList,
          ]),
        ],
      );
      store.log.clear();

      expect(await preferences.getString(stringKey), testString);
      expect(await preferences.getBool(boolKey), testBool);
      expect(await preferences.getInt(intKey), testInt);
      expect(await preferences.getDouble(doubleKey), testDouble);
      expect(await preferences.getStringList(listKey), testList);
      expect(
        store.log,
        <Matcher>[
          isMethodCall('getString', arguments: <dynamic>[
            stringKey,
          ]),
          isMethodCall('getBool', arguments: <dynamic>[
            boolKey,
          ]),
          isMethodCall('getInt', arguments: <dynamic>[
            intKey,
          ]),
          isMethodCall('getDouble', arguments: <dynamic>[
            doubleKey,
          ]),
          isMethodCall('getStringList', arguments: <dynamic>[
            listKey,
          ]),
        ],
      );
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

    test('remove', () async {
      const String key = 'testKey';
      await preferences.remove(key);
      expect(
          store.log,
          List<Matcher>.filled(
            1,
            isMethodCall(
              'clear',
              arguments: <String>[key],
            ),
            growable: true,
          ));
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
      store.log.clear();
      await preferences.clear(
          const ClearPreferencesParameters(filter: PreferencesFilters()));
      expect(
          store.log, <Matcher>[isMethodCall('clear', arguments: <Object>[])]);
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
      store.log.clear();
      await preferences.clear(
        const ClearPreferencesParameters(
          filter: PreferencesFilters(allowList: <String>{stringKey, boolKey}),
        ),
      );
      expect(store.log, <Matcher>[
        isMethodCall('clear', arguments: <Object>[stringKey, boolKey])
      ]);
      expect(await preferences.getString(stringKey), null);
      expect(await preferences.getBool(boolKey), null);
      expect(await preferences.getInt(intKey), testInt);
      expect(await preferences.getDouble(doubleKey), testDouble);
      expect(await preferences.getStringList(listKey), testList);
    });
  });

  group('withCache', () {
    late FakeSharedPreferencesAsync store;
    late SharedPreferencesWithCache preferences;
    late Map<String, Object?> cache;

    setUp(() async {
      store = FakeSharedPreferencesAsync();
      SharedPreferencesAsyncPlatform.instance = store;
      cache = <String, Object?>{};
      preferences = SharedPreferencesWithCache(
        cache: cache,
        sharedPreferencesOptions: const SharedPreferencesOptions(),
        cacheOptions: SharedPreferencesWithCacheOptions(
          filter: const PreferencesFilters(),
        ),
      );

      store.log.clear();
    });

    test('set and get', () async {
      await Future.wait(<Future<bool>>[
        preferences.setString(stringKey, testString),
        preferences.setBool(boolKey, testBool),
        preferences.setInt(intKey, testInt),
        preferences.setDouble(doubleKey, testDouble),
        preferences.setStringList(listKey, testList)
      ]);
      expect(
        store.log,
        <Matcher>[
          isMethodCall('setString', arguments: <dynamic>[
            stringKey,
            testString,
          ]),
          isMethodCall('setBool', arguments: <dynamic>[
            boolKey,
            testBool,
          ]),
          isMethodCall('setInt', arguments: <dynamic>[
            intKey,
            testInt,
          ]),
          isMethodCall('setDouble', arguments: <dynamic>[
            doubleKey,
            testDouble,
          ]),
          isMethodCall('setStringList', arguments: <dynamic>[
            listKey,
            testList,
          ]),
        ],
      );
      store.log.clear();

      expect(preferences.getString(stringKey), testString);
      expect(preferences.getBool(boolKey), testBool);
      expect(preferences.getInt(intKey), testInt);
      expect(preferences.getDouble(doubleKey), testDouble);
      expect(preferences.getStringList(listKey), testList);
      expect(store.log, <Matcher>[]);
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

    test('remove', () async {
      const String key = 'testKey';
      await preferences.remove(key);
      expect(
          store.log,
          List<Matcher>.filled(
            1,
            isMethodCall(
              'clear',
              arguments: <String>[key],
            ),
            growable: true,
          ));
    });

    test('clear', () async {
      await Future.wait(<Future<bool>>[
        preferences.setString(stringKey, testString),
        preferences.setBool(boolKey, testBool),
        preferences.setInt(intKey, testInt),
        preferences.setDouble(doubleKey, testDouble),
        preferences.setStringList(listKey, testList)
      ]);
      store.log.clear();
      await preferences.clear();
      expect(
          store.log, <Matcher>[isMethodCall('clear', arguments: <Object>[])]);
      expect(preferences.getString(stringKey), null);
      expect(preferences.getBool(boolKey), null);
      expect(preferences.getInt(intKey), null);
      expect(preferences.getDouble(doubleKey), null);
      expect(preferences.getStringList(listKey), null);
    });
  });

  group('withCache with filter', () {
    late FakeSharedPreferencesAsync store;
    late SharedPreferencesWithCache preferences;
    late Map<String, Object?> cache;

    setUp(() async {
      store = FakeSharedPreferencesAsync();
      SharedPreferencesAsyncPlatform.instance = store;
      cache = <String, Object?>{};
      preferences = SharedPreferencesWithCache(
        cache: cache,
        sharedPreferencesOptions: const SharedPreferencesOptions(),
        cacheOptions: SharedPreferencesWithCacheOptions(
          filter:
              const PreferencesFilters(allowList: <String>{stringKey, boolKey}),
        ),
      );

      store.log.clear();
    });

    test('set and get', () async {
      await Future.wait(<Future<bool>>[
        preferences.setString(stringKey, testString),
        preferences.setBool(boolKey, testBool),
        preferences.setInt(intKey, testInt),
        preferences.setDouble(doubleKey, testDouble),
        preferences.setStringList(listKey, testList)
      ]);
      expect(
        store.log,
        <Matcher>[
          isMethodCall('setString', arguments: <dynamic>[
            stringKey,
            testString,
          ]),
          isMethodCall('setBool', arguments: <dynamic>[
            boolKey,
            testBool,
          ]),
          isMethodCall('setInt', arguments: <dynamic>[
            intKey,
            testInt,
          ]),
          isMethodCall('setDouble', arguments: <dynamic>[
            doubleKey,
            testDouble,
          ]),
          isMethodCall('setStringList', arguments: <dynamic>[
            listKey,
            testList,
          ]),
        ],
      );
      store.log.clear();

      expect(preferences.getString(stringKey), testString);
      expect(preferences.getBool(boolKey), testBool);
      expect(preferences.getInt(intKey), testInt);
      expect(preferences.getDouble(doubleKey), testDouble);
      expect(preferences.getStringList(listKey), testList);
      expect(store.log, <Matcher>[]);
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

    test('remove', () async {
      const String key = 'testKey';
      await preferences.remove(key);
      expect(
          store.log,
          List<Matcher>.filled(
            1,
            isMethodCall(
              'clear',
              arguments: <String>[key],
            ),
            growable: true,
          ));
    });

    test('clear', () async {
      await Future.wait(<Future<bool>>[
        preferences.setString(stringKey, testString),
        preferences.setBool(boolKey, testBool),
        preferences.setInt(intKey, testInt),
        preferences.setDouble(doubleKey, testDouble),
        preferences.setStringList(listKey, testList)
      ]);
      store.log.clear();
      await preferences.clear();
      expect(store.log, <Matcher>[
        isMethodCall('clear', arguments: <Object>[stringKey, boolKey])
      ]);

      expect(preferences.getString(stringKey), null);
      expect(preferences.getBool(boolKey), null);
      expect(preferences.getInt(intKey), testInt);
      expect(preferences.getDouble(doubleKey), testDouble);
      expect(preferences.getStringList(listKey), testList);
    });
  });
}

base class FakeSharedPreferencesAsync extends SharedPreferencesAsyncPlatform {
  final InMemorySharedPreferencesAsync backend =
      InMemorySharedPreferencesAsync.empty();
  final List<MethodCall> log = <MethodCall>[];

  @override
  Future<bool> clear(
      ClearPreferencesParameters parameters, SharedPreferencesOptions options) {
    log.add(MethodCall('clear', <Object>[...?parameters.filter.allowList]));
    return backend.clear(parameters, options);
  }

  @override
  Future<bool?> getBool(String key, SharedPreferencesOptions options) {
    log.add(MethodCall('getBool', <String>[key]));
    return backend.getBool(key, options);
  }

  @override
  Future<double?> getDouble(String key, SharedPreferencesOptions options) {
    log.add(MethodCall('getDouble', <String>[key]));
    return backend.getDouble(key, options);
  }

  @override
  Future<int?> getInt(String key, SharedPreferencesOptions options) {
    log.add(MethodCall('getInt', <String>[key]));
    return backend.getInt(key, options);
  }

  @override
  Future<Set<String?>> getKeys(
      GetPreferencesParameters parameters, SharedPreferencesOptions options) {
    log.add(MethodCall('getKeys', <String>[...?parameters.filter.allowList]));
    return backend.getKeys(parameters, options);
  }

  @override
  Future<Map<String, Object>> getPreferences(
      GetPreferencesParameters parameters, SharedPreferencesOptions options) {
    log.add(MethodCall(
        'getPreferences', <Object>[...?parameters.filter.allowList]));
    return backend.getPreferences(parameters, options);
  }

  @override
  Future<String?> getString(String key, SharedPreferencesOptions options) {
    log.add(MethodCall('getString', <String>[key]));
    return backend.getString(key, options);
  }

  @override
  Future<List<String>?> getStringList(
      String key, SharedPreferencesOptions options) {
    log.add(MethodCall('getStringList', <String>[key]));
    return backend.getStringList(key, options);
  }

  @override
  Future<bool> setBool(
      String key, bool value, SharedPreferencesOptions options) {
    log.add(MethodCall('setBool', <Object>[key, value]));
    return backend.setBool(key, value, options);
  }

  @override
  Future<bool> setDouble(
      String key, double value, SharedPreferencesOptions options) {
    log.add(MethodCall('setDouble', <Object>[key, value]));
    return backend.setDouble(key, value, options);
  }

  @override
  Future<bool> setInt(String key, int value, SharedPreferencesOptions options) {
    log.add(MethodCall('setInt', <Object>[key, value]));
    return backend.setInt(key, value, options);
  }

  @override
  Future<bool> setString(
      String key, String value, SharedPreferencesOptions options) {
    log.add(MethodCall('setString', <Object>[key, value]));
    return backend.setString(key, value, options);
  }

  @override
  Future<bool> setStringList(
      String key, List<String> value, SharedPreferencesOptions options) {
    log.add(MethodCall('setStringList', <Object>[key, value]));
    return backend.setStringList(key, value, options);
  }
}
