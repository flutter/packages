// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';

import 'async_state.dart';

@internal
@immutable
class SharedPreferencesState {
  const SharedPreferencesState({
    required this.allKeys,
    required this.selectedKey,
    this.editing = false,
  });

  final List<String> allKeys;
  final SelectedSharedPreferencesKey? selectedKey;
  final bool editing;

  SharedPreferencesState copyWith({
    List<String>? allKeys,
    SelectedSharedPreferencesKey? selectedKey,
    bool? editing,
  }) {
    return SharedPreferencesState(
      allKeys: allKeys ?? this.allKeys,
      selectedKey: selectedKey ?? this.selectedKey,
      editing: editing ?? this.editing,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is SharedPreferencesState &&
            listEquals(other.allKeys, allKeys) &&
            other.selectedKey == selectedKey &&
            other.editing == editing);
  }

  @override
  int get hashCode =>
      allKeys.hashCode ^ selectedKey.hashCode ^ editing.hashCode;

  @override
  String toString() {
    return 'SharedPreferencesState(allKeys: $allKeys, selectedKey: $selectedKey, editing: $editing)';
  }
}

@internal
@immutable
class SelectedSharedPreferencesKey {
  const SelectedSharedPreferencesKey({
    required this.key,
    required this.value,
  });

  final String key;

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

@internal
@immutable
sealed class SharedPreferencesData {
  const SharedPreferencesData();

  const factory SharedPreferencesData.string({
    required String value,
  }) = SharedPreferencesDataString;

  const factory SharedPreferencesData.int({
    required int value,
  }) = SharedPreferencesDataInt;

  const factory SharedPreferencesData.double({
    required double value,
  }) = SharedPreferencesDataDouble;

  const factory SharedPreferencesData.bool({
    required bool value,
  }) = SharedPreferencesDataBool;

  const factory SharedPreferencesData.stringList({
    required List<String> value,
  }) = SharedPreferencesDataStringList;

  String get valueAsString {
    return switch (this) {
      final SharedPreferencesDataString data => data.value,
      final SharedPreferencesDataInt data => data.value.toString(),
      final SharedPreferencesDataDouble data => data.value.toString(),
      final SharedPreferencesDataBool data => data.value.toString(),
      final SharedPreferencesDataStringList data => '\n${<String>[
          for (final (int index, String str) in data.value.indexed)
            '$index -> $str',
        ].join('\n')}'
    };
  }

  String get prettyType {
    return switch (this) {
      SharedPreferencesDataString() => 'String',
      SharedPreferencesDataInt() => 'int',
      SharedPreferencesDataDouble() => 'double',
      SharedPreferencesDataBool() => 'bool',
      SharedPreferencesDataStringList() => 'List<String>',
    };
  }

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
              final SharedPreferencesDataString data =>
                other is SharedPreferencesDataString &&
                    other.value == data.value,
              final SharedPreferencesDataInt data =>
                other is SharedPreferencesDataInt && other.value == data.value,
              final SharedPreferencesDataDouble data =>
                other is SharedPreferencesDataDouble &&
                    other.value == data.value,
              final SharedPreferencesDataBool data =>
                other is SharedPreferencesDataBool && other.value == data.value,
              final SharedPreferencesDataStringList data =>
                other is SharedPreferencesDataStringList &&
                    listEquals(other.value, data.value),
            });
  }

  @override
  int get hashCode => switch (this) {
        final SharedPreferencesDataString data => data.value.hashCode,
        final SharedPreferencesDataInt data => data.value.hashCode,
        final SharedPreferencesDataDouble data => data.value.hashCode,
        final SharedPreferencesDataBool data => data.value.hashCode,
        final SharedPreferencesDataStringList data => data.value.hashCode,
      };

  @override
  String toString() {
    return 'SharedPreferencesData($valueAsString)';
  }
}

@internal
class SharedPreferencesDataString extends SharedPreferencesData {
  const SharedPreferencesDataString({
    required this.value,
  });

  final String value;
}

@internal
class SharedPreferencesDataInt extends SharedPreferencesData {
  const SharedPreferencesDataInt({
    required this.value,
  });

  final int value;
}

@internal
class SharedPreferencesDataDouble extends SharedPreferencesData {
  const SharedPreferencesDataDouble({
    required this.value,
  });

  final double value;
}

@internal
class SharedPreferencesDataBool extends SharedPreferencesData {
  const SharedPreferencesDataBool({
    required this.value,
  });

  final bool value;
}

@internal
class SharedPreferencesDataStringList extends SharedPreferencesData {
  const SharedPreferencesDataStringList({
    required this.value,
  });

  final List<String> value;
}
