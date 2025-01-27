// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'async_state.dart';

const Object _undefined = Object();

@immutable

/// A class that represents the state of the shared preferences tool.
class SharedPreferencesState {
  /// Default constructor for [SharedPreferencesState].
  const SharedPreferencesState({
    this.allKeys = const AsyncState<List<String>>.loading(),
    this.selectedKey,
    this.editing = false,
    this.legacyApi = false,
  });

  /// A list of all keys in the shared preferences of the target debug session using the selected API.
  final AsyncState<List<String>> allKeys;

  /// The user selected key and its value in the shared preferences
  /// of the target debug session.
  final SelectedSharedPreferencesKey? selectedKey;

  /// Whether the user is editing the value of the selected key or not.
  final bool editing;

  /// Whether the user has selected the legacy api or not.
  final bool legacyApi;

  /// Creates a copy of this [SharedPreferencesState] but replacing the given
  /// fields with the new values.
  SharedPreferencesState Function({
    AsyncState<List<String>> allKeys,
    SelectedSharedPreferencesKey? selectedKey,
    bool editing,
    bool legacyApi,
  }) get copyWith => ({
        Object allKeys = _undefined,
        Object? selectedKey = _undefined,
        Object editing = _undefined,
        Object legacyApi = _undefined,
      }) {
        return SharedPreferencesState(
          allKeys: allKeys == _undefined
              ? this.allKeys
              : allKeys as AsyncState<List<String>>,
          selectedKey: selectedKey == _undefined
              ? this.selectedKey
              : selectedKey as SelectedSharedPreferencesKey?,
          editing: editing == _undefined ? this.editing : editing as bool,
          legacyApi:
              legacyApi == _undefined ? this.legacyApi : legacyApi as bool,
        );
      };

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is SharedPreferencesState &&
            other.allKeys == allKeys &&
            other.selectedKey == selectedKey &&
            other.editing == editing &&
            other.legacyApi == legacyApi);
  }

  @override
  int get hashCode => Object.hash(
        allKeys,
        selectedKey,
        editing,
        legacyApi,
      );

  @override
  String toString() {
    return 'SharedPreferencesState(allKeys: $allKeys, selectedKey: $selectedKey, editing: $editing)';
  }
}

@immutable

/// A class that represents the selected key and its value in the shared
/// preferences of the target debug session.
class SelectedSharedPreferencesKey {
  /// Default constructor for [SelectedSharedPreferencesKey].
  const SelectedSharedPreferencesKey({
    required this.key,
    required this.value,
  });

  /// The user selected key.
  final String key;

  /// The value of the selected key in the shared preferences of the target
  /// debug session.
  final AsyncState<SharedPreferencesData> value;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is SelectedSharedPreferencesKey &&
            other.key == key &&
            other.value == value);
  }

  @override
  int get hashCode => key.hashCode ^ value.hashCode;

  @override
  String toString() {
    return 'SelectedSharedPreferencesKey(key: $key, value: $value)';
  }
}

abstract interface class _SharedPreferencesData<T> {
  T get value;
}

@immutable

/// A class that represents the data of a shared preference in the target
/// debug session.
sealed class SharedPreferencesData implements _SharedPreferencesData<Object> {
  const SharedPreferencesData();

  const factory SharedPreferencesData.string({
    required String value,
  }) = SharedPreferencesDataString._;

  const factory SharedPreferencesData.int({
    required int value,
  }) = SharedPreferencesDataInt._;

  const factory SharedPreferencesData.double({
    required double value,
  }) = SharedPreferencesDataDouble._;

  const factory SharedPreferencesData.bool({
    required bool value,
  }) = SharedPreferencesDataBool._;

  const factory SharedPreferencesData.stringList({
    required List<String> value,
  }) = SharedPreferencesDataStringList._;

  /// The string representation of the value.
  String get valueAsString {
    return switch (this) {
      final SharedPreferencesDataStringList data => '\n${<String>[
          for (final (int index, String str) in data.value.indexed)
            '$index -> $str',
        ].join('\n')}',
      _ => '$value',
    };
  }

  /// The kind of the value as a String.
  String get kind {
    return switch (this) {
      SharedPreferencesDataString() => 'String',
      SharedPreferencesDataInt() => 'int',
      SharedPreferencesDataDouble() => 'double',
      SharedPreferencesDataBool() => 'bool',
      SharedPreferencesDataStringList() => 'List<String>',
    };
  }

  /// Changes the value of the shared preference to the new value.
  ///
  /// This is just a in memory change and does not affect the actual shared
  /// preference value.
  SharedPreferencesData changeValue(String newValue) {
    return switch (this) {
      SharedPreferencesDataString() =>
        SharedPreferencesData.string(value: newValue),
      SharedPreferencesDataInt() =>
        SharedPreferencesData.int(value: int.parse(newValue)),
      SharedPreferencesDataDouble() =>
        SharedPreferencesData.double(value: double.parse(newValue)),
      SharedPreferencesDataBool() =>
        SharedPreferencesData.bool(value: bool.parse(newValue)),
      SharedPreferencesDataStringList() => SharedPreferencesData.stringList(
          value: (jsonDecode(newValue) as List<dynamic>).cast(),
        ),
    };
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is SharedPreferencesData &&
            switch (this) {
              final SharedPreferencesDataStringList data =>
                other is SharedPreferencesDataStringList &&
                    listEquals(other.value, data.value),
              _ => other.value == value,
            });
  }

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() {
    return 'SharedPreferencesData($valueAsString)';
  }
}

/// A class that represents a shared preference with a string value.
class SharedPreferencesDataString extends SharedPreferencesData {
  const SharedPreferencesDataString._({
    required this.value,
  });

  /// The string value of the shared preference.
  @override
  final String value;
}

/// A class that represents a shared preference with an integer value.
class SharedPreferencesDataInt extends SharedPreferencesData {
  const SharedPreferencesDataInt._({
    required this.value,
  });

  /// The integer value of the shared preference.
  @override
  final int value;
}

/// A class that represents a shared preference with a double value.
class SharedPreferencesDataDouble extends SharedPreferencesData {
  const SharedPreferencesDataDouble._({
    required this.value,
  });

  /// The double value of the shared preference.
  @override
  final double value;
}

/// A class that represents a shared preference with a boolean value.
class SharedPreferencesDataBool extends SharedPreferencesData {
  const SharedPreferencesDataBool._({
    required this.value,
  });

  /// The boolean value of the shared preference.
  @override
  final bool value;
}

/// A class that represents a shared preference with a list of string values.
class SharedPreferencesDataStringList extends SharedPreferencesData {
  const SharedPreferencesDataStringList._({
    required this.value,
  });

  /// The list of string values of the shared preference.
  @override
  final List<String> value;
}
