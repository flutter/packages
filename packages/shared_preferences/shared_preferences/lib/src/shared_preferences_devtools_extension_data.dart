// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

import '../shared_preferences.dart';

const String _eventPrefix = 'shared_preferences.';

/// A typedef for the post event function.
@visibleForTesting
typedef PostEvent = void Function(
  String eventKind,
  Map<String, Object?> eventData,
);

/// A helper class that provides data to the DevTools extension.
///
/// It is only visible for testing and eval.
@visibleForTesting
class SharedPreferencesDevToolsExtensionData {
  /// The default constructor for [SharedPreferencesDevToolsExtensionData].
  ///
  /// Accepts an optional [PostEvent] that should only be overwritten when testing.
  const SharedPreferencesDevToolsExtensionData([
    this._postEvent = developer.postEvent,
  ]);

  final PostEvent _postEvent;

  /// Requests all legacy and async keys and post an event with the result.
  Future<void> requestAllKeys() async {
    final SharedPreferences legacyPrefs = await SharedPreferences.getInstance();
    final Set<String> legacyKeys = legacyPrefs.getKeys();
    final Set<String> asyncKeys = await SharedPreferencesAsync().getKeys();

    _postEvent('${_eventPrefix}all_keys', <String, List<String>>{
      'asyncKeys': asyncKeys.toList(),
      'legacyKeys': legacyKeys.toList(),
    });
  }

  /// Requests the value for a given key and posts an event with the result.
  Future<void> requestValue(String key, bool legacy) async {
    final Object? value;
    if (legacy) {
      final SharedPreferences legacyPrefs =
          await SharedPreferences.getInstance();
      value = legacyPrefs.get(key);
    } else {
      value = await SharedPreferencesAsync().getAll(allowList: <String>{
        key
      }).then((Map<String, Object?> map) => map.values.firstOrNull);
    }

    _postEvent('${_eventPrefix}value', <String, Object?>{
      'value': value,
      // It is safe to use `runtimeType` here. This code
      // will only ever run in debug mode.
      'kind': value.runtimeType.toString(),
    });
  }

  /// Requests the value change for the given key and posts an empty event when finished.
  Future<void> requestValueChange(
    String key,
    String serializedValue,
    String kind,
    bool legacy,
  ) async {
    final Object? value = jsonDecode(serializedValue);
    if (legacy) {
      final SharedPreferences legacyPrefs =
          await SharedPreferences.getInstance();
      // we need to check the kind because sometimes a double
      // gets interpreted as an int. If this was not an issue
      // we'd only need to do a simple pattern matching on value.
      switch (kind) {
        case 'int':
          await legacyPrefs.setInt(key, value! as int);
        case 'bool':
          await legacyPrefs.setBool(key, value! as bool);
        case 'double':
          await legacyPrefs.setDouble(key, value! as double);
        case 'String':
          await legacyPrefs.setString(key, value! as String);
        case 'List<String>':
          await legacyPrefs.setStringList(
            key,
            (value! as List<Object?>).cast(),
          );
      }
    } else {
      final SharedPreferencesAsync prefs = SharedPreferencesAsync();
      // we need to check the kind because sometimes a double
      // gets interpreted as an int. If this was not an issue
      // we'd only need to do a simple pattern matching on value.
      switch (kind) {
        case 'int':
          await prefs.setInt(key, value! as int);
        case 'bool':
          await prefs.setBool(key, value! as bool);
        case 'double':
          await prefs.setDouble(key, value! as double);
        case 'String':
          await prefs.setString(key, value! as String);
        case 'List<String>':
          await prefs.setStringList(
            key,
            (value! as List<Object?>).cast(),
          );
      }
    }
    _postEvent('${_eventPrefix}change_value', <String, Object?>{});
  }

  /// Requests a key removal and posts an empty event when removed.
  Future<void> requestRemoveKey(String key, bool legacy) async {
    if (legacy) {
      final SharedPreferences legacyPrefs =
          await SharedPreferences.getInstance();
      await legacyPrefs.remove(key);
    } else {
      await SharedPreferencesAsync().remove(key);
    }
    _postEvent('${_eventPrefix}remove', <String, Object?>{});
  }
}

/// Include a variable to keep the library alive in web builds.
/// It must be a `final` variable.
/// Check this discussion for more info: https://github.com/flutter/packages/pull/6749/files/6eb1b4fdce1eba107294770d581713658ff971e9#discussion_r1755375409
// ignore: prefer_const_declarations
final bool fieldToKeepDevtoolsExtensionLibraryAlive = false;
