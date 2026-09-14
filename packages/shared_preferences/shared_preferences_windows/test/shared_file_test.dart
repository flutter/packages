// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';

import 'package:file/memory.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider_windows/path_provider_windows.dart';
import 'package:shared_preferences_platform_interface/types.dart';
import 'package:shared_preferences_windows/shared_preferences_windows.dart';

import 'fake_path_provider_windows.dart';

/// [SharedPreferencesWindows] and [SharedPreferencesAsyncWindows] store their
/// data in the same `shared_preferences.json`, and each write replaces the
/// whole file with that store's map. Neither may write a map it read before
/// the other store's writes, or those keys are silently lost.
void main() {
  late MemoryFileSystem fs;
  late PathProviderWindows pathProvider;

  const legacyKey = 'flutter.legacyString';
  const asyncKey = 'asyncString';
  const options = SharedPreferencesWindowsOptions();

  setUp(() {
    fs = MemoryFileSystem.test();
    pathProvider = FakePathProviderWindows();
  });

  SharedPreferencesWindows getLegacyPreferences() {
    final preferences = SharedPreferencesWindows();
    preferences.fs = fs;
    preferences.pathProvider = pathProvider;
    return preferences;
  }

  SharedPreferencesAsyncWindows getAsyncPreferences() {
    final preferences = SharedPreferencesAsyncWindows();
    preferences.fs = fs;
    preferences.pathProvider = pathProvider;
    return preferences;
  }

  Future<Map<String, Object?>> readFile() async {
    final String? directory = await pathProvider.getApplicationSupportPath();
    final String contents = fs
        .file(path.join(directory!, 'shared_preferences.json'))
        .readAsStringSync();
    return json.decode(contents) as Map<String, Object?>;
  }

  test('a legacy write keeps keys the async store wrote after it loaded', () async {
    final SharedPreferencesWindows legacy = getLegacyPreferences();
    final SharedPreferencesAsyncWindows async = getAsyncPreferences();

    // Both stores load while the file is empty, as they do at app startup.
    await legacy.getAllWithParameters(
      GetAllParameters(filter: PreferencesFilter(prefix: 'flutter.')),
    );
    await async.getString(asyncKey, options);

    await async.setString(asyncKey, 'async value', options);
    await legacy.setValue('String', legacyKey, 'legacy value');

    expect(await readFile(), <String, Object?>{asyncKey: 'async value', legacyKey: 'legacy value'});
  });

  test('an async write keeps keys the legacy store wrote after it loaded', () async {
    final SharedPreferencesWindows legacy = getLegacyPreferences();
    final SharedPreferencesAsyncWindows async = getAsyncPreferences();

    await legacy.getAllWithParameters(
      GetAllParameters(filter: PreferencesFilter(prefix: 'flutter.')),
    );
    await async.getString(asyncKey, options);

    await legacy.setValue('String', legacyKey, 'legacy value');
    await async.setString(asyncKey, 'async value', options);

    expect(await readFile(), <String, Object?>{legacyKey: 'legacy value', asyncKey: 'async value'});
  });

  test('repeated interleaved writes keep both stores intact', () async {
    final SharedPreferencesWindows legacy = getLegacyPreferences();
    final SharedPreferencesAsyncWindows async = getAsyncPreferences();

    for (var i = 0; i < 5; i++) {
      await async.setInt('$asyncKey$i', i, options);
      await legacy.setValue('int', '$legacyKey$i', i);
    }

    final Map<String, Object?> file = await readFile();
    for (var i = 0; i < 5; i++) {
      expect(file['$asyncKey$i'], i);
      expect(file['$legacyKey$i'], i);
    }
  });

  test('a legacy remove leaves the async store alone', () async {
    final SharedPreferencesWindows legacy = getLegacyPreferences();
    final SharedPreferencesAsyncWindows async = getAsyncPreferences();

    await legacy.setValue('String', legacyKey, 'legacy value');
    await async.setString(asyncKey, 'async value', options);
    await legacy.remove(legacyKey);

    expect(await readFile(), <String, Object?>{asyncKey: 'async value'});
  });

  test('a legacy clear leaves the async store alone', () async {
    final SharedPreferencesWindows legacy = getLegacyPreferences();
    final SharedPreferencesAsyncWindows async = getAsyncPreferences();

    await legacy.setValue('String', legacyKey, 'legacy value');
    await async.setString(asyncKey, 'async value', options);
    await legacy.clear();

    expect(await readFile(), <String, Object?>{asyncKey: 'async value'});
  });

  test('an async clear leaves the legacy store alone', () async {
    final SharedPreferencesWindows legacy = getLegacyPreferences();
    final SharedPreferencesAsyncWindows async = getAsyncPreferences();

    await legacy.setValue('String', legacyKey, 'legacy value');
    await async.setString(asyncKey, 'async value', options);
    await async.clear(
      const ClearPreferencesParameters(filter: PreferencesFilters(allowList: <String>{asyncKey})),
      options,
    );

    expect(await readFile(), <String, Object?>{legacyKey: 'legacy value'});
  });
}
