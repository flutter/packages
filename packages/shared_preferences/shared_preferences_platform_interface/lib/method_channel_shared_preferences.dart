// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/services.dart';

import 'shared_preferences_platform_interface.dart';
import 'types.dart';

const MethodChannel _kChannel =
    MethodChannel('plugins.flutter.io/shared_preferences');

/// Wraps NSUserDefaults (on iOS) and SharedPreferences (on Android), providing
/// a persistent store for simple data.
///
/// Data is persisted to disk asynchronously.
class MethodChannelSharedPreferencesStore
    extends SharedPreferencesStorePlatform {
  @override
  Future<bool> remove(String key) async {
    return (await _kChannel.invokeMethod<bool>(
      'remove',
      <String, dynamic>{'key': key},
    ))!;
  }

  @override
  Future<bool> setValue(String valueType, String key, Object value) async {
    return (await _kChannel.invokeMethod<bool>(
      'set$valueType',
      <String, dynamic>{'key': key, 'value': value},
    ))!;
  }

  @override
  Future<bool> clear() async {
    return (await _kChannel.invokeMethod<bool>('clear'))!;
  }

  @override
  @Deprecated('Use clearWithParameters instead')
  Future<bool> clearWithPrefix(String prefix) async {
    return clearWithParameters(
      ClearParameters(
        filter: PreferencesFilter(prefix: prefix),
      ),
    );
  }

  @override
  Future<bool> clearWithParameters(ClearParameters parameters) async {
    final PreferencesFilter filter = parameters.filter;
    return (await _kChannel.invokeMethod<bool>(
      'clearWithParameters',
      <String, dynamic>{
        'prefix': filter.prefix,
        'allowList': filter.allowList?.toList(),
      },
    ))!;
  }

  @override
  Future<Map<String, Object>> getAll() async {
    return await _kChannel.invokeMapMethod<String, Object>('getAll') ??
        <String, Object>{};
  }

  @override
  @Deprecated('Use getAllWithParameters instead')
  Future<Map<String, Object>> getAllWithPrefix(
    String prefix, {
    Set<String>? allowList,
  }) async {
    return getAllWithParameters(
      GetAllParameters(
        filter: PreferencesFilter(prefix: prefix),
      ),
    );
  }

  @override
  Future<Map<String, Object>> getAllWithParameters(
      GetAllParameters parameters) async {
    final PreferencesFilter filter = parameters.filter;
    final List<String>? allowListAsList = filter.allowList?.toList();
    return await _kChannel.invokeMapMethod<String, Object>(
          'getAllWithParameters',
          <String, dynamic>{
            'prefix': filter.prefix,
            'allowList': allowListAsList
          },
        ) ??
        <String, Object>{};
  }
}
