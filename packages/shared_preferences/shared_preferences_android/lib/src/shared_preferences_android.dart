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
import 'strings.dart';

/// The Android implementation of [SharedPreferencesStorePlatform].
///
/// This class implements the `package:shared_preferences` functionality for Android.
class SharedPreferencesAndroid extends SharedPreferencesStorePlatform {
  /// Creates a new plugin implementation instance.
  SharedPreferencesAndroid({
    @visibleForTesting SharedPreferencesApi? api,
  }) : api = api ?? SharedPreferencesApi();

  /// The pigeon API used to send messages to the platform.
  @visibleForTesting
  final SharedPreferencesApi api;

  /// Registers this class as the default instance of [SharedPreferencesStorePlatform].
  static void registerWith() {
    SharedPreferencesStorePlatform.instance = SharedPreferencesAndroid();
    // A temporary work-around for having two plugins contained in a single package.
    SharedPreferencesAsyncAndroid.registerWith();
  }

  static const String _defaultPrefix = 'flutter.';

  @override
  Future<bool> remove(String key) async {
    return api.remove(key);
  }

  @override
  Future<bool> setValue(String valueType, String key, Object value) async {
    switch (valueType) {
      case 'String':
        return api.setString(key, value as String);
      case 'Bool':
        return api.setBool(key, value as bool);
      case 'Int':
        return api.setInt(key, value as int);
      case 'Double':
        return api.setDouble(key, value as double);
      case 'StringList':
        return api.setEncodedStringList(
            key, '$jsonListPrefix${jsonEncode(value)}');
    }
    // TODO(tarrinneal): change to ArgumentError across all platforms.
    throw PlatformException(
        code: 'InvalidOperation',
        message: '"$valueType" is not a supported type.');
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
    return api.clear(
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
        await api.getAll(filter.prefix, filter.allowList?.toList());
    data.forEach((String? key, Object? value) {
      if (value.runtimeType == String &&
          (value! as String).startsWith(jsonListPrefix)) {
        data[key!] =
            (jsonDecode((value as String).substring(jsonListPrefix.length))
                    as List<dynamic>)
                .cast<String>()
                .toList();
      }
    });
    return data.cast<String, Object>();
  }
}
