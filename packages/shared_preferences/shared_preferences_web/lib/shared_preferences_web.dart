// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert' show json;
import 'dart:js_interop';

import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:web/web.dart' as web;
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';

/// The web implementation of [SharedPreferencesStorePlatform].
///
/// This class implements the `package:shared_preferences` functionality for the web.
class SharedPreferencesPlugin extends SharedPreferencesStorePlatform {
  /// Registers this class as the default instance of [SharedPreferencesStorePlatform].
  static void registerWith(Registrar? registrar) {
    SharedPreferencesStorePlatform.instance = SharedPreferencesPlugin();
  }

  static const String _defaultPrefix = 'flutter.';

  @override
  Future<bool> clear() async {
    return clearWithPrefix(_defaultPrefix);
  }

  @override
  Future<bool> clearWithPrefix(String prefix) async {
    // IMPORTANT: Do not use html.window.localStorage.clear() as that will
    //            remove _all_ local data, not just the keys prefixed with
    //            _prefix
    for (final key in _getStoredFlutterKeys(prefix)) {
      web.window.localStorage.removeItem(key.toJS);
    }
    return true;
  }

  @override
  Future<Map<String, Object>> getAll() async {
    return getAllWithPrefix(_defaultPrefix);
  }

  @override
  Future<Map<String, Object>> getAllWithPrefix(String prefix) async {
    final Map<String, Object> allData = <String, Object>{};
    for (final String key in _getStoredFlutterKeys(prefix)) {
      String dartKey = web.window.localStorage.getItem(key.toJS)!.toDart;
      allData[key] = _decodeValue(dartKey);
    }
    return allData;
  }

  @override
  Future<bool> remove(String key) async {
    web.window.localStorage.removeItem(key.toJS);
    return true;
  }

  @override
  Future<bool> setValue(String valueType, String key, Object? value) async {
    web.window.localStorage.setItem(key.toJS, _encodeValue(value).toJS);
    return true;
  }

  Iterable<String> _getStoredFlutterKeys(String prefix) {
    List<String> keys = [];
    for (int i = 0; i < web.window.localStorage.length.toDart; i++) {
      String key = web.window.localStorage.key(i.toDouble().toJS)!.toDart;
      if (key.startsWith(prefix)) {
        keys.add(key);
      }
    }
    return keys;
  }

  String _encodeValue(Object? value) {
    return json.encode(value);
  }

  Object _decodeValue(String encodedValue) {
    final Object? decodedValue = json.decode(encodedValue);

    if (decodedValue is List) {
      // JSON does not preserve generics. The encode/decode roundtrip is
      // `List<String>` => JSON => `List<dynamic>`. We have to explicitly
      // restore the RTTI.
      return decodedValue.cast<String>();
    }

    return decodedValue!;
  }
}
