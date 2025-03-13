// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_android/shared_preferences_android.dart';
import 'package:shared_preferences_android/src/messages.g.dart';
import 'package:shared_preferences_android/src/strings.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';
import 'package:shared_preferences_platform_interface/types.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late _FakeSharedPreferencesApi api;
  late SharedPreferencesAndroid plugin;

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

  final Map<String, Object> allTestValuesForComparison = <String, Object>{};

  allTestValuesForComparison.addAll(flutterTestValues);
  allTestValuesForComparison.addAll(prefixTestValues);
  allTestValuesForComparison.addAll(nonPrefixTestValues);

  final Map<String, Object> allTestValuesForAddingDirectlyToCache =
      <String, Object>{...allTestValuesForComparison};

  final String encodedListStringValue =
      '$jsonListPrefix${jsonEncode(<String>['foo', 'bar'])}';
  allTestValuesForAddingDirectlyToCache['flutter.StringList'] =
      encodedListStringValue;
  allTestValuesForAddingDirectlyToCache['prefix.StringList'] =
      encodedListStringValue;
  allTestValuesForAddingDirectlyToCache['StringList'] = encodedListStringValue;

  setUp(() {
    api = _FakeSharedPreferencesApi();
    plugin = SharedPreferencesAndroid(api: api);
  });

  test('registerWith', () async {
    SharedPreferencesAndroid.registerWith();
    expect(SharedPreferencesStorePlatform.instance,
        isA<SharedPreferencesAndroid>());
  });

  test('remove', () async {
    api.items['flutter.hi'] = 'world';
    expect(await plugin.remove('flutter.hi'), isTrue);
    expect(api.items.containsKey('flutter.hi'), isFalse);
  });

  test('clear', () async {
    api.items['flutter.hi'] = 'world';
    expect(await plugin.clear(), isTrue);
    expect(api.items.containsKey('flutter.hi'), isFalse);
  });

  test('clearWithPrefix', () async {
    for (final String key in allTestValuesForAddingDirectlyToCache.keys) {
      api.items[key] = allTestValuesForAddingDirectlyToCache[key]!;
    }

    Map<String?, Object?> all = await plugin.getAllWithPrefix('prefix.');
    expect(all.length, 5);
    await plugin.clearWithPrefix('prefix.');
    all = await plugin.getAll();
    expect(all.length, 5);
    all = await plugin.getAllWithPrefix('prefix.');
    expect(all.length, 0);
  });

  test('clearWithParameters', () async {
    for (final String key in allTestValuesForAddingDirectlyToCache.keys) {
      api.items[key] = allTestValuesForAddingDirectlyToCache[key]!;
    }

    Map<String?, Object?> all = await plugin.getAllWithParameters(
      GetAllParameters(
        filter: PreferencesFilter(prefix: 'prefix.'),
      ),
    );
    expect(all.length, 5);
    await plugin.clearWithParameters(
      ClearParameters(
        filter: PreferencesFilter(prefix: 'prefix.'),
      ),
    );
    all = await plugin.getAll();
    expect(all.length, 5);
    all = await plugin.getAllWithParameters(
      GetAllParameters(
        filter: PreferencesFilter(prefix: 'prefix.'),
      ),
    );
    expect(all.length, 0);
  });

  test('clearWithParameters with allow list', () async {
    for (final String key in allTestValuesForAddingDirectlyToCache.keys) {
      api.items[key] = allTestValuesForAddingDirectlyToCache[key]!;
    }

    Map<String?, Object?> all = await plugin.getAllWithParameters(
      GetAllParameters(
        filter: PreferencesFilter(prefix: 'prefix.'),
      ),
    );
    expect(all.length, 5);
    await plugin.clearWithParameters(
      ClearParameters(
        filter: PreferencesFilter(
          prefix: 'prefix.',
          allowList: <String>{'prefix.StringList'},
        ),
      ),
    );
    all = await plugin.getAll();
    expect(all.length, 5);
    all = await plugin.getAllWithParameters(
      GetAllParameters(
        filter: PreferencesFilter(prefix: 'prefix.'),
      ),
    );
    expect(all.length, 4);
  });

  test('getAll', () async {
    for (final String key in flutterTestValues.keys) {
      api.items[key] = flutterTestValues[key]!;
    }
    final Map<String?, Object?> all = await plugin.getAll();
    expect(all.length, 5);
    expect(all, flutterTestValues);
  });

  test('getAllWithNoPrefix', () async {
    for (final String key in allTestValuesForAddingDirectlyToCache.keys) {
      api.items[key] = allTestValuesForAddingDirectlyToCache[key]!;
    }
    final Map<String?, Object?> all = await plugin.getAllWithPrefix('');
    expect(all.length, 15);
    expect(all, allTestValuesForComparison);
  });

  test('clearWithNoPrefix', () async {
    for (final String key in allTestValuesForAddingDirectlyToCache.keys) {
      api.items[key] = allTestValuesForAddingDirectlyToCache[key]!;
    }

    Map<String?, Object?> all = await plugin.getAllWithPrefix('');
    expect(all.length, 15);
    await plugin.clearWithPrefix('');
    all = await plugin.getAllWithPrefix('');
    expect(all.length, 0);
  });

  test('getAllWithParameters', () async {
    for (final String key in allTestValuesForAddingDirectlyToCache.keys) {
      api.items[key] = allTestValuesForAddingDirectlyToCache[key]!;
    }
    final Map<String?, Object?> all = await plugin.getAllWithParameters(
      GetAllParameters(
        filter: PreferencesFilter(prefix: 'prefix.'),
      ),
    );
    expect(all.length, 5);
    expect(all, prefixTestValues);
  });

  test('getAllWithParameters with allow list', () async {
    for (final String key in allTestValuesForAddingDirectlyToCache.keys) {
      api.items[key] = allTestValuesForAddingDirectlyToCache[key]!;
    }
    final Map<String?, Object?> all = await plugin.getAllWithParameters(
      GetAllParameters(
        filter: PreferencesFilter(
          prefix: 'prefix.',
          allowList: <String>{'prefix.Bool'},
        ),
      ),
    );
    expect(all.length, 1);
    expect(all['prefix.Bool'], true);
  });

  test('setValue', () async {
    expect(await plugin.setValue('Bool', 'flutter.Bool', true), isTrue);
    expect(api.items['flutter.Bool'], true);
    expect(await plugin.setValue('Double', 'flutter.Double', 1.5), isTrue);
    expect(api.items['flutter.Double'], 1.5);
    expect(await plugin.setValue('Int', 'flutter.Int', 12), isTrue);
    expect(api.items['flutter.Int'], 12);
    expect(await plugin.setValue('String', 'flutter.String', 'hi'), isTrue);
    expect(api.items['flutter.String'], 'hi');
    expect(
        await plugin
            .setValue('StringList', 'flutter.StringList', <String>['hi']),
        isTrue);
    expect(api.items['flutter.StringList'],
        '$jsonListPrefix${jsonEncode(<String>['hi'])}');
  });

  test('setValue with unsupported type', () async {
    expect(() async {
      await plugin.setValue('Map', 'flutter.key', <String, String>{});
    }, throwsA(isA<PlatformException>()));
  });

  test('getAllWithNoPrefix', () async {
    for (final String key in allTestValuesForAddingDirectlyToCache.keys) {
      api.items[key] = allTestValuesForAddingDirectlyToCache[key]!;
    }
    final Map<String?, Object?> all = await plugin.getAllWithParameters(
      GetAllParameters(
        filter: PreferencesFilter(prefix: ''),
      ),
    );
    expect(all.length, 15);
    expect(all, allTestValuesForComparison);
  });

  test('clearWithNoPrefix', () async {
    for (final String key in allTestValuesForAddingDirectlyToCache.keys) {
      api.items[key] = allTestValuesForAddingDirectlyToCache[key]!;
    }

    Map<String?, Object?> all = await plugin.getAllWithParameters(
      GetAllParameters(
        filter: PreferencesFilter(prefix: ''),
      ),
    );
    expect(all.length, 15);
    await plugin.clearWithParameters(
      ClearParameters(
        filter: PreferencesFilter(prefix: ''),
      ),
    );
    all = await plugin.getAllWithParameters(
      GetAllParameters(
        filter: PreferencesFilter(prefix: ''),
      ),
    );
    expect(all.length, 0);
  });
}

class _FakeSharedPreferencesApi implements SharedPreferencesApi {
  final Map<String, Object> items = <String, Object>{};

  @override
  Future<Map<String, Object>> getAll(
    String prefix,
    List<String?>? allowList,
  ) async {
    Set<String?>? allowSet;
    if (allowList != null) {
      allowSet = Set<String>.from(allowList);
    }
    final Map<String, Object> filteredItems = <String, Object>{
      for (final String key in items.keys)
        if (key.startsWith(prefix) &&
            (allowSet == null || allowSet.contains(key)))
          key: items[key]!
    };
    filteredItems.forEach((String? key, Object? value) {
      if (value.runtimeType == String &&
          (value! as String).startsWith(jsonListPrefix)) {
        filteredItems[key!] =
            (jsonDecode((value as String).substring(jsonListPrefix.length))
                    as List<dynamic>)
                .cast<String>()
                .toList();
      }
    });
    return filteredItems;
  }

  @override
  Future<bool> remove(String key) async {
    items.remove(key);
    return true;
  }

  @override
  Future<bool> setBool(String key, bool value) async {
    items[key] = value;
    return true;
  }

  @override
  Future<bool> setDouble(String key, double value) async {
    items[key] = value;
    return true;
  }

  @override
  Future<bool> clear(String prefix, List<String?>? allowList) async {
    items.keys.toList().forEach((String key) {
      if (key.startsWith(prefix) &&
          (allowList == null || allowList.contains(key))) {
        items.remove(key);
      }
    });
    return true;
  }

  @override
  Future<bool> setInt(String key, Object value) async {
    items[key] = value;
    return true;
  }

  @override
  Future<bool> setString(String key, String value) async {
    items[key] = value;
    return true;
  }

  @override
  Future<bool> setEncodedStringList(String key, String value) async {
    items[key] = value;
    return true;
  }

  @override
  Future<bool> setDeprecatedStringList(String key, List<String> value) async {
    items[key] = value;
    return true;
  }

  @override
  // ignore: non_constant_identifier_names
  BinaryMessenger? get pigeonVar_binaryMessenger => throw UnimplementedError();

  @override
  // ignore: non_constant_identifier_names
  String get pigeonVar_messageChannelSuffix => throw UnimplementedError();
}
