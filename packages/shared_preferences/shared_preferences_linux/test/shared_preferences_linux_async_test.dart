// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file/memory.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_linux/path_provider_linux.dart';
import 'package:shared_preferences_linux/shared_preferences_linux.dart';
import 'package:shared_preferences_platform_interface/types.dart';

import 'fake_path_provider_linux.dart';

void main() {
  late MemoryFileSystem fs;
  late PathProviderLinux pathProvider;

  SharedPreferencesAsyncLinux.registerWith();

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

  const SharedPreferencesLinuxOptions emptyOptions =
      SharedPreferencesLinuxOptions();

  setUp(() {
    fs = MemoryFileSystem.test();
    pathProvider = FakePathProviderLinux();
  });

  SharedPreferencesAsyncLinux getPreferences() {
    final SharedPreferencesAsyncLinux prefs = SharedPreferencesAsyncLinux();
    prefs.fs = fs;
    prefs.pathProvider = pathProvider;
    return prefs;
  }

  test('set and get String', () async {
    final SharedPreferencesAsyncLinux preferences = getPreferences();

    await preferences.setString(stringKey, testString, emptyOptions);
    expect(await preferences.getString(stringKey, emptyOptions), testString);
  });

  test('set and get bool', () async {
    final SharedPreferencesAsyncLinux preferences = getPreferences();

    await preferences.setBool(boolKey, testBool, emptyOptions);
    expect(await preferences.getBool(boolKey, emptyOptions), testBool);
  });

  test('set and get int', () async {
    final SharedPreferencesAsyncLinux preferences = getPreferences();

    await preferences.setInt(intKey, testInt, emptyOptions);
    expect(await preferences.getInt(intKey, emptyOptions), testInt);
  });

  test('set and get double', () async {
    final SharedPreferencesAsyncLinux preferences = getPreferences();

    await preferences.setDouble(doubleKey, testDouble, emptyOptions);
    expect(await preferences.getDouble(doubleKey, emptyOptions), testDouble);
  });

  test('set and get StringList', () async {
    final SharedPreferencesAsyncLinux preferences = getPreferences();

    await preferences.setStringList(listKey, testList, emptyOptions);
    expect(await preferences.getStringList(listKey, emptyOptions), testList);
  });

  test('getPreferences', () async {
    final SharedPreferencesAsyncLinux preferences = getPreferences();

    await preferences.setString(stringKey, testString, emptyOptions);
    await preferences.setBool(boolKey, testBool, emptyOptions);
    await preferences.setInt(intKey, testInt, emptyOptions);
    await preferences.setDouble(doubleKey, testDouble, emptyOptions);
    await preferences.setStringList(listKey, testList, emptyOptions);

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
    final SharedPreferencesAsyncLinux preferences = getPreferences();

    await preferences.setString(stringKey, testString, emptyOptions);
    await preferences.setBool(boolKey, testBool, emptyOptions);
    await preferences.setInt(intKey, testInt, emptyOptions);
    await preferences.setDouble(doubleKey, testDouble, emptyOptions);
    await preferences.setStringList(listKey, testList, emptyOptions);

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
    final SharedPreferencesAsyncLinux preferences = getPreferences();

    await preferences.setString(stringKey, testString, emptyOptions);
    await preferences.setBool(boolKey, testBool, emptyOptions);
    await preferences.setInt(intKey, testInt, emptyOptions);
    await preferences.setDouble(doubleKey, testDouble, emptyOptions);
    await preferences.setStringList(listKey, testList, emptyOptions);

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
    final SharedPreferencesAsyncLinux preferences = getPreferences();

    await preferences.setString(stringKey, testString, emptyOptions);
    await preferences.setBool(boolKey, testBool, emptyOptions);
    await preferences.setInt(intKey, testInt, emptyOptions);
    await preferences.setDouble(doubleKey, testDouble, emptyOptions);
    await preferences.setStringList(listKey, testList, emptyOptions);

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
    final SharedPreferencesAsyncLinux preferences = getPreferences();

    await preferences.setString(stringKey, testString, emptyOptions);
    await preferences.setBool(boolKey, testBool, emptyOptions);
    await preferences.setInt(intKey, testInt, emptyOptions);
    await preferences.setDouble(doubleKey, testDouble, emptyOptions);
    await preferences.setStringList(listKey, testList, emptyOptions);
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
    final SharedPreferencesAsyncLinux preferences = getPreferences();

    await preferences.setString(stringKey, testString, emptyOptions);
    await preferences.setBool(boolKey, testBool, emptyOptions);
    await preferences.setInt(intKey, testInt, emptyOptions);
    await preferences.setDouble(doubleKey, testDouble, emptyOptions);
    await preferences.setStringList(listKey, testList, emptyOptions);
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
