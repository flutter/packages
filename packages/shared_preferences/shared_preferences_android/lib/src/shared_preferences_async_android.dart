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
    @visibleForTesting SharedPreferencesAsyncApi? dataStoreApi,
    @visibleForTesting SharedPreferencesAsyncApi? sharedPreferencesApi,
  })  : _dataStoreApi = dataStoreApi ??
            SharedPreferencesAsyncApi(messageChannelSuffix: 'data_store'),
        _sharedPreferencesApi = sharedPreferencesApi ??
            SharedPreferencesAsyncApi(
                messageChannelSuffix: 'shared_preferences');

  final SharedPreferencesAsyncApi _dataStoreApi;
  final SharedPreferencesAsyncApi _sharedPreferencesApi;

  /// Registers this class as the default instance of [SharedPreferencesAsyncPlatform].
  static void registerWith() {
    SharedPreferencesAsyncPlatform.instance = SharedPreferencesAsyncAndroid();
  }

  /// Returns a SharedPreferencesPigeonOptions for sending to platform.
  SharedPreferencesPigeonOptions _convertOptionsToPigeonOptions(
      SharedPreferencesOptions options) {
    if (options is SharedPreferencesAsyncAndroidOptions) {
      return SharedPreferencesPigeonOptions(
        fileName: options.originalSharedPreferencesOptions?.fileName,
        useDataStore:
            options.backend == SharedPreferencesAndroidBackendLibrary.DataStore,
      );
    }
    return SharedPreferencesPigeonOptions();
  }

  SharedPreferencesAsyncApi _getApiForBackend(
      SharedPreferencesPigeonOptions options) {
    return options.useDataStore ? _dataStoreApi : _sharedPreferencesApi;
  }

  @override
  Future<Set<String>> getKeys(
    GetPreferencesParameters parameters,
    SharedPreferencesOptions options,
  ) async {
    final PreferencesFilters filter = parameters.filter;
    final SharedPreferencesPigeonOptions pigeonOptions =
        _convertOptionsToPigeonOptions(options);
    final SharedPreferencesAsyncApi api = _getApiForBackend(pigeonOptions);
    return (await api.getKeys(
      filter.allowList?.toList(),
      pigeonOptions,
    ))
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
    final SharedPreferencesPigeonOptions pigeonOptions =
        _convertOptionsToPigeonOptions(options);
    final SharedPreferencesAsyncApi api = _getApiForBackend(pigeonOptions);

    return api.setString(key, value, pigeonOptions);
  }

  @override
  Future<void> setInt(
    String key,
    int value,
    SharedPreferencesOptions options,
  ) async {
    final SharedPreferencesPigeonOptions pigeonOptions =
        _convertOptionsToPigeonOptions(options);
    final SharedPreferencesAsyncApi api = _getApiForBackend(pigeonOptions);
    return api.setInt(key, value, pigeonOptions);
  }

  @override
  Future<void> setDouble(
    String key,
    double value,
    SharedPreferencesOptions options,
  ) async {
    final SharedPreferencesPigeonOptions pigeonOptions =
        _convertOptionsToPigeonOptions(options);
    final SharedPreferencesAsyncApi api = _getApiForBackend(pigeonOptions);
    return api.setDouble(key, value, pigeonOptions);
  }

  @override
  Future<void> setBool(
    String key,
    bool value,
    SharedPreferencesOptions options,
  ) async {
    final SharedPreferencesPigeonOptions pigeonOptions =
        _convertOptionsToPigeonOptions(options);
    final SharedPreferencesAsyncApi api = _getApiForBackend(pigeonOptions);
    return api.setBool(key, value, pigeonOptions);
  }

  @override
  Future<void> setStringList(
    String key,
    List<String> value,
    SharedPreferencesOptions options,
  ) async {
    final SharedPreferencesPigeonOptions pigeonOptions =
        _convertOptionsToPigeonOptions(options);
    final SharedPreferencesAsyncApi api = _getApiForBackend(pigeonOptions);
    return api.setStringList(key, value, pigeonOptions);
  }

  @override
  Future<String?> getString(
    String key,
    SharedPreferencesOptions options,
  ) async {
    final SharedPreferencesPigeonOptions pigeonOptions =
        _convertOptionsToPigeonOptions(options);
    final SharedPreferencesAsyncApi api = _getApiForBackend(pigeonOptions);
    return _convertKnownExceptions<String>(
        () async => api.getString(key, pigeonOptions));
  }

  @override
  Future<bool?> getBool(
    String key,
    SharedPreferencesOptions options,
  ) async {
    final SharedPreferencesPigeonOptions pigeonOptions =
        _convertOptionsToPigeonOptions(options);
    final SharedPreferencesAsyncApi api = _getApiForBackend(pigeonOptions);
    return _convertKnownExceptions<bool>(
        () async => api.getBool(key, pigeonOptions));
  }

  @override
  Future<double?> getDouble(
    String key,
    SharedPreferencesOptions options,
  ) async {
    final SharedPreferencesPigeonOptions pigeonOptions =
        _convertOptionsToPigeonOptions(options);
    final SharedPreferencesAsyncApi api = _getApiForBackend(pigeonOptions);
    return _convertKnownExceptions<double>(
        () async => api.getDouble(key, pigeonOptions));
  }

  @override
  Future<int?> getInt(
    String key,
    SharedPreferencesOptions options,
  ) async {
    final SharedPreferencesPigeonOptions pigeonOptions =
        _convertOptionsToPigeonOptions(options);
    final SharedPreferencesAsyncApi api = _getApiForBackend(pigeonOptions);
    return _convertKnownExceptions<int>(
        () async => api.getInt(key, pigeonOptions));
  }

  @override
  Future<List<String>?> getStringList(
    String key,
    SharedPreferencesOptions options,
  ) async {
    final SharedPreferencesPigeonOptions pigeonOptions =
        _convertOptionsToPigeonOptions(options);
    final SharedPreferencesAsyncApi api = _getApiForBackend(pigeonOptions);
    // TODO(tarrinneal): Remove cast once https://github.com/flutter/flutter/issues/97848
    // is fixed. In practice, the values will never be null, and the native implementation assumes that.
    return _convertKnownExceptions<List<String>>(() async =>
        (await api.getStringList(key, pigeonOptions))?.cast<String>().toList());
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
    final SharedPreferencesPigeonOptions pigeonOptions =
        _convertOptionsToPigeonOptions(options);
    final SharedPreferencesAsyncApi api = _getApiForBackend(pigeonOptions);
    return api.clear(
      filter.allowList?.toList(),
      pigeonOptions,
    );
  }

  @override
  Future<Map<String, Object>> getPreferences(
    GetPreferencesParameters parameters,
    SharedPreferencesOptions options,
  ) async {
    final PreferencesFilters filter = parameters.filter;
    final SharedPreferencesPigeonOptions pigeonOptions =
        _convertOptionsToPigeonOptions(options);
    final SharedPreferencesAsyncApi api = _getApiForBackend(pigeonOptions);
    final Map<String?, Object?> data = await api.getAll(
      filter.allowList?.toList(),
      pigeonOptions,
    );
    return data.cast<String, Object>();
  }
}

/// Used to identify which Android library should be used on the backend of this call.
enum SharedPreferencesAndroidBackendLibrary {
  /// Represents the newer DataStore Preferences library.
  DataStore,

  /// Represents the older SharedPreferences library.
  SharedPreferences,
}

/// Options for the Android specific SharedPreferences plugin.
class SharedPreferencesAsyncAndroidOptions extends SharedPreferencesOptions {
  /// Constructor for SharedPreferencesAsyncAndroidOptions.
  const SharedPreferencesAsyncAndroidOptions({
    this.backend = SharedPreferencesAndroidBackendLibrary.DataStore,
    this.originalSharedPreferencesOptions,
  });

  /// Which backend should be used for this method call.
  final SharedPreferencesAndroidBackendLibrary backend;

  /// These options define how the `SharedPreferences` backend should behave.
  ///
  /// Any options in this field will be ignored unless the backend that is selected
  /// is `SharedPreferences`.
  final AndroidSharedPreferencesStoreOptions? originalSharedPreferencesOptions;
}

/// Options necessary for defining the use of the original `SharedPreferences`
/// library.
///
/// These options are only ever used with the original `SharedPreferences` and
/// have no purpose when using the default DataStore Preferences.
class AndroidSharedPreferencesStoreOptions {
  /// Constructor for AndroidSharedPreferencesStoreOptions.
  const AndroidSharedPreferencesStoreOptions({this.fileName});

  /// The name of the file in which the preferences are stored.
  final String? fileName;
}
