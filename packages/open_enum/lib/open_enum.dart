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
extension type const OpenEnum<V extends Object>(V value) {}

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
