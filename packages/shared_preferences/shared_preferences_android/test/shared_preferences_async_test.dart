// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_android/shared_preferences_android.dart';
import 'package:shared_preferences_android/src/messages_async.g.dart';
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

  const SharedPreferencesAsyncAndroidOptions emptyOptions =
      SharedPreferencesAsyncAndroidOptions();

  SharedPreferencesAsyncAndroid getPreferences() {
    final _FakeSharedPreferencesApi api = _FakeSharedPreferencesApi();
    final SharedPreferencesAsyncAndroid preferences =
        SharedPreferencesAsyncAndroid(api: api);

    return preferences;
  }

  test('set and get String', () async {
    final SharedPreferencesAsyncAndroid preferences = getPreferences();

    await preferences.setString(stringKey, testString, emptyOptions);
    expect(await preferences.getString(stringKey, emptyOptions), testString);
  });

  test('set and get bool', () async {
    final SharedPreferencesAsyncAndroid preferences = getPreferences();

    await preferences.setBool(boolKey, testBool, emptyOptions);
    expect(await preferences.getBool(boolKey, emptyOptions), testBool);
  });

  test('set and get int', () async {
    final SharedPreferencesAsyncAndroid preferences = getPreferences();

    await preferences.setInt(intKey, testInt, emptyOptions);
    expect(await preferences.getInt(intKey, emptyOptions), testInt);
  });

  test('set and get double', () async {
    final SharedPreferencesAsyncAndroid preferences = getPreferences();

    await preferences.setDouble(doubleKey, testDouble, emptyOptions);
    expect(await preferences.getDouble(doubleKey, emptyOptions), testDouble);
  });

  test('set and get StringList', () async {
    final SharedPreferencesAsyncAndroid preferences = getPreferences();

    await preferences.setStringList(listKey, testList, emptyOptions);
    expect(await preferences.getStringList(listKey, emptyOptions), testList);
  });

  test('getPreferences', () async {
    final SharedPreferencesAsyncAndroid preferences = getPreferences();
    await Future.wait(<Future<void>>[
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

  test('getPreferences with filter', () async {
    final SharedPreferencesAsyncAndroid preferences = getPreferences();
    await Future.wait(<Future<void>>[
      preferences.setString(stringKey, testString, emptyOptions),
      preferences.setBool(boolKey, testBool, emptyOptions),
      preferences.setInt(intKey, testInt, emptyOptions),
      preferences.setDouble(doubleKey, testDouble, emptyOptions),
      preferences.setStringList(listKey, testList, emptyOptions)
    ]);

    final Map<String, Object?> gotAll = await preferences.getPreferences(
        const GetPreferencesParameters(
            filter:
                PreferencesFilters(allowList: <String>{stringKey, boolKey})),
        emptyOptions);

    expect(gotAll.length, 2);
    expect(gotAll[stringKey], testString);
    expect(gotAll[boolKey], testBool);
  });

  test('getKeys', () async {
    final SharedPreferencesAsyncAndroid preferences = getPreferences();
    await Future.wait(<Future<void>>[
      preferences.setString(stringKey, testString, emptyOptions),
      preferences.setBool(boolKey, testBool, emptyOptions),
      preferences.setInt(intKey, testInt, emptyOptions),
      preferences.setDouble(doubleKey, testDouble, emptyOptions),
      preferences.setStringList(listKey, testList, emptyOptions)
    ]);

    final Set<String> keys = await preferences.getKeys(
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
    final SharedPreferencesAsyncAndroid preferences = getPreferences();
    await Future.wait(<Future<void>>[
      preferences.setString(stringKey, testString, emptyOptions),
      preferences.setBool(boolKey, testBool, emptyOptions),
      preferences.setInt(intKey, testInt, emptyOptions),
      preferences.setDouble(doubleKey, testDouble, emptyOptions),
      preferences.setStringList(listKey, testList, emptyOptions)
    ]);

    final Set<String> keys = await preferences.getKeys(
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
    final SharedPreferencesAsyncAndroid preferences = getPreferences();
    await Future.wait(<Future<void>>[
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
    final SharedPreferencesAsyncAndroid preferences = getPreferences();
    await Future.wait(<Future<void>>[
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
}

class _FakeSharedPreferencesApi implements SharedPreferencesAsyncApi {
  final Map<String, Object> items = <String, Object>{};

  @override
  Future<bool> clear(
      List<String?>? allowList, SharedPreferencesPigeonOptions options) async {
    if (allowList != null) {
      items.removeWhere((String key, _) => allowList.contains(key));
    } else {
      items.clear();
    }

    return true;
  }

  @override
  Future<Map<String?, Object?>> getAll(
      List<String?>? allowList, SharedPreferencesPigeonOptions options) async {
    final Map<String, Object> filteredItems = <String, Object>{...items};
    if (allowList != null) {
      filteredItems.removeWhere((String key, _) => !allowList.contains(key));
    }
    return filteredItems;
  }

  @override
  Future<bool?> getBool(
      String key, SharedPreferencesPigeonOptions options) async {
    return items[key] as bool?;
  }

  @override
  Future<double?> getDouble(
      String key, SharedPreferencesPigeonOptions options) async {
    return items[key] as double?;
  }

  @override
  Future<int?> getInt(
      String key, SharedPreferencesPigeonOptions options) async {
    return items[key] as int?;
  }

  @override
  Future<List<String?>> getKeys(
      List<String?>? allowList, SharedPreferencesPigeonOptions options) async {
    final List<String> filteredItems = items.keys.toList();
    if (allowList != null) {
      filteredItems.removeWhere((String key) => !allowList.contains(key));
    }
    return filteredItems;
  }

  @override
  Future<String?> getString(
      String key, SharedPreferencesPigeonOptions options) async {
    return items[key] as String?;
  }

  @override
  Future<List<String?>?> getStringList(
      String key, SharedPreferencesPigeonOptions options) async {
    return items[key] as List<String>?;
  }

  @override
  Future<bool> setBool(
      String key, bool value, SharedPreferencesPigeonOptions options) async {
    items[key] = value;
    return true;
  }

  @override
  Future<bool> setDouble(
      String key, double value, SharedPreferencesPigeonOptions options) async {
    items[key] = value;
    return true;
  }

  @override
  Future<bool> setInt(
      String key, int value, SharedPreferencesPigeonOptions options) async {
    items[key] = value;
    return true;
  }

  @override
  Future<bool> setString(
      String key, String value, SharedPreferencesPigeonOptions options) async {
    items[key] = value;
    return true;
  }

  @override
  Future<bool> setStringList(String key, List<String?> value,
      SharedPreferencesPigeonOptions options) async {
    items[key] = value;
    return true;
  }
}
