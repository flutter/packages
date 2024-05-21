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
  /// You don't need to call this constructor directly. Use [SharedPreferencesStateNotifierProvider] instead.
  SharedPreferencesStateNotifier(this._eval) : super(const _State.loading());

  final SharedPreferencesToolEval _eval;

  List<String> _keys = <String>[];

  /// Retrieves all keys from the shared preferences of the target debug session.
  /// If this is called when data already exists, it will update the list of keys.
  Future<void> fetchAllKeys() async {
    value = const _State.loading();
    try {
      _keys = await _eval.fetchAllKeys();
      value = _State.data(SharedPreferencesState(
        allKeys: _keys,
        selectedKey: null,
      ));
    } catch (error, stackTrace) {
      value = _State.error(error, stackTrace);
    }
  }

  void _setSelectedKeyValue(
    String key,
    AsyncState<SharedPreferencesData> asyncValue,
  ) {
    value = value.whenData(
      (SharedPreferencesState data) => data.copyWith(
        selectedKey: SelectedSharedPreferencesKey(
          key: key,
          value: asyncValue,
        ),
      ),
    );
  }

  /// Set the key as selected and retrieve the value from the shared preferences of the target debug session.
  Future<void> selectKey(String key) async {
    stopEditing();
    _setSelectedKeyValue(
      key,
      const AsyncState<SharedPreferencesData>.loading(),
    );

    try {
      final SharedPreferencesData keyValue = await _eval.fetchValue(key);
      _setSelectedKeyValue(
        key,
        AsyncState<SharedPreferencesData>.data(keyValue),
      );
    } catch (error, stackTrace) {
      _setSelectedKeyValue(
        key,
        AsyncState<SharedPreferencesData>.error(error, stackTrace),
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
    value = value.whenData((SharedPreferencesState data) {
      return data.copyWith(
          allKeys: _keys.where(
        (String key) {
          String currentSubstring = key.toLowerCase();
          for (final String char in lowercaseToken.characters) {
            final int currentIndex = currentSubstring.indexOf(char);
            if (currentIndex == -1) {
              return false;
            }
            currentSubstring = currentSubstring.substring(currentIndex + 1);
          }
          return true;
        },
      ).toList());
    });
  }

  /// Changes the value of the selected key in the shared preferences of the target debug session.
  Future<void> changeValue(String key, SharedPreferencesData newValue) async {
    await _eval.changeValue(key, newValue);
    await selectKey(key);
    stopEditing();
  }

  /// Deletes the selected key from the shared preferences of the target debug session.
  Future<void> deleteKey(SelectedSharedPreferencesKey selectedKey) async {
    await _eval.deleteKey(selectedKey.key);
    await fetchAllKeys();
    stopEditing();
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
