// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';
import 'package:shared_preferences_platform_interface/types.dart';

import 'messages.g.dart';
import 'shared_preferences_async_android.dart';

const String _listPrefix = 'VGhpcyBpcyB0aGUgcHJlZml4IGZvciBhIGxpc3Qu';
const String _bigIntPrefix = 'VGhpcyBpcyB0aGUgcHJlZml4IGZvciBCaWdJbnRlZ2Vy';
const String _doublePrefix = 'VGhpcyBpcyB0aGUgcHJlZml4IGZvciBEb3VibGUu';
const String _jsonListPrefix = 'VGhpcyBpcyB0aGUgcHJlZml4IGZvciBhIGxpc3Qu!';

/// The Android implementation of [SharedPreferencesStorePlatform].
///
/// This class implements the `package:shared_preferences` functionality for Android.
class SharedPreferencesAndroid extends SharedPreferencesStorePlatform {
  /// Creates a new plugin implementation instance.
  SharedPreferencesAndroid({
    @visibleForTesting SharedPreferencesApi? api,
  }) : _api = api ?? SharedPreferencesApi();

  final SharedPreferencesApi _api;

  /// Registers this class as the default instance of [SharedPreferencesStorePlatform].
  static void registerWith() {
    SharedPreferencesStorePlatform.instance = SharedPreferencesAndroid();
    // A temporary work-around for having two plugins contained in a single package.
    SharedPreferencesAsyncAndroid.registerWith();
  }

  static const String _defaultPrefix = 'flutter.';

  @override
  Future<bool> remove(String key) async {
    return _api.remove(key);
  }

  @override
  Future<bool> setValue(String valueType, String key, Object value) async {
    switch (valueType) {
      case 'String':
        value as String;
        if (value.startsWith(_listPrefix) ||
            value.startsWith(_jsonListPrefix) ||
            value.startsWith(_bigIntPrefix) ||
            value.startsWith(_doublePrefix)) {
          throw ArgumentError(
              'The string $value cannot be stored as it clashes with special identifier prefixes');
        }
        return _api.setString(key, value);
      case 'Bool':
        return _api.setBool(key, value as bool);
      case 'Int':
        return _api.setInt(key, value as int);
      case 'Double':
        return _api.setDouble(key, value as double);
      case 'StringList':
        return _api.setString(key, '$_jsonListPrefix${jsonEncode(value)}');
      case 'LegacyStringListForTesting':
        return _api.setStringList(key, value as List<String>);
    }
    throw ArgumentError(
        'value: $value of type: $valueType" is not of a supported type.');
  }

  @override
  Future<bool> clear() async {
    return clearWithParameters(
      ClearParameters(
        filter: PreferencesFilter(prefix: _defaultPrefix),
      ),
    );
  }

  @override
  Future<bool> clearWithPrefix(String prefix) async {
    return clearWithParameters(
        ClearParameters(filter: PreferencesFilter(prefix: prefix)));
  }

  @override
  Future<bool> clearWithParameters(ClearParameters parameters) async {
    final PreferencesFilter filter = parameters.filter;
    return _api.clear(
      filter.prefix,
      filter.allowList?.toList(),
    );
  }

  @override
  Future<Map<String, Object>> getAll() async {
    return getAllWithParameters(
      GetAllParameters(
        filter: PreferencesFilter(prefix: _defaultPrefix),
      ),
    );
  }

  @override
  Future<Map<String, Object>> getAllWithPrefix(String prefix) async {
    return getAllWithParameters(
        GetAllParameters(filter: PreferencesFilter(prefix: prefix)));
  }

  @override
  Future<Map<String, Object>> getAllWithParameters(
      GetAllParameters parameters) async {
    final PreferencesFilter filter = parameters.filter;
    final Map<String?, Object?> data =
        await _api.getAll(filter.prefix, filter.allowList?.toList());
    data.forEach((String? key, Object? value) {
      if (value.runtimeType == String &&
          (value! as String).startsWith(_jsonListPrefix)) {
        data[key!] =
            (jsonDecode((value as String).substring(_jsonListPrefix.length))
                    as List<dynamic>)
                .cast<String>()
                .toList();
      }
    });
    return data.cast<String, Object>();
  }
}
