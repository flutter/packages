// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:shared_preferences_platform_interface/types.dart';

/// Provides a persistent store for simple data.
///
/// Data is persisted to and fetched from the disk asynchronously.
/// If synchronous access to preferences in a locally cached version of preferences
/// is preferred, consider using [SharedPreferencesWithCache] instead.
@immutable
class SharedPreferencesAsync {
  /// Creates a new instance with the given [options].
  SharedPreferencesAsync({
    SharedPreferencesOptions options = const SharedPreferencesOptions(),
  }) : _options = options {
    if (SharedPreferencesAsyncPlatform.instance == null) {
      throw StateError(
          'The SharedPreferencesAsyncPlatform instance must be set.');
    } else {
      _platform = SharedPreferencesAsyncPlatform.instance!;
    }
  }

  /// Options that determine the behavior of contained methods, usually
  /// platform specific extensions of the [SharedPreferencesOptions] class.
  final SharedPreferencesOptions _options;

  late final SharedPreferencesAsyncPlatform _platform;

  /// Returns all keys on the the platform that match provided [parameters].
  ///
  /// If no restrictions are provided, fetches all keys stored on the platform.
  ///
  /// Ignores any keys whose values are types which are incompatible with shared_preferences.
  Future<Set<String>> getKeys({Set<String>? allowList}) async {
    final GetPreferencesParameters parameters = GetPreferencesParameters(
        filter: PreferencesFilters(allowList: allowList));
    return _platform.getKeys(parameters, _options);
  }

  /// Returns all keys and values on the the platform that match provided [parameters].
  ///
  /// If no restrictions are provided, fetches all entries stored on the platform.
  ///
  /// Ignores any entries of types which are incompatible with shared_preferences.
  Future<Map<String, Object?>> getAll({Set<String>? allowList}) async {
    final GetPreferencesParameters parameters = GetPreferencesParameters(
        filter: PreferencesFilters(allowList: allowList));
    return _platform.getPreferences(parameters, _options);
  }

  /// Reads a value from the platform, throwing a [TypeError] if the value is
  /// not a bool.
  Future<bool?> getBool(String key) async {
    return _platform.getBool(key, _options);
  }

  /// Reads a value from the platform, throwing a [TypeError] if the value is
  /// not an int.
  Future<int?> getInt(String key) async {
    return _platform.getInt(key, _options);
  }

  /// Reads a value from the platform, throwing a [TypeError] if the value is
  /// not a double.
  Future<double?> getDouble(String key) async {
    return _platform.getDouble(key, _options);
  }

  /// Reads a value from the platform, throwing a [TypeError] if the value is
  /// not a String.
  Future<String?> getString(String key) async {
    return _platform.getString(key, _options);
  }

  /// Reads a list of string values from the platform, throwing a [TypeError]
  /// if the value not a List<String>.
  Future<List<String>?> getStringList(String key) async {
    return _platform.getStringList(key, _options);
  }

  /// Returns true if the the platform contains the given [key].
  Future<bool> containsKey(String key) async {
    return (await getKeys(allowList: <String>{key})).isNotEmpty;
  }

  /// Saves a boolean [value] to the platform.
  Future<void> setBool(String key, bool value) {
    return _platform.setBool(key, value, _options);
  }

  /// Saves an integer [value] to the platform.
  Future<void> setInt(String key, int value) {
    return _platform.setInt(key, value, _options);
  }

  /// Saves a double [value] to the platform.
  ///
  /// On platforms that do not support storing doubles,
  /// the value will be stored as a float.
  Future<void> setDouble(String key, double value) {
    return _platform.setDouble(key, value, _options);
  }

  /// Saves a string [value] to the platform.
  ///
  /// Some platforms have special values that cannot be stored, please refer to
  /// the README for more information.
  Future<void> setString(String key, String value) {
    return _platform.setString(key, value, _options);
  }

  /// Saves a list of strings [value] to the platform.
  Future<void> setStringList(String key, List<String> value) {
    return _platform.setStringList(key, value, _options);
  }

  /// Removes an entry from the platform.
  Future<void> remove(String key) {
    return _platform.clear(
        ClearPreferencesParameters(
            filter: PreferencesFilters(allowList: <String>{key})),
        _options);
  }

  /// Clears all preferences from the platform.
  ///
  /// If no [parameters] are provided, and [SharedPreferencesAsync] has no filter,
  /// all preferences will be removed. This may include values not set by this instance,
  /// such as those stored by native code or by other packages using
  /// shared_preferences internally, which may cause unintended side effects.
  ///
  /// It is highly recommended that an [allowList] be provided to this call.
  Future<void> clear({Set<String>? allowList}) {
    final ClearPreferencesParameters parameters = ClearPreferencesParameters(
        filter: PreferencesFilters(allowList: allowList));
    return _platform.clear(parameters, _options);
  }
}

/// Options necessary to create a [SharedPreferencesWithCache].
class SharedPreferencesWithCacheOptions {
  /// Creates a new instance with the given options.
  const SharedPreferencesWithCacheOptions({
    this.allowList,
  });

  /// Information about what data will be fetched during `get` and `init`
  /// methods, what data can be `set`, as well as what data will be removed by `clear`.
  ///
  /// A `null` allowList will prevent filtering, allowing all items to be cached.
  /// An empty allowList will prevent all caching as well as getting and setting.
  ///
  /// Setting an allowList is strongly recommended, to prevent getting and
  /// caching unneeded or unexpected data.
  final Set<String>? allowList;
}

/// Provides a persistent store for simple data.
///
/// Cache provided to allow for synchronous gets.
///
/// If preferences on the platform may be altered by other means than through
/// this instance, consider using [SharedPreferencesAsync] instead. You may also
/// refresh the cached data using [reloadCache] prior to a get request to prevent
/// missed changes that may have occurred since the cache was last updated.
@immutable
class SharedPreferencesWithCache {
  /// Creates a new instance with the given options.
  SharedPreferencesWithCache._create({
    required SharedPreferencesOptions sharedPreferencesOptions,
    required SharedPreferencesWithCacheOptions cacheOptions,
    Map<String, Object?>? cache,
  })  : _cacheOptions = cacheOptions,
        _platformMethods =
            SharedPreferencesAsync(options: sharedPreferencesOptions),
        _cache = cache ?? <String, Object?>{};

  /// Creates a new instance with the given options and reloads the cache from
  /// the platform data.
  static Future<SharedPreferencesWithCache> create({
    SharedPreferencesOptions sharedPreferencesOptions =
        const SharedPreferencesOptions(),
    required SharedPreferencesWithCacheOptions cacheOptions,
    Map<String, Object?>? cache,
  }) async {
    final SharedPreferencesWithCache preferences =
        SharedPreferencesWithCache._create(
      sharedPreferencesOptions: sharedPreferencesOptions,
      cacheOptions: cacheOptions,
      cache: cache,
    );

    await preferences.reloadCache();

    return preferences;
  }

  /// Cache containing in-memory data.
  final Map<String, Object?> _cache;

  /// Options that define cache behavior.
  final SharedPreferencesWithCacheOptions _cacheOptions;

  /// Async access directly to the platform.
  ///
  /// Methods called through [_platformMethods] will NOT update the cache.
  final SharedPreferencesAsync _platformMethods;

  /// Updates cache with latest values from platform.
  ///
  /// This should be called before reading any values if the values may have
  /// been changed by anything other than this cache instance,
  /// such as from another isolate or native code that changes the underlying
  /// preference storage directly.
  Future<void> reloadCache() async {
    _cache.clear();
    _cache.addAll(
        await _platformMethods.getAll(allowList: _cacheOptions.allowList));
  }

  /// Returns true if cache contains the given [key].
  ///
  /// Throws an [ArgumentError] if [key] is not in this instance's filter.
  bool containsKey(String key) {
    if (!_isValidKey(key)) {
      throw ArgumentError(
          '$key is not included in the PreferencesFilter allowlist');
    }
    return _cache.containsKey(key);
  }

  /// Returns all keys in the cache.
  Set<String> get keys => _cache.keys.toSet();

  /// Reads a value of any type from the cache.
  ///
  /// Throws an [ArgumentError] if [key] is not in this instance's filter.
  Object? get(String key) {
    if (!_isValidKey(key)) {
      throw ArgumentError(
          '$key is not included in the PreferencesFilter allowlist');
    }
    return _cache[key];
  }

  /// Reads a value from the cache, throwing a [TypeError] if the value is not a
  /// bool.
  ///
  /// Throws an [ArgumentError] if [key] is not in this instance's filter.
  bool? getBool(String key) {
    if (!_isValidKey(key)) {
      throw ArgumentError(
          '$key is not included in the PreferencesFilter allowlist');
    }
    return get(key) as bool?;
  }

  /// Reads a value from the cache, throwing a [TypeError] if the value is not
  /// an int.
  ///
  /// Throws an [ArgumentError] if [key] is not in this instance's filter.
  int? getInt(String key) {
    if (!_isValidKey(key)) {
      throw ArgumentError(
          '$key is not included in the PreferencesFilter allowlist');
    }
    return get(key) as int?;
  }

  /// Reads a value from the cache, throwing a [TypeError] if the value is not a
  /// double.
  ///
  /// Throws an [ArgumentError] if [key] is not in this instance's filter.
  double? getDouble(String key) {
    if (!_isValidKey(key)) {
      throw ArgumentError(
          '$key is not included in the PreferencesFilter allowlist');
    }
    return get(key) as double?;
  }

  /// Reads a value from the cache, throwing a [TypeError] if the value is not a
  /// String.
  ///
  /// Throws an [ArgumentError] if [key] is not in this instance's filter.
  String? getString(String key) {
    if (!_isValidKey(key)) {
      throw ArgumentError(
          '$key is not included in the PreferencesFilter allowlist');
    }
    return get(key) as String?;
  }

  /// Reads a list of string values from the cache, throwing an
  /// exception if it's not a string list.
  ///
  /// Throws an [ArgumentError] if [key] is not in this instance's filter.
  List<String>? getStringList(String key) {
    if (!_isValidKey(key)) {
      throw ArgumentError(
          '$key is not included in the PreferencesFilter allowlist');
    }
    // Make a copy of the list so that later mutations won't propagate
    return (_cache[key] as List<Object?>?)?.cast<String>().toList();
  }

  /// Saves a boolean [value] to the cache and platform.
  ///
  /// Throws an [ArgumentError] if [key] is not in this instance's filter.
  Future<void> setBool(String key, bool value) async {
    if (!_isValidKey(key)) {
      throw ArgumentError(
          '$key is not included in the PreferencesFilter allowlist');
    }
    _cache[key] = value;
    return _platformMethods.setBool(key, value);
  }

  /// Saves an integer [value] to the cache and platform.
  ///
  /// Throws an [ArgumentError] if [key] is not in this instance's filter.
  Future<void> setInt(String key, int value) async {
    if (!_isValidKey(key)) {
      throw ArgumentError(
          '$key is not included in the PreferencesFilter allowlist');
    }
    _cache[key] = value;
    return _platformMethods.setInt(key, value);
  }

  /// Saves a double [value] to the cache and platform.
  ///
  /// On platforms that do not support storing doubles,
  /// the value will be stored as a float instead.
  ///
  /// Throws an [ArgumentError] if [key] is not in this instance's filter.
  Future<void> setDouble(String key, double value) async {
    if (!_isValidKey(key)) {
      throw ArgumentError(
          '$key is not included in the PreferencesFilter allowlist');
    }
    _cache[key] = value;
    return _platformMethods.setDouble(key, value);
  }

  /// Saves a string [value] to the cache and platform.
  ///
  /// Note: Due to limitations on some platforms,
  /// values cannot start with the following:
  ///
  /// - 'VGhpcyBpcyB0aGUgcHJlZml4IGZvciBhIGxpc3Qu'
  ///
  /// Throws an [ArgumentError] if [key] is not in this instance's filter.
  Future<void> setString(String key, String value) async {
    if (!_isValidKey(key)) {
      throw ArgumentError(
          '$key is not included in the PreferencesFilter allowlist');
    }
    _cache[key] = value;
    return _platformMethods.setString(key, value);
  }

  /// Saves a list of strings [value] to the cache and platform.
  ///
  /// Throws an [ArgumentError] if [key] is not in this instance's filter.
  Future<void> setStringList(String key, List<String> value) async {
    if (!_isValidKey(key)) {
      throw ArgumentError(
          '$key is not included in the PreferencesFilter allowlist');
    }
    _cache[key] = value;
    return _platformMethods.setStringList(key, value);
  }

  /// Removes an entry from cache and platform.
  ///
  /// Throws an [ArgumentError] if [key] is not in this instance's filter.
  Future<void> remove(String key) async {
    if (!_isValidKey(key)) {
      throw ArgumentError(
          '$key is not included in the PreferencesFilter allowlist');
    }
    _cache.remove(key);
    return _platformMethods.remove(key);
  }

  /// Clears cache and platform preferences that match filter options.
  Future<void> clear() async {
    _cache.clear();
    return _platformMethods.clear(allowList: _cacheOptions.allowList);
  }

  bool _isValidKey(String key) {
    return _cacheOptions.allowList?.contains(key) ?? true;
  }
}
