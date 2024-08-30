// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:shared_preferences_platform_interface/types.dart';

import 'messages_async.g.dart';

const String _listPrefix = 'VGhpcyBpcyB0aGUgcHJlZml4IGZvciBhIGxpc3Qu';

/// The Android implementation of [SharedPreferencesAsyncPlatform].
///
/// This class implements the `package:shared_preferences` functionality for Android.
base class SharedPreferencesAsyncAndroid
    extends SharedPreferencesAsyncPlatform {
  /// Creates a new plugin implementation instance.
  SharedPreferencesAsyncAndroid({
    @visibleForTesting SharedPreferencesAsyncApi? api,
  }) : _api = api ?? SharedPreferencesAsyncApi();

  final SharedPreferencesAsyncApi _api;

  /// Registers this class as the default instance of [SharedPreferencesAsyncPlatform].
  static void registerWith() {
    SharedPreferencesAsyncPlatform.instance = SharedPreferencesAsyncAndroid();
  }

  /// Returns a SharedPreferencesPigeonOptions for sending to platform.
  SharedPreferencesPigeonOptions _convertOptionsToPigeonOptions(
      SharedPreferencesOptions options) {
    return SharedPreferencesPigeonOptions();
  }

  @override
  Future<Set<String>> getKeys(
    GetPreferencesParameters parameters,
    SharedPreferencesOptions options,
  ) async {
    final PreferencesFilters filter = parameters.filter;
    // TODO(tarrinneal): Remove cast once https://github.com/flutter/flutter/issues/97848
    // is fixed. In practice, the values will never be null, and the native implementation assumes that.
    return (await _api.getKeys(
      filter.allowList?.toList(),
      _convertOptionsToPigeonOptions(options),
    ))
        .cast<String>()
        .toSet();
  }

  @override
  Future<void> setString(
    String key,
    String value,
    SharedPreferencesOptions options,
  ) async {
    if (value.startsWith(_listPrefix)) {
      throw ArgumentError(
          'StorageError: This string cannot be stored as it clashes with special identifier prefixes');
    }

    return _api.setString(key, value, _convertOptionsToPigeonOptions(options));
  }

  @override
  Future<void> setInt(
    String key,
    int value,
    SharedPreferencesOptions options,
  ) async {
    return _api.setInt(key, value, _convertOptionsToPigeonOptions(options));
  }

  @override
  Future<void> setDouble(
    String key,
    double value,
    SharedPreferencesOptions options,
  ) async {
    return _api.setDouble(key, value, _convertOptionsToPigeonOptions(options));
  }

  @override
  Future<void> setBool(
    String key,
    bool value,
    SharedPreferencesOptions options,
  ) async {
    return _api.setBool(key, value, _convertOptionsToPigeonOptions(options));
  }

  @override
  Future<void> setStringList(
    String key,
    List<String> value,
    SharedPreferencesOptions options,
  ) async {
    return _api.setStringList(
        key, value, _convertOptionsToPigeonOptions(options));
  }

  @override
  Future<String?> getString(
    String key,
    SharedPreferencesOptions options,
  ) async {
    return _convertKnownExceptions<String>(() async =>
        _api.getString(key, _convertOptionsToPigeonOptions(options)));
  }

  @override
  Future<bool?> getBool(
    String key,
    SharedPreferencesOptions options,
  ) async {
    return _convertKnownExceptions<bool>(
        () async => _api.getBool(key, _convertOptionsToPigeonOptions(options)));
  }

  @override
  Future<double?> getDouble(
    String key,
    SharedPreferencesOptions options,
  ) async {
    return _convertKnownExceptions<double>(() async =>
        _api.getDouble(key, _convertOptionsToPigeonOptions(options)));
  }

  @override
  Future<int?> getInt(
    String key,
    SharedPreferencesOptions options,
  ) async {
    return _convertKnownExceptions<int>(
        () async => _api.getInt(key, _convertOptionsToPigeonOptions(options)));
  }

  @override
  Future<List<String>?> getStringList(
    String key,
    SharedPreferencesOptions options,
  ) async {
    // TODO(tarrinneal): Remove cast once https://github.com/flutter/flutter/issues/97848
    // is fixed. In practice, the values will never be null, and the native implementation assumes that.
    return _convertKnownExceptions<List<String>>(() async =>
        (await _api.getStringList(key, _convertOptionsToPigeonOptions(options)))
            ?.cast<String>()
            .toList());
  }

  Future<T?> _convertKnownExceptions<T>(Future<T?> Function() method) async {
    try {
      final T? value = await method();
      return value;
    } on PlatformException catch (e) {
      if (e.code == 'ClassCastException') {
        throw TypeError();
      } else {
        rethrow;
      }
    }
  }

  @override
  Future<void> clear(
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
class SharedPreferencesAsyncAndroidOptions extends SharedPreferencesOptions {
  /// Constructor for SharedPreferencesAsyncAndroidOptions.
  const SharedPreferencesAsyncAndroidOptions();
}
