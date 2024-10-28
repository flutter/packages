// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'shared_preferences_async_platform_interface.dart';
import 'types.dart';

/// Stores data in memory.
///
/// Data does not persist across application restarts. This is useful in unit tests.
base class InMemorySharedPreferencesAsync
    extends SharedPreferencesAsyncPlatform {
  /// Instantiates an empty in-memory preferences store.
  InMemorySharedPreferencesAsync.empty() : _data = <String, Object>{};

  /// Instantiates an in-memory preferences store containing a copy of [data].
  InMemorySharedPreferencesAsync.withData(Map<String, Object> data)
      : _data = Map<String, Object>.from(data);

  final Map<String, Object> _data;

  @override
  Future<bool> clear(
    ClearPreferencesParameters parameters,
    SharedPreferencesOptions options,
  ) async {
    final PreferencesFilters filter = parameters.filter;
    if (filter.allowList != null) {
      _data.removeWhere((String key, _) => filter.allowList!.contains(key));
    } else {
      _data.clear();
    }
    return true;
  }

  @override
  Future<Map<String, Object>> getPreferences(
    GetPreferencesParameters parameters,
    SharedPreferencesOptions options,
  ) async {
    final PreferencesFilters filter = parameters.filter;
    final Map<String, Object> preferences = Map<String, Object>.from(_data);
    preferences.removeWhere((String key, _) =>
        filter.allowList != null && !filter.allowList!.contains(key));
    return preferences;
  }

  Future<bool> _setValue(
    String key,
    Object value,
    SharedPreferencesOptions options,
  ) async {
    _data[key] = value;
    return true;
  }

  @override
  Future<bool> setString(
    String key,
    String value,
    SharedPreferencesOptions options,
  ) async {
    return _setValue(key, value, options);
  }

  @override
  Future<bool> setInt(
    String key,
    int value,
    SharedPreferencesOptions options,
  ) async {
    return _setValue(key, value, options);
  }

  @override
  Future<bool> setDouble(
    String key,
    double value,
    SharedPreferencesOptions options,
  ) async {
    return _setValue(key, value, options);
  }

  @override
  Future<bool> setBool(
    String key,
    bool value,
    SharedPreferencesOptions options,
  ) async {
    return _setValue(key, value, options);
  }

  @override
  Future<bool> setStringList(
    String key,
    List<String> value,
    SharedPreferencesOptions options,
  ) async {
    return _setValue(key, value, options);
  }

  @override
  Future<String?> getString(
    String key,
    SharedPreferencesOptions options,
  ) async {
    return _data[key] as String?;
  }

  @override
  Future<bool?> getBool(
    String key,
    SharedPreferencesOptions options,
  ) async {
    return _data[key] as bool?;
  }

  @override
  Future<double?> getDouble(
    String key,
    SharedPreferencesOptions options,
  ) async {
    return _data[key] as double?;
  }

  @override
  Future<int?> getInt(
    String key,
    SharedPreferencesOptions options,
  ) async {
    return _data[key] as int?;
  }

  @override
  Future<List<String>?> getStringList(
    String key,
    SharedPreferencesOptions options,
  ) async {
    final List<Object>? data = _data[key] as List<Object>?;
    return data?.cast<String>();
  }

  @override
  Future<Set<String>> getKeys(
    GetPreferencesParameters parameters,
    SharedPreferencesOptions options,
  ) async {
    final Set<String> keys = _data.keys.toSet();
    if (parameters.filter.allowList != null) {
      keys.retainWhere(
          (String element) => parameters.filter.allowList!.contains(element));
    }

    return keys;
  }
}
