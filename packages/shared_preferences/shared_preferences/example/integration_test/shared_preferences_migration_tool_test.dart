// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences/tools/legacy_to_async_migration_tool.dart';
import 'package:shared_preferences_android/shared_preferences_android.dart';
import 'package:shared_preferences_foundation/shared_preferences_foundation.dart';
import 'package:shared_preferences_linux/shared_preferences_linux.dart';
import 'package:shared_preferences_platform_interface/types.dart';
import 'package:shared_preferences_windows/shared_preferences_windows.dart';

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

  group('shared_preferences', () {
    late SharedPreferences preferences;
    late SharedPreferencesOptions sharedPreferencesAsyncOptions;
    const String migrationCompletedKey = 'migrationCompleted';

    void runTests(
        {String? stringValue = testString, bool keysAndNamesCollide = false}) {
      testWidgets('data is successfully transferred to new system', (_) async {
        final SharedPreferencesAsync asyncPreferences =
            SharedPreferencesAsync(options: sharedPreferencesAsyncOptions);

        expect(await asyncPreferences.getBool(boolKey), testBool);
        expect(await asyncPreferences.getInt(intKey), testInt);
        expect(await asyncPreferences.getDouble(doubleKey), testDouble);
        expect(await asyncPreferences.getString(stringKey), stringValue);
        expect(await asyncPreferences.getStringList(listKey), testList);
      });

      testWidgets('migrationCompleted key is set', (_) async {
        final SharedPreferencesAsync asyncPreferences =
            SharedPreferencesAsync(options: sharedPreferencesAsyncOptions);

        expect(await asyncPreferences.getBool(migrationCompletedKey), true);
      });

      testWidgets(
        're-running migration tool does not overwrite data',
        (_) async {
          final SharedPreferencesAsync asyncPreferences =
              SharedPreferencesAsync(options: sharedPreferencesAsyncOptions);
          await preferences.setInt(intKey, -0);
          await migrateLegacySharedPreferencesToSharedPreferencesAsync(
            preferences,
            sharedPreferencesAsyncOptions,
            migrationCompletedKey,
          );
          expect(await asyncPreferences.getInt(intKey), testInt);
        },
        // Since the desktop versions would be moving to the same file, this test will always fail.
        // They are the same files with the same keys.
        skip: keysAndNamesCollide &&
            (Platform.isWindows ||
                Platform.isLinux ||
                Platform.isMacOS ||
                Platform.isIOS),
      );
    }

    void runAllGroups(
        {String? stringValue = testString, bool keysCollide = false}) {
      setUp(() async {
        await preferences.setBool(boolKey, testBool);
        await preferences.setInt(intKey, testInt);
        await preferences.setDouble(doubleKey, testDouble);
        await preferences.setString(stringKey, testString);
        await preferences.setStringList(listKey, testList);
      });
      group('default sharedPreferencesAsyncOptions', () {
        setUp(() async {
          sharedPreferencesAsyncOptions = const SharedPreferencesOptions();

          await migrateLegacySharedPreferencesToSharedPreferencesAsync(
            preferences,
            sharedPreferencesAsyncOptions,
            migrationCompletedKey,
          );
        });

        tearDown(() async {
          await SharedPreferencesAsync(options: sharedPreferencesAsyncOptions)
              .clear();
        });
        group('', () {
          runTests(stringValue: stringValue, keysAndNamesCollide: keysCollide);
        });
      });

      group('file name (or equivalent) sharedPreferencesAsyncOptions', () {
        setUp(() async {
          if (Platform.isAndroid) {
            sharedPreferencesAsyncOptions =
                const SharedPreferencesAsyncAndroidOptions(
              backend: SharedPreferencesAndroidBackendLibrary.SharedPreferences,
              originalSharedPreferencesOptions:
                  AndroidSharedPreferencesStoreOptions(
                fileName: 'fileName',
              ),
            );
          } else if (Platform.isIOS || Platform.isMacOS) {
            sharedPreferencesAsyncOptions =
                SharedPreferencesAsyncFoundationOptions(
                    suiteName: 'group.fileName');
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

          await migrateLegacySharedPreferencesToSharedPreferencesAsync(
            preferences,
            sharedPreferencesAsyncOptions,
            migrationCompletedKey,
          );
        });

        tearDown(() async {
          await SharedPreferencesAsync(options: sharedPreferencesAsyncOptions)
              .clear();
        });
        group('', () {
          runTests(stringValue: stringValue);
        });
      });

      if (Platform.isAndroid) {
        group('Android default sharedPreferences', () {
          setUp(() async {
            sharedPreferencesAsyncOptions =
                const SharedPreferencesAsyncAndroidOptions(
              backend: SharedPreferencesAndroidBackendLibrary.SharedPreferences,
              originalSharedPreferencesOptions:
                  AndroidSharedPreferencesStoreOptions(),
            );

            await migrateLegacySharedPreferencesToSharedPreferencesAsync(
              preferences,
              sharedPreferencesAsyncOptions,
              migrationCompletedKey,
            );
          });

          tearDown(() async {
            await SharedPreferencesAsync(options: sharedPreferencesAsyncOptions)
                .clear();
          });
          group('', () {
            runTests(stringValue: stringValue);
          });
        });
      }
    }

    group('SharedPreferences without setting prefix', () {
      setUp(() async {
        SharedPreferences.resetStatic();
        preferences = await SharedPreferences.getInstance();
        await preferences.clear();
        group('', () {
          runAllGroups();
        });
      });
    });

    group('SharedPreferences with setPrefix', () {
      setUp(() async {
        SharedPreferences.resetStatic();
        SharedPreferences.setPrefix('prefix.');
        preferences = await SharedPreferences.getInstance();
        await preferences.clear();
      });
      group('', () {
        runAllGroups();
      });
    });

    group('SharedPreferences with setPrefix and allowList', () {
      setUp(() async {
        SharedPreferences.resetStatic();
        final Set<String> allowList = <String>{
          'prefix.$boolKey',
          'prefix.$intKey',
          'prefix.$doubleKey',
          'prefix.$listKey'
        };
        SharedPreferences.setPrefix('prefix.', allowList: allowList);
        preferences = await SharedPreferences.getInstance();
        await preferences.clear();
      });
      group('', () {
        runAllGroups(stringValue: null);
      });
    });

    group('SharedPreferences with prefix set to empty string', () {
      setUp(() async {
        SharedPreferences.resetStatic();
        SharedPreferences.setPrefix('');
        preferences = await SharedPreferences.getInstance();
        await preferences.clear();
      });
      group('', () {
        runAllGroups(keysCollide: true);
      });
    });
  });
}
