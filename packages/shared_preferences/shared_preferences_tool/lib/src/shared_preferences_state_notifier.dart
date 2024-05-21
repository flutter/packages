// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import 'async_state.dart';
import 'shared_preferences_state.dart';
import 'shared_preferences_tool_eval.dart';

typedef _State = AsyncState<SharedPreferencesState>;

@internal
class SharedPreferencesStateNotifier extends ValueNotifier<_State> {
  SharedPreferencesStateNotifier(this._eval) : super(const _State.loading());

  final SharedPreferencesToolEval _eval;

  List<String> _keys = <String>[];

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

  // poor man's fuzzy search algorithm
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

  Future<void> changeValue(String key, SharedPreferencesData newValue) async {
    await _eval.changeValue(key, newValue);
    await selectKey(key);
    stopEditing();
  }

  Future<void> deleteKey(SelectedSharedPreferencesKey selectedKey) async {
    await _eval.deleteKey(selectedKey.key);
    await fetchAllKeys();
    stopEditing();
  }

  void startEditing() {
    value = value.whenData((SharedPreferencesState data) {
      return data.copyWith(editing: true);
    });
  }

  void stopEditing() {
    value = value.whenData((SharedPreferencesState data) {
      return data.copyWith(editing: false);
    });
  }
}
