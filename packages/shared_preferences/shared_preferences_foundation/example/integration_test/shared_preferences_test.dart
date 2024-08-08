// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences_foundation/shared_preferences_foundation.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';
import 'package:shared_preferences_platform_interface/types.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('SharedPreferencesAsyncFoundation', () {
    const Map<String, Object> flutterTestValues = <String, Object>{
      'flutter.String': 'hello world',
      'flutter.Bool': true,
      'flutter.Int': 42,
      'flutter.Double': 3.14159,
      'flutter.StringList': <String>['foo', 'bar'],
    };

    const Map<String, Object> prefixTestValues = <String, Object>{
      'prefix.String': 'hello world',
      'prefix.Bool': true,
      'prefix.Int': 42,
      'prefix.Double': 3.14159,
      'prefix.StringList': <String>['foo', 'bar'],
    };

    const Map<String, Object> nonPrefixTestValues = <String, Object>{
      'String': 'hello world',
      'Bool': true,
      'Int': 42,
      'Double': 3.14159,
      'StringList': <String>['foo', 'bar'],
    };

    final Map<String, Object> allTestValues = <String, Object>{};

    allTestValues.addAll(flutterTestValues);
    allTestValues.addAll(prefixTestValues);
    allTestValues.addAll(nonPrefixTestValues);

    late SharedPreferencesStorePlatform preferences;

    setUp(() async {
      preferences = SharedPreferencesStorePlatform.instance;
    });

    tearDown(() async {
      await preferences.clearWithParameters(
        ClearParameters(
          filter: PreferencesFilter(prefix: ''),
        ),
      );
    });

    group('withPrefix', () {
      testWidgets('reading', (WidgetTester _) async {
        final Map<String, Object> values =
            // ignore: deprecated_member_use
            await preferences.getAllWithPrefix('');
        expect(values['String'], isNull);
        expect(values['Bool'], isNull);
        expect(values['Int'], isNull);
        expect(values['Double'], isNull);
        expect(values['StringList'], isNull);
      });

      testWidgets('getAllWithPrefix', (WidgetTester _) async {
        await Future.wait(<Future<bool>>[
          preferences.setValue(
              'String', 'prefix.String', allTestValues['prefix.String']!),
          preferences.setValue(
              'Bool', 'prefix.Bool', allTestValues['prefix.Bool']!),
          preferences.setValue(
              'Int', 'prefix.Int', allTestValues['prefix.Int']!),
          preferences.setValue(
              'Double', 'prefix.Double', allTestValues['prefix.Double']!),
          preferences.setValue('StringList', 'prefix.StringList',
              allTestValues['prefix.StringList']!),
          preferences.setValue(
              'String', 'flutter.String', allTestValues['flutter.String']!),
          preferences.setValue(
              'Bool', 'flutter.Bool', allTestValues['flutter.Bool']!),
          preferences.setValue(
              'Int', 'flutter.Int', allTestValues['flutter.Int']!),
          preferences.setValue(
              'Double', 'flutter.Double', allTestValues['flutter.Double']!),
          preferences.setValue('StringList', 'flutter.StringList',
              allTestValues['flutter.StringList']!)
        ]);
        final Map<String, Object> values =
            // ignore: deprecated_member_use
            await preferences.getAllWithPrefix('prefix.');
        expect(values['prefix.String'], allTestValues['prefix.String']);
        expect(values['prefix.Bool'], allTestValues['prefix.Bool']);
        expect(values['prefix.Int'], allTestValues['prefix.Int']);
        expect(values['prefix.Double'], allTestValues['prefix.Double']);
        expect(values['prefix.StringList'], allTestValues['prefix.StringList']);
      });

      testWidgets('clearWithPrefix', (WidgetTester _) async {
        await Future.wait(<Future<bool>>[
          preferences.setValue(
              'String', 'prefix.String', allTestValues['prefix.String']!),
          preferences.setValue(
              'Bool', 'prefix.Bool', allTestValues['prefix.Bool']!),
          preferences.setValue(
              'Int', 'prefix.Int', allTestValues['prefix.Int']!),
          preferences.setValue(
              'Double', 'prefix.Double', allTestValues['prefix.Double']!),
          preferences.setValue('StringList', 'prefix.StringList',
              allTestValues['prefix.StringList']!),
          preferences.setValue(
              'String', 'flutter.String', allTestValues['flutter.String']!),
          preferences.setValue(
              'Bool', 'flutter.Bool', allTestValues['flutter.Bool']!),
          preferences.setValue(
              'Int', 'flutter.Int', allTestValues['flutter.Int']!),
          preferences.setValue(
              'Double', 'flutter.Double', allTestValues['flutter.Double']!),
          preferences.setValue('StringList', 'flutter.StringList',
              allTestValues['flutter.StringList']!)
        ]);
        // ignore: deprecated_member_use
        await preferences.clearWithPrefix('prefix.');
        Map<String, Object> values =
            // ignore: deprecated_member_use
            await preferences.getAllWithPrefix('prefix.');
        expect(values['prefix.String'], null);
        expect(values['prefix.Bool'], null);
        expect(values['prefix.Int'], null);
        expect(values['prefix.Double'], null);
        expect(values['prefix.StringList'], null);
        // ignore: deprecated_member_use
        values = await preferences.getAllWithPrefix('flutter.');
        expect(values['flutter.String'], allTestValues['flutter.String']);
        expect(values['flutter.Bool'], allTestValues['flutter.Bool']);
        expect(values['flutter.Int'], allTestValues['flutter.Int']);
        expect(values['flutter.Double'], allTestValues['flutter.Double']);
        expect(
            values['flutter.StringList'], allTestValues['flutter.StringList']);
      });

      testWidgets('getAllWithNoPrefix', (WidgetTester _) async {
        await Future.wait(<Future<bool>>[
          preferences.setValue('String', 'String', allTestValues['String']!),
          preferences.setValue('Bool', 'Bool', allTestValues['Bool']!),
          preferences.setValue('Int', 'Int', allTestValues['Int']!),
          preferences.setValue('Double', 'Double', allTestValues['Double']!),
          preferences.setValue(
              'StringList', 'StringList', allTestValues['StringList']!),
          preferences.setValue(
              'String', 'flutter.String', allTestValues['flutter.String']!),
          preferences.setValue(
              'Bool', 'flutter.Bool', allTestValues['flutter.Bool']!),
          preferences.setValue(
              'Int', 'flutter.Int', allTestValues['flutter.Int']!),
          preferences.setValue(
              'Double', 'flutter.Double', allTestValues['flutter.Double']!),
          preferences.setValue('StringList', 'flutter.StringList',
              allTestValues['flutter.StringList']!)
        ]);
        final Map<String, Object> values =
            // ignore: deprecated_member_use
            await preferences.getAllWithPrefix('');
        expect(values['String'], allTestValues['String']);
        expect(values['Bool'], allTestValues['Bool']);
        expect(values['Int'], allTestValues['Int']);
        expect(values['Double'], allTestValues['Double']);
        expect(values['StringList'], allTestValues['StringList']);
        expect(values['flutter.String'], allTestValues['flutter.String']);
        expect(values['flutter.Bool'], allTestValues['flutter.Bool']);
        expect(values['flutter.Int'], allTestValues['flutter.Int']);
        expect(values['flutter.Double'], allTestValues['flutter.Double']);
        expect(
            values['flutter.StringList'], allTestValues['flutter.StringList']);
      });

      testWidgets('clearWithNoPrefix', (WidgetTester _) async {
        await Future.wait(<Future<bool>>[
          preferences.setValue('String', 'String', allTestValues['String']!),
          preferences.setValue('Bool', 'Bool', allTestValues['Bool']!),
          preferences.setValue('Int', 'Int', allTestValues['Int']!),
          preferences.setValue('Double', 'Double', allTestValues['Double']!),
          preferences.setValue(
              'StringList', 'StringList', allTestValues['StringList']!),
          preferences.setValue(
              'String', 'flutter.String', allTestValues['flutter.String']!),
          preferences.setValue(
              'Bool', 'flutter.Bool', allTestValues['flutter.Bool']!),
          preferences.setValue(
              'Int', 'flutter.Int', allTestValues['flutter.Int']!),
          preferences.setValue(
              'Double', 'flutter.Double', allTestValues['flutter.Double']!),
          preferences.setValue('StringList', 'flutter.StringList',
              allTestValues['flutter.StringList']!)
        ]);
        // ignore: deprecated_member_use
        await preferences.clearWithPrefix('');
        final Map<String, Object> values =
            // ignore: deprecated_member_use
            await preferences.getAllWithPrefix('');
        expect(values['String'], null);
        expect(values['Bool'], null);
        expect(values['Int'], null);
        expect(values['Double'], null);
        expect(values['StringList'], null);
        expect(values['flutter.String'], null);
        expect(values['flutter.Bool'], null);
        expect(values['flutter.Int'], null);
        expect(values['flutter.Double'], null);
        expect(values['flutter.StringList'], null);
      });
    });

    group('withParameters', () {
      testWidgets('reading', (WidgetTester _) async {
        final Map<String, Object> values =
            await preferences.getAllWithParameters(
          GetAllParameters(
            filter: PreferencesFilter(prefix: ''),
          ),
        );
        expect(values['String'], isNull);
        expect(values['Bool'], isNull);
        expect(values['Int'], isNull);
        expect(values['Double'], isNull);
        expect(values['StringList'], isNull);
      });

      Future<void> addData() async {
        await preferences.setValue(
            'String', 'String', allTestValues['String']!);
        await preferences.setValue('Bool', 'Bool', allTestValues['Bool']!);
        await preferences.setValue('Int', 'Int', allTestValues['Int']!);
        await preferences.setValue(
            'Double', 'Double', allTestValues['Double']!);
        await preferences.setValue(
            'StringList', 'StringList', allTestValues['StringList']!);
        await preferences.setValue(
            'String', 'prefix.String', allTestValues['prefix.String']!);
        await preferences.setValue(
            'Bool', 'prefix.Bool', allTestValues['prefix.Bool']!);
        await preferences.setValue(
            'Int', 'prefix.Int', allTestValues['prefix.Int']!);
        await preferences.setValue(
            'Double', 'prefix.Double', allTestValues['prefix.Double']!);
        await preferences.setValue('StringList', 'prefix.StringList',
            allTestValues['prefix.StringList']!);
        await preferences.setValue(
            'String', 'flutter.String', allTestValues['flutter.String']!);
        await preferences.setValue(
            'Bool', 'flutter.Bool', allTestValues['flutter.Bool']!);
        await preferences.setValue(
            'Int', 'flutter.Int', allTestValues['flutter.Int']!);
        await preferences.setValue(
            'Double', 'flutter.Double', allTestValues['flutter.Double']!);
        await preferences.setValue('StringList', 'flutter.StringList',
            allTestValues['flutter.StringList']!);
      }

      testWidgets('get all with prefix', (WidgetTester _) async {
        await addData();
        final Map<String, Object> values =
            await preferences.getAllWithParameters(
          GetAllParameters(
            filter: PreferencesFilter(prefix: 'prefix.'),
          ),
        );
        expect(values['prefix.String'], allTestValues['prefix.String']);
        expect(values['prefix.Bool'], allTestValues['prefix.Bool']);
        expect(values['prefix.Int'], allTestValues['prefix.Int']);
        expect(values['prefix.Double'], allTestValues['prefix.Double']);
        expect(values['prefix.StringList'], allTestValues['prefix.StringList']);
      });

      testWidgets('get all with allow list', (WidgetTester _) async {
        await addData();
        final Map<String, Object> values =
            await preferences.getAllWithParameters(
          GetAllParameters(
            filter: PreferencesFilter(
              prefix: 'prefix.',
              allowList: <String>{'prefix.String'},
            ),
          ),
        );
        expect(values['prefix.String'], allTestValues['prefix.String']);
        expect(values['prefix.Bool'], null);
        expect(values['prefix.Int'], null);
        expect(values['prefix.Double'], null);
        expect(values['prefix.StringList'], null);
      });

      testWidgets('getAllWithNoPrefix', (WidgetTester _) async {
        await addData();
        final Map<String, Object> values =
            await preferences.getAllWithParameters(
          GetAllParameters(
            filter: PreferencesFilter(prefix: ''),
          ),
        );
        expect(values['String'], allTestValues['String']);
        expect(values['Bool'], allTestValues['Bool']);
        expect(values['Int'], allTestValues['Int']);
        expect(values['Double'], allTestValues['Double']);
        expect(values['StringList'], allTestValues['StringList']);
        expect(values['flutter.String'], allTestValues['flutter.String']);
        expect(values['flutter.Bool'], allTestValues['flutter.Bool']);
        expect(values['flutter.Int'], allTestValues['flutter.Int']);
        expect(values['flutter.Double'], allTestValues['flutter.Double']);
        expect(
            values['flutter.StringList'], allTestValues['flutter.StringList']);
      });

      testWidgets('clearWithParameters', (WidgetTester _) async {
        await addData();
        await preferences.clearWithParameters(
          ClearParameters(
            filter: PreferencesFilter(prefix: 'prefix.'),
          ),
        );
        Map<String, Object> values = await preferences.getAllWithParameters(
          GetAllParameters(
            filter: PreferencesFilter(prefix: 'prefix.'),
          ),
        );
        expect(values['prefix.String'], null);
        expect(values['prefix.Bool'], null);
        expect(values['prefix.Int'], null);
        expect(values['prefix.Double'], null);
        expect(values['prefix.StringList'], null);
        values = await preferences.getAllWithParameters(
          GetAllParameters(
            filter: PreferencesFilter(prefix: 'flutter.'),
          ),
        );
        expect(values['flutter.String'], allTestValues['flutter.String']);
        expect(values['flutter.Bool'], allTestValues['flutter.Bool']);
        expect(values['flutter.Int'], allTestValues['flutter.Int']);
        expect(values['flutter.Double'], allTestValues['flutter.Double']);
        expect(
            values['flutter.StringList'], allTestValues['flutter.StringList']);
      });

      testWidgets('clearWithParameters with allow list',
          (WidgetTester _) async {
        await addData();
        await preferences.clearWithParameters(
          ClearParameters(
            filter: PreferencesFilter(
              prefix: 'prefix.',
              allowList: <String>{'prefix.StringList'},
            ),
          ),
        );
        Map<String, Object> values = await preferences.getAllWithParameters(
          GetAllParameters(
            filter: PreferencesFilter(prefix: 'prefix.'),
          ),
        );
        expect(values['prefix.String'], allTestValues['prefix.String']);
        expect(values['prefix.Bool'], allTestValues['prefix.Bool']);
        expect(values['prefix.Int'], allTestValues['prefix.Int']);
        expect(values['prefix.Double'], allTestValues['prefix.Double']);
        expect(values['prefix.StringList'], null);
        values = await preferences.getAllWithParameters(
          GetAllParameters(
            filter: PreferencesFilter(prefix: 'flutter.'),
          ),
        );
        expect(values['flutter.String'], allTestValues['flutter.String']);
        expect(values['flutter.Bool'], allTestValues['flutter.Bool']);
        expect(values['flutter.Int'], allTestValues['flutter.Int']);
        expect(values['flutter.Double'], allTestValues['flutter.Double']);
        expect(
            values['flutter.StringList'], allTestValues['flutter.StringList']);
      });

      testWidgets('clearWithNoPrefix', (WidgetTester _) async {
        await addData();
        await preferences.clearWithParameters(
          ClearParameters(
            filter: PreferencesFilter(prefix: ''),
          ),
        );
        final Map<String, Object> values =
            await preferences.getAllWithParameters(
          GetAllParameters(
            filter: PreferencesFilter(prefix: ''),
          ),
        );
        expect(values['String'], null);
        expect(values['Bool'], null);
        expect(values['Int'], null);
        expect(values['Double'], null);
        expect(values['StringList'], null);
        expect(values['flutter.String'], null);
        expect(values['flutter.Bool'], null);
        expect(values['flutter.Int'], null);
        expect(values['flutter.Double'], null);
        expect(values['flutter.StringList'], null);
      });
    });

    testWidgets('getAll', (WidgetTester _) async {
      await preferences.setValue(
          'String', 'flutter.String', allTestValues['flutter.String']!);
      await preferences.setValue(
          'Bool', 'flutter.Bool', allTestValues['flutter.Bool']!);
      await preferences.setValue(
          'Int', 'flutter.Int', allTestValues['flutter.Int']!);
      await preferences.setValue(
          'Double', 'flutter.Double', allTestValues['flutter.Double']!);
      await preferences.setValue('StringList', 'flutter.StringList',
          allTestValues['flutter.StringList']!);
      final Map<String, Object> values = await preferences.getAll();
      expect(values['flutter.String'], allTestValues['flutter.String']);
      expect(values['flutter.Bool'], allTestValues['flutter.Bool']);
      expect(values['flutter.Int'], allTestValues['flutter.Int']);
      expect(values['flutter.Double'], allTestValues['flutter.Double']);
      expect(values['flutter.StringList'], allTestValues['flutter.StringList']);
    });

    testWidgets('remove', (WidgetTester _) async {
      const String key = 'testKey';
      await preferences.setValue(
          'String', key, allTestValues['flutter.String']!);
      await preferences.setValue('Bool', key, allTestValues['flutter.Bool']!);
      await preferences.setValue('Int', key, allTestValues['flutter.Int']!);
      await preferences.setValue(
          'Double', key, allTestValues['flutter.Double']!);
      await preferences.setValue(
          'StringList', key, allTestValues['flutter.StringList']!);
      await preferences.remove(key);
      final Map<String, Object> values = await preferences.getAllWithParameters(
        GetAllParameters(
          filter: PreferencesFilter(prefix: ''),
        ),
      );
      expect(values[key], isNull);
    });

    testWidgets('clear', (WidgetTester _) async {
      await preferences.setValue(
          'String', 'flutter.String', allTestValues['flutter.String']!);
      await preferences.setValue(
          'Bool', 'flutter.Bool', allTestValues['flutter.Bool']!);
      await preferences.setValue(
          'Int', 'flutter.Int', allTestValues['flutter.Int']!);
      await preferences.setValue(
          'Double', 'flutter.Double', allTestValues['flutter.Double']!);
      await preferences.setValue('StringList', 'flutter.StringList',
          allTestValues['flutter.StringList']!);
      await preferences.clear();
      final Map<String, Object> values = await preferences.getAll();
      expect(values['flutter.String'], null);
      expect(values['flutter.Bool'], null);
      expect(values['flutter.Int'], null);
      expect(values['flutter.Double'], null);
      expect(values['flutter.StringList'], null);
    });

    testWidgets('simultaneous writes', (WidgetTester _) async {
      final List<Future<bool>> writes = <Future<bool>>[];
      const int writeCount = 100;
      for (int i = 1; i <= writeCount; i++) {
        writes.add(preferences.setValue('Int', 'Int', i));
      }
      final List<bool> result = await Future.wait(writes, eagerError: true);
      // All writes should succeed.
      expect(result.where((bool element) => !element), isEmpty);
      // The last write should win.
      final Map<String, Object> values = await preferences.getAllWithParameters(
        GetAllParameters(
          filter: PreferencesFilter(prefix: ''),
        ),
      );
      expect(values['Int'], writeCount);
    });
  });

  group('shared_preferences_async', () {
    final SharedPreferencesAsyncFoundationOptions emptyOptions =
        SharedPreferencesAsyncFoundationOptions();
    final SharedPreferencesAsyncFoundationOptions optionsWithSuiteName =
        SharedPreferencesAsyncFoundationOptions(
            suiteName: 'group.example.sharedPreferencesFoundation');

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

    Future<SharedPreferencesAsyncPlatform> getPreferences() async {
      final SharedPreferencesAsyncPlatform preferences =
          SharedPreferencesAsyncPlatform.instance!;
      await preferences.clear(
          const ClearPreferencesParameters(filter: PreferencesFilters()),
          emptyOptions);
      await preferences.clear(
          const ClearPreferencesParameters(filter: PreferencesFilters()),
          optionsWithSuiteName);
      return preferences;
    }

    testWidgets('set and get String', (WidgetTester _) async {
      final SharedPreferencesAsyncPlatform preferences = await getPreferences();

      await preferences.setString(stringKey, testString, emptyOptions);
      expect(await preferences.getString(stringKey, emptyOptions), testString);
    });

    testWidgets('set and get bool', (WidgetTester _) async {
      final SharedPreferencesAsyncPlatform preferences = await getPreferences();

      await preferences.setBool(boolKey, testBool, emptyOptions);
      expect(await preferences.getBool(boolKey, emptyOptions), testBool);
    });

    testWidgets('set and get int', (WidgetTester _) async {
      final SharedPreferencesAsyncPlatform preferences = await getPreferences();

      await preferences.setInt(intKey, testInt, emptyOptions);
      expect(await preferences.getInt(intKey, emptyOptions), testInt);
    });

    testWidgets('set and get double', (WidgetTester _) async {
      final SharedPreferencesAsyncPlatform preferences = await getPreferences();

      await preferences.setDouble(doubleKey, testDouble, emptyOptions);
      expect(await preferences.getDouble(doubleKey, emptyOptions), testDouble);
    });

    testWidgets('set and get StringList', (WidgetTester _) async {
      final SharedPreferencesAsyncPlatform preferences = await getPreferences();

      await preferences.setStringList(listKey, testList, emptyOptions);
      expect(await preferences.getStringList(listKey, emptyOptions), testList);
    });

    testWidgets('getPreferences', (WidgetTester _) async {
      final SharedPreferencesAsyncPlatform preferences = await getPreferences();
      await Future.wait(<Future<void>>[
        preferences.setString(stringKey, testString, emptyOptions),
        preferences.setBool(boolKey, testBool, emptyOptions),
        preferences.setInt(intKey, testInt, emptyOptions),
        preferences.setDouble(doubleKey, testDouble, emptyOptions),
        preferences.setStringList(listKey, testList, emptyOptions)
      ]);

      final Map<String, Object?> gotAll = await preferences.getPreferences(
        const GetPreferencesParameters(filter: PreferencesFilters()),
        emptyOptions,
      );

      expect(gotAll.length, 5);
      expect(gotAll[stringKey], testString);
      expect(gotAll[boolKey], testBool);
      expect(gotAll[intKey], testInt);
      expect(gotAll[doubleKey], testDouble);
      expect(gotAll[listKey], testList);
    });

    testWidgets('getPreferences with options', (WidgetTester _) async {
      final SharedPreferencesAsyncPlatform preferences = await getPreferences();
      await Future.wait(<Future<void>>[
        preferences.setString(stringKey, testString, optionsWithSuiteName),
        preferences.setBool(boolKey, testBool, emptyOptions),
        preferences.setInt(intKey, testInt, optionsWithSuiteName),
        preferences.setDouble(doubleKey, testDouble, emptyOptions),
        preferences.setStringList(listKey, testList, optionsWithSuiteName)
      ]);

      final Map<String, Object?> preferencesWithEmptyOptions =
          await preferences.getPreferences(
        const GetPreferencesParameters(filter: PreferencesFilters()),
        emptyOptions,
      );

      final Map<String, Object?> preferencesWithSuiteName =
          await preferences.getPreferences(
        const GetPreferencesParameters(filter: PreferencesFilters()),
        optionsWithSuiteName,
      );

      expect(preferencesWithEmptyOptions.length, 2);
      expect(preferencesWithSuiteName.length, 3);

      expect(preferencesWithEmptyOptions[boolKey], testBool);
      expect(preferencesWithEmptyOptions[doubleKey], testDouble);

      expect(preferencesWithSuiteName[stringKey], testString);
      expect(preferencesWithSuiteName[intKey], testInt);
      expect(preferencesWithSuiteName[listKey], testList);
    });

    testWidgets('getPreferences with filter', (WidgetTester _) async {
      final SharedPreferencesAsyncPlatform preferences = await getPreferences();
      await Future.wait(<Future<void>>[
        preferences.setString(stringKey, testString, emptyOptions),
        preferences.setBool(boolKey, testBool, emptyOptions),
        preferences.setInt(intKey, testInt, emptyOptions),
        preferences.setDouble(doubleKey, testDouble, emptyOptions),
        preferences.setStringList(listKey, testList, emptyOptions)
      ]);

      final Map<String, Object?> gotAll = await preferences.getPreferences(
        const GetPreferencesParameters(
          filter: PreferencesFilters(allowList: <String>{stringKey, boolKey}),
        ),
        emptyOptions,
      );

      expect(gotAll.length, 2);
      expect(gotAll[stringKey], testString);
      expect(gotAll[boolKey], testBool);
    });

    testWidgets('getKeys', (WidgetTester _) async {
      final SharedPreferencesAsyncPlatform preferences = await getPreferences();
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

    testWidgets('getKeys with options', (WidgetTester _) async {
      final SharedPreferencesAsyncPlatform preferences = await getPreferences();
      await Future.wait(<Future<void>>[
        preferences.setString(stringKey, testString, optionsWithSuiteName),
        preferences.setBool(boolKey, testBool, emptyOptions),
        preferences.setInt(intKey, testInt, optionsWithSuiteName),
        preferences.setDouble(doubleKey, testDouble, emptyOptions),
        preferences.setStringList(listKey, testList, optionsWithSuiteName)
      ]);

      final Set<String> keysWithEmptyOptions = await preferences.getKeys(
        const GetPreferencesParameters(filter: PreferencesFilters()),
        emptyOptions,
      );

      final Set<String> keysWithSuiteName = await preferences.getKeys(
        const GetPreferencesParameters(filter: PreferencesFilters()),
        optionsWithSuiteName,
      );

      expect(keysWithEmptyOptions.length, 2);
      expect(keysWithSuiteName.length, 3);

      expect(keysWithEmptyOptions, contains(boolKey));
      expect(keysWithEmptyOptions, contains(doubleKey));

      expect(keysWithSuiteName, contains(stringKey));
      expect(keysWithSuiteName, contains(intKey));
      expect(keysWithSuiteName, contains(listKey));
    });

    testWidgets('getKeys with filter', (WidgetTester _) async {
      final SharedPreferencesAsyncPlatform preferences = await getPreferences();
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

    testWidgets('clear', (WidgetTester _) async {
      final SharedPreferencesAsyncPlatform preferences = await getPreferences();
      await Future.wait(<Future<void>>[
        preferences.setString(stringKey, testString, emptyOptions),
        preferences.setBool(boolKey, testBool, emptyOptions),
        preferences.setInt(intKey, testInt, emptyOptions),
        preferences.setDouble(doubleKey, testDouble, emptyOptions),
        preferences.setStringList(listKey, testList, emptyOptions)
      ]);

      await preferences.clear(
        const ClearPreferencesParameters(filter: PreferencesFilters()),
        emptyOptions,
      );

      expect(await preferences.getString(stringKey, emptyOptions), null);
      expect(await preferences.getBool(boolKey, emptyOptions), null);
      expect(await preferences.getInt(intKey, emptyOptions), null);
      expect(await preferences.getDouble(doubleKey, emptyOptions), null);
      expect(await preferences.getStringList(listKey, emptyOptions), null);
    });

    testWidgets('clear with filter', (WidgetTester _) async {
      final SharedPreferencesAsyncPlatform preferences = await getPreferences();
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
  });
}
