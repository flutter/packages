// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert' show json;

import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';
import 'package:shared_preferences_platform_interface/types.dart';
import 'package:web/web.dart' as html;

import 'src/keys_extension.dart';

/// The web implementation of [SharedPreferencesStorePlatform].
///
/// This class implements the `package:shared_preferences` functionality for the web.
class SharedPreferencesPlugin extends SharedPreferencesStorePlatform {
  /// Registers this class as the default instance of [SharedPreferencesStorePlatform].
  static void registerWith(Registrar? registrar) {
    SharedPreferencesStorePlatform.instance = SharedPreferencesPlugin();
    SharedPreferencesAsyncWeb.registerWith(registrar);
  }

  static const String _defaultPrefix = 'flutter.';

  @override
  Future<bool> clear() async {
    return clearWithParameters(
      ClearParameters(
        filter: PreferencesFilter(prefix: _defaultPrefix),
      ),
    );
  }

  @override
  Future<bool> clearWithPrefix(String prefix) async {
    return clearWithParameters(
        ClearParameters(filter: PreferencesFilter(prefix: prefix)));
  }

  @override
  Future<bool> clearWithParameters(ClearParameters parameters) async {
    final PreferencesFilter filter = parameters.filter;
    // IMPORTANT: Do not use html.window.localStorage.clear() as that will
    //            remove _all_ local data, not just the keys prefixed with
    //            _prefix
    _getPrefixedKeys(filter.prefix, allowList: filter.allowList)
        .forEach(remove);
    return true;
  }

  @override
  Future<Map<String, Object>> getAll() async {
    return getAllWithParameters(
      GetAllParameters(
        filter: PreferencesFilter(prefix: _defaultPrefix),
      ),
    );
  }

  @override
  Future<Map<String, Object>> getAllWithPrefix(String prefix) async {
    return getAllWithParameters(
        GetAllParameters(filter: PreferencesFilter(prefix: prefix)));
  }

  @override
  Future<Map<String, Object>> getAllWithParameters(
      GetAllParameters parameters) async {
    final PreferencesFilter filter = parameters.filter;
    final Map<String, Object> allData = <String, Object>{};
    for (final String key
        in _getPrefixedKeys(filter.prefix, allowList: filter.allowList)) {
      final Object? value =
          _decodeValue(html.window.localStorage.getItem(key)!);
      if (value != null) {
        allData[key] = value;
      }
    }
    return allData;
  }

  @override
  Future<bool> remove(String key) async {
    html.window.localStorage.removeItem(key);
    return true;
  }

  @override
  Future<bool> setValue(String valueType, String key, Object? value) async {
    html.window.localStorage.setItem(key, _encodeValue(value));
    return true;
  }

  Iterable<String> _getPrefixedKeys(
    String prefix, {
    Set<String>? allowList,
  }) {
    return _getAllowedKeys(allowList: allowList)
        .where((String key) => key.startsWith(prefix));
  }
}

/// The web implementation of [SharedPreferencesAsyncPlatform].
///
/// This class implements the `package:shared_preferences` functionality for the web.
base class SharedPreferencesAsyncWeb extends SharedPreferencesAsyncPlatform {
  /// Registers this class as the default instance of [SharedPreferencesAsyncPlatform].
  static void registerWith(Registrar? registrar) {
    SharedPreferencesAsyncPlatform.instance = SharedPreferencesAsyncWeb();
  }

  @override
  Future<void> clear(
    ClearPreferencesParameters parameters,
    SharedPreferencesOptions options,
  ) async {
    final PreferencesFilters filter = parameters.filter;
    _getAllowedKeys(allowList: filter.allowList)
        .forEach((String key) => html.window.localStorage.removeItem(key));
  }

  @override
  Future<Map<String, Object>> getPreferences(
    GetPreferencesParameters parameters,
    SharedPreferencesOptions options,
  ) async {
    return _readAllFromLocalStorage(parameters.filter.allowList, options);
  }

  Future<Map<String, Object>> _readAllFromLocalStorage(
    Set<String>? allowList,
    SharedPreferencesOptions options,
  ) async {
    final Map<String, Object> allData = <String, Object>{};
    for (final String key in _getAllowedKeys(allowList: allowList)) {
      final Object? value =
          _decodeValue(html.window.localStorage.getItem(key)!);
      if (value != null) {
        allData[key] = value;
      }
    }
    return allData;
  }

  @override
  Future<Set<String>> getKeys(GetPreferencesParameters parameters,
      SharedPreferencesOptions options) async {
    return (await getPreferences(parameters, options)).keys.toSet();
  }

  @override
  Future<void> setString(
    String key,
    String value,
    SharedPreferencesOptions options,
  ) {
    return _setValue(key, value, options);
  }

  @override
  Future<void> setBool(
    String key,
    bool value,
    SharedPreferencesOptions options,
  ) {
    return _setValue(key, value, options);
  }

  @override
  Future<void> setDouble(
    String key,
    double value,
    SharedPreferencesOptions options,
  ) {
    return _setValue(key, value, options);
  }

  @override
  Future<void> setInt(
    String key,
    int value,
    SharedPreferencesOptions options,
  ) {
    return _setValue(key, value, options);
  }

  @override
  Future<void> setStringList(
    String key,
    List<String> value,
    SharedPreferencesOptions options,
  ) {
    return _setValue(key, value, options);
  }

  Future<void> _setValue(
    String key,
    Object? value,
    SharedPreferencesOptions options,
  ) async {
    html.window.localStorage.setItem(key, _encodeValue(value));
  }

  @override
  Future<String?> getString(
    String key,
    SharedPreferencesOptions options,
  ) async {
    final Map<String, Object> data =
        await _readAllFromLocalStorage(<String>{key}, options);
    return data[key] as String?;
  }

  @override
  Future<bool?> getBool(
    String key,
    SharedPreferencesOptions options,
  ) async {
    final Map<String, Object> data =
        await _readAllFromLocalStorage(<String>{key}, options);
    return data[key] as bool?;
  }

  @override
  Future<double?> getDouble(
    String key,
    SharedPreferencesOptions options,
  ) async {
    final Map<String, Object> data =
        await _readAllFromLocalStorage(<String>{key}, options);
    return data[key] as double?;
  }

  @override
  Future<int?> getInt(
    String key,
    SharedPreferencesOptions options,
  ) async {
    final Map<String, Object> data =
        await _readAllFromLocalStorage(<String>{key}, options);
    return data[key] as int?;
  }

  @override
  Future<List<String>?> getStringList(
    String key,
    SharedPreferencesOptions options,
  ) async {
    final Map<String, Object> data =
        await _readAllFromLocalStorage(<String>{key}, options);
    return (data[key] as List<String>?)?.toList();
  }
}

Iterable<String> _getAllowedKeys({
  Set<String>? allowList,
}) {
  return html.window.localStorage.keys
      .where((String key) => allowList?.contains(key) ?? true);
}

String _encodeValue(Object? value) {
  return json.encode(value);
}

Object? _decodeValue(String encodedValue) {
  final Object? decodedValue;
  try {
    decodedValue = json.decode(encodedValue);
  } on FormatException catch (_) {
    return null;
  }

  if (decodedValue is List) {
    // JSON does not preserve generics. The encode/decode roundtrip is
    // `List<String>` => JSON => `List<dynamic>`. We have to explicitly
    // restore the RTTI.
    return decodedValue.cast<String>();
  }

  return decodedValue;
}

/// Web specific SharedPreferences Options.
class SharedPreferencesWebOptions extends SharedPreferencesOptions {
  /// Constructor for SharedPreferencesWebOptions.
  const SharedPreferencesWebOptions();
}
