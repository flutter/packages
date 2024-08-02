// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

import 'async_state.dart';
import 'shared_preferences_state.dart';
import 'shared_preferences_tool_eval.dart';

typedef _State = AsyncState<SharedPreferencesState>;

/// A [ValueNotifier] that manages the state of the shared preferences tool.
class SharedPreferencesStateNotifier extends ValueNotifier<_State> {
  /// Default constructor that takes an instance of [SharedPreferencesToolEval].
  ///
  /// You don't need to call this constructor directly. Use [SharedPreferencesStateNotifierProvider] instead.
  SharedPreferencesStateNotifier(
    this._eval,
  ) : super(const _State.loading());

  final SharedPreferencesToolEval _eval;

  List<String> _asyncKeys = const <String>[];
  List<String> _legacyKeys = const <String>[];

  /// Retrieves all keys from the shared preferences of the target debug session.
  ///
  /// If this is called when data already exists, it will update the list of keys.
  Future<void> fetchAllKeys() async {
    value = const _State.loading();
    try {
      final KeysResult allKeys = await _eval.fetchAllKeys();
      _legacyKeys = allKeys.legacyKeys;
      // Platforms other than Android also add the legacy keys to the async keys
      // in the pattern `flutter.$key`, so we need to remove them to avoid duplicates.
      const String legacyPrefix = 'flutter.';
      _asyncKeys = <String>[
        for (final String key in allKeys.asyncKeys)
          if (!(key.startsWith(legacyPrefix) &&
              _legacyKeys.contains(key.replaceAll(legacyPrefix, ''))))
            key,
      ];
      value = _State.data(SharedPreferencesState(
        asyncKeys: _asyncKeys,
        legacyKeys: _legacyKeys,
      ));
    } catch (error, stackTrace) {
      value = _State.error(error, stackTrace);
    }
  }

  void _setSelectedKeyValue(
    String key,
    AsyncState<SharedPreferencesData> asyncValue,
    bool legacy,
  ) {
    value = value.whenData(
      (SharedPreferencesState data) => data.copyWith(
        selectedKey: SelectedSharedPreferencesKey(
          key: key,
          value: asyncValue,
          legacy: legacy,
        ),
      ),
    );
  }

  /// Set the key as selected and retrieve the value from the shared preferences of the target debug session.
  Future<void> selectKey(String key, bool legacy) async {
    stopEditing();
    _setSelectedKeyValue(
      key,
      const AsyncState<SharedPreferencesData>.loading(),
      legacy,
    );

    try {
      final SharedPreferencesData keyValue =
          await _eval.fetchValue(key, legacy);
      _setSelectedKeyValue(
        key,
        AsyncState<SharedPreferencesData>.data(keyValue),
        legacy,
      );
    } catch (error, stackTrace) {
      _setSelectedKeyValue(
        key,
        AsyncState<SharedPreferencesData>.error(error, stackTrace),
        legacy,
      );
    }
  }

  /// Filters the keys based on the provided token.
  ///
  /// The function converts the token and each key to lowercase to ensure case-insensitive matching.
  /// It then iterates over each character in the token and checks if it exists in the key.
  /// The search for the next character starts from the position after the current character was found.
  /// This ensures that the characters in the token appear in the same order in the key.
  /// If a character from the token is not found in the key, the key is excluded from the result.
  /// If all characters from the token are found in the key, the key is included in the result.
  void filter(String token) {
    final String lowercaseToken = token.toLowerCase();

    bool filter(String key) {
      String currentSubstring = key.toLowerCase();
      for (final String char in lowercaseToken.characters) {
        final int currentIndex = currentSubstring.indexOf(char);
        if (currentIndex == -1) {
          return false;
        }
        currentSubstring = currentSubstring.substring(currentIndex + 1);
      }
      return true;
    }

    value = value.whenData((SharedPreferencesState data) {
      return data.copyWith(
        asyncKeys: _asyncKeys.where(filter).toList(),
        legacyKeys: _legacyKeys.where(filter).toList(),
      );
    });
  }

  /// Changes the value of the selected key in the shared preferences of the target debug session.
  Future<void> changeValue(
    SharedPreferencesData newValue,
  ) async {
    if (value.dataOrNull?.selectedKey
        case final SelectedSharedPreferencesKey selectedKey) {
      await _eval.changeValue(selectedKey.key, newValue, selectedKey.legacy);
      await selectKey(selectedKey.key, selectedKey.legacy);
      stopEditing();
    }
  }

  /// Deletes the selected key from the shared preferences of the target debug session.
  Future<void> deleteSelectedKey() async {
    if (value.dataOrNull?.selectedKey
        case final SelectedSharedPreferencesKey selectedKey) {
      await _eval.deleteKey(selectedKey.key, selectedKey.legacy);
      await fetchAllKeys();
      stopEditing();
    }
  }

  /// Change the editing state to true, allowing the user to edit the value of the selected key.
  void startEditing() {
    value = value.whenData((SharedPreferencesState data) {
      return data.copyWith(editing: true);
    });
  }

  /// Change the editing state to false, preventing the user from editing the value of the selected key.
  void stopEditing() {
    value = value.whenData((SharedPreferencesState data) {
      return data.copyWith(editing: false);
    });
  }
}
