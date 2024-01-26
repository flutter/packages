// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:shared_preferences_platform_interface/types.dart';

import './messages.g.dart';

/// iOS and macOS implementation of shared_preferences.
base class SharedPreferencesAsyncFoundation
    extends SharedPreferencesAsyncPlatform {
  /// Creates a new plugin implementation instance.
  SharedPreferencesAsyncFoundation({
    @visibleForTesting UserDefaultsApi? api,
  }) : _api = api ?? UserDefaultsApi();

  final UserDefaultsApi _api;

  /// Registers this class as the default instance of [SharedPreferencesAsyncPlatform].
  static void registerWith() {
    SharedPreferencesAsyncPlatform.instance =
        SharedPreferencesAsyncFoundation();
  }

  /// Returns a SharedPreferencesPigeonOptions for sending to platform.
  SharedPreferencesPigeonOptions _convertOptionsToPigeonOptions(
      SharedPreferencesOptions options) {
    String? suiteName;

    if (options is SharedPreferencesFoundationOptions) {
      suiteName = options.suiteName;
    }

    return SharedPreferencesPigeonOptions(
      suiteName: suiteName,
    );
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

  Future<void> _setValue(
    String key,
    Object value,
    SharedPreferencesOptions options,
  ) async {
    final SharedPreferencesPigeonOptions pigeonOptions =
        _convertOptionsToPigeonOptions(options);

    await _api.setValue(key, value, pigeonOptions);
  }

  @override
  Future<bool> setString(
    String key,
    String value,
    SharedPreferencesOptions options,
  ) async {
    await _setValue(key, value, options);
    return true;
  }

  @override
  Future<bool> setInt(
    String key,
    int value,
    SharedPreferencesOptions options,
  ) async {
    await _setValue(key, value, options);
    return true;
  }

  @override
  Future<bool> setStringList(
    String key,
    List<String> value,
    SharedPreferencesOptions options,
  ) async {
    await _setValue(key, value, options);
    return true;
  }

  @override
  Future<bool> setBool(
    String key,
    Object value,
    SharedPreferencesOptions options,
  ) async {
    final SharedPreferencesPigeonOptions pigeonOptions =
        _convertOptionsToPigeonOptions(options);

    await _api.setBool(key, value as bool, pigeonOptions);
    return true;
  }

  @override
  Future<bool> setDouble(
    String key,
    Object value,
    SharedPreferencesOptions options,
  ) async {
    final SharedPreferencesPigeonOptions pigeonOptions =
        _convertOptionsToPigeonOptions(options);

    await _api.setDouble(key, value as double, pigeonOptions);
    return true;
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
    await _api.clear(
      filter.allowList?.toList(),
      _convertOptionsToPigeonOptions(options),
    );
    return true;
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

/// Options for the Foundation specific SharedPreferences plugin.
class SharedPreferencesFoundationOptions extends SharedPreferencesOptions {
  /// Creates a new instance with the given options.
  SharedPreferencesFoundationOptions({
    this.suiteName,
  });

  /// Name of Foundation SharedPreferences instance to get/set to.
  ///
  /// If this option is not set, Foundations default SharedPreferences will be used.
  final String? suiteName;
}
