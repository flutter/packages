// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:shared_preferences_platform_interface/types.dart';

import 'deprecated_shared_preferences_android.dart';
import 'src/messages_async.g.dart';

const String _listPrefix = 'VGhpcyBpcyB0aGUgcHJlZml4IGZvciBhIGxpc3Qu';
const String _doublePrefix = 'VGhpcyBpcyB0aGUgcHJlZml4IGZvciBEb3VibGUu';

/// The Android implementation of [SharedPreferencesAsyncPlatform].
///
/// This class implements the `package:shared_preferences` functionality for Android.
base class SharedPreferencesAndroid extends SharedPreferencesAsyncPlatform {
  /// Creates a new plugin implementation instance.
  SharedPreferencesAndroid({
    @visibleForTesting SharedPreferencesAsyncApi? api,
  }) : _api = api ?? SharedPreferencesAsyncApi();

  final SharedPreferencesAsyncApi _api;

  /// Registers this class as the default instance of [SharedPreferencesAsyncPlatform].
  static void registerWith() {
    SharedPreferencesAsyncPlatform.instance = SharedPreferencesAndroid();
    DeprecatedSharedPreferencesAndroid.registerWith();
  }

  /// Returns a SharedPreferencesPigeonOptions for sending to platform.
  SharedPreferencesPigeonOptions _convertOptionsToPigeonOptions(
      SharedPreferencesOptions options) {
    return SharedPreferencesPigeonOptions();
  }

  @override
  Future<Set<String?>> getKeys(
    GetPreferencesParameters parameters,
    SharedPreferencesOptions options,
  ) async {
    final PreferencesFilters filter = parameters.filter;

    return (await _api.getKeys(
      filter.allowList?.toList(),
      _convertOptionsToPigeonOptions(options),
    ))
        .toSet();
  }

  @override
  Future<bool> setString(
    String key,
    String value,
    SharedPreferencesOptions options,
  ) async {
    final SharedPreferencesPigeonOptions pigeonOptions =
        _convertOptionsToPigeonOptions(options);

    if (value.startsWith(_listPrefix) || value.startsWith(_doublePrefix)) {
      throw ArgumentError(
          'StorageError: This string cannot be stored as it clashes with special identifier prefixes');
    }
    return _api.setString(key, value, pigeonOptions);
  }

  @override
  Future<bool> setInt(
    String key,
    int value,
    SharedPreferencesOptions options,
  ) async {
    final SharedPreferencesPigeonOptions pigeonOptions =
        _convertOptionsToPigeonOptions(options);

    return _api.setInt(key, value, pigeonOptions);
  }

  @override
  Future<bool> setDouble(
    String key,
    double value,
    SharedPreferencesOptions options,
  ) async {
    final SharedPreferencesPigeonOptions pigeonOptions =
        _convertOptionsToPigeonOptions(options);

    return _api.setDouble(key, value, pigeonOptions);
  }

  @override
  Future<bool> setBool(
    String key,
    bool value,
    SharedPreferencesOptions options,
  ) async {
    final SharedPreferencesPigeonOptions pigeonOptions =
        _convertOptionsToPigeonOptions(options);

    return _api.setBool(key, value, pigeonOptions);
  }

  @override
  Future<bool> setStringList(
    String key,
    List<String> value,
    SharedPreferencesOptions options,
  ) async {
    final SharedPreferencesPigeonOptions pigeonOptions =
        _convertOptionsToPigeonOptions(options);

    return _api.setStringList(key, value, pigeonOptions);
  }

  @override
  Future<String?> getString(
    String key,
    SharedPreferencesOptions options,
  ) async {
    final SharedPreferencesPigeonOptions pigeonOptions =
        _convertOptionsToPigeonOptions(options);

    return _api.getString(key, pigeonOptions);
  }

  @override
  Future<bool?> getBool(
    String key,
    SharedPreferencesOptions options,
  ) async {
    final SharedPreferencesPigeonOptions pigeonOptions =
        _convertOptionsToPigeonOptions(options);

    return _api.getBool(key, pigeonOptions);
  }

  @override
  Future<double?> getDouble(
    String key,
    SharedPreferencesOptions options,
  ) async {
    final SharedPreferencesPigeonOptions pigeonOptions =
        _convertOptionsToPigeonOptions(options);

    return _api.getDouble(key, pigeonOptions);
  }

  @override
  Future<int?> getInt(
    String key,
    SharedPreferencesOptions options,
  ) async {
    final SharedPreferencesPigeonOptions pigeonOptions =
        _convertOptionsToPigeonOptions(options);

    return _api.getInt(key, pigeonOptions);
  }

  @override
  Future<List<String?>?> getStringList(
    String key,
    SharedPreferencesOptions options,
  ) async {
    final SharedPreferencesPigeonOptions pigeonOptions =
        _convertOptionsToPigeonOptions(options);

    return _api.getStringList(key, pigeonOptions);
  }

  @override
  Future<bool> clear(
    ClearPreferencesParameters parameters,
    SharedPreferencesOptions options,
  ) async {
    final PreferencesFilters filter = parameters.filter;
    return _api.clear(
      filter.allowList?.toList(),
      _convertOptionsToPigeonOptions(options),
    );
  }

  @override
  Future<Map<String, Object>> getPreferences(
    GetPreferencesParameters parameters,
    SharedPreferencesOptions options,
  ) async {
    final PreferencesFilters filter = parameters.filter;
    final Map<String?, Object?> data = await _api.getAll(
      filter.allowList?.toList(),
      _convertOptionsToPigeonOptions(options),
    );
    return data.cast<String, Object>();
  }
}

/// Options for the Android specific SharedPreferences plugin.
class SharedPreferencesAndroidOptions extends SharedPreferencesOptions {}
