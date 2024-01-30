// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/method_channel_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:shared_preferences_platform_interface/types.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel channel = MethodChannel(
    'plugins.flutter.io/shared_preferences',
  );

  late InMemorySharedPreferencesAsync testData;

  final List<MethodCall> log = <MethodCall>[];
  final MethodChannelSharedPreferencesAsync preferences =
      MethodChannelSharedPreferencesAsync();

  const SharedPreferencesOptions emptyOptions = SharedPreferencesOptions();

  setUp(() async {
    testData = InMemorySharedPreferencesAsync.empty();

    Map<String, Object?> getArgumentDictionary(MethodCall call) {
      return (call.arguments as Map<Object?, Object?>).cast<String, Object?>();
    }

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      final Map<String, Object?> arguments = getArgumentDictionary(methodCall);
      log.add(methodCall);
      if (methodCall.method == 'getPreferences') {
        Set<String>? allowSet;
        final List<dynamic>? allowList =
            arguments['allowList'] as List<dynamic>?;
        if (allowList != null) {
          allowSet = <String>{};
          for (final dynamic key in allowList) {
            allowSet.add(key as String);
          }
        }
        return testData.getPreferences(
          GetPreferencesParameters(
            filter: PreferencesFilters(
              allowList: allowSet,
            ),
          ),
          emptyOptions,
        );
      }

      if (methodCall.method == 'clear') {
        Set<String>? allowSet;
        final List<dynamic>? allowList =
            arguments['allowList'] as List<dynamic>?;
        if (allowList != null) {
          allowSet = <String>{};
          for (final dynamic key in allowList) {
            allowSet.add(key as String);
          }
        }
        return testData.clear(
          ClearPreferencesParameters(
            filter: PreferencesFilters(allowList: allowSet),
          ),
          emptyOptions,
        );
      }
      if (methodCall.method == 'setString') {
        return testData.setString(
          arguments['key']! as String,
          arguments['value']! as String,
          arguments['options'] as SharedPreferencesOptions? ?? emptyOptions,
        );
      }
      if (methodCall.method == 'setBool') {
        return testData.setBool(
          arguments['key']! as String,
          arguments['value']! as bool,
          arguments['options'] as SharedPreferencesOptions? ?? emptyOptions,
        );
      }
      if (methodCall.method == 'setInt') {
        return testData.setInt(
          arguments['key']! as String,
          arguments['value']! as int,
          arguments['options'] as SharedPreferencesOptions? ?? emptyOptions,
        );
      }
      if (methodCall.method == 'setDouble') {
        return testData.setDouble(
          arguments['key']! as String,
          arguments['value']! as double,
          arguments['options'] as SharedPreferencesOptions? ?? emptyOptions,
        );
      }
      if (methodCall.method == 'setStringList') {
        return testData.setStringList(
          arguments['key']! as String,
          arguments['value']! as List<String>,
          arguments['options'] as SharedPreferencesOptions? ?? emptyOptions,
        );
      }
      if (methodCall.method == 'getString') {
        return testData.getString(
          arguments['key']! as String,
          arguments['options'] as SharedPreferencesOptions? ?? emptyOptions,
        );
      }
      if (methodCall.method == 'getBool') {
        return testData.getBool(
          arguments['key']! as String,
          arguments['options'] as SharedPreferencesOptions? ?? emptyOptions,
        );
      }
      if (methodCall.method == 'getInt') {
        return testData.getInt(
          arguments['key']! as String,
          arguments['options'] as SharedPreferencesOptions? ?? emptyOptions,
        );
      }
      if (methodCall.method == 'getDouble') {
        return testData.getDouble(
          arguments['key']! as String,
          arguments['options'] as SharedPreferencesOptions? ?? emptyOptions,
        );
      }
      if (methodCall.method == 'getStringList') {
        return testData.getStringList(
          arguments['key']! as String,
          arguments['options'] as SharedPreferencesOptions? ?? emptyOptions,
        );
      }

      fail('Unexpected method call: ${methodCall.method}');
    });
    log.clear();
  });

  tearDown(() async {
    await preferences.clear(
      const ClearPreferencesParameters(filter: PreferencesFilters()),
      emptyOptions,
    );
  });

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

  testWidgets('set and get', (WidgetTester _) async {
    await Future.wait(<Future<bool>>[
      preferences.setString(stringKey, testString, emptyOptions),
      preferences.setBool(boolKey, testBool, emptyOptions),
      preferences.setInt(intKey, testInt, emptyOptions),
      preferences.setDouble(doubleKey, testDouble, emptyOptions),
      preferences.setStringList(listKey, testList, emptyOptions)
    ]);

    expect(await preferences.getString(stringKey, emptyOptions), testString);
    expect(await preferences.getBool(boolKey, emptyOptions), testBool);
    expect(await preferences.getInt(intKey, emptyOptions), testInt);
    expect(await preferences.getDouble(doubleKey, emptyOptions), testDouble);
    expect(await preferences.getStringList(listKey, emptyOptions), testList);
  });

  testWidgets('getPreferences', (WidgetTester _) async {
    await Future.wait(<Future<bool>>[
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
    await Future.wait(<Future<bool>>[
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
    await Future.wait(<Future<bool>>[
      preferences.setString(stringKey, testString, emptyOptions),
      preferences.setBool(boolKey, testBool, emptyOptions),
      preferences.setInt(intKey, testInt, emptyOptions),
      preferences.setDouble(doubleKey, testDouble, emptyOptions),
      preferences.setStringList(listKey, testList, emptyOptions)
    ]);

    final Set<String?> keys = await preferences.getKeys(
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
    await Future.wait(<Future<bool>>[
      preferences.setString(stringKey, testString, emptyOptions),
      preferences.setBool(boolKey, testBool, emptyOptions),
      preferences.setInt(intKey, testInt, emptyOptions),
      preferences.setDouble(doubleKey, testDouble, emptyOptions),
      preferences.setStringList(listKey, testList, emptyOptions)
    ]);

    final Set<String?> keys = await preferences.getKeys(
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
    await Future.wait(<Future<bool>>[
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
    await Future.wait(<Future<bool>>[
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
