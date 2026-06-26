// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// A library for defining open (non-exhaustive) enums in Dart using extension
/// types, ensuring API evolution remains non-breaking.
library open_enum;

/// An interface/base for open enums.
///
/// Implement this in an extension type to denote an open enum.
///
/// Example:
/// ```dart
/// extension type const Color(String name) implements OpenEnum<String> {
///   static const red = Color('red');
///   static const blue = Color('blue');
///
///   static const values = [red, blue];
/// }
/// ```
extension type const OpenEnum<V extends Object>._(V value) {}

/// Helper extensions for collections of [OpenEnum] values.
extension OpenEnumIterableExtension<V extends Object, T extends OpenEnum<V>> on Iterable<T> {
  /// Finds the first enum value with a matching [value] representation.
  ///
  /// Returns `null` if no match is found.
  T? byValue(V value) {
    for (final element in this) {
      final OpenEnum<V> openEnum = element;
      if (openEnum.value == value) {
        return element;
      }
    }
    return null;
  }
}

/// Specialized helper extensions for collections of [OpenEnum] values
/// represented as [String]s (commonly used for string-based enums).
extension OpenEnumStringIterableExtension<T extends OpenEnum<String>> on Iterable<T> {
  /// Finds the enum value with the matching string name.
  ///
  /// Throws an [ArgumentError] if no match is found.
  T byName(String name) {
    for (final element in this) {
      final OpenEnum<String> openEnum = element;
      if (openEnum.value == name) {
        return element;
      }
    }
    throw ArgumentError.value(name, 'name', 'No OpenEnum value found with this name');
  }

  /// Finds the enum value with the matching string name.
  ///
  /// Returns `null` if no match is found.
  T? byNameOrNull(String name) {
    for (final element in this) {
      final OpenEnum<String> openEnum = element;
      if (openEnum.value == name) {
        return element;
      }
    }
    return null;
  }
}

/// An interface/base for open enums that require both an index and a name representation.
///
/// Implement this in an extension type wrapping a named record `({int index, String name})`.
///
/// Example:
/// ```dart
/// extension type const Color(({int index, String name}) data) implements OpenEnumRecord {
///   static const Color red = Color((index: 0, name: 'red'));
///   static const Color blue = Color((index: 1, name: 'blue'));
///
///   static const values = [red, blue];
/// }
/// ```
extension type const OpenEnumRecord._(({int index, String name}) data)
    implements OpenEnum<({int index, String name})> {
  /// The integer index representation of the enum value.
  int get index => value.index;

  /// The string name representation of the enum value.
  String get name => value.name;

  /// Converts the record representation to a JSON-compatible map.
  Map<String, dynamic> toJson() => <String, dynamic>{'index': index, 'name': name};
}

/// Helper extensions for collections of [OpenEnumRecord] values.
extension OpenEnumRecordIterableExtension<T extends OpenEnumRecord> on Iterable<T> {
  /// Finds the enum value with the matching string name.
  ///
  /// Throws an [ArgumentError] if no match is found.
  T byName(String name) {
    for (final element in this) {
      final OpenEnumRecord openEnum = element;
      if (openEnum.name == name) {
        return element;
      }
    }
    throw ArgumentError.value(name, 'name', 'No OpenEnumRecord value found with this name');
  }

  /// Finds the enum value with the matching string name.
  ///
  /// Returns `null` if no match is found.
  T? byNameOrNull(String name) {
    for (final element in this) {
      final OpenEnumRecord openEnum = element;
      if (openEnum.name == name) {
        return element;
      }
    }
    return null;
  }

  /// Finds the enum value with the matching integer index.
  ///
  /// Returns `null` if no match is found.
  T? byIndex(int index) {
    for (final element in this) {
      final OpenEnumRecord openEnum = element;
      if (openEnum.index == index) {
        return element;
      }
    }
    return null;
  }
}
