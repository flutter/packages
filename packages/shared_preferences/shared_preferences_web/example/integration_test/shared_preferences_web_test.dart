// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences_platform_interface/method_channel_shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';
import 'package:shared_preferences_platform_interface/types.dart';
import 'package:shared_preferences_web/shared_preferences_web.dart';
import 'package:shared_preferences_web/src/keys_extension.dart';
import 'package:web/web.dart' as html;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    html.window.localStorage.clear();
  });
  group('shared_preferences_web', () {
    testWidgets('registers itself', (WidgetTester tester) async {
      SharedPreferencesStorePlatform.instance =
          MethodChannelSharedPreferencesStore();
      expect(SharedPreferencesStorePlatform.instance,
          isNot(isA<SharedPreferencesPlugin>()));
      SharedPreferencesPlugin.registerWith(null);
      expect(SharedPreferencesStorePlatform.instance,
          isA<SharedPreferencesPlugin>());
    });

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

    testWidgets('reading', (WidgetTester _) async {
      final Map<String, Object> values = await preferences.getAll();
      expect(values.length, 0);
    });

    Future<void> addData() async {
      await preferences.setValue('String', 'String', allTestValues['String']!);
      await preferences.setValue('Bool', 'Bool', allTestValues['Bool']!);
      await preferences.setValue('Int', 'Int', allTestValues['Int']!);
      await preferences.setValue('Double', 'Double', allTestValues['Double']!);
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

    testWidgets('keys', (WidgetTester _) async {
      await addData();
      final Iterable<String> keys = html.window.localStorage.keys;
      final Iterable<String> expectedKeys = allTestValues.keys;

      expect(keys, hasLength(expectedKeys.length));
      expect(keys, containsAll(expectedKeys));
    });

    testWidgets('clear', (WidgetTester _) async {
      await addData();
      await preferences.clear();
      final Map<String, Object> values = await preferences.getAll();
      expect(values['flutter.String'], null);
      expect(values['flutter.Bool'], null);
      expect(values['flutter.Int'], null);
      expect(values['flutter.Double'], null);
      expect(values['flutter.StringList'], null);
    });

    group('withPrefix', () {
      setUp(() async {
        await addData();
      });

      testWidgets('remove', (WidgetTester _) async {
        const String key = 'flutter.String';
        await preferences.remove(key);
        final Map<String, Object> values =
            // ignore: deprecated_member_use
            await preferences.getAllWithPrefix('');
        expect(values[key], isNull);
      });

      testWidgets('get all with prefix', (WidgetTester _) async {
        final Map<String, Object> values =
            // ignore: deprecated_member_use
            await preferences.getAllWithPrefix('prefix.');
        expect(values['prefix.String'], allTestValues['prefix.String']);
        expect(values['prefix.Bool'], allTestValues['prefix.Bool']);
        expect(values['prefix.Int'], allTestValues['prefix.Int']);
        expect(values['prefix.Double'], allTestValues['prefix.Double']);
        expect(values['prefix.StringList'], allTestValues['prefix.StringList']);
      });

      testWidgets('getAllWithNoPrefix', (WidgetTester _) async {
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

      testWidgets('clearWithPrefix', (WidgetTester _) async {
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

      testWidgets('clearWithNoPrefix', (WidgetTester _) async {
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
      setUp(() async {
        await addData();
      });

      testWidgets('remove', (WidgetTester _) async {
        const String key = 'flutter.String';
        await preferences.remove(key);
        final Map<String, Object> values =
            await preferences.getAllWithParameters(
          GetAllParameters(
            filter: PreferencesFilter(prefix: ''),
          ),
        );
        expect(values[key], isNull);
      });

      testWidgets('get all with prefix', (WidgetTester _) async {
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
    const SharedPreferencesWebOptions emptyOptions =
        SharedPreferencesWebOptions();

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

    testWidgets('getStringList returns mutable list', (WidgetTester _) async {
      final SharedPreferencesAsyncPlatform preferences = await getPreferences();

      await preferences.setStringList(listKey, testList, emptyOptions);
      final List<String>? list =
          await preferences.getStringList(listKey, emptyOptions);
      list?.add('value');
      expect(list?.length, testList.length + 1);
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
