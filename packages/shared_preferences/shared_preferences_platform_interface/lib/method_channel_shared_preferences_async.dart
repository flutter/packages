// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/services.dart';

import 'shared_preferences_async_platform_interface.dart';
import 'types.dart';

const MethodChannel _kChannel =
    MethodChannel('plugins.flutter.io/shared_preferences');

/// Provides a persistent store for simple data.
///
/// Data is persisted to disk asynchronously.
base class MethodChannelSharedPreferencesAsync
    extends SharedPreferencesAsyncPlatform {
  @override
  Future<bool> clear(
    ClearPreferencesParameters parameters,
    SharedPreferencesOptions options,
  ) async {
    final PreferencesFilters filter = parameters.filter;
    return (await _kChannel.invokeMethod<bool>(
      'clear',
      <String, dynamic>{
        'allowList': filter.allowList?.toList(),
      },
    ))!;
  }

  @override
  Future<Map<String, Object>> getPreferences(
    GetPreferencesParameters parameters,
    SharedPreferencesOptions options,
  ) async {
    final PreferencesFilters filter = parameters.filter;
    final List<String>? allowListAsList = filter.allowList?.toList();
    return await _kChannel.invokeMapMethod<String, Object>(
          'getPreferences',
          <String, dynamic>{'allowList': allowListAsList},
        ) ??
        <String, Object>{};
  }

  Future<bool> _setValue(
    String valueType,
    String key,
    Object value,
    SharedPreferencesOptions options,
  ) async {
    return (await _kChannel.invokeMethod<bool>(
      'set$valueType',
      <String, dynamic>{'key': key, 'value': value},
    ))!;
  }

  @override
  Future<bool> setString(
    String key,
    Object value,
    SharedPreferencesOptions options,
  ) async {
    return _setValue('String', key, value, options);
  }

  @override
  Future<bool> setBool(
    String key,
    Object value,
    SharedPreferencesOptions options,
  ) async {
    return _setValue('Bool', key, value, options);
  }

  @override
  Future<bool> setInt(
    String key,
    Object value,
    SharedPreferencesOptions options,
  ) async {
    return _setValue('Int', key, value, options);
  }

  @override
  Future<bool> setDouble(
    String key,
    Object value,
    SharedPreferencesOptions options,
  ) async {
    return _setValue('Double', key, value, options);
  }

  @override
  Future<bool> setStringList(
    String key,
    Object value,
    SharedPreferencesOptions options,
  ) async {
    return _setValue('StringList', key, value, options);
  }

  @override
  Future<String?> getString(
    String key,
    SharedPreferencesOptions options,
  ) async {
    return await _kChannel.invokeMethod<Set<String>>('getString') as String?;
  }

  @override
  Future<bool?> getBool(
    String key,
    SharedPreferencesOptions options,
  ) async {
    return await _kChannel.invokeMethod<Set<String>>('getBool') as bool?;
  }

  @override
  Future<double?> getDouble(
    String key,
    SharedPreferencesOptions options,
  ) async {
    return await _kChannel.invokeMethod<Set<String>>('getDouble') as double?;
  }

  @override
  Future<int?> getInt(
    String key,
    SharedPreferencesOptions options,
  ) async {
    return await _kChannel.invokeMethod<Set<String>>('getInt') as int?;
  }

  @override
  Future<List<String>?> getStringList(
    String key,
    SharedPreferencesOptions options,
  ) async {
    return await _kChannel.invokeMethod<Set<String>>('getStringList')
        as List<String>?;
  }

  @override
  Future<Set<String>> getKeys(
    GetPreferencesParameters parameters,
    SharedPreferencesOptions options,
  ) async {
    final PreferencesFilters filter = parameters.filter;
    final List<String>? allowListAsList = filter.allowList?.toList();
    return await _kChannel.invokeMethod<Set<String>>(
          'getKeys',
          <String, dynamic>{'allowList': allowListAsList},
        ) ??
        <String>{};
  }
}
