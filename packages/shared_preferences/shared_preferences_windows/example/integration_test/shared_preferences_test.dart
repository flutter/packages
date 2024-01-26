// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences_platform_interface/types.dart';
import 'package:shared_preferences_windows/shared_preferences_windows.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('SharedPreferencesWindows', () {
    late SharedPreferencesWindows preferences;

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

    setUp(() async {
      preferences = SharedPreferencesWindows();
      await addData();
    });

    tearDown(() async {
      await preferences.clearWithParameters(
        ClearParameters(
          filter: PreferencesFilter(prefix: ''),
        ),
      );
    });

    testWidgets('getAll', (WidgetTester _) async {
      final Map<String, Object> values = await preferences.getAll();
      expect(values['flutter.String'], allTestValues['flutter.String']);
      expect(values['flutter.Bool'], allTestValues['flutter.Bool']);
      expect(values['flutter.Int'], allTestValues['flutter.Int']);
      expect(values['flutter.Double'], allTestValues['flutter.Double']);
      expect(values['flutter.StringList'], allTestValues['flutter.StringList']);
    });

    group('withPrefix', () {
      testWidgets('remove', (WidgetTester _) async {
        const String key = 'flutter.String';
        await preferences.remove(key);
        final Map<String, Object> values =
            await preferences.getAllWithPrefix('');
        expect(values[key], isNull);
      });

      testWidgets('clear', (WidgetTester _) async {
        await preferences.clear();
        final Map<String, Object> values = await preferences.getAll();
        expect(values['flutter.String'], null);
        expect(values['flutter.Bool'], null);
        expect(values['flutter.Int'], null);
        expect(values['flutter.Double'], null);
        expect(values['flutter.StringList'], null);
      });

      testWidgets('get all with prefix', (WidgetTester _) async {
        final Map<String, Object> values =
            await preferences.getAllWithPrefix('prefix.');
        expect(values['prefix.String'], allTestValues['prefix.String']);
        expect(values['prefix.Bool'], allTestValues['prefix.Bool']);
        expect(values['prefix.Int'], allTestValues['prefix.Int']);
        expect(values['prefix.Double'], allTestValues['prefix.Double']);
        expect(values['prefix.StringList'], allTestValues['prefix.StringList']);
      });

      testWidgets('getAllWithNoPrefix', (WidgetTester _) async {
        final Map<String, Object> values =
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
        await preferences.clearWithPrefix('prefix.');
        Map<String, Object> values =
            await preferences.getAllWithPrefix('prefix.');
        expect(values['prefix.String'], null);
        expect(values['prefix.Bool'], null);
        expect(values['prefix.Int'], null);
        expect(values['prefix.Double'], null);
        expect(values['prefix.StringList'], null);
        values = await preferences.getAllWithPrefix('flutter.');
        expect(values['flutter.String'], allTestValues['flutter.String']);
        expect(values['flutter.Bool'], allTestValues['flutter.Bool']);
        expect(values['flutter.Int'], allTestValues['flutter.Int']);
        expect(values['flutter.Double'], allTestValues['flutter.Double']);
        expect(
            values['flutter.StringList'], allTestValues['flutter.StringList']);
      });

      testWidgets('clearWithNoPrefix', (WidgetTester _) async {
        await preferences.clearWithPrefix('');
        final Map<String, Object> values =
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

      testWidgets('clear', (WidgetTester _) async {
        await preferences.clear();
        final Map<String, Object> values = await preferences.getAll();
        expect(values['flutter.String'], null);
        expect(values['flutter.Bool'], null);
        expect(values['flutter.Int'], null);
        expect(values['flutter.Double'], null);
        expect(values['flutter.StringList'], null);
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
  });
}
