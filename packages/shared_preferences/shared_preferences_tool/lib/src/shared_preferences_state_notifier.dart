// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:devtools_app_shared/utils.dart';
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

  bool get _legacyApi => value.dataOrNull?.legacyApi ?? false;

  List<String> get _keysForSelectedApi => _legacyApi ? _legacyKeys : _asyncKeys;

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
        allKeys: _keysForSelectedApi,
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
      final SharedPreferencesData keyValue =
          await _eval.fetchValue(key, _legacyApi);
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
  /// This function uses [caseInsensitiveFuzzyMatch] to filter the keys.
  void filter(String token) {
    value = value.whenData((SharedPreferencesState data) {
      return data.copyWith(
        allKeys: _keysForSelectedApi.where((String key) {
          return key.caseInsensitiveFuzzyMatch(token);
        }).toList(),
      );
    });
  }

  /// Changes the value of the selected key in the shared preferences of the target debug session.
  Future<void> changeValue(
    SharedPreferencesData newValue,
  ) async {
    if (value.dataOrNull?.selectedKey
        case final SelectedSharedPreferencesKey selectedKey) {
      await _eval.changeValue(selectedKey.key, newValue, _legacyApi);
      await selectKey(selectedKey.key);
      stopEditing();
    }
  }

  /// Deletes the selected key from the shared preferences of the target debug session.
  Future<void> deleteSelectedKey() async {
    if (value.dataOrNull?.selectedKey
        case final SelectedSharedPreferencesKey selectedKey) {
      await _eval.deleteKey(selectedKey.key, _legacyApi);
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

  /// Change the API used to fetch the shared preferences of the target debug session.
  void selectApi({required bool legacyApi}) {
    value = value.whenData((SharedPreferencesState data) {
      return SharedPreferencesState(
        legacyApi: legacyApi,
        allKeys: legacyApi ? _legacyKeys : _asyncKeys,
      );
    });
  }
}
