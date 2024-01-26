// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'method_channel_shared_preferences_async.dart';
import 'types.dart';

/// The interface that implementations of shared_preferences must implement.
///
/// Platform implementations should extend this class rather than implement it as `shared_preferences`
/// does not consider newly added methods to be breaking changes. Extending this class
/// (using `extends`) ensures that the subclass will get the default implementation, while
/// platform implementations that `implements` this interface will be broken by newly added
/// [SharedPreferencesAsyncPlatform] methods.
abstract base class SharedPreferencesAsyncPlatform<T> {
  /// Constructs a SharedPreferencesAsyncPlatform.
  SharedPreferencesAsyncPlatform();

  /// The instance of [SharedPreferencesAsyncPlatform] to use.
  ///
  /// Defaults to [MethodChannelSharedPreferencesAsync].
  static SharedPreferencesAsyncPlatform<SharedPreferencesOptions> instance =
      MethodChannelSharedPreferencesAsync();

  /// Stores the String [value] associated with the [key].
  Future<bool> setString(
    String key,
    String value,
    T options,
  );

  /// Stores the bool [value] associated with the [key].
  Future<bool> setBool(
    String key,
    bool value,
    T options,
  );

  /// Stores the double [value] associated with the [key].
  Future<bool> setDouble(
    String key,
    double value,
    T options,
  );

  /// Stores the int [value] associated with the [key].
  Future<bool> setInt(
    String key,
    int value,
    T options,
  );

  /// Stores the List<String> [value] associated with the [key].
  Future<bool> setStringList(
    String key,
    List<String> value,
    T options,
  );

  /// Retrieves the String [value] associated with the [key], if any.
  Future<String?> getString(
    String key,
    T options,
  );

  /// Retrieves the bool [value] associated with the [key], if any.
  Future<bool?> getBool(
    String key,
    T options,
  );

  /// Retrieves the double [value] associated with the [key], if any.
  Future<double?> getDouble(
    String key,
    T options,
  );

  /// Retrieves the int [value] associated with the [key], if any.
  Future<int?> getInt(
    String key,
    T options,
  );

  /// Retrieves the List<String> [value] associated with the [key], if any.
  Future<List<String?>?> getStringList(
    String key,
    T options,
  );

  /// Removes all keys and values in the store that match the given [parameters].
  Future<bool> clear(
    ClearPreferencesParameters parameters,
    T options,
  );

  /// Returns all key/value pairs persisting in this store that match the given [parameters].
  Future<Map<String, Object>> getPreferences(
    GetPreferencesParameters parameters,
    T options,
  );

  /// Returns all keys persisting in this store that match the given [parameters].
  Future<Set<String?>> getKeys(
    GetPreferencesParameters parameters,
    T options,
  );
}

/// Stores data in-memory.
///
/// Data does not persist across application restarts. This is useful in unit-tests.
base class InMemorySharedPreferencesAsync<T>
    extends SharedPreferencesAsyncPlatform<T> {
  /// Instantiates an empty in-memory preferences store.
  InMemorySharedPreferencesAsync.empty() : _data = <String, Object>{};

  /// Instantiates an in-memory preferences store containing a copy of [data].
  InMemorySharedPreferencesAsync.withData(Map<String, Object> data)
      : _data = Map<String, Object>.from(data);

  final Map<String, Object> _data;

  @override
  Future<bool> clear(
    ClearPreferencesParameters parameters,
    T options,
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
    T options,
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
    T options,
  ) async {
    _data[key] = value;
    return true;
  }

  @override
  Future<bool> setString(
    String key,
    String value,
    T options,
  ) async {
    return _setValue(key, value, options);
  }

  @override
  Future<bool> setInt(
    String key,
    int value,
    T options,
  ) async {
    return _setValue(key, value, options);
  }

  @override
  Future<bool> setDouble(
    String key,
    double value,
    T options,
  ) async {
    return _setValue(key, value, options);
  }

  @override
  Future<bool> setBool(
    String key,
    bool value,
    T options,
  ) async {
    return _setValue(key, value, options);
  }

  @override
  Future<bool> setStringList(
    String key,
    List<String> value,
    T options,
  ) async {
    return _setValue(key, value, options);
  }

  @override
  Future<String?> getString(
    String key,
    T options,
  ) async {
    return _data[key] as String?;
  }

  @override
  Future<bool?> getBool(
    String key,
    T options,
  ) async {
    return _data[key] as bool?;
  }

  @override
  Future<double?> getDouble(
    String key,
    T options,
  ) async {
    return _data[key] as double?;
  }

  @override
  Future<int?> getInt(
    String key,
    T options,
  ) async {
    return _data[key] as int?;
  }

  @override
  Future<List<String>?> getStringList(
    String key,
    T options,
  ) async {
    return _data[key] as List<String>?;
  }

  @override
  Future<Set<String?>> getKeys(
    GetPreferencesParameters parameters,
    T options,
  ) async {
    final Set<String> keys = _data.keys.toSet();
    if (parameters.filter.allowList != null) {
      keys.retainWhere(
          (String element) => parameters.filter.allowList!.contains(element));
    }

    return keys;
  }
}
