// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:shared_preferences_platform_interface/types.dart';

void main() {
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
    (SharedPreferencesAsync, FakeSharedPreferencesAsync) getPreferences() {
      final FakeSharedPreferencesAsync store = FakeSharedPreferencesAsync();
      SharedPreferencesAsyncPlatform.instance = store;
      final SharedPreferencesAsync preferences = SharedPreferencesAsync();
      return (preferences, store);
    }

    test('set and get String', () async {
      final (
        SharedPreferencesAsync preferences,
        FakeSharedPreferencesAsync store,
      ) = getPreferences();
      await preferences.setString(stringKey, testString);
      expect(
        store.log,
        <Matcher>[
          isMethodCall('setString', arguments: <dynamic>[
            stringKey,
            testString,
          ]),
        ],
      );
      store.log.clear();
      expect(await preferences.getString(stringKey), testString);
      expect(
        store.log,
        <Matcher>[
          isMethodCall('getString', arguments: <dynamic>[
            stringKey,
          ]),
        ],
      );
    });

    test('set and get bool', () async {
      final (
        SharedPreferencesAsync preferences,
        FakeSharedPreferencesAsync store
      ) = getPreferences();
      await preferences.setBool(boolKey, testBool);
      expect(
        store.log,
        <Matcher>[
          isMethodCall('setBool', arguments: <dynamic>[
            boolKey,
            testBool,
          ]),
        ],
      );
      store.log.clear();
      expect(await preferences.getBool(boolKey), testBool);
      expect(
        store.log,
        <Matcher>[
          isMethodCall('getBool', arguments: <dynamic>[
            boolKey,
          ]),
        ],
      );
    });

    test('set and get int', () async {
      final (
        SharedPreferencesAsync preferences,
        FakeSharedPreferencesAsync store
      ) = getPreferences();
      await preferences.setInt(intKey, testInt);
      expect(
        store.log,
        <Matcher>[
          isMethodCall('setInt', arguments: <dynamic>[
            intKey,
            testInt,
          ]),
        ],
      );
      store.log.clear();

      expect(await preferences.getInt(intKey), testInt);
      expect(
        store.log,
        <Matcher>[
          isMethodCall('getInt', arguments: <dynamic>[
            intKey,
          ]),
        ],
      );
    });

    test('set and get double', () async {
      final (
        SharedPreferencesAsync preferences,
        FakeSharedPreferencesAsync store
      ) = getPreferences();
      await preferences.setDouble(doubleKey, testDouble);
      expect(
        store.log,
        <Matcher>[
          isMethodCall('setDouble', arguments: <dynamic>[
            doubleKey,
            testDouble,
          ]),
        ],
      );
      store.log.clear();
      expect(await preferences.getDouble(doubleKey), testDouble);
      expect(
        store.log,
        <Matcher>[
          isMethodCall('getDouble', arguments: <dynamic>[
            doubleKey,
          ]),
        ],
      );
    });

    test('set and get StringList', () async {
      final (
        SharedPreferencesAsync preferences,
        FakeSharedPreferencesAsync store
      ) = getPreferences();
      await preferences.setStringList(listKey, testList);
      expect(
        store.log,
        <Matcher>[
          isMethodCall('setStringList', arguments: <dynamic>[
            listKey,
            testList,
          ]),
        ],
      );
      store.log.clear();
      expect(await preferences.getStringList(listKey), testList);
      expect(
        store.log,
        <Matcher>[
          isMethodCall('getStringList', arguments: <dynamic>[
            listKey,
          ]),
        ],
      );
    });

    test('getAll', () async {
      final (SharedPreferencesAsync preferences, _) = getPreferences();
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

    test('getAll with filter', () async {
      final (SharedPreferencesAsync preferences, _) = getPreferences();
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

    test('remove', () async {
      final (
        SharedPreferencesAsync preferences,
        FakeSharedPreferencesAsync store
      ) = getPreferences();
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
      final (SharedPreferencesAsync preferences, _) = getPreferences();
      await Future.wait(<Future<void>>[
        preferences.setString(stringKey, testString),
        preferences.setBool(boolKey, testBool),
        preferences.setInt(intKey, testInt),
        preferences.setDouble(doubleKey, testDouble),
        preferences.setStringList(listKey, testList)
      ]);

      final Set<String> keys = await preferences.getKeys();

      expect(keys.length, 5);
      expect(keys, contains(stringKey));
      expect(keys, contains(boolKey));
      expect(keys, contains(intKey));
      expect(keys, contains(doubleKey));
      expect(keys, contains(listKey));
    });

    test('getKeys with filter', () async {
      final (SharedPreferencesAsync preferences, _) = getPreferences();
      await Future.wait(<Future<void>>[
        preferences.setString(stringKey, testString),
        preferences.setBool(boolKey, testBool),
        preferences.setInt(intKey, testInt),
        preferences.setDouble(doubleKey, testDouble),
        preferences.setStringList(listKey, testList)
      ]);

      final Set<String> keys =
          await preferences.getKeys(allowList: <String>{stringKey, boolKey});

      expect(keys.length, 2);
      expect(keys, contains(stringKey));
      expect(keys, contains(boolKey));
    });

    test('containsKey', () async {
      final (SharedPreferencesAsync preferences, _) = getPreferences();
      const String key = 'testKey';

      expect(false, await preferences.containsKey(key));

      await preferences.setString(key, 'test');
      expect(true, await preferences.containsKey(key));
    });

    test('clear', () async {
      final (
        SharedPreferencesAsync preferences,
        FakeSharedPreferencesAsync store
      ) = getPreferences();
      await Future.wait(<Future<void>>[
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
      expect(await preferences.getString(stringKey), null);
      expect(await preferences.getBool(boolKey), null);
      expect(await preferences.getInt(intKey), null);
      expect(await preferences.getDouble(doubleKey), null);
      expect(await preferences.getStringList(listKey), null);
    });

    test('clear with filter', () async {
      final (
        SharedPreferencesAsync preferences,
        FakeSharedPreferencesAsync store
      ) = getPreferences();
      await Future.wait(<Future<void>>[
        preferences.setString(stringKey, testString),
        preferences.setBool(boolKey, testBool),
        preferences.setInt(intKey, testInt),
        preferences.setDouble(doubleKey, testDouble),
        preferences.setStringList(listKey, testList)
      ]);
      store.log.clear();
      await preferences.clear(allowList: <String>{stringKey, boolKey});
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
    Future<
        (
          SharedPreferencesWithCache,
          FakeSharedPreferencesAsync,
          Map<String, Object?>,
        )> getPreferences() async {
      final Map<String, Object?> cache = <String, Object?>{};
      final FakeSharedPreferencesAsync store = FakeSharedPreferencesAsync();
      SharedPreferencesAsyncPlatform.instance = store;
      final SharedPreferencesWithCache preferences =
          await SharedPreferencesWithCache.create(
        cache: cache,
        cacheOptions: const SharedPreferencesWithCacheOptions(),
      );
      store.log.clear();
      return (preferences, store, cache);
    }

    test('set and get String', () async {
      final (
        SharedPreferencesWithCache preferences,
        FakeSharedPreferencesAsync store,
        _,
      ) = await getPreferences();
      await preferences.setString(stringKey, testString);
      expect(
        store.log,
        <Matcher>[
          isMethodCall('setString', arguments: <dynamic>[
            stringKey,
            testString,
          ]),
        ],
      );
      store.log.clear();
      expect(preferences.getString(stringKey), testString);
      expect(
        store.log,
        <Matcher>[],
      );
    });

    test('set and get bool', () async {
      final (
        SharedPreferencesWithCache preferences,
        FakeSharedPreferencesAsync store,
        _,
      ) = await getPreferences();
      await preferences.setBool(boolKey, testBool);
      expect(
        store.log,
        <Matcher>[
          isMethodCall('setBool', arguments: <dynamic>[
            boolKey,
            testBool,
          ]),
        ],
      );
      store.log.clear();
      expect(preferences.getBool(boolKey), testBool);
      expect(
        store.log,
        <Matcher>[],
      );
    });

    test('set and get int', () async {
      final (
        SharedPreferencesWithCache preferences,
        FakeSharedPreferencesAsync store,
        _,
      ) = await getPreferences();
      await preferences.setInt(intKey, testInt);
      expect(
        store.log,
        <Matcher>[
          isMethodCall('setInt', arguments: <dynamic>[
            intKey,
            testInt,
          ]),
        ],
      );
      store.log.clear();

      expect(preferences.getInt(intKey), testInt);
      expect(
        store.log,
        <Matcher>[],
      );
    });

    test('set and get double', () async {
      final (
        SharedPreferencesWithCache preferences,
        FakeSharedPreferencesAsync store,
        _,
      ) = await getPreferences();
      await preferences.setDouble(doubleKey, testDouble);
      expect(
        store.log,
        <Matcher>[
          isMethodCall('setDouble', arguments: <dynamic>[
            doubleKey,
            testDouble,
          ]),
        ],
      );
      store.log.clear();
      expect(preferences.getDouble(doubleKey), testDouble);
      expect(
        store.log,
        <Matcher>[],
      );
    });

    test('set and get StringList', () async {
      final (
        SharedPreferencesWithCache preferences,
        FakeSharedPreferencesAsync store,
        _,
      ) = await getPreferences();
      await preferences.setStringList(listKey, testList);
      expect(
        store.log,
        <Matcher>[
          isMethodCall('setStringList', arguments: <dynamic>[
            listKey,
            testList,
          ]),
        ],
      );
      store.log.clear();
      expect(preferences.getStringList(listKey), testList);
      expect(
        store.log,
        <Matcher>[],
      );
    });

    test('reloading', () async {
      final (
        SharedPreferencesWithCache preferences,
        _,
        Map<String, Object?> cache,
      ) = await getPreferences();
      await preferences.setString(stringKey, testString);
      expect(preferences.getString(stringKey), testString);

      cache.clear();
      expect(preferences.getString(stringKey), null);

      await preferences.reloadCache();
      expect(preferences.getString(stringKey), testString);
    });

    test('containsKey', () async {
      final (
        SharedPreferencesWithCache preferences,
        _,
        _,
      ) = await getPreferences();
      const String key = 'testKey';

      expect(false, preferences.containsKey(key));

      await preferences.setString(key, 'test');
      expect(true, preferences.containsKey(key));
    });

    test('getKeys', () async {
      final (
        SharedPreferencesWithCache preferences,
        _,
        _,
      ) = await getPreferences();
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

    test('remove', () async {
      final (
        SharedPreferencesWithCache preferences,
        FakeSharedPreferencesAsync store,
        _,
      ) = await getPreferences();
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
      final (
        SharedPreferencesWithCache preferences,
        FakeSharedPreferencesAsync store,
        _,
      ) = await getPreferences();
      await Future.wait(<Future<void>>[
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
    Future<
        (
          SharedPreferencesWithCache,
          FakeSharedPreferencesAsync,
          Map<String, Object?>,
        )> getPreferences() async {
      final Map<String, Object?> cache = <String, Object?>{};
      final FakeSharedPreferencesAsync store = FakeSharedPreferencesAsync();
      SharedPreferencesAsyncPlatform.instance = store;
      final SharedPreferencesWithCache preferences =
          await SharedPreferencesWithCache.create(
        cache: cache,
        cacheOptions:
            const SharedPreferencesWithCacheOptions(allowList: <String>{
          stringKey,
          boolKey,
          intKey,
          doubleKey,
          listKey,
        }),
      );
      store.log.clear();
      return (preferences, store, cache);
    }

    test('set and get String', () async {
      final (
        SharedPreferencesWithCache preferences,
        FakeSharedPreferencesAsync store,
        _,
      ) = await getPreferences();
      await preferences.setString(stringKey, testString);
      expect(
        store.log,
        <Matcher>[
          isMethodCall('setString', arguments: <dynamic>[
            stringKey,
            testString,
          ]),
        ],
      );
      store.log.clear();
      expect(preferences.getString(stringKey), testString);
      expect(
        store.log,
        <Matcher>[],
      );
    });

    test('set and get bool', () async {
      final (
        SharedPreferencesWithCache preferences,
        FakeSharedPreferencesAsync store,
        _,
      ) = await getPreferences();
      await preferences.setBool(boolKey, testBool);
      expect(
        store.log,
        <Matcher>[
          isMethodCall('setBool', arguments: <dynamic>[
            boolKey,
            testBool,
          ]),
        ],
      );
      store.log.clear();
      expect(preferences.getBool(boolKey), testBool);
      expect(
        store.log,
        <Matcher>[],
      );
    });

    test('set and get int', () async {
      final (
        SharedPreferencesWithCache preferences,
        FakeSharedPreferencesAsync store,
        _,
      ) = await getPreferences();
      await preferences.setInt(intKey, testInt);
      expect(
        store.log,
        <Matcher>[
          isMethodCall('setInt', arguments: <dynamic>[
            intKey,
            testInt,
          ]),
        ],
      );
      store.log.clear();

      expect(preferences.getInt(intKey), testInt);
      expect(
        store.log,
        <Matcher>[],
      );
    });

    test('set and get double', () async {
      final (
        SharedPreferencesWithCache preferences,
        FakeSharedPreferencesAsync store,
        _,
      ) = await getPreferences();
      await preferences.setDouble(doubleKey, testDouble);
      expect(
        store.log,
        <Matcher>[
          isMethodCall('setDouble', arguments: <dynamic>[
            doubleKey,
            testDouble,
          ]),
        ],
      );
      store.log.clear();
      expect(preferences.getDouble(doubleKey), testDouble);
      expect(
        store.log,
        <Matcher>[],
      );
    });

    test('set and get StringList', () async {
      final (
        SharedPreferencesWithCache preferences,
        FakeSharedPreferencesAsync store,
        _,
      ) = await getPreferences();
      await preferences.setStringList(listKey, testList);
      expect(
        store.log,
        <Matcher>[
          isMethodCall('setStringList', arguments: <dynamic>[
            listKey,
            testList,
          ]),
        ],
      );
      store.log.clear();
      expect(preferences.getStringList(listKey), testList);
      expect(
        store.log,
        <Matcher>[],
      );
    });
    test('reloading', () async {
      final (
        SharedPreferencesWithCache preferences,
        _,
        Map<String, Object?> cache,
      ) = await getPreferences();
      await preferences.setString(stringKey, testString);
      expect(preferences.getString(stringKey), testString);

      cache.clear();
      expect(preferences.getString(stringKey), null);

      await preferences.reloadCache();
      expect(preferences.getString(stringKey), testString);
    });

    test('throws ArgumentError if key is not included in filter', () async {
      final (
        SharedPreferencesWithCache preferences,
        _,
        _,
      ) = await getPreferences();
      const String key = 'testKey';

      expect(
          () async => preferences.setString(key, 'test'), throwsArgumentError);
    });

    test('containsKey', () async {
      final (
        SharedPreferencesWithCache preferences,
        _,
        _,
      ) = await getPreferences();

      expect(false, preferences.containsKey(stringKey));

      await preferences.setString(stringKey, 'test');
      expect(true, preferences.containsKey(stringKey));
    });

    test('getKeys', () async {
      final (
        SharedPreferencesWithCache preferences,
        _,
        _,
      ) = await getPreferences();
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

    test('remove', () async {
      final (
        SharedPreferencesWithCache preferences,
        FakeSharedPreferencesAsync store,
        _,
      ) = await getPreferences();
      await preferences.remove(stringKey);
      expect(
          store.log,
          List<Matcher>.filled(
            1,
            isMethodCall(
              'clear',
              arguments: <String>[stringKey],
            ),
            growable: true,
          ));
    });

    test('clear', () async {
      final (
        SharedPreferencesWithCache preferences,
        FakeSharedPreferencesAsync store,
        _,
      ) = await getPreferences();
      await Future.wait(<Future<void>>[
        preferences.setString(stringKey, testString),
        preferences.setBool(boolKey, testBool),
        preferences.setInt(intKey, testInt),
        preferences.setDouble(doubleKey, testDouble),
        preferences.setStringList(listKey, testList)
      ]);
      store.log.clear();
      await preferences.clear();
      expect(store.log, <Matcher>[
        isMethodCall('clear', arguments: <Object>[
          stringKey,
          boolKey,
          intKey,
          doubleKey,
          listKey,
        ])
      ]);

      expect(preferences.getString(stringKey), null);
      expect(preferences.getBool(boolKey), null);
      // The cache will clear everything, even though the backend will still hold this data.
      // Since the cache shouldn't ever be able to add data that isn't in the allowlist,
      // this is expected behavior.
      expect(preferences.getInt(intKey), null);
      expect(preferences.getDouble(doubleKey), null);
      expect(preferences.getStringList(listKey), null);
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
  Future<Set<String>> getKeys(
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
