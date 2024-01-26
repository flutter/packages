// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:shared_preferences_platform_interface/types.dart';

/// Provides a persistent store for simple data.
///
/// Data is persisted to disk asynchronously.
class SharedPreferencesAsync {
  /// Creates a new instance with the given [options].
  SharedPreferencesAsync({required SharedPreferencesOptions options})
      : _options = options;

  /// Options that determine the behavior of contained methods,  usually
  /// platform specific extensions of the [SharedPreferencesOptions] class.
  final SharedPreferencesOptions _options;

  final SharedPreferencesAsyncPlatform _platform =
      SharedPreferencesAsyncPlatform.instance;

  /// Returns all keys on the the platform that match provided [parameters].
  ///
  /// If no restrictions are provided, fetches all keys stored on the platform.
  ///
  /// Ignores any keys whose values are types which are incompatible with shared_preferences.
  Future<Set<String?>> getKeys(GetPreferencesParameters parameters) async =>
      _platform.getKeys(parameters, _options);

  /// Returns all keys and values on the the platform that match provided [parameters].
  ///
  /// If no restrictions are provided, fetches all entries stored on the platform.
  ///
  /// Ignores any entries of types which are incompatible with shared_preferences.
  Future<Map<String, Object?>> getAll(
      GetPreferencesParameters parameters) async {
    return _platform.getPreferences(parameters, _options);
  }

  /// Reads a value from the platform, throwing an exception if it's not a
  /// bool.
  Future<bool?> getBool(String key) async => _platform.getBool(key, _options);

  /// Reads a value from the platform, throwing an exception if it's not
  /// an int.
  Future<int?> getInt(String key) async => _platform.getInt(key, _options);

  /// Reads a value from the platform, throwing an exception if it's not a
  /// double.
  Future<double?> getDouble(String key) async =>
      _platform.getDouble(key, _options);

  /// Reads a value from the platform, throwing an exception if it's not a
  /// String.
  Future<String?> getString(String key) async =>
      _platform.getString(key, _options);

  /// Reads a list of string values from the platform, throwing an
  /// exception if it's not a string list.
  Future<List<String>?> getStringList(String key) async {
    List<dynamic>? list = await _platform.getStringList(key, _options);
    if (list != null && list is! List<String>) {
      list = list.cast<String>().toList();
    }
    // Make a copy of the list so that later mutations won't propagate
    return list?.toList() as List<String>?;
  }

  /// Returns true if the the platform contains the given [key].
  Future<bool> containsKey(String key) async =>
      (await getKeys(GetPreferencesParameters(
              filter: PreferencesFilters(allowList: <String>{key}))))
          .isNotEmpty;

  /// Saves a boolean [value] to the platform.
  Future<bool> setBool(String key, bool value) =>
      _platform.setBool(key, value, _options);

  /// Saves an integer [value] to the platform.
  Future<bool> setInt(String key, int value) =>
      _platform.setInt(key, value, _options);

  /// Saves a double [value] to the platform.
  ///
  /// On platforms that do not support storing doubles,
  /// the value will be stored as a float.
  Future<bool> setDouble(String key, double value) =>
      _platform.setDouble(key, value, _options);

  /// Saves a string [value] to the platform.
  ///
  /// Some platforms have special values that cannot be stored, please refer to
  /// the README for more information.
  Future<bool> setString(String key, String value) =>
      _platform.setString(key, value, _options);

  /// Saves a list of strings [value] to the platform.
  Future<bool> setStringList(String key, List<String> value) =>
      _platform.setStringList(key, value, _options);

  /// Removes an entry from the platform.
  Future<bool> remove(String key) {
    return _platform.clear(
        ClearPreferencesParameters(
            filter: PreferencesFilters(allowList: <String>{key})),
        _options);
  }

  /// Completes with true once the user preferences for the app have been cleared.
  ///
  /// If no [parameters] are provided, and [SharedPreferencesAsync] has no filter,
  /// all preferences will be removed.
  Future<bool> clear(ClearPreferencesParameters parameters) {
    return _platform.clear(parameters, _options);
  }
}

/// Options necessary to create a [SharedPreferencesWithCache].
class SharedPreferencesWithCacheOptions {
  /// Creates a new instance with the given options.
  SharedPreferencesWithCacheOptions({
    required this.filter,
  });

  /// Information about what data should be fetched during `getAll` and `init`
  /// methods, as well as what data will be removed by `clear`.
  PreferencesFilters filter;
}

/// Provides a persistent store for simple data.
///
/// Cache provided to allow for synchronous gets.
class SharedPreferencesWithCache {
  /// Creates a new instance with the given [options].
  SharedPreferencesWithCache({
    required this.sharedPreferencesOptions,
    required SharedPreferencesWithCacheOptions cacheOptions,
    Map<String, Object?>? cache,
  })  : _cacheOptions = cacheOptions,
        directAccess =
            SharedPreferencesAsync(options: sharedPreferencesOptions),
        _cache = cache ?? <String, Object?>{} {
    _init();
  }

  /// Cache containing in-memory data.
  final Map<String, Object?> _cache;

  /// Options that determine the behavior of contained methods, usually
  /// platform specific extensions of the [SharedPreferencesOptions] class.
  final SharedPreferencesOptions sharedPreferencesOptions;

  /// Options that define cache behavior.
  final SharedPreferencesWithCacheOptions _cacheOptions;

  /// Async access directly to the platform.
  ///
  /// Methods called through [directAccess] will NOT update the cache.
  final SharedPreferencesAsync directAccess;

  Future<void> _init() async {
    await reloadCache();
  }

  /// Updates cache with latest values from platform.
  Future<void> reloadCache() async {
    _cache.clear();
    _cache.addAll(await directAccess
        .getAll(GetPreferencesParameters(filter: _cacheOptions.filter)));
  }

  /// Returns true if cache contains the given [key].
  bool containsKey(String key) => _cache.containsKey(key);

  /// Returns all keys in the cache.
  Set<String> getKeys() {
    final Set<String> keys = _cache.keys.toSet();
    if (_cacheOptions.filter.allowList != null) {
      keys.removeWhere((String element) =>
          !_cacheOptions.filter.allowList!.contains(element));
    }
    return keys;
  }

  /// Reads a value of any type from the cache.
  Object? get(String key) => _cache[key];

  /// Reads a value from the cache, throwing an exception if it's not a
  /// bool.
  bool? getBool(String key) => get(key) as bool?;

  /// Reads a value from the cache, throwing an exception if it's not
  /// an int.
  int? getInt(String key) => get(key) as int?;

  /// Reads a value from the cache, throwing an exception if it's not a
  /// double.
  double? getDouble(String key) => get(key) as double?;

  /// Reads a value from the cache, throwing an exception if it's not a
  /// String.
  String? getString(String key) => get(key) as String?;

  /// Reads a set of string values from the cache, throwing an
  /// exception if it's not a string list.
  List<String>? getStringList(String key) {
    List<dynamic>? list = get(key) as List<dynamic>?;
    if (list != null && list is! List<String>) {
      list = list.cast<String>().toList();
    }
    // Make a copy of the list so that later mutations won't propagate
    return list?.toList() as List<String>?;
  }

  /// Saves a boolean [value] to the cache and platform.
  Future<bool> setBool(String key, bool value) async {
    _cache[key] = value;
    return directAccess.setBool(key, value);
  }

  /// Saves an integer [value] to the cache and platform.
  Future<bool> setInt(String key, int value) async {
    _cache[key] = value;
    return directAccess.setInt(key, value);
  }

  /// Saves a double [value] to the cache and platform.
  ///
  /// On platforms that do not support storing doubles,
  /// the value will be stored as a float instead.
  Future<bool> setDouble(String key, double value) async {
    _cache[key] = value;
    return directAccess.setDouble(key, value);
  }

  /// Saves a string [value] to the cache and platform.
  ///
  /// Note: Due to limitations on some platform's,
  /// values cannot start with the following:
  ///
  /// - 'VGhpcyBpcyB0aGUgcHJlZml4IGZvciBhIGxpc3Qu'
  /// - 'VGhpcyBpcyB0aGUgcHJlZml4IGZvciBEb3VibGUu'
  Future<bool> setString(String key, String value) async {
    _cache[key] = value;
    return directAccess.setString(key, value);
  }

  /// Saves a list of strings [value] to the cache and platform.
  Future<bool> setStringList(String key, List<String> value) async {
    _cache[key] = value;
    return directAccess.setStringList(key, value);
  }

  /// Removes an entry from cache and platform.
  Future<bool> remove(String key) async {
    _cache.remove(key);
    return directAccess.remove(key);
  }

  /// Clears cache and platform preferences that match filter options.
  Future<bool> clear() async {
    if (_cacheOptions.filter.allowList != null) {
      _cache.removeWhere(
          (String key, _) => _cacheOptions.filter.allowList!.contains(key));
    } else {
      _cache.clear();
    }
    return directAccess
        .clear(ClearPreferencesParameters(filter: _cacheOptions.filter));
  }
}
