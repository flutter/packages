// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:shared_preferences_platform_interface/types.dart';

import './messages.g.dart';
import './shared_preferences_foundation.dart';

const String _argumentErrorCode = 'Argument Error';

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
    // A temporary work-around for having two plugins contained in a single package.
    SharedPreferencesFoundation.registerWith();
  }

  /// Returns a SharedPreferencesPigeonOptions for sending to platform.
  SharedPreferencesPigeonOptions _convertOptionsToPigeonOptions(
      SharedPreferencesOptions options) {
    if (options is SharedPreferencesAsyncFoundationOptions) {
      final String? suiteName = options.suiteName;
      return SharedPreferencesPigeonOptions(
        suiteName: suiteName,
      );
    }
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
    return (await _convertKnownExceptions<List<String>>(
            () async => (await _api.getKeys(
                  filter.allowList?.toList(),
                  _convertOptionsToPigeonOptions(options),
                ))
                    .cast<String>()))!
        .toSet();
  }

  Future<void> _setValue(
    String key,
    Object value,
    SharedPreferencesOptions options,
  ) async {
    return _convertKnownExceptions<void>(() async =>
        _api.set(key, value, _convertOptionsToPigeonOptions(options)));
  }

  @override
  Future<void> setString(
    String key,
    String value,
    SharedPreferencesOptions options,
  ) async {
    await _setValue(key, value, options);
  }

  @override
  Future<void> setInt(
    String key,
    int value,
    SharedPreferencesOptions options,
  ) async {
    await _setValue(key, value, options);
  }

  @override
  Future<void> setStringList(
    String key,
    List<String> value,
    SharedPreferencesOptions options,
  ) async {
    await _setValue(key, value, options);
  }

  @override
  Future<void> setBool(
    String key,
    bool value,
    SharedPreferencesOptions options,
  ) async {
    await _api.set(key, value, _convertOptionsToPigeonOptions(options));
  }

  @override
  Future<void> setDouble(
    String key,
    double value,
    SharedPreferencesOptions options,
  ) async {
    await _api.set(key, value, _convertOptionsToPigeonOptions(options));
  }

  @override
  Future<String?> getString(
    String key,
    SharedPreferencesOptions options,
  ) async {
    return _convertKnownExceptions<String>(() async => (await _api.getValue(
        key, _convertOptionsToPigeonOptions(options))) as String?);
  }

  @override
  Future<bool?> getBool(
    String key,
    SharedPreferencesOptions options,
  ) async {
    return _convertKnownExceptions<bool>(() async => await _api.getValue(
        key, _convertOptionsToPigeonOptions(options)) as bool?);
  }

  @override
  Future<double?> getDouble(
    String key,
    SharedPreferencesOptions options,
  ) async {
    return _convertKnownExceptions<double>(() async => await _api.getValue(
        key, _convertOptionsToPigeonOptions(options)) as double?);
  }

  @override
  Future<int?> getInt(
    String key,
    SharedPreferencesOptions options,
  ) async {
    return _convertKnownExceptions<int>(() async => await _api.getValue(
        key, _convertOptionsToPigeonOptions(options)) as int?);
  }

  @override
  Future<List<String>?> getStringList(
    String key,
    SharedPreferencesOptions options,
  ) async {
    // TODO(tarrinneal): Remove cast once https://github.com/flutter/flutter/issues/97848
    // is fixed. In practice, the values will never be null, and the native implementation assumes that.
    return _convertKnownExceptions<List<String>>(() async =>
        ((await _api.getValue(key, _convertOptionsToPigeonOptions(options)))
                as List<Object?>?)
            ?.cast<String>());
  }

  @override
  Future<void> clear(
    ClearPreferencesParameters parameters,
    SharedPreferencesOptions options,
  ) async {
    final PreferencesFilters filter = parameters.filter;
    return _convertKnownExceptions<void>(() async => _api.clear(
          filter.allowList?.toList(),
          _convertOptionsToPigeonOptions(options),
        ));
  }

  @override
  Future<Map<String, Object>> getPreferences(
    GetPreferencesParameters parameters,
    SharedPreferencesOptions options,
  ) async {
    final PreferencesFilters filter = parameters.filter;
    final Map<String?, Object?>? data =
        await _convertKnownExceptions<Map<String?, Object?>>(
            () async => _api.getAll(
                  filter.allowList?.toList(),
                  _convertOptionsToPigeonOptions(options),
                ));

    return data!.cast<String, Object>();
  }

  Future<T?> _convertKnownExceptions<T>(Future<T?> Function() method) async {
    try {
      final T? value = await method();
      return value;
    } on PlatformException catch (e) {
      if (e.code == _argumentErrorCode) {
        throw ArgumentError(
            'shared_preferences_foundation argument error ${e.message ?? ''}');
      } else {
        rethrow;
      }
    }
  }
}

/// Options for the Foundation specific SharedPreferences plugin.
@immutable
class SharedPreferencesAsyncFoundationOptions extends SharedPreferencesOptions {
  /// Creates a new instance with the given options.
  SharedPreferencesAsyncFoundationOptions({
    this.suiteName,
  }) {
    // Ensure that use of suite is compliant with required reason API category 1C8F.1; see
    // https://developer.apple.com/documentation/bundleresources/privacy_manifest_files/describing_use_of_required_reason_api
    if (Platform.isIOS && !(suiteName?.startsWith('group.') ?? true)) {
      throw ArgumentError('iOS suite name must begin with "group."');
    }
  }

  /// Name of Foundation suite to get/set to.
  ///
  /// On iOS this represents a container ID which must begin with `group.`
  /// followed by a custom string in reverse DNS notation.
  ///
  /// If this option is not set, the default NSUserDefaults will be used.
  final String? suiteName;

  /// Returns a new instance of [SharedPreferencesAsyncFoundationOptions] from an existing
  /// [SharedPreferencesOptions].
  static SharedPreferencesAsyncFoundationOptions fromSharedPreferencesOptions(
      SharedPreferencesOptions options) {
    if (options is SharedPreferencesAsyncFoundationOptions) {
      return options;
    }
    return SharedPreferencesAsyncFoundationOptions();
  }
}
