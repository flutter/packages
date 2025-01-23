// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences/util/legacy_to_async_migration_util.dart';
import 'package:shared_preferences_android/shared_preferences_android.dart';
import 'package:shared_preferences_foundation/shared_preferences_foundation.dart';
import 'package:shared_preferences_linux/shared_preferences_linux.dart';
import 'package:shared_preferences_platform_interface/types.dart';
import 'package:shared_preferences_windows/shared_preferences_windows.dart';

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

const String migrationCompletedKey = 'migrationCompleted';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('SharedPreferences without setting prefix', () {
    runAllGroups(() {});
  });

  group('SharedPreferences with setPrefix', () {
    runAllGroups(() {
      SharedPreferences.setPrefix('prefix.');
    });
  });

  group('SharedPreferences with setPrefix and allowList', () {
    runAllGroups(
      () {
        final Set<String> allowList = <String>{
          'prefix.$boolKey',
          'prefix.$intKey',
          'prefix.$doubleKey',
          'prefix.$listKey'
        };
        SharedPreferences.setPrefix('prefix.', allowList: allowList);
      },
      stringValue: null,
    );
  });

  group('SharedPreferences with prefix set to empty string', () {
    runAllGroups(
      () {
        SharedPreferences.setPrefix('');
      },
      keysCollide: true,
    );
  });
}

void runAllGroups(void Function() legacySharedPrefsConfig,
    {String? stringValue = testString, bool keysCollide = false}) {
  group('default sharedPreferencesAsyncOptions', () {
    const SharedPreferencesOptions sharedPreferencesAsyncOptions =
        SharedPreferencesOptions();

    runTests(
      sharedPreferencesAsyncOptions,
      legacySharedPrefsConfig,
      stringValue: stringValue,
      keysAndNamesCollide: keysCollide,
    );
  });

  group('file name (or equivalent) sharedPreferencesAsyncOptions', () {
    final SharedPreferencesOptions sharedPreferencesAsyncOptions;
    if (Platform.isAndroid) {
      sharedPreferencesAsyncOptions =
          const SharedPreferencesAsyncAndroidOptions(
        backend: SharedPreferencesAndroidBackendLibrary.SharedPreferences,
        originalSharedPreferencesOptions: AndroidSharedPreferencesStoreOptions(
          fileName: 'fileName',
        ),
      );
    } else if (Platform.isIOS || Platform.isMacOS) {
      sharedPreferencesAsyncOptions =
          SharedPreferencesAsyncFoundationOptions(suiteName: 'group.fileName');
    } else if (Platform.isLinux) {
      sharedPreferencesAsyncOptions = const SharedPreferencesLinuxOptions(
        fileName: 'fileName',
      );
    } else if (Platform.isWindows) {
      sharedPreferencesAsyncOptions =
          const SharedPreferencesWindowsOptions(fileName: 'fileName');
    } else {
      sharedPreferencesAsyncOptions = const SharedPreferencesOptions();
    }

    runTests(
      sharedPreferencesAsyncOptions,
      legacySharedPrefsConfig,
      stringValue: stringValue,
    );
  });

  if (Platform.isAndroid) {
    group('Android default sharedPreferences', () {
      const SharedPreferencesOptions sharedPreferencesAsyncOptions =
          SharedPreferencesAsyncAndroidOptions(
        backend: SharedPreferencesAndroidBackendLibrary.SharedPreferences,
        originalSharedPreferencesOptions:
            AndroidSharedPreferencesStoreOptions(),
      );

      runTests(
        sharedPreferencesAsyncOptions,
        legacySharedPrefsConfig,
        stringValue: stringValue,
      );
    });
  }
}

void runTests(SharedPreferencesOptions sharedPreferencesAsyncOptions,
    void Function() legacySharedPrefsConfig,
    {String? stringValue = testString, bool keysAndNamesCollide = false}) {
  setUp(() async {
    // Configure and populate the source legacy shared preferences.
    SharedPreferences.resetStatic();
    legacySharedPrefsConfig();

    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.clear();
    await preferences.setBool(boolKey, testBool);
    await preferences.setInt(intKey, testInt);
    await preferences.setDouble(doubleKey, testDouble);
    await preferences.setString(stringKey, testString);
    await preferences.setStringList(listKey, testList);
  });

  tearDown(() async {
    await SharedPreferencesAsync(options: sharedPreferencesAsyncOptions)
        .clear();
  });

  testWidgets('data is successfully transferred to new system', (_) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await migrateLegacySharedPreferencesToSharedPreferencesAsyncIfNecessary(
      legacySharedPreferencesInstance: preferences,
      sharedPreferencesAsyncOptions: sharedPreferencesAsyncOptions,
      migrationCompletedKey: migrationCompletedKey,
    );

    final SharedPreferencesAsync asyncPreferences =
        SharedPreferencesAsync(options: sharedPreferencesAsyncOptions);

    expect(await asyncPreferences.getBool(boolKey), testBool);
    expect(await asyncPreferences.getInt(intKey), testInt);
    expect(await asyncPreferences.getDouble(doubleKey), testDouble);
    expect(await asyncPreferences.getString(stringKey), stringValue);
    expect(await asyncPreferences.getStringList(listKey), testList);
  });

  testWidgets('migrationCompleted key is set', (_) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await migrateLegacySharedPreferencesToSharedPreferencesAsyncIfNecessary(
      legacySharedPreferencesInstance: preferences,
      sharedPreferencesAsyncOptions: sharedPreferencesAsyncOptions,
      migrationCompletedKey: migrationCompletedKey,
    );

    final SharedPreferencesAsync asyncPreferences =
        SharedPreferencesAsync(options: sharedPreferencesAsyncOptions);

    expect(await asyncPreferences.getBool(migrationCompletedKey), true);
  });

  testWidgets(
    're-running migration tool does not overwrite data',
    (_) async {
      final SharedPreferences preferences =
          await SharedPreferences.getInstance();
      await migrateLegacySharedPreferencesToSharedPreferencesAsyncIfNecessary(
        legacySharedPreferencesInstance: preferences,
        sharedPreferencesAsyncOptions: sharedPreferencesAsyncOptions,
        migrationCompletedKey: migrationCompletedKey,
      );

      final SharedPreferencesAsync asyncPreferences =
          SharedPreferencesAsync(options: sharedPreferencesAsyncOptions);
      await preferences.setInt(intKey, -0);
      await migrateLegacySharedPreferencesToSharedPreferencesAsyncIfNecessary(
        legacySharedPreferencesInstance: preferences,
        sharedPreferencesAsyncOptions: sharedPreferencesAsyncOptions,
        migrationCompletedKey: migrationCompletedKey,
      );
      expect(await asyncPreferences.getInt(intKey), testInt);
    },
    // Skips platforms that would be adding the preferences to the same file.
    skip: keysAndNamesCollide &&
        (Platform.isWindows ||
            Platform.isLinux ||
            Platform.isMacOS ||
            Platform.isIOS),
  );
}
