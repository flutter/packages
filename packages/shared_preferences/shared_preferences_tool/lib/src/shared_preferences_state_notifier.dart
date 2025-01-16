// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:devtools_app_shared/utils.dart';
import 'package:flutter/material.dart';

import 'async_state.dart';
import 'shared_preferences_state.dart';
import 'shared_preferences_tool_eval.dart';

/// A [ValueNotifier] that manages the state of the shared preferences tool.
class SharedPreferencesStateNotifier
    extends ValueNotifier<SharedPreferencesState> {
  /// Default constructor that takes an instance of [SharedPreferencesToolEval].
  ///
  /// You don't need to call this constructor directly. Use [SharedPreferencesStateNotifierProvider] instead.
  SharedPreferencesStateNotifier(
    this._eval,
  ) : super(const SharedPreferencesState());

  final SharedPreferencesToolEval _eval;

  List<String> _asyncKeys = const <String>[];
  List<String> _legacyKeys = const <String>[];

  bool get _legacyApi => value.legacyApi;

  List<String> get _keysForSelectedApi => _legacyApi ? _legacyKeys : _asyncKeys;

  /// Retrieves all keys from the shared preferences of the target debug session.
  ///
  /// If this is called when data already exists, it will update the list of keys.
  Future<void> fetchAllKeys() async {
    value = value.copyWith(
      selectedKey: null,
      allKeys: const AsyncState<List<String>>.loading(),
    );

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

      value = value.copyWith(
        allKeys: AsyncState<List<String>>.data(_keysForSelectedApi),
      );
    } catch (error, stackTrace) {
      value = value.copyWith(
        allKeys: AsyncState<List<String>>.error(error, stackTrace),
      );
    }
  }

  /// Set the key as selected and retrieve the value from the shared preferences of the target debug session.
  Future<void> selectKey(String key) async {
    stopEditing();

    value = value.copyWith(
      selectedKey: SelectedSharedPreferencesKey(
        key: key,
        value: const AsyncState<SharedPreferencesData>.loading(),
      ),
    );

    try {
      final SharedPreferencesData keyValue =
          await _eval.fetchValue(key, _legacyApi);
      value = value.copyWith(
        selectedKey: SelectedSharedPreferencesKey(
          key: key,
          value: AsyncState<SharedPreferencesData>.data(keyValue),
        ),
      );
    } catch (error, stackTrace) {
      value = value.copyWith(
        selectedKey: SelectedSharedPreferencesKey(
          key: key,
          value: AsyncState<SharedPreferencesData>.error(
            error,
            stackTrace,
          ),
        ),
      );
    }
  }

  /// Filters the keys based on the provided token.
  ///
  /// This function uses [caseInsensitiveFuzzyMatch] to filter the keys.
  void filter(String token) {
    value = value.copyWith(
      allKeys: AsyncState<List<String>>.data(
        _keysForSelectedApi.where((String key) {
          return key.caseInsensitiveFuzzyMatch(token);
        }).toList(),
      ),
    );
  }

  /// Changes the value of the selected key in the shared preferences of the target debug session.
  Future<void> changeValue(
    SharedPreferencesData newValue,
  ) async {
    if (value.selectedKey case final SelectedSharedPreferencesKey selectedKey) {
      value = value.copyWith(
        selectedKey: SelectedSharedPreferencesKey(
          key: selectedKey.key,
          value: const AsyncState<SharedPreferencesData>.loading(),
        ),
      );
      await _eval.changeValue(selectedKey.key, newValue, _legacyApi);
      await selectKey(selectedKey.key);
      stopEditing();
    }
  }

  /// Deletes the selected key from the shared preferences of the target debug session.
  Future<void> deleteSelectedKey() async {
    if (value.selectedKey case final SelectedSharedPreferencesKey selectedKey) {
      value = value.copyWith(
        allKeys: const AsyncState<List<String>>.loading(),
        selectedKey: SelectedSharedPreferencesKey(
          key: selectedKey.key,
          value: const AsyncState<SharedPreferencesData>.loading(),
        ),
      );
      await _eval.deleteKey(selectedKey.key, _legacyApi);
      await fetchAllKeys();
      stopEditing();
    }
  }

  /// Change the editing state to true, allowing the user to edit the value of the selected key.
  void startEditing() {
    value = value.copyWith(editing: true);
  }

  /// Change the editing state to false, preventing the user from editing the value of the selected key.
  void stopEditing() {
    value = value.copyWith(editing: false);
  }

  /// Change the API used to fetch the shared preferences of the target debug session.
  void selectApi({required bool legacyApi}) {
    value = value.copyWith(
      legacyApi: legacyApi,
      allKeys: AsyncState<List<String>>.data(
        legacyApi ? _legacyKeys : _asyncKeys,
      ),
    );
  }
}
