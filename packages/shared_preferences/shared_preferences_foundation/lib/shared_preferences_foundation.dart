// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:shared_preferences_platform_interface/types.dart';

import './messages.g.dart';
import 'deprecated_shared_preferences_foundation.dart';

const String _argumentErrorCode = 'Argument Error';

/// iOS and macOS implementation of shared_preferences.
base class SharedPreferencesFoundation extends SharedPreferencesAsyncPlatform {
  /// Creates a new plugin implementation instance.
  SharedPreferencesFoundation({
    @visibleForTesting UserDefaultsApi? api,
  }) : _api = api ?? UserDefaultsApi();

  final UserDefaultsApi _api;

  /// Registers this class as the default instance of [SharedPreferencesAsyncPlatform].
  static void registerWith() {
    SharedPreferencesAsyncPlatform.instance = SharedPreferencesFoundation();
    // A temporary work-around for having two plugins contained in a single package.
    DeprecatedSharedPreferencesFoundation.registerWith();
  }

  /// Returns a SharedPreferencesPigeonOptions for sending to platform.
  SharedPreferencesPigeonOptions _convertOptionsToPigeonOptions(
      SharedPreferencesOptions options) {
    if (options is SharedPreferencesFoundationOptions) {
      final String? suiteName = options.suiteName;
      return SharedPreferencesPigeonOptions(
        suiteName: suiteName,
      );
    }
    return SharedPreferencesPigeonOptions();
  }

  @override
  Future<Set<String?>> getKeys(
    GetPreferencesParameters parameters,
    SharedPreferencesOptions options,
  ) async {
    final PreferencesFilters filter = parameters.filter;
    try {
      return (await _api.getKeys(
        filter.allowList?.toList(),
        _convertOptionsToPigeonOptions(options),
      ))
          .toSet();
    } on PlatformException catch (err) {
      if (err.code == _argumentErrorCode) {
        throw ArgumentError(
            'shared_preferences_foundation getString argument error${err.message ?? ''}');
      } else {
        rethrow;
      }
    }
  }

  Future<void> _setValue(
    String key,
    Object value,
    SharedPreferencesOptions options,
  ) async {
    final SharedPreferencesPigeonOptions pigeonOptions =
        _convertOptionsToPigeonOptions(options);

    try {
      await _api.setValue(key, value, pigeonOptions);
    } on PlatformException catch (err) {
      if (err.code == _argumentErrorCode) {
        throw ArgumentError(
            'shared_preferences_foundation getString argument error${err.message ?? ''}');
      } else {
        rethrow;
      }
    }
  }

  @override
  Future<void> setString(
    String key,
    String value,
    SharedPreferencesOptions options,
  ) async {
    try {
      await _setValue(key, value, options);
    } on PlatformException catch (err) {
      if (err.code == _argumentErrorCode) {
        throw ArgumentError(
            'shared_preferences_foundation getString argument error${err.message ?? ''}');
      } else {
        rethrow;
      }
    }
  }

  @override
  Future<void> setInt(
    String key,
    int value,
    SharedPreferencesOptions options,
  ) async {
    try {
      await _setValue(key, value, options);
    } on PlatformException catch (err) {
      if (err.code == _argumentErrorCode) {
        throw ArgumentError(
            'shared_preferences_foundation getString argument error${err.message ?? ''}');
      } else {
        rethrow;
      }
    }
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
    final SharedPreferencesPigeonOptions pigeonOptions =
        _convertOptionsToPigeonOptions(options);

    try {
      await _api.setValue(key, value, pigeonOptions);
    } on PlatformException catch (err) {
      if (err.code == _argumentErrorCode) {
        throw ArgumentError(
            'shared_preferences_foundation getString argument error${err.message ?? ''}');
      } else {
        rethrow;
      }
    }
  }

  @override
  Future<void> setDouble(
    String key,
    double value,
    SharedPreferencesOptions options,
  ) async {
    final SharedPreferencesPigeonOptions pigeonOptions =
        _convertOptionsToPigeonOptions(options);

    try {
      await _api.setValue(key, value, pigeonOptions);
    } on PlatformException catch (err) {
      if (err.code == _argumentErrorCode) {
        throw ArgumentError(
            'shared_preferences_foundation getString argument error${err.message ?? ''}');
      } else {
        rethrow;
      }
    }
  }

  @override
  Future<String?> getString(
    String key,
    SharedPreferencesOptions options,
  ) async {
    final SharedPreferencesPigeonOptions pigeonOptions =
        _convertOptionsToPigeonOptions(options);
    try {
      return _api.getString(key, pigeonOptions);
    } on PlatformException catch (err) {
      if (err.code == _argumentErrorCode) {
        throw ArgumentError(
            'shared_preferences_foundation getString argument error${err.message ?? ''}');
      } else {
        rethrow;
      }
    }
  }

  @override
  Future<bool?> getBool(
    String key,
    SharedPreferencesOptions options,
  ) async {
    final SharedPreferencesPigeonOptions pigeonOptions =
        _convertOptionsToPigeonOptions(options);

    try {
      return await _api.getValue(key, pigeonOptions) as bool?;
    } on PlatformException catch (err) {
      if (err.code == _argumentErrorCode) {
        throw ArgumentError(
            'shared_preferences_foundation getString argument error${err.message ?? ''}');
      } else {
        rethrow;
      }
    }
  }

  @override
  Future<double?> getDouble(
    String key,
    SharedPreferencesOptions options,
  ) async {
    final SharedPreferencesPigeonOptions pigeonOptions =
        _convertOptionsToPigeonOptions(options);

    try {
      return await _api.getValue(key, pigeonOptions) as double?;
    } on PlatformException catch (err) {
      if (err.code == _argumentErrorCode) {
        throw ArgumentError(
            'shared_preferences_foundation getString argument error${err.message ?? ''}');
      } else {
        rethrow;
      }
    }
  }

  @override
  Future<int?> getInt(
    String key,
    SharedPreferencesOptions options,
  ) async {
    final SharedPreferencesPigeonOptions pigeonOptions =
        _convertOptionsToPigeonOptions(options);

    try {
      return await _api.getValue(key, pigeonOptions) as int?;
    } on PlatformException catch (err) {
      if (err.code == _argumentErrorCode) {
        throw ArgumentError(
            'shared_preferences_foundation getString argument error${err.message ?? ''}');
      } else {
        rethrow;
      }
    }
  }

  @override
  Future<List<String?>?> getStringList(
    String key,
    SharedPreferencesOptions options,
  ) async {
    final SharedPreferencesPigeonOptions pigeonOptions =
        _convertOptionsToPigeonOptions(options);

    try {
      return _api.getStringList(key, pigeonOptions);
    } on PlatformException catch (err) {
      if (err.code == _argumentErrorCode) {
        throw ArgumentError(
            'shared_preferences_foundation getString argument error${err.message ?? ''}');
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
    try {
      await _api.clear(
        filter.allowList?.toList(),
        _convertOptionsToPigeonOptions(options),
      );
    } on PlatformException catch (err) {
      if (err.code == _argumentErrorCode) {
        throw ArgumentError(
            'shared_preferences_foundation getString argument error${err.message ?? ''}');
      } else {
        rethrow;
      }
    }
  }

  @override
  Future<Map<String, Object>> getPreferences(
    GetPreferencesParameters parameters,
    SharedPreferencesOptions options,
  ) async {
    final PreferencesFilters filter = parameters.filter;
    try {
      final Map<String?, Object?> data = await _api.getAll(
        filter.allowList?.toList(),
        _convertOptionsToPigeonOptions(options),
      );
      return data.cast<String, Object>();
    } on PlatformException catch (err) {
      if (err.code == _argumentErrorCode) {
        throw ArgumentError(
            'shared_preferences_foundation getString argument error${err.message ?? ''}');
      } else {
        rethrow;
      }
    }
  }
}

/// Options for the Foundation specific SharedPreferences plugin.
@immutable
class SharedPreferencesFoundationOptions extends SharedPreferencesOptions {
  /// Creates a new instance with the given options.
  SharedPreferencesFoundationOptions({
    this.suiteName,
  }) {
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

  /// Returns a new instance of [SharedPreferencesFoundationOptions] from an existing
  /// [SharedPreferencesOptions].
  static SharedPreferencesFoundationOptions fromSharedPreferencesOptions(
      SharedPreferencesOptions options) {
    if (options is SharedPreferencesFoundationOptions) {
      return options;
    }
    return SharedPreferencesFoundationOptions();
  }
}
