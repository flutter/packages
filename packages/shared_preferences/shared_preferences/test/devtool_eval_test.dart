import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import 'shared_preferences_async_test.dart';

// The tests present in this file are meant to preserve the contract
// between shared_preferences_tool and shared_preferences. Real integration
// tests will be implemented when the test tooling gets extracted from devtools
// https://github.com/flutter/devtools/issues/8210
void main() {
  group('async', () {
    SharedPreferencesAsync getPreferences() {
      final FakeSharedPreferencesAsync store = FakeSharedPreferencesAsync();
      SharedPreferencesAsyncPlatform.instance = store;
      final SharedPreferencesAsync preferences = SharedPreferencesAsync();
      return preferences;
    }

    // This test is meant to validate the eval performed by
    // SharedPreferencesToolEval.fetchAllKeys
    test('should fetch keys', () async {
      final SharedPreferencesAsync prefs = getPreferences();
      await prefs.setBool('test1', true);
      await prefs.setBool('test2', true);
      await prefs.setBool('test3', true);

      // This is the actual eval, it should match the eval performed by SharedPreferencesToolEval
      // do not edit this line unless you change the eval.
      final Set<String> keys = await prefs.getKeys();

      expect(keys, equals(<String>{'test1', 'test2', 'test3'}));
    });

    // This test is meant to validate the eval performed by
    // SharedPreferencesToolEval.fetchValue
    test('should fetch value', () async {
      final SharedPreferencesAsync prefs = getPreferences();
      await prefs.setInt('test1', 1);

      // This is the actual eval, it should match the eval performed by SharedPreferencesToolEval
      // do not edit this line unless you change the eval.
      final Object? value = await prefs.getAll(allowList: <String>{
        'test1'
      }).then((Map<String, Object?> map) => map.values.firstOrNull);

      expect(value, equals(1));
    });

    // This test is meant to validate the eval performed by
    // SharedPreferencesToolEval.changeValue
    test('should change value', () async {
      final SharedPreferencesAsync prefs = getPreferences();
      await prefs.setInt('test1', 1);
      await prefs.setBool('test2', false);
      await prefs.setDouble('test3', 1.1);
      await prefs.setString('test4', 'some string');
      await prefs.setStringList('test5', <String>['some', 'string']);

      // This is the actual eval, it should match the eval performed by SharedPreferencesToolEval
      // do not edit this line unless you change the eval.
      await prefs.setInt('test1', 2);
      // This is the actual eval, it should match the eval performed by SharedPreferencesToolEval
      // do not edit this line unless you change the eval.
      await prefs.setBool('test2', true);
      // This is the actual eval, it should match the eval performed by SharedPreferencesToolEval
      // do not edit this line unless you change the eval.
      await prefs.setDouble('test3', 2.2);
      // This is the actual eval, it should match the eval performed by SharedPreferencesToolEval
      // do not edit this line unless you change the eval.
      await prefs.setString('test4', 'some other string');
      // This is the actual eval, it should match the eval performed by SharedPreferencesToolEval
      // do not edit this line unless you change the eval.
      await prefs.setStringList('test5', <String>['some other', 'string']);

      expect(await prefs.getInt('test1'), equals(2));
      expect(await prefs.getBool('test2'), equals(true));
      expect(await prefs.getDouble('test3'), equals(2.2));
      expect(await prefs.getString('test4'), equals('some other string'));
      expect(
        await prefs.getStringList('test5'),
        equals(<String>['some other', 'string']),
      );
    });

    // This test is meant to validate the eval performed by
    // SharedPreferencesToolEval.deleteKey
    test('should delete key', () async {
      final SharedPreferencesAsync prefs = getPreferences();
      await prefs.setInt('test1', 1);

      // This is the actual eval, it should match the eval performed by SharedPreferencesToolEval
      // do not edit this line unless you change the eval.
      await prefs.remove('test1');

      expect(await prefs.getKeys(), isEmpty);
    });
  });

  group('legacy', () {
    // This test is meant to validate the eval performed by
    // SharedPreferencesToolEval.fetchAllKeys()
    test('should fetch keys', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'test1': true,
        'test2': true,
        'test3': true,
      });
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      // This is the actual eval, it should match the eval performed by SharedPreferencesToolEval
      // do not edit this line unless you change the eval.
      final Set<String> keys = prefs.getKeys();

      expect(keys, equals(<String>{'test1', 'test2', 'test3'}));
    });

    // This test is meant to validate the eval performed by
    // SharedPreferencesToolEval.fetchValue
    test('should fetch value', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'test1': 1,
      });
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      // This is the actual eval, it should match the eval performed by SharedPreferencesToolEval
      // do not edit this line unless you change the eval.
      final Object? value = prefs.get('test1');

      expect(value, equals(1));
    });

    // This test is meant to validate the eval performed by
    // SharedPreferencesToolEval.changeValue
    test('should change value', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'test1': 1,
        'test2': false,
        'test3': 1.1,
        'test4': 'some string',
        'test5': <String>['some', 'string'],
      });

      final SharedPreferences prefs = await SharedPreferences.getInstance();

      // This is the actual eval, it should match the eval performed by SharedPreferencesToolEval
      // do not edit this line unless you change the eval.
      await prefs.setInt('test1', 2);
      // This is the actual eval, it should match the eval performed by SharedPreferencesToolEval
      // do not edit this line unless you change the eval.
      await prefs.setBool('test2', true);
      // This is the actual eval, it should match the eval performed by SharedPreferencesToolEval
      // do not edit this line unless you change the eval.
      await prefs.setDouble('test3', 2.2);
      // This is the actual eval, it should match the eval performed by SharedPreferencesToolEval
      // do not edit this line unless you change the eval.
      await prefs.setString('test4', 'some other string');
      // This is the actual eval, it should match the eval performed by SharedPreferencesToolEval
      // do not edit this line unless you change the eval.
      await prefs.setStringList('test5', <String>['some other', 'string']);

      expect(prefs.getInt('test1'), equals(2));
      expect(prefs.getBool('test2'), equals(true));
      expect(prefs.getDouble('test3'), equals(2.2));
      expect(prefs.getString('test4'), equals('some other string'));
      expect(
        prefs.getStringList('test5'),
        equals(<String>['some other', 'string']),
      );
    });

    // This test is meant to validate the eval performed by
    // SharedPreferencesToolEval.deleteKey
    test('should delete key', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'test1': 1,
      });
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      // This is the actual eval, it should match the eval performed by SharedPreferencesToolEval
      // do not edit this line unless you change the eval.
      await prefs.remove('test1');

      expect(prefs.getKeys(), isEmpty);
    });
  });
}
